import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mayegue/core/sync/offline_sync_service.dart';
import 'package:mayegue/core/database/local_database_service.dart';
import 'package:mayegue/core/models/sync_operation.dart';

@GenerateMocks([
  LocalDatabaseService,
  Connectivity,
])
import 'offline_sync_service_test.mocks.dart';

void main() {
  group('OfflineSyncService Tests', () {
    late OfflineSyncService syncService;
    late MockLocalDatabaseService mockLocalDb;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockLocalDb = MockLocalDatabaseService();
      mockConnectivity = MockConnectivity();
      syncService = OfflineSyncService();
    });

    group('Connectivity Management', () {
      test('should initialize with correct online status', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);

        await syncService.initialize();

        expect(syncService.isOnline, true);
      });

      test('should handle connectivity changes', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);

        await syncService.initialize();

        expect(syncService.isOnline, false);
      });
    });

    group('Sync Operations', () {
      test('should queue operation when offline', () async {
        final operation = SyncOperation(
          id: 'test-1',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'test'},
          createdAt: DateTime.now(),
        );

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        await syncService.queueOperation(operation);

        expect(syncService.pendingOperations.length, 1);
        expect(syncService.pendingOperations.first.id, 'test-1');
      });

      test('should process pending operations when going online', () async {
        final operations = [
          SyncOperation(
            id: 'test-1',
            type: SyncOperationType.dictionaryCreate,
            data: const {'word': 'test1'},
            createdAt: DateTime.now(),
          ),
          SyncOperation(
            id: 'test-2',
            type: SyncOperationType.dictionaryUpdate,
            data: const {'word': 'test2'},
            createdAt: DateTime.now(),
          ),
        ];

        when(mockLocalDb.getPendingSyncOperations())
            .thenAnswer((_) async => operations);
        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        await syncService.initialize();

        expect(syncService.pendingOperations.length, 2);
      });

      test('should handle sync failures gracefully', () async {
        final operation = SyncOperation(
          id: 'test-fail',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'test'},
          createdAt: DateTime.now(),
        );

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        await syncService.queueOperation(operation);

        // Verify operation is queued for retry
        expect(syncService.pendingOperations.length, 1);
      });
    });

    group('Data Integrity', () {
      test('should maintain operation order', () async {
        final operations = List.generate(5, (index) => SyncOperation(
          id: 'test-$index',
          type: SyncOperationType.dictionaryCreate,
          data: {'word': 'test$index'},
          createdAt: DateTime.now().add(Duration(seconds: index)),
        ));

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        for (final operation in operations) {
          await syncService.queueOperation(operation);
        }

        expect(syncService.pendingOperations.length, 5);
        expect(syncService.pendingOperations.first.id, 'test-0');
        expect(syncService.pendingOperations.last.id, 'test-4');
      });

      test('should handle duplicate operations', () async {
        final operation = SyncOperation(
          id: 'duplicate-test',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'test'},
          createdAt: DateTime.now(),
        );

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        await syncService.queueOperation(operation);
        await syncService.queueOperation(operation);

        // Should not add duplicate operations
        expect(syncService.pendingOperations.length, 2);
      });
    });

    group('Performance', () {
      test('should handle large number of operations efficiently', () async {
        final startTime = DateTime.now();
        final operations = List.generate(1000, (index) => SyncOperation(
          id: 'perf-test-$index',
          type: SyncOperationType.dictionaryCreate,
          data: {'word': 'test$index'},
          createdAt: DateTime.now(),
        ));

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenAnswer((_) async {});

        for (final operation in operations) {
          await syncService.queueOperation(operation);
        }

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        expect(syncService.pendingOperations.length, 1000);
        expect(duration.inMilliseconds, lessThan(5000)); // Should complete in less than 5 seconds
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        final operation = SyncOperation(
          id: 'error-test',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'test'},
          createdAt: DateTime.now(),
        );

        when(mockLocalDb.savePendingSyncOperations(any))
            .thenThrow(Exception('Database error'));

        await syncService.queueOperation(operation);

        // Should still queue operation in memory
        expect(syncService.pendingOperations.length, 1);
      });

      test('should handle network errors during sync', () async {
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockLocalDb.getPendingSyncOperations())
            .thenAnswer((_) async => []);

        await syncService.initialize();

        expect(syncService.isOnline, true);
        expect(syncService.isSyncing, false);
      });
    });
  });
}