import 'package:flutter_test/flutter_test.dart';
import 'package:mayegue/features/authentication/domain/usecases/login_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/register_usecase.dart';
import 'package:mayegue/features/authentication/domain/repositories/auth_repository.dart';
import 'package:mayegue/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:mayegue/features/authentication/domain/entities/user_entity.dart';
import 'package:mockito/mockito.dart';

// Mock repository for integration testing
class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Future<AuthResponseEntity> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    if (email == 'test@example.com' && password == 'password123') {
      final user = UserEntity(
        id: 'user123',
        email: email,
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );
      return AuthResponseEntity(
        user: user,
        success: true,
        message: 'Login successful',
      );
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<AuthResponseEntity> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    final user = UserEntity(
      id: 'user456',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    return AuthResponseEntity(
      user: user,
      success: true,
      message: 'Registration successful',
    );
  }
}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    // Note: In a real integration test, we would use dependency injection
    // For now, we'll test the usecases directly
  });

  group('Authentication Integration Tests', () {
    test('should successfully login with valid credentials', () async {
      final loginUsecase = LoginUsecase(mockRepository);

      final result = await loginUsecase('test@example.com', 'password123');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (response) {
          expect(response.success, isTrue);
          expect(response.message, 'Login successful');
          expect(response.user.email, 'test@example.com');
        },
      );
    });

    test('should fail login with invalid credentials', () async {
      final loginUsecase = LoginUsecase(mockRepository);

      final result = await loginUsecase('wrong@example.com', 'wrongpass');

      expect(result.isLeft(), isTrue);
    });

    test('should successfully register new user', () async {
      final registerUsecase = RegisterUsecase(mockRepository);

      final result = await registerUsecase('new@example.com', 'password123', 'New User');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (response) {
          expect(response.success, isTrue);
          expect(response.message, 'Registration successful');
          expect(response.user.email, 'new@example.com');
          expect(response.user.displayName, 'New User');
        },
      );
    });

    test('should handle network delay in authentication', () async {
      final loginUsecase = LoginUsecase(mockRepository as dynamic);

      final startTime = DateTime.now();
      final result = await loginUsecase('test@example.com', 'password123');
      final endTime = DateTime.now();

      expect(result.isRight(), isTrue);
      // Should take at least 100ms due to simulated delay
      expect(endTime.difference(startTime).inMilliseconds, greaterThanOrEqualTo(90));
    });
  });
}