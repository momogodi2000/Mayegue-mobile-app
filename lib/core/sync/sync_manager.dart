import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../network/network_info.dart';
import '../../features/dictionary/data/datasources/lexicon_local_datasource.dart';
import '../../features/dictionary/data/datasources/lexicon_remote_datasource.dart';
import '../../features/dictionary/data/models/dictionary_entry_model.dart';
import '../../features/dictionary/domain/entities/dictionary_entry_entity.dart';

/// Manager for handling offline-first sync with conflict resolution
class SyncManager {
  final LexiconLocalDataSource localDataSource;
  final LexiconRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  SyncManager({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetryAttempts = 3;
  static const Duration _backoffMultiplier = Duration(seconds: 2);

  Timer? _syncTimer;
  bool _isSyncing = false;
  final _syncController = StreamController<SyncStatus>.broadcast();

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncController.stream;

  /// Start automatic sync
  void startAutoSync() {
    stopAutoSync();
    _syncTimer = Timer.periodic(_syncInterval, (_) => sync());
  }

  /// Stop automatic sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manually trigger sync
  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return SyncResult.inProgress();
    }

    _isSyncing = true;
    _syncController.add(SyncStatus.syncing);

    try {
      if (!await networkInfo.isConnected) {
        _syncController.add(SyncStatus.offline);
        return SyncResult.offline();
      }

      final result = await _performSync();

      if (result.isSuccess) {
        _syncController.add(SyncStatus.completed);
      } else {
        _syncController.add(SyncStatus.error(result.errorMessage ?? 'Unknown sync error'));
      }

      return result;
    } catch (e) {
      _syncController.add(SyncStatus.error(e.toString()));
      return SyncResult.error(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform the actual sync operation
  Future<SyncResult> _performSync() async {
    try {
      int uploadedCount = 0;
      int downloadedCount = 0;
      int conflictsDetected = 0;
      int conflictsResolved = 0;

      // 1. Upload pending local changes
      final pendingEntries = await localDataSource.getPendingSyncEntries();

      for (final entry in pendingEntries) {
        try {
          await _uploadEntry(entry);
          await localDataSource.markAsSynced(entry.id);
          uploadedCount++;
        } catch (e) {
          // Check if it's a conflict
          if (e.toString().contains('conflict') || e.toString().contains('version')) {
            await _handleUploadConflict(entry);
            conflictsDetected++;
          } else {
            // Log error but continue with other entries
            debugPrint('Failed to upload entry ${entry.id}: $e');
          }
        }
      }

      // 2. Download remote changes
      final lastSyncTime = await _getLastSyncTime();
      final remoteChanges = await remoteDataSource.getEntriesModifiedSince(lastSyncTime);

      for (final remoteEntry in remoteChanges) {
        try {
          final localEntry = await localDataSource.getEntry(remoteEntry.id);

          if (localEntry == null) {
            // New entry from remote
            await localDataSource.insertEntry(remoteEntry);
            downloadedCount++;
          } else {
            // Check for conflicts
            final conflictResult = await _detectConflict(localEntry, remoteEntry);

            if (conflictResult.hasConflict) {
              await _handleDownloadConflict(localEntry, remoteEntry, conflictResult);
              conflictsDetected++;
            } else {
              // No conflict, update local entry
              await localDataSource.updateEntry(remoteEntry);
              downloadedCount++;
            }
          }
        } catch (e) {
          debugPrint('Failed to process remote entry ${remoteEntry.id}: $e');
        }
      }

      // 3. Attempt to auto-resolve conflicts
      final conflictEntries = await localDataSource.getConflictEntries();
      for (final conflictEntry in conflictEntries) {
        final autoResolved = await _attemptAutoResolveConflict(conflictEntry);
        if (autoResolved) {
          conflictsResolved++;
        }
      }

      // 4. Update last sync time
      await _updateLastSyncTime();

      return SyncResult.success(
        uploadedCount: uploadedCount,
        downloadedCount: downloadedCount,
        conflictsDetected: conflictsDetected,
        conflictsResolved: conflictsResolved,
      );

    } catch (e) {
      return SyncResult.error(e.toString());
    }
  }

  /// Upload a local entry to remote
  Future<void> _uploadEntry(DictionaryEntryModel entry) async {
    // Implement retry logic with exponential backoff
    int retryCount = 0;
    Duration delay = _backoffMultiplier;

    while (retryCount < _maxRetryAttempts) {
      try {
        if (entry.metadata['isDeleted'] == true) {
          await remoteDataSource.deleteEntry(entry.id);
        } else {
          await remoteDataSource.updateEntry(entry);
        }
        return; // Success
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetryAttempts) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  /// Handle upload conflict
  Future<void> _handleUploadConflict(DictionaryEntryModel localEntry) async {
    try {
      // Get the current remote version
      final remoteEntry = await remoteDataSource.getDictionaryEntry(localEntry.id);

      final conflictData = {
        'type': 'upload_conflict',
        'localVersion': localEntry.toFirestore(),
        'remoteVersion': remoteEntry.toFirestore(),
        'detectedAt': DateTime.now().toIso8601String(),
      };

      await localDataSource.markAsConflict(localEntry.id, conflictData);
    } catch (e) {
      debugPrint('Failed to handle upload conflict for ${localEntry.id}: $e');
    }
  }

  /// Handle download conflict
  Future<void> _handleDownloadConflict(
    DictionaryEntryModel localEntry,
    DictionaryEntryModel remoteEntry,
    ConflictDetectionResult conflictResult,
  ) async {
    final conflictData = {
      'type': 'download_conflict',
      'localVersion': localEntry.toFirestore(),
      'remoteVersion': remoteEntry.toFirestore(),
      'conflictFields': conflictResult.conflictFields,
      'detectedAt': DateTime.now().toIso8601String(),
    };

    await localDataSource.markAsConflict(localEntry.id, conflictData);
  }

  /// Detect conflicts between local and remote entries
  Future<ConflictDetectionResult> _detectConflict(
    DictionaryEntryModel localEntry,
    DictionaryEntryModel remoteEntry,
  ) async {
    final conflictFields = <String>[];

    // Check if both versions were modified since last sync
    if (localEntry.metadata['needs_sync'] == true &&
        remoteEntry.lastUpdated.isAfter(localEntry.lastUpdated)) {

      // Check specific fields for conflicts
      if (localEntry.canonicalForm != remoteEntry.canonicalForm) {
        conflictFields.add('canonicalForm');
      }

      if (localEntry.ipa != remoteEntry.ipa) {
        conflictFields.add('ipa');
      }

      if (!_mapsEqual(localEntry.translations, remoteEntry.translations)) {
        conflictFields.add('translations');
      }

      if (localEntry.partOfSpeech != remoteEntry.partOfSpeech) {
        conflictFields.add('partOfSpeech');
      }

      if (!_listsEqual(localEntry.tags, remoteEntry.tags)) {
        conflictFields.add('tags');
      }

      if (localEntry.reviewStatus != remoteEntry.reviewStatus) {
        conflictFields.add('reviewStatus');
      }
    }

    return ConflictDetectionResult(
      hasConflict: conflictFields.isNotEmpty,
      conflictFields: conflictFields,
    );
  }

  /// Attempt to automatically resolve conflicts
  Future<bool> _attemptAutoResolveConflict(DictionaryEntryModel conflictEntry) async {
    try {
      final conflictData = jsonDecode(conflictEntry.metadata['conflict_data'] ?? '{}');
      final localVersion = DictionaryEntryModel.fromFirestore(conflictData['localVersion']);
      final remoteVersion = DictionaryEntryModel.fromFirestore(conflictData['remoteVersion']);
      final conflictFields = List<String>.from(conflictData['conflictFields'] ?? []);

      // Auto-resolution strategies
      DictionaryEntryModel? resolvedEntry;

      // Strategy 1: If only review status conflicts and remote is more advanced, use remote
      if (conflictFields.length == 1 && conflictFields.contains('reviewStatus')) {
        if (_isReviewStatusMoreAdvanced(remoteVersion.reviewStatus, localVersion.reviewStatus)) {
          resolvedEntry = remoteVersion;
        }
      }

      // Strategy 2: If only translations differ, merge them
      if (conflictFields.length == 1 && conflictFields.contains('translations')) {
        final mergedTranslations = Map<String, String>.from(localVersion.translations);
        mergedTranslations.addAll(remoteVersion.translations);

        resolvedEntry = DictionaryEntryModel.fromEntity(
          localVersion.copyWith(
            translations: mergedTranslations,
            lastUpdated: DateTime.now(),
          ),
        );
      }

      // Strategy 3: If only tags differ, merge them
      if (conflictFields.length == 1 && conflictFields.contains('tags')) {
        final mergedTags = Set<String>.from(localVersion.tags);
        mergedTags.addAll(remoteVersion.tags);

        resolvedEntry = DictionaryEntryModel.fromEntity(localVersion.copyWith(
          tags: mergedTags.toList(),
          lastUpdated: DateTime.now(),
        ));
      }

      // Strategy 4: Use remote version if it has higher quality score
      if (resolvedEntry == null && remoteVersion.qualityScore > localVersion.qualityScore) {
        resolvedEntry = remoteVersion;
      }

      // Apply resolution if found
      if (resolvedEntry != null) {
        await localDataSource.resolveConflict(conflictEntry.id, resolvedEntry);
        return true;
      }

      return false; // Could not auto-resolve
    } catch (e) {
      debugPrint('Failed to auto-resolve conflict for ${conflictEntry.id}: $e');
      return false;
    }
  }

  /// Check if review status is more advanced
  bool _isReviewStatusMoreAdvanced(ReviewStatus status1, ReviewStatus status2) {
    const statusOrder = {
      ReviewStatus.autoSuggested: 0,
      ReviewStatus.pendingReview: 1,
      ReviewStatus.humanVerified: 3,
      ReviewStatus.rejected: -1,
    };

    return (statusOrder[status1] ?? 0) > (statusOrder[status2] ?? 0);
  }

  /// Helper to compare maps
  bool _mapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }

  /// Helper to compare lists
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final sorted1 = List<String>.from(list1)..sort();
    final sorted2 = List<String>.from(list2)..sort();
    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i] != sorted2[i]) return false;
    }
    return true;
  }

