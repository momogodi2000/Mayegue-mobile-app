import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';
import 'sync_operation.dart';

/// General sync manager for queuing and executing operations offline-first
class GeneralSyncManager {
  static const String _operationsKey = 'sync_operations';
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetryAttempts = 3;

  final NetworkInfo _networkInfo;
  SharedPreferences? _prefs;

  Timer? _syncTimer;
  bool _isSyncing = false;
  final _syncController = StreamController<SyncStatusType>.broadcast();

  GeneralSyncManager({
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Stream of sync status updates
  Stream<SyncStatusType> get syncStatusStream => _syncController.stream;

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

  /// Queue an operation for sync
  Future<void> queueOperation(SyncOperation operation) async {
    final operations = await _getQueuedOperations();
    operations.add(operation);
    await _saveQueuedOperations(operations);
  }

  /// Manually trigger sync
  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return SyncResult.inProgress();
    }

    _isSyncing = true;
    _syncController.add(SyncStatusType.syncing);

    try {
      if (!await _networkInfo.isConnected) {
        _syncController.add(SyncStatusType.offline);
        return SyncResult.offline();
      }

      final result = await _performSync();

      if (result.isSuccess) {
        _syncController.add(SyncStatusType.completed);
      } else {
        _syncController.add(SyncStatusType.error);
      }

      return result;
    } catch (e) {
      _syncController.add(SyncStatusType.error);
      return SyncResult.error(e.toString());
    } finally {
      _isSyncing = false;
    }
  }

  /// Perform the actual sync operation
  Future<SyncResult> _performSync() async {
    final operations = await _getQueuedOperations();
    if (operations.isEmpty) {
      return SyncResult.success(0, 0);
    }

    int successCount = 0;
    int failureCount = 0;
    final remainingOperations = <SyncOperation>[];

    for (final operation in operations) {
      try {
        await _executeOperation(operation);
        successCount++;
      } catch (e) {
        final updatedOperation = operation.copyWith(
          retryCount: operation.retryCount + 1,
          errorMessage: e.toString(),
          status: operation.retryCount >= _maxRetryAttempts
              ? SyncStatus.failed
              : SyncStatus.pending,
        );

        if (updatedOperation.status == SyncStatus.pending) {
          remainingOperations.add(updatedOperation);
        }
        failureCount++;
      }
    }

    await _saveQueuedOperations(remainingOperations);
    return SyncResult.success(successCount, failureCount);
  }

  /// Execute a single operation
  Future<void> _executeOperation(SyncOperation operation) async {
    // This is a placeholder - actual implementation would depend on the table
    // For now, we'll just simulate success
    // In real implementation, this would call appropriate services based on tableName
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network call

    if (operation.tableName == 'users') {
      // Handle user sync
      // This would call FirebaseService or similar
    } else if (operation.tableName == 'dictionary') {
      // Handle dictionary sync
      // This would call dictionary services
    }

    // If we get here without throwing, operation succeeded
  }

  /// Get queued operations from storage
  Future<List<SyncOperation>> _getQueuedOperations() async {
    await _ensurePrefsInitialized();
    final operationsJson = _prefs!.getStringList(_operationsKey) ?? [];
    return operationsJson
        .map((json) => SyncOperation.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Save queued operations to storage
  Future<void> _saveQueuedOperations(List<SyncOperation> operations) async {
    await _ensurePrefsInitialized();
    final operationsJson = operations
        .map((op) => jsonEncode(op.toJson()))
        .toList();
    await _prefs!.setStringList(_operationsKey, operationsJson);
  }

  /// Ensure SharedPreferences is initialized
  Future<void> _ensurePrefsInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get pending operations count
  Future<int> getPendingOperationsCount() async {
    final operations = await _getQueuedOperations();
    return operations.where((op) => op.status == SyncStatus.pending).length;
  }

  /// Clear completed operations
  Future<void> clearCompletedOperations() async {
    final operations = await _getQueuedOperations();
    final pendingOperations = operations
        .where((op) => op.status != SyncStatus.success)
        .toList();
    await _saveQueuedOperations(pendingOperations);
  }

  /// Dispose resources
  void dispose() {
    stopAutoSync();
    _syncController.close();
  }
}

/// Sync status types
enum SyncStatusType {
  idle,
  syncing,
  completed,
  error,
  offline,
}

/// Result of a sync operation
class SyncResult {
  final bool isSuccess;
  final int successCount;
  final int failureCount;
  final String? errorMessage;

  SyncResult._({
    required this.isSuccess,
    this.successCount = 0,
    this.failureCount = 0,
    this.errorMessage,
  });

  factory SyncResult.success(int successCount, int failureCount) {
    return SyncResult._(
      isSuccess: true,
      successCount: successCount,
      failureCount: failureCount,
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  factory SyncResult.offline() {
    return SyncResult._(isSuccess: false, errorMessage: 'No internet connection');
  }

  factory SyncResult.inProgress() {
    return SyncResult._(isSuccess: false, errorMessage: 'Sync already in progress');
  }
}