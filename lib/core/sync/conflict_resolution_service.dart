import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../features/dictionary/data/models/dictionary_entry_model.dart';
import '../../features/dictionary/domain/entities/dictionary_entry_entity.dart';
import '../../features/dictionary/data/datasources/lexicon_local_datasource.dart';

/// Service for handling sync conflicts with user interaction
class ConflictResolutionService {
  final LexiconLocalDataSource localDataSource;

  ConflictResolutionService({required this.localDataSource});

  /// Get all pending conflicts
  Future<List<ConflictItem>> getPendingConflicts() async {
    final conflictEntries = await localDataSource.getConflictEntries();

    return conflictEntries.map((entry) {
      final conflictData = jsonDecode(entry.metadata['conflict_data'] ?? '{}');
      return ConflictItem.fromConflictData(entry.id, conflictData);
    }).toList();
  }

  /// Resolve conflict by choosing local version
  Future<void> resolveWithLocal(String entryId) async {
    final conflictEntry = await localDataSource.getEntry(entryId);
    if (conflictEntry == null) return;

    final conflictData = jsonDecode(conflictEntry.metadata['conflict_data'] ?? '{}');
    final localVersion = DictionaryEntryModel.fromFirestore(conflictData['localVersion']);

    final resolvedEntry = DictionaryEntryModel.fromEntity(localVersion.copyWith(
      lastUpdated: DateTime.now(),
      metadata: {
        ...localVersion.metadata,
        'conflictResolvedAt': DateTime.now().toIso8601String(),
        'resolutionMethod': 'local_chosen',
      },
    ));

    await localDataSource.resolveConflict(entryId, resolvedEntry);
  }

  /// Resolve conflict by choosing remote version
  Future<void> resolveWithRemote(String entryId) async {
    final conflictEntry = await localDataSource.getEntry(entryId);
    if (conflictEntry == null) return;

    final conflictData = jsonDecode(conflictEntry.metadata['conflict_data'] ?? '{}');
    final remoteVersion = DictionaryEntryModel.fromFirestore(conflictData['remoteVersion']);

    final resolvedEntry = DictionaryEntryModel.fromEntity(remoteVersion.copyWith(
      lastUpdated: DateTime.now(),
      metadata: {
        ...remoteVersion.metadata,
        'conflictResolvedAt': DateTime.now().toIso8601String(),
        'resolutionMethod': 'remote_chosen',
      },
    ));

    await localDataSource.resolveConflict(entryId, resolvedEntry);
  }

  /// Resolve conflict with custom merged version
  Future<void> resolveWithMerged(String entryId, DictionaryEntryModel mergedEntry) async {
    final resolvedEntry = DictionaryEntryModel.fromEntity(mergedEntry.copyWith(
      lastUpdated: DateTime.now(),
      metadata: {
        ...mergedEntry.metadata,
        'conflictResolvedAt': DateTime.now().toIso8601String(),
        'resolutionMethod': 'manual_merge',
      },
    ));

    await localDataSource.resolveConflict(entryId, resolvedEntry);
  }

