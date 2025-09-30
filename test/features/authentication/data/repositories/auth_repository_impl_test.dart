import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mayegue/core/sync/general_sync_manager.dart';
import 'package:mayegue/core/sync/sync_operation.dart';
import 'package:mayegue/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:mayegue/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:mayegue/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mayegue/features/authentication/data/models/user_model.dart';
import 'package:mayegue/features/authentication/data/models/auth_response_model.dart';

import 'auth_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
  Connectivity,
  GeneralSyncManager,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockConnectivity mockConnectivity;
  late MockGeneralSyncManager mockSyncManager;

  // Test data
  final testUser = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: true,
  );

  final testAuthResponse = AuthResponseModel(
    user: testUser,
    token: 'test-token',
    success: true,
    message: 'Success',
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockConnectivity = MockConnectivity();
    mockSyncManager = MockGeneralSyncManager();

    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      connectivity: mockConnectivity,
      syncManager: mockSyncManager,
    );
  });

  group('AuthRepositoryImpl - Sign In with Email and Password', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should sign in with remote data source when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithEmailAndPassword(tEmail, tPassword))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.signInWithEmailAndPassword(tEmail, tPassword);

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      expect(result.user.email, tEmail);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signInWithEmailAndPassword(tEmail, tPassword)).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
      verify(mockSyncManager.queueOperation(any)).called(1);
    });

    test('should return cached user when offline and credentials match', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // act
      final result = await repository.signInWithEmailAndPassword(tEmail, tPassword);

      // assert
      expect(result.success, true);
      expect(result.user.email, tEmail);
      expect(result.message, 'Signed in offline');
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verifyNever(mockRemoteDataSource.signInWithEmailAndPassword(any, any));
    });

    test('should return error when offline and no cached user', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.signInWithEmailAndPassword(tEmail, tPassword);

      // assert
      expect(result.success, false);
      expect(result.message, contains('No internet connection'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verifyNever(mockRemoteDataSource.signInWithEmailAndPassword(any, any));
    });

    test('should return error when offline and cached user email does not match', () async {
      // arrange
      final differentUser = testUser.copyWith();
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => differentUser);

      // act
      final result = await repository.signInWithEmailAndPassword('different@example.com', tPassword);

      // assert
      expect(result.success, false);
      expect(result.message, contains('No internet connection'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
    });
  });

  group('AuthRepositoryImpl - Sign Up with Email and Password', () {
    const tEmail = 'newuser@example.com';
    const tPassword = 'password123';
    const tDisplayName = 'New User';

    test('should sign up with remote data source when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName)).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
      verify(mockSyncManager.queueOperation(any)).called(1);
    });

    test('should return error when offline during registration', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName);

      // assert
      expect(result.success, false);
      expect(result.message, contains('Internet connection required'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signUpWithEmailAndPassword(any, any, any));
    });

    test('should save user locally and queue sync operation on successful registration', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      await repository.signUpWithEmailAndPassword(tEmail, tPassword, tDisplayName);

      // assert
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
      verify(mockSyncManager.queueOperation(argThat(
        predicate<SyncOperation>((op) =>
            op.operationType == SyncOperationType.insert &&
            op.tableName == 'users'
        )
      ))).called(1);
    });
  });

  group('AuthRepositoryImpl - OAuth Sign In', () {
    test('should sign in with Google when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithGoogle())
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.signInWithGoogle();

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signInWithGoogle()).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
    });

    test('should return error when Google sign in attempted offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signInWithGoogle();

      // assert
      expect(result.success, false);
      expect(result.message, contains('Internet connection required for Google'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signInWithGoogle());
    });

    test('should sign in with Facebook when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithFacebook())
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.signInWithFacebook();

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      verify(mockRemoteDataSource.signInWithFacebook()).called(1);
    });

    test('should return error when Facebook sign in attempted offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signInWithFacebook();

      // assert
      expect(result.success, false);
      expect(result.message, contains('Internet connection required for Facebook'));
      verifyNever(mockRemoteDataSource.signInWithFacebook());
    });

    test('should sign in with Apple when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithApple())
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.signInWithApple();

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      verify(mockRemoteDataSource.signInWithApple()).called(1);
    });
  });

  group('AuthRepositoryImpl - Phone Authentication', () {
    const tPhoneNumber = '+237612345678';
    const tVerificationId = 'test-verification-id';
    const tSmsCode = '123456';

    test('should send OTP when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithPhoneNumber(tPhoneNumber))
          .thenAnswer((_) async => tVerificationId);

      // act
      final result = await repository.signInWithPhoneNumber(tPhoneNumber);

      // assert
      expect(result.success, true);
      expect(result.message, tVerificationId);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.signInWithPhoneNumber(tPhoneNumber)).called(1);
    });

    test('should return error when phone sign in attempted offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.signInWithPhoneNumber(tPhoneNumber);

      // assert
      expect(result.success, false);
      expect(result.message, contains('Internet connection required for phone'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.signInWithPhoneNumber(any));
    });

    test('should verify phone number with OTP when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.verifyPhoneNumber(tVerificationId, tSmsCode))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.verifyPhoneNumber(tVerificationId, tSmsCode);

      // assert
      expect(result, testAuthResponse);
      expect(result.success, true);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.verifyPhoneNumber(tVerificationId, tSmsCode)).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
    });

    test('should return error when phone verification attempted offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);

      // act
      final result = await repository.verifyPhoneNumber(tVerificationId, tSmsCode);

      // assert
      expect(result.success, false);
      expect(result.message, contains('Internet connection required for phone verification'));
      verify(mockConnectivity.checkConnectivity()).called(1);
      verifyNever(mockRemoteDataSource.verifyPhoneNumber(any, any));
    });

    test('should handle exception during OTP send', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithPhoneNumber(tPhoneNumber))
          .thenThrow(Exception('Network error'));

      // act
      final result = await repository.signInWithPhoneNumber(tPhoneNumber);

      // assert
      expect(result.success, false);
      expect(result.message, contains('Failed to send verification code'));
      verify(mockRemoteDataSource.signInWithPhoneNumber(tPhoneNumber)).called(1);
    });

    test('should handle exception during OTP verification', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.verifyPhoneNumber(tVerificationId, tSmsCode))
          .thenThrow(Exception('Invalid code'));

      // act
      final result = await repository.verifyPhoneNumber(tVerificationId, tSmsCode);

      // assert
      expect(result.success, false);
      expect(result.message, contains('Failed to verify code'));
      verify(mockRemoteDataSource.verifyPhoneNumber(tVerificationId, tSmsCode)).called(1);
    });
  });

  group('AuthRepositoryImpl - Sign Out', () {
    test('should sign out and clear local data', () async {
      // arrange
      when(mockRemoteDataSource.signOut())
          .thenAnswer((_) async => {});
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(mockLocalDataSource.deleteUser(any))
          .thenAnswer((_) async => {});

      // act
      await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.deleteUser(testUser.id)).called(1);
    });

    test('should handle sign out when no local user exists', () async {
      // arrange
      when(mockRemoteDataSource.signOut())
          .thenAnswer((_) async => {});
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      await repository.signOut();

      // assert
      verify(mockRemoteDataSource.signOut()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verifyNever(mockLocalDataSource.deleteUser(any));
    });
  });

  group('AuthRepositoryImpl - Get Current User', () {
    test('should get current user from remote when online', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, testUser);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
    });

    test('should get current user from local cache when offline', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.none);
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, testUser);
      verify(mockConnectivity.checkConnectivity()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verifyNever(mockRemoteDataSource.getCurrentUser());
    });

    test('should return null when no remote user is available', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, null);
      verify(mockRemoteDataSource.getCurrentUser()).called(1);
      verifyNever(mockLocalDataSource.saveUser(any));
    });
  });

  group('AuthRepositoryImpl - Password Reset', () {
    const tEmail = 'test@example.com';

    test('should send password reset email', () async {
      // arrange
      when(mockRemoteDataSource.sendPasswordResetEmail(tEmail))
          .thenAnswer((_) async => {});

      // act
      await repository.sendPasswordResetEmail(tEmail);

      // assert
      verify(mockRemoteDataSource.sendPasswordResetEmail(tEmail)).called(1);
    });
  });

  group('AuthRepositoryImpl - Update User Profile', () {
    test('should update user profile remotely and cache locally', () async {
      // arrange
      final updatedUser = UserModel(
        id: testUser.id,
        email: testUser.email,
        displayName: 'Updated Name',
        role: testUser.role,
        createdAt: testUser.createdAt,
        isEmailVerified: testUser.isEmailVerified,
      );
      when(mockRemoteDataSource.updateUserProfile(any))
          .thenAnswer((_) async => updatedUser);
      when(mockLocalDataSource.saveUser(updatedUser))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.updateUserProfile(updatedUser);

      // assert
      expect(result.displayName, 'Updated Name');
      verify(mockRemoteDataSource.updateUserProfile(any)).called(1);
      verify(mockLocalDataSource.saveUser(updatedUser)).called(1);
    });
  });

  group('AuthRepositoryImpl - Delete Account', () {
    test('should delete user account remotely and clear local data', () async {
      // arrange
      when(mockRemoteDataSource.deleteUserAccount())
          .thenAnswer((_) async => {});
      when(mockLocalDataSource.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(mockLocalDataSource.deleteUser(any))
          .thenAnswer((_) async => {});

      // act
      await repository.deleteUserAccount();

      // assert
      verify(mockRemoteDataSource.deleteUserAccount()).called(1);
      verify(mockLocalDataSource.getCurrentUser()).called(1);
      verify(mockLocalDataSource.deleteUser(testUser.id)).called(1);
    });
  });

  group('AuthRepositoryImpl - Auth State Changes', () {
    test('should listen to auth state changes and cache user locally', () async {
      // arrange
      when(mockRemoteDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(testUser));
      when(mockLocalDataSource.saveUser(testUser))
          .thenAnswer((_) async => {});

      // act
      final stream = repository.authStateChanges;
      final result = await stream.first;

      // assert
      expect(result, testUser);
      verify(mockLocalDataSource.saveUser(testUser)).called(1);
    });

    test('should handle null user in auth state changes', () async {
      // arrange
      when(mockRemoteDataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      // act
      final stream = repository.authStateChanges;
      final result = await stream.first;

      // assert
      expect(result, null);
      verifyNever(mockLocalDataSource.saveUser(any));
    });
  });

  group('AuthRepositoryImpl - Sync Operations', () {
    test('should queue sync operation with correct data on successful sign in', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      await repository.signInWithEmailAndPassword('test@example.com', 'password');

      // assert
      verify(mockSyncManager.queueOperation(argThat(
        predicate<SyncOperation>((op) =>
            op.operationType == SyncOperationType.update &&
            op.tableName == 'users' &&
            op.recordId == testUser.id &&
            op.data['email'] == testUser.email
        )
      ))).called(1);
    });

    test('should queue sync operation with insert type on registration', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signUpWithEmailAndPassword(any, any, any))
          .thenAnswer((_) async => testAuthResponse);
      when(mockLocalDataSource.saveUser(any))
          .thenAnswer((_) async => {});
      when(mockSyncManager.queueOperation(any))
          .thenAnswer((_) async => {});

      // act
      await repository.signUpWithEmailAndPassword('test@example.com', 'password', 'Test');

      // assert
      verify(mockSyncManager.queueOperation(argThat(
        predicate<SyncOperation>((op) =>
            op.operationType == SyncOperationType.insert &&
            op.tableName == 'users'
        )
      ))).called(1);
    });
  });

  group('AuthRepositoryImpl - Error Scenarios', () {
    test('should handle remote data source exception during sign in', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.signInWithEmailAndPassword(any, any))
          .thenThrow(Exception('Server error'));

      // act & assert
      expect(
        () => repository.signInWithEmailAndPassword('test@example.com', 'password'),
        throwsException,
      );
    });

    test('should handle connectivity check exception', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenThrow(Exception('Connectivity check failed'));

      // act & assert
      expect(
        () => repository.signInWithEmailAndPassword('test@example.com', 'password'),
        throwsException,
      );
    });
  });

  group('AuthRepositoryImpl - isAuthenticated', () {
    test('should check if user is authenticated', () async {
      // arrange
      when(mockRemoteDataSource.isAuthenticated())
          .thenAnswer((_) async => true);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, true);
      verify(mockRemoteDataSource.isAuthenticated()).called(1);
    });

    test('should return false when user is not authenticated', () async {
      // arrange
      when(mockRemoteDataSource.isAuthenticated())
          .thenAnswer((_) async => false);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, false);
      verify(mockRemoteDataSource.isAuthenticated()).called(1);
    });
  });
}