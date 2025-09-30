import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/local_database_service.dart';
import '../services/firebase_service.dart';
import '../models/sync_operation.dart';

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  bool _isOnline = false;
  List<SyncOperation> _pendingOperations = [];
  DateTime? _lastSyncTime;

  // Getters
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  List<SyncOperation> get pendingOperations => List.unmodifiable(_pendingOperations);
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingCount => _pendingOperations.length;

  /// Initialize the sync service
  Future<void> initialize() async {
    // Check initial connectivity
    final connectivity = await _connectivity.checkConnectivity();
    _isOnline = connectivity != ConnectivityResult.none;

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Load pending operations from local storage
    await _loadPendingOperations();

    // Start auto-sync if online
    if (_isOnline) {
      _scheduleAutoSync();
    }

    notifyListeners();
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    if (_isOnline && !wasOnline) {
      // Just came online - trigger sync
      _scheduleAutoSync();
    }

    notifyListeners();
  }

  /// Queue an operation for sync
  Future<void> queueOperation(SyncOperation operation) async {
    // Try immediate sync if online
    if (_isOnline && !_isSyncing) {
      try {
        await _executeSyncOperation(operation);
        return;
      } catch (e) {
        // If immediate sync fails, queue it
        debugPrint('Immediate sync failed, queuing operation: $e');
      }
    }

    // Add to pending operations
    _pendingOperations.add(operation);
    await _savePendingOperations();
    notifyListeners();
  }

  /// Manual sync trigger
  Future<bool> syncNow() async {
    if (_isSyncing || !_isOnline) {
      return false;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      await _performSync();
      _lastSyncTime = DateTime.now();
      await _saveLastSyncTime();
      return true;
    } catch (e) {
      debugPrint('Sync failed: $e');
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Perform the actual sync
  Future<void> _performSync() async {
    if (_pendingOperations.isEmpty) return;

    final operationsToSync = List<SyncOperation>.from(_pendingOperations);
    final successfulOperations = <SyncOperation>[];

    for (final operation in operationsToSync) {
      try {
        await _executeSyncOperation(operation);
        successfulOperations.add(operation);
      } catch (e) {
        debugPrint('Failed to sync operation ${operation.id}: $e');
        // Keep failed operations in queue for retry
      }
    }

    // Remove successful operations
    _pendingOperations.removeWhere((op) => successfulOperations.contains(op));
    await _savePendingOperations();
  }

  /// Execute a single sync operation
  Future<void> _executeSyncOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.dictionaryCreate:
        await _syncDictionaryCreate(operation);
        break;
      case SyncOperationType.dictionaryUpdate:
        await _syncDictionaryUpdate(operation);
        break;
      case SyncOperationType.dictionaryDelete:
        await _syncDictionaryDelete(operation);
        break;
      case SyncOperationType.progressUpdate:
        await _syncProgressUpdate(operation);
        break;
      case SyncOperationType.userProfileUpdate:
        await _syncUserProfileUpdate(operation);
        break;
    }
  }

  /// Sync dictionary creation
  Future<void> _syncDictionaryCreate(SyncOperation operation) async {
    final data = operation.data;
    final docRef = _firebaseService.firestore
        .collection('lexicon')
        .doc();

    final entryData = Map<String, dynamic>.from(data);
    entryData['id'] = docRef.id;
    entryData['syncedAt'] = DateTime.now().toIso8601String();

    await docRef.set(entryData);

    // Update local record with Firebase ID
    await _localDb.updateDictionaryEntryFirebaseId(
      operation.localId!,
      docRef.id,
    );
  }

  /// Sync dictionary update
  Future<void> _syncDictionaryUpdate(SyncOperation operation) async {
    final data = operation.data;
    data['syncedAt'] = DateTime.now().toIso8601String();

    await _firebaseService.firestore
        .collection('lexicon')
        .doc(operation.firebaseId)
        .update(data);
  }

  /// Sync dictionary delete
  Future<void> _syncDictionaryDelete(SyncOperation operation) async {
    await _firebaseService.firestore
        .collection('lexicon')
        .doc(operation.firebaseId)
        .delete();
  }

  /// Sync progress update
  Future<void> _syncProgressUpdate(SyncOperation operation) async {
    final data = operation.data;
    data['syncedAt'] = DateTime.now().toIso8601String();

    await _firebaseService.firestore
        .collection('userProgress')
        .doc(operation.firebaseId)
        .set(data, SetOptions(merge: true));
  }

  /// Sync user profile update
  Future<void> _syncUserProfileUpdate(SyncOperation operation) async {
    final data = operation.data;
    data['syncedAt'] = DateTime.now().toIso8601String();

    await _firebaseService.firestore
        .collection('users')
        .doc(operation.firebaseId)
        .update(data);
  }

  /// Schedule automatic sync
  void _scheduleAutoSync() {
    if (!_isOnline) return;

    // Perform immediate sync if we have pending operations
    if (_pendingOperations.isNotEmpty && !_isSyncing) {
      Future.delayed(Duration.zero, () => syncNow());
    }

    // Schedule periodic sync
    Future.delayed(const Duration(minutes: 5), () {
      if (_isOnline && !_isSyncing) {
        syncNow();
      }
      _scheduleAutoSync(); // Reschedule
    });
  }

  /// Load pending operations from local storage
  Future<void> _loadPendingOperations() async {
    try {
      _pendingOperations = await _localDb.getPendingSyncOperations();
      _lastSyncTime = await _localDb.getLastSyncTime();
    } catch (e) {
      debugPrint('Failed to load pending operations: $e');
      _pendingOperations = [];
    }
  }

  /// Save pending operations to local storage
  Future<void> _savePendingOperations() async {
    try {
      await _localDb.savePendingSyncOperations(_pendingOperations);
    } catch (e) {
      debugPrint('Failed to save pending operations: $e');
    }
  }

  /// Save last sync time
  Future<void> _saveLastSyncTime() async {
    try {
      await _localDb.saveLastSyncTime(_lastSyncTime!);
    } catch (e) {
      debugPrint('Failed to save last sync time: $e');
    }
  }

  /// Clear all pending operations (admin only)
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    await _savePendingOperations();
    notifyListeners();
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'pendingCount': _pendingOperations.length,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'operationTypes': _pendingOperations
          .map((op) => op.type.toString())
          .toSet()
          .toList(),
    };
  }
}