  /// Get last sync timestamp
  Future<DateTime> _getLastSyncTime() async {
    // This would typically be stored in local storage or database
    // For now, return a default value
    return DateTime.now().subtract(const Duration(days: 1));
  }

  /// Update last sync timestamp
  Future<void> _updateLastSyncTime() async {
    // This would typically update local storage or database
    // Implementation depends on your storage solution
  }

  /// Dispose resources
  void dispose() {
    stopAutoSync();
    _syncController.close();
  }
}

/// Sync status enum
enum SyncStatusType { idle, syncing, completed, error, offline }

/// Sync status with optional error message
class SyncStatus {
  final SyncStatusType type;
  final String? message;

  const SyncStatus._(this.type, this.message);

  static const SyncStatus idle = SyncStatus._(SyncStatusType.idle, null);
  static const SyncStatus syncing = SyncStatus._(SyncStatusType.syncing, null);
  static const SyncStatus completed = SyncStatus._(SyncStatusType.completed, null);
  static const SyncStatus offline = SyncStatus._(SyncStatusType.offline, null);
  static SyncStatus error(String message) => SyncStatus._(SyncStatusType.error, message);
}

/// Sync result with statistics
class SyncResult {
  final bool isSuccess;
  final String? errorMessage;
  final int uploadedCount;
  final int downloadedCount;
  final int conflictsDetected;
  final int conflictsResolved;