  /// Create a suggested merge of conflicting versions
  DictionaryEntryModel createMergedVersion(
    DictionaryEntryModel localVersion,
    DictionaryEntryModel remoteVersion,
    List<String> conflictFields,
  ) {
    // Start with local version as base
    DictionaryEntryEntity merged = localVersion;

    // Apply smart merging strategies for each field
    for (final field in conflictFields) {
      switch (field) {
        case 'canonicalForm':
          // For canonical form, use the longer or more complete version
          if (remoteVersion.canonicalForm.length > localVersion.canonicalForm.length) {
            merged = merged.copyWith(canonicalForm: remoteVersion.canonicalForm);
          }
          break;

        case 'translations':
          // Merge translations from both versions
          final mergedTranslations = Map<String, String>.from(localVersion.translations);
          mergedTranslations.addAll(remoteVersion.translations);
          merged = merged.copyWith(translations: mergedTranslations);
          break;

        case 'tags':
          // Merge tags from both versions (unique only)
          final mergedTags = Set<String>.from(localVersion.tags);
          mergedTags.addAll(remoteVersion.tags);
          merged = merged.copyWith(tags: mergedTags.toList());
          break;

        case 'exampleSentences':
          // Merge example sentences (avoid duplicates by sentence text)
          final existingSentences = localVersion.exampleSentences.map((e) => e.sentence).toSet();
          final newSentences = remoteVersion.exampleSentences
              .where((e) => !existingSentences.contains(e.sentence))
              .toList();

          merged = merged.copyWith(
            exampleSentences: [...localVersion.exampleSentences, ...newSentences],
          );
          break;

        case 'orthographyVariants':
          // Merge orthography variants (unique only)
          final mergedVariants = Set<String>.from(localVersion.orthographyVariants);
          mergedVariants.addAll(remoteVersion.orthographyVariants);
          merged = merged.copyWith(orthographyVariants: mergedVariants.toList());
          break;

        case 'ipa':
          // For IPA, prefer the non-null value, or remote if both exist
          if (localVersion.ipa == null && remoteVersion.ipa != null) {
            merged = merged.copyWith(ipa: remoteVersion.ipa);
          } else if (localVersion.ipa != null && remoteVersion.ipa != null) {
            // Both exist, use remote (assuming it might be more accurate)
            merged = merged.copyWith(ipa: remoteVersion.ipa);
          }
          break;

        case 'partOfSpeech':
          // For part of speech, prefer remote if it's more specific
          if (_isMoreSpecificPartOfSpeech(remoteVersion.partOfSpeech, localVersion.partOfSpeech)) {
            merged = merged.copyWith(partOfSpeech: remoteVersion.partOfSpeech);
          }
          break;

        case 'reviewStatus':
          // Use the more advanced review status
          if (_isReviewStatusMoreAdvanced(remoteVersion.reviewStatus, localVersion.reviewStatus)) {
            merged = merged.copyWith(reviewStatus: remoteVersion.reviewStatus);
          }
          break;

        case 'qualityScore':
          // Use the higher quality score
          if (remoteVersion.qualityScore > localVersion.qualityScore) {
            merged = merged.copyWith(qualityScore: remoteVersion.qualityScore);
          }
          break;

        case 'difficultyLevel':
          // For difficulty, we could use a more conservative approach (lower difficulty)
          // or trust the remote version if it comes from a teacher
          if (remoteVersion.reviewStatus == ReviewStatus.humanVerified) {
            merged = merged.copyWith(difficultyLevel: remoteVersion.difficultyLevel);
          }
          break;
      }
    }

    return DictionaryEntryModel.fromEntity(merged.copyWith(
      lastUpdated: DateTime.now(),
      metadata: {
        ...merged.metadata,
        'mergedFields': conflictFields,
        'mergedAt': DateTime.now().toIso8601String(),
        'resolutionMethod': 'merged',
      },
    ));
  }

  /// Check if one part of speech is more specific than another
  bool _isMoreSpecificPartOfSpeech(String pos1, String pos2) {
    // Define specificity order (more specific parts of speech)
    const specificityOrder = {
      'unknown': 0,
      'other': 1,
      'noun': 2,
      'verb': 2,
      'adjective': 2,
      'adverb': 2,
      'pronoun': 3,
      'preposition': 3,
      'conjunction': 3,
      'interjection': 3,
      'proper_noun': 4,
      'transitive_verb': 4,
      'intransitive_verb': 4,
      'modal_verb': 4,
    };

    return (specificityOrder[pos1.toLowerCase()] ?? 0) >
           (specificityOrder[pos2.toLowerCase()] ?? 0);
  }

  /// Check if review status is more advanced
  bool _isReviewStatusMoreAdvanced(ReviewStatus status1, ReviewStatus status2) {
    const statusOrder = {
      ReviewStatus.autoSuggested: 0,
      ReviewStatus.pendingReview: 1,
      ReviewStatus.humanVerified: 2,
      ReviewStatus.rejected: -1,
    };

    return (statusOrder[status1] ?? 0) > (statusOrder[status2] ?? 0);
  }

  /// Get conflict statistics
  Future<ConflictStatistics> getConflictStatistics() async {
    final conflicts = await getPendingConflicts();

    final fieldConflictCounts = <String, int>{};
    final conflictTypesCounts = <ConflictType, int>{};

    for (final conflict in conflicts) {
      // Count field conflicts
      for (final field in conflict.conflictFields) {
        fieldConflictCounts[field] = (fieldConflictCounts[field] ?? 0) + 1;
      }

      // Count conflict types
      conflictTypesCounts[conflict.type] = (conflictTypesCounts[conflict.type] ?? 0) + 1;
    }

    return ConflictStatistics(
      totalConflicts: conflicts.length,
      fieldConflictCounts: fieldConflictCounts,
      conflictTypesCounts: conflictTypesCounts,
      oldestConflictAge: conflicts.isNotEmpty
          ? DateTime.now().difference(conflicts.map((c) => c.detectedAt).reduce(
              (a, b) => a.isBefore(b) ? a : b))
          : Duration.zero,
    );
  }

