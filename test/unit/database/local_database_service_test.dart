import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mayegue/core/database/local_database_service.dart';
import 'package:mayegue/core/models/sync_operation.dart';

void main() {
  group('LocalDatabaseService Tests', () {
    late LocalDatabaseService databaseService;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseService = LocalDatabaseService();
      // Use in-memory database for testing
      await databaseService.clearAllData();
    });

    tearDown(() async {
      await databaseService.close();
    });

    group('Sync Operations CRUD', () {
      test('should save and retrieve sync operations', () async {
        final operations = [
          SyncOperation(
            id: 'test-1',
            type: SyncOperationType.dictionaryCreate,
            data: const {'word': 'hello', 'translation': 'mbolo'},
            createdAt: DateTime.now(),
          ),
          SyncOperation(
            id: 'test-2',
            type: SyncOperationType.dictionaryUpdate,
            data: const {'word': 'goodbye', 'translation': 'kwa'},
            createdAt: DateTime.now(),
          ),
        ];

        await databaseService.savePendingSyncOperations(operations);
        final retrieved = await databaseService.getPendingSyncOperations();

        expect(retrieved.length, 2);
        expect(retrieved.first.id, 'test-1');
        expect(retrieved.first.type, SyncOperationType.dictionaryCreate);
        expect(retrieved.last.id, 'test-2');
        expect(retrieved.last.type, SyncOperationType.dictionaryUpdate);
      });

      test('should update sync operation status', () async {
        final operation = SyncOperation(
          id: 'update-test',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'test'},
          createdAt: DateTime.now(),
          status: SyncStatus.pending,
        );

        await databaseService.savePendingSyncOperations([operation]);

        final updatedOperation = operation.copyWith(
          status: SyncStatus.completed,
          retryCount: 1,
        );

        await databaseService.updateSyncOperation(updatedOperation);

        final retrieved = await databaseService.getPendingSyncOperations();
        expect(retrieved.isEmpty, true); // Completed operations should not be in pending
      });

      test('should handle empty operations list', () async {
        await databaseService.savePendingSyncOperations([]);
        final retrieved = await databaseService.getPendingSyncOperations();

        expect(retrieved.isEmpty, true);
      });
    });

    group('Dictionary Entries CRUD', () {
      test('should insert and retrieve dictionary entries', () async {
        final entry = {
          'id': 'entry-1',
          'canonical_form': 'hello',
          'language_code': 'ewondo',
          'translations': {'fr': 'salut', 'en': 'hello'},
          'examples': ['Hello world', 'Hello there'],
          'tags': ['greeting', 'common'],
          'contributor_id': 'user-123',
          'review_status': 'verified',
        };

        await databaseService.insertDictionaryEntry(entry);

        final retrieved = await databaseService.getDictionaryEntries(
          languageCode: 'ewondo',
        );

        expect(retrieved.length, 1);
        expect(retrieved.first['canonical_form'], 'hello');
        expect(retrieved.first['language_code'], 'ewondo');
        expect(retrieved.first['translations'], isA<Map>());
        expect(retrieved.first['examples'], isA<List>());
        expect(retrieved.first['tags'], isA<List>());
      });

      test('should filter entries by language code', () async {
        final entries = [
          {
            'id': 'entry-1',
            'canonical_form': 'hello',
            'language_code': 'ewondo',
            'contributor_id': 'user-123',
            'review_status': 'verified',
          },
          {
            'id': 'entry-2',
            'canonical_form': 'bonjour',
            'language_code': 'duala',
            'contributor_id': 'user-123',
            'review_status': 'verified',
          },
        ];

        for (final entry in entries) {
          await databaseService.insertDictionaryEntry(entry);
        }

        final ewondoEntries = await databaseService.getDictionaryEntries(
          languageCode: 'ewondo',
        );
        final dualaEntries = await databaseService.getDictionaryEntries(
          languageCode: 'duala',
        );

        expect(ewondoEntries.length, 1);
        expect(ewondoEntries.first['canonical_form'], 'hello');
        expect(dualaEntries.length, 1);
        expect(dualaEntries.first['canonical_form'], 'bonjour');
      });

      test('should filter entries by contributor', () async {
        final entries = [
          {
            'id': 'entry-1',
            'canonical_form': 'hello',
            'language_code': 'ewondo',
            'contributor_id': 'teacher-1',
            'review_status': 'verified',
          },
          {
            'id': 'entry-2',
            'canonical_form': 'world',
            'language_code': 'ewondo',
            'contributor_id': 'teacher-2',
            'review_status': 'verified',
          },
        ];

        for (final entry in entries) {
          await databaseService.insertDictionaryEntry(entry);
        }

        final teacher1Entries = await databaseService.getDictionaryEntries(
          contributorId: 'teacher-1',
        );

        expect(teacher1Entries.length, 1);
        expect(teacher1Entries.first['canonical_form'], 'hello');
        expect(teacher1Entries.first['contributor_id'], 'teacher-1');
      });

      test('should update Firebase ID for dictionary entry', () async {
        final entry = {
          'id': 'local-123',
          'canonical_form': 'test',
          'language_code': 'ewondo',
          'contributor_id': 'user-123',
          'review_status': 'pending',
        };

        await databaseService.insertDictionaryEntry(entry);
        await databaseService.updateDictionaryEntryFirebaseId(
          'local-123',
          'firebase-456',
        );

        final retrieved = await databaseService.getDictionaryEntries();
        expect(retrieved.first['firebase_id'], 'firebase-456');
        expect(retrieved.first['sync_status'], 'synced');
      });
    });

    group('Metadata Management', () {
      test('should store and retrieve last sync time', () async {
        final syncTime = DateTime.now();
        await databaseService.saveLastSyncTime(syncTime);

        final retrieved = await databaseService.getLastSyncTime();

        expect(retrieved, isNotNull);
        expect(retrieved!.difference(syncTime).inSeconds, lessThan(1));
      });

      test('should handle metadata operations', () async {
        await databaseService.setMetadata('app_version', '1.0.0');
        await databaseService.setMetadata('last_update', '2025-01-01');

        final version = await databaseService.getMetadata('app_version');
        final lastUpdate = await databaseService.getMetadata('last_update');
        final nonExistent = await databaseService.getMetadata('non_existent');

        expect(version, '1.0.0');
        expect(lastUpdate, '2025-01-01');
        expect(nonExistent, isNull);
      });
    });

    group('Performance Tests', () {
      test('should handle large number of entries efficiently', () async {
        final startTime = DateTime.now();

        for (int i = 0; i < 1000; i++) {
          await databaseService.insertDictionaryEntry({
            'id': 'perf-entry-$i',
            'canonical_form': 'word$i',
            'language_code': 'ewondo',
            'contributor_id': 'user-123',
            'review_status': 'verified',
          });
        }

        final endTime = DateTime.now();
        final insertDuration = endTime.difference(startTime);

        final retrieveStartTime = DateTime.now();
        final entries = await databaseService.getDictionaryEntries();
        final retrieveEndTime = DateTime.now();
        final retrieveDuration = retrieveEndTime.difference(retrieveStartTime);

        expect(entries.length, 1000);
        expect(insertDuration.inSeconds, lessThan(10));
        expect(retrieveDuration.inMilliseconds, lessThan(1000));
      });

      test('should efficiently query with filters', () async {
        // Insert test data
        final languages = ['ewondo', 'duala', 'bafang'];
        for (int i = 0; i < 300; i++) {
          await databaseService.insertDictionaryEntry({
            'id': 'filter-entry-$i',
            'canonical_form': 'word$i',
            'language_code': languages[i % 3],
            'contributor_id': 'user-${i % 10}',
            'review_status': 'verified',
          });
        }

        final startTime = DateTime.now();

        final ewondoEntries = await databaseService.getDictionaryEntries(
          languageCode: 'ewondo',
        );

        final endTime = DateTime.now();
        final queryDuration = endTime.difference(startTime);

        expect(ewondoEntries.length, 100);
        expect(queryDuration.inMilliseconds, lessThan(500));
      });
    });

    group('Error Handling', () {
      test('should handle invalid data gracefully', () async {
        // Test with missing required fields
        final invalidEntry = {
          'id': 'invalid-1',
          // Missing canonical_form and language_code
        };

        expect(
          () => databaseService.insertDictionaryEntry(invalidEntry),
          throwsException,
        );
      });

      test('should handle database corruption gracefully', () async {
        // This test would typically involve corrupting the database
        // For now, we'll test basic error handling
        await databaseService.clearAllData();

        final operations = await databaseService.getPendingSyncOperations();
        expect(operations, isEmpty);
      });
    });

    group('Cleanup Operations', () {
      test('should clean up expired operations', () async {
        final oldOperation = SyncOperation(
          id: 'old-op',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'old'},
          createdAt: DateTime.now().subtract(const Duration(days: 8)),
          status: SyncStatus.completed,
        );

        final recentOperation = SyncOperation(
          id: 'recent-op',
          type: SyncOperationType.dictionaryCreate,
          data: const {'word': 'recent'},
          createdAt: DateTime.now(),
          status: SyncStatus.pending,
        );

        await databaseService.savePendingSyncOperations([oldOperation, recentOperation]);
        await databaseService.cleanupExpiredOperations();

        final remaining = await databaseService.getPendingSyncOperations();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'recent-op');
      });

      test('should clear all data', () async {
        // Add some test data
        await databaseService.insertDictionaryEntry({
          'id': 'test-entry',
          'canonical_form': 'test',
          'language_code': 'ewondo',
          'contributor_id': 'user-123',
          'review_status': 'verified',
        });

        await databaseService.savePendingSyncOperations([
          SyncOperation(
            id: 'test-op',
            type: SyncOperationType.dictionaryCreate,
            data: const {'word': 'test'},
            createdAt: DateTime.now(),
          ),
        ]);

        await databaseService.setMetadata('test_key', 'test_value');

        // Clear all data
        await databaseService.clearAllData();

        // Verify everything is cleared
        final entries = await databaseService.getDictionaryEntries();
        final operations = await databaseService.getPendingSyncOperations();
        final metadata = await databaseService.getMetadata('test_key');

        expect(entries, isEmpty);
        expect(operations, isEmpty);
        expect(metadata, isNull);
      });
    });
  });
}