  const SyncResult._({
    required this.isSuccess,
    this.errorMessage,
    this.uploadedCount = 0,
    this.downloadedCount = 0,
    this.conflictsDetected = 0,
    this.conflictsResolved = 0,
  });

  static SyncResult success({
    int uploadedCount = 0,
    int downloadedCount = 0,
    int conflictsDetected = 0,
    int conflictsResolved = 0,
  }) {
    return SyncResult._(
      isSuccess: true,
      uploadedCount: uploadedCount,
      downloadedCount: downloadedCount,
      conflictsDetected: conflictsDetected,
      conflictsResolved: conflictsResolved,
    );
  }

  static SyncResult error(String error) => SyncResult._(isSuccess: false, errorMessage: error);
  static SyncResult offline() => const SyncResult._(isSuccess: false, errorMessage: 'No network connection');
  static SyncResult inProgress() => const SyncResult._(isSuccess: false, errorMessage: 'Sync already in progress');
}

/// Conflict detection result
class ConflictDetectionResult {
  final bool hasConflict;
  final List<String> conflictFields;

  const ConflictDetectionResult({
    required this.hasConflict,
    required this.conflictFields,
  });
}

/// Extension to add missing methods to remote data source
extension LexiconRemoteDataSourceExtensions on LexiconRemoteDataSource {
  Future<List<DictionaryEntryModel>> getEntriesModifiedSince(DateTime timestamp) async {
    // This would typically query Firebase with a timestamp filter
    // For now, return empty list - this should be implemented in the actual data source
    return [];
  }
}