  /// Batch resolve conflicts using default strategies
  Future<int> batchResolveConflicts({
    bool preferRemote = false,
    bool autoMergeWhenPossible = true,
  }) async {
    final conflicts = await getPendingConflicts();
    int resolvedCount = 0;

    for (final conflict in conflicts) {
      try {
        if (autoMergeWhenPossible && _canAutoMerge(conflict.conflictFields)) {
          // Try auto-merge for safe conflicts
          final merged = createMergedVersion(
            conflict.localVersion,
            conflict.remoteVersion,
            conflict.conflictFields,
          );
          await resolveWithMerged(conflict.entryId, merged);
          resolvedCount++;
        } else if (preferRemote) {
          await resolveWithRemote(conflict.entryId);
          resolvedCount++;
        } else {
          await resolveWithLocal(conflict.entryId);
          resolvedCount++;
        }
      } catch (e) {
        debugPrint('Failed to resolve conflict for ${conflict.entryId}: $e');
      }
    }

    return resolvedCount;
  }

  /// Check if conflicts can be safely auto-merged
  bool _canAutoMerge(List<String> conflictFields) {
    // Only auto-merge if conflicts are in "safe" fields that can be combined
    const safeMergeFields = {
      'translations',
      'tags',
      'orthographyVariants',
      'exampleSentences',
    };

    return conflictFields.every((field) => safeMergeFields.contains(field));
  }
}

/// Represents a single conflict item
class ConflictItem {
  final String entryId;
  final ConflictType type;
  final DictionaryEntryModel localVersion;
  final DictionaryEntryModel remoteVersion;
  final List<String> conflictFields;
  final DateTime detectedAt;

  const ConflictItem({
    required this.entryId,
    required this.type,
    required this.localVersion,
    required this.remoteVersion,
    required this.conflictFields,
    required this.detectedAt,
  });

  factory ConflictItem.fromConflictData(String entryId, Map<String, dynamic> conflictData) {
    return ConflictItem(
      entryId: entryId,
      type: ConflictType.values.firstWhere(
        (t) => t.toString().split('.').last == conflictData['type']?.toString().split('_').last,
        orElse: () => ConflictType.download,
      ),
      localVersion: DictionaryEntryModel.fromFirestore(conflictData['localVersion']),
      remoteVersion: DictionaryEntryModel.fromFirestore(conflictData['remoteVersion']),
      conflictFields: List<String>.from(conflictData['conflictFields'] ?? []),
      detectedAt: DateTime.parse(conflictData['detectedAt']),
    );
  }

  /// Get a human-readable description of the conflict
  String get description {
    final word = localVersion.canonicalForm;
    final fieldCount = conflictFields.length;
    final fieldNames = conflictFields.join(', ');

    return 'Conflict in "$word": $fieldCount field${fieldCount > 1 ? 's' : ''} ($fieldNames)';
  }

  /// Get conflict severity based on fields involved
  ConflictSeverity get severity {
    const criticalFields = {'canonicalForm', 'reviewStatus'};
    const moderateFields = {'translations', 'partOfSpeech', 'ipa'};

    if (conflictFields.any((field) => criticalFields.contains(field))) {
      return ConflictSeverity.critical;
    } else if (conflictFields.any((field) => moderateFields.contains(field))) {
      return ConflictSeverity.moderate;
    } else {
      return ConflictSeverity.low;
    }
  }
}

/// Types of conflicts
enum ConflictType { upload, download, merge }

/// Conflict severity levels
enum ConflictSeverity { low, moderate, critical }

/// Conflict resolution statistics
class ConflictStatistics {
  final int totalConflicts;
  final Map<String, int> fieldConflictCounts;
  final Map<ConflictType, int> conflictTypesCounts;
  final Duration oldestConflictAge;

  const ConflictStatistics({
    required this.totalConflicts,
    required this.fieldConflictCounts,
    required this.conflictTypesCounts,
    required this.oldestConflictAge,
  });

  /// Get the most problematic field
  String? get mostProblematicField {
    if (fieldConflictCounts.isEmpty) return null;

    String? maxField;
    int maxCount = 0;

    for (final entry in fieldConflictCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxField = entry.key;
      }
    }

    return maxField;
  }

  /// Check if conflicts need urgent attention
  bool get needsUrgentAttention {
    return totalConflicts > 10 || oldestConflictAge.inDays > 7;
  }
}