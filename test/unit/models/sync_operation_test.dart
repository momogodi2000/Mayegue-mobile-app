import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/core/models/sync_operation.dart';

void main() {
  group('SyncOperation Tests', () {
    test('should create SyncOperation with required fields', () {
      final operation = SyncOperation(
        id: 'test-1',
        type: SyncOperationType.dictionaryCreate,
        data: const {'word': 'hello', 'translation': 'mbolo'},
        createdAt: DateTime.now(),
      );

      expect(operation.id, 'test-1');
      expect(operation.type, SyncOperationType.dictionaryCreate);
      expect(operation.status, SyncStatus.pending);
      expect(operation.retryCount, 0);
      expect(operation.maxRetries, 3);
    });

    test('should create SyncOperation from JSON', () {
      final json = {
        'id': 'test-json',
        'type': 'SyncOperationType.dictionaryUpdate',
        'data': {'word': 'test'},
        'status': 'SyncStatus.pending',
        'createdAt': '2025-01-01T00:00:00.000Z',
        'retryCount': 1,
        'maxRetries': 5,
        'metadata': {'source': 'test'}
      };

      final operation = SyncOperation.fromJson(json);

      expect(operation.id, 'test-json');
      expect(operation.type, SyncOperationType.dictionaryUpdate);
      expect(operation.status, SyncStatus.pending);
      expect(operation.retryCount, 1);
      expect(operation.maxRetries, 5);
    });

    test('should convert SyncOperation to JSON', () {
      final operation = SyncOperation(
        id: 'test-to-json',
        type: SyncOperationType.dictionaryDelete,
        data: const {'entryId': '123'},
        createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
        status: SyncStatus.failed,
        retryCount: 2,
        errorMessage: 'Network error',
      );

      final json = operation.toJson();

      expect(json['id'], 'test-to-json');
      expect(json['type'], 'SyncOperationType.dictionaryDelete');
      expect(json['status'], 'SyncStatus.failed');
      expect(json['retryCount'], 2);
      expect(json['errorMessage'], 'Network error');
    });

    test('should create copy with updated fields', () {
      final original = SyncOperation(
        id: 'original',
        type: SyncOperationType.progressUpdate,
        data: const {'progress': 50},
        createdAt: DateTime.now(),
      );

      final copy = original.copyWith(
        status: SyncStatus.completed,
        retryCount: 1,
      );

      expect(copy.id, original.id);
      expect(copy.type, original.type);
      expect(copy.status, SyncStatus.completed);
      expect(copy.retryCount, 1);
      expect(copy.data, original.data);
    });

    test('should handle retry logic correctly', () {
      final operation = SyncOperation(
        id: 'retry-test',
        type: SyncOperationType.dictionaryCreate,
        data: const {'word': 'test'},
        createdAt: DateTime.now(),
        status: SyncStatus.failed,
        retryCount: 2,
        maxRetries: 3,
      );

      expect(operation.canRetry, true);
      expect(operation.needsRetry, true);

      final exhaustedOperation = operation.copyWith(retryCount: 3);
      expect(exhaustedOperation.canRetry, false);
      expect(exhaustedOperation.needsRetry, false);
    });

    test('should detect expired operations', () {
      final oldOperation = SyncOperation(
        id: 'old',
        type: SyncOperationType.dictionaryCreate,
        data: const {'word': 'old'},
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      );

      final recentOperation = SyncOperation(
        id: 'recent',
        type: SyncOperationType.dictionaryCreate,
        data: const {'word': 'recent'},
        createdAt: DateTime.now(),
      );

      expect(oldOperation.isExpired, true);
      expect(recentOperation.isExpired, false);
    });

    test('should handle all sync operation types', () {
      final types = [
        SyncOperationType.dictionaryCreate,
        SyncOperationType.dictionaryUpdate,
        SyncOperationType.dictionaryDelete,
        SyncOperationType.progressUpdate,
        SyncOperationType.userProfileUpdate,
      ];

      for (final type in types) {
        final operation = SyncOperation(
          id: 'test-${type.toString()}',
          type: type,
          data: const {'test': 'data'},
          createdAt: DateTime.now(),
        );

        expect(operation.type, type);
      }
    });

    test('should handle all sync statuses', () {
      final statuses = [
        SyncStatus.pending,
        SyncStatus.inProgress,
        SyncStatus.completed,
        SyncStatus.failed,
        SyncStatus.retrying,
      ];

      for (final status in statuses) {
        final operation = SyncOperation(
          id: 'test-${status.toString()}',
          type: SyncOperationType.dictionaryCreate,
          data: const {'test': 'data'},
          createdAt: DateTime.now(),
          status: status,
        );

        expect(operation.status, status);
      }
    });
  });
}