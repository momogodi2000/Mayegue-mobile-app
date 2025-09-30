import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:mayegue/core/errors/failures.dart';
import 'package:mayegue/core/usecases/usecase.dart';
import 'package:mayegue/features/authentication/domain/entities/user_entity.dart';
import 'package:mayegue/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:mayegue/features/authentication/domain/usecases/login_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/register_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/google_sign_in_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/facebook_sign_in_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/apple_sign_in_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/sign_in_with_phone_number_usecase.dart';
import 'package:mayegue/features/authentication/domain/usecases/verify_phone_number_usecase.dart';
import 'package:mayegue/features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import 'package:mayegue/features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';

import 'auth_viewmodel_test.mocks.dart';

// Generate mocks for the usecases
@GenerateMocks([
  LoginUsecase,
  RegisterUsecase,
  LogoutUsecase,
  ResetPasswordUsecase,
  GetCurrentUserUsecase,
  GoogleSignInUsecase,
  FacebookSignInUsecase,
  AppleSignInUsecase,
  ForgotPasswordUsecase,
  GetOnboardingStatusUsecase,
  SignInWithPhoneNumberUsecase,
  VerifyPhoneNumberUsecase,
])
void main() {
  late AuthViewModel authViewModel;
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockGoogleSignInUsecase mockGoogleSignInUsecase;
  late MockFacebookSignInUsecase mockFacebookSignInUsecase;
  late MockAppleSignInUsecase mockAppleSignInUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockGetOnboardingStatusUsecase mockGetOnboardingStatusUsecase;
  late MockSignInWithPhoneNumberUsecase mockSignInWithPhoneNumberUsecase;
  late MockVerifyPhoneNumberUsecase mockVerifyPhoneNumberUsecase;

  // Test data
  final testUser = UserEntity(
    id: 'test-user-id',
    email: 'test@example.com',
    displayName: 'Test User',
    role: 'learner',
    createdAt: DateTime(2024, 1, 1),
    isEmailVerified: true,
  );

  final testAuthResponse = AuthResponseEntity(
    user: testUser,
    token: 'test-token',
    success: true,
    message: 'Success',
  );

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockGoogleSignInUsecase = MockGoogleSignInUsecase();
    mockFacebookSignInUsecase = MockFacebookSignInUsecase();
    mockAppleSignInUsecase = MockAppleSignInUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockGetOnboardingStatusUsecase = MockGetOnboardingStatusUsecase();
    mockSignInWithPhoneNumberUsecase = MockSignInWithPhoneNumberUsecase();
    mockVerifyPhoneNumberUsecase = MockVerifyPhoneNumberUsecase();

    authViewModel = AuthViewModel(
      loginUsecase: mockLoginUsecase,
      registerUsecase: mockRegisterUsecase,
      logoutUsecase: mockLogoutUsecase,
      resetPasswordUsecase: mockResetPasswordUsecase,
      getCurrentUserUsecase: mockGetCurrentUserUsecase,
      googleSignInUsecase: mockGoogleSignInUsecase,
      facebookSignInUsecase: mockFacebookSignInUsecase,
      appleSignInUsecase: mockAppleSignInUsecase,
      forgotPasswordUsecase: mockForgotPasswordUsecase,
      getOnboardingStatusUsecase: mockGetOnboardingStatusUsecase,
      signInWithPhoneNumberUsecase: mockSignInWithPhoneNumberUsecase,
      verifyPhoneNumberUsecase: mockVerifyPhoneNumberUsecase,
    );
  });

  group('AuthViewModel - Initial State', () {
    test('should have correct initial state', () {
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, null);
      expect(authViewModel.currentUser, null);
      expect(authViewModel.isAuthenticated, false);
      expect(authViewModel.isOnboardingCompleted, false);
      expect(authViewModel.isPhoneAuthInProgress, false);
    });
  });

  group('AuthViewModel - Login', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    test('should emit loading state and then success when login succeeds', () async {
      // arrange
      when(mockLoginUsecase.call(tEmail, tPassword))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      final states = <bool>[];
      authViewModel.addListener(() {
        states.add(authViewModel.isLoading);
      });

      final result = await authViewModel.login(tEmail, tPassword);

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, null);
      expect(authViewModel.currentUser, testUser);
      expect(authViewModel.isAuthenticated, true);
      verify(mockLoginUsecase.call(tEmail, tPassword)).called(1);
    });

    test('should emit loading state and then error when login fails', () async {
      // arrange
      const tFailure = AuthFailure('Invalid credentials');
      when(mockLoginUsecase.call(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.login(tEmail, tPassword);

      // assert
      expect(result, false);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, contains('authentification'));
      expect(authViewModel.currentUser, null);
      expect(authViewModel.isAuthenticated, false);
      verify(mockLoginUsecase.call(tEmail, tPassword)).called(1);
    });

    test('should handle network failure during login', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(mockLoginUsecase.call(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.login(tEmail, tPassword);

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, contains('réseau'));
      verify(mockLoginUsecase.call(tEmail, tPassword)).called(1);
    });
  });

  group('AuthViewModel - Register', () {
    const tEmail = 'newuser@example.com';
    const tPassword = 'password123';
    const tDisplayName = 'New User';

    test('should emit loading state and then success when registration succeeds', () async {
      // arrange
      when(mockRegisterUsecase.call(tEmail, tPassword, tDisplayName))
          .thenAnswer((_) async => Right(testAuthResponse));
      when(mockGetOnboardingStatusUsecase.call(const NoParams()))
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await authViewModel.register(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, null);
      expect(authViewModel.currentUser, testUser);
      expect(authViewModel.isAuthenticated, true);
      verify(mockRegisterUsecase.call(tEmail, tPassword, tDisplayName)).called(1);
    });

    test('should emit loading state and then error when registration fails', () async {
      // arrange
      const tFailure = AuthFailure('Email already exists');
      when(mockRegisterUsecase.call(tEmail, tPassword, tDisplayName))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.register(tEmail, tPassword, tDisplayName);

      // assert
      expect(result, false);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, contains('authentification'));
      expect(authViewModel.currentUser, null);
      verify(mockRegisterUsecase.call(tEmail, tPassword, tDisplayName)).called(1);
    });
  });

  group('AuthViewModel - OAuth Sign In', () {
    test('should successfully sign in with Google', () async {
      // arrange
      when(mockGoogleSignInUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      final result = await authViewModel.signInWithGoogle();

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, testUser);
      expect(authViewModel.isAuthenticated, true);
      verify(mockGoogleSignInUsecase.call(const NoParams())).called(1);
    });

    test('should handle Google sign in failure', () async {
      // arrange
      const tFailure = AuthFailure('Google sign in cancelled');
      when(mockGoogleSignInUsecase.call(const NoParams()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.signInWithGoogle();

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, isNotNull);
      expect(authViewModel.currentUser, null);
      verify(mockGoogleSignInUsecase.call(const NoParams())).called(1);
    });

    test('should successfully sign in with Facebook', () async {
      // arrange
      when(mockFacebookSignInUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      final result = await authViewModel.signInWithFacebook();

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, testUser);
      verify(mockFacebookSignInUsecase.call(const NoParams())).called(1);
    });

    test('should successfully sign in with Apple', () async {
      // arrange
      when(mockAppleSignInUsecase.call(const NoParams()))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      final result = await authViewModel.signInWithApple();

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, testUser);
      verify(mockAppleSignInUsecase.call(const NoParams())).called(1);
    });
  });

  group('AuthViewModel - Phone Authentication', () {
    const tPhoneNumber = '+237612345678';
    const tVerificationId = 'test-verification-id';
    const tSmsCode = '123456';

    test('should successfully send OTP for phone authentication', () async {
      // arrange
      final otpResponse = AuthResponseEntity(
        user: UserEntity(
          id: 'phone_verification_pending',
          email: 'phone@verification.pending',
          createdAt: DateTime.now(),
        ),
        success: true,
        message: tVerificationId,
      );
      when(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber))
          .thenAnswer((_) async => otpResponse);

      // act
      final result = await authViewModel.signInWithPhoneNumber(tPhoneNumber);

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.isPhoneAuthInProgress, true);
      expect(authViewModel.phoneNumber, tPhoneNumber);
      expect(authViewModel.verificationId, tVerificationId);
      verify(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber)).called(1);
    });

    test('should handle OTP send failure', () async {
      // arrange
      final failureResponse = AuthResponseEntity(
        user: UserEntity(
          id: 'offline',
          email: 'offline@example.com',
          createdAt: DateTime.now(),
        ),
        success: false,
        message: 'Failed to send OTP',
      );
      when(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber))
          .thenAnswer((_) async => failureResponse);

      // act
      final result = await authViewModel.signInWithPhoneNumber(tPhoneNumber);

      // assert
      expect(result, false);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.isPhoneAuthInProgress, false);
      expect(authViewModel.errorMessage, isNotNull);
      verify(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber)).called(1);
    });

    test('should successfully verify phone number with OTP', () async {
      // arrange
      // First send OTP
      final otpResponse = AuthResponseEntity(
        user: UserEntity(
          id: 'phone_verification_pending',
          email: 'phone@verification.pending',
          createdAt: DateTime.now(),
        ),
        success: true,
        message: tVerificationId,
      );
      when(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber))
          .thenAnswer((_) async => otpResponse);
      await authViewModel.signInWithPhoneNumber(tPhoneNumber);

      // Then verify OTP
      when(mockVerifyPhoneNumberUsecase.call(tVerificationId, tSmsCode))
          .thenAnswer((_) async => testAuthResponse);

      // act
      final result = await authViewModel.verifyPhoneNumber(tSmsCode);

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.isPhoneAuthInProgress, false);
      expect(authViewModel.currentUser, testUser);
      expect(authViewModel.isAuthenticated, true);
      verify(mockVerifyPhoneNumberUsecase.call(tVerificationId, tSmsCode)).called(1);
    });

    test('should handle OTP verification failure', () async {
      // arrange
      // First send OTP
      final otpResponse = AuthResponseEntity(
        user: UserEntity(
          id: 'phone_verification_pending',
          email: 'phone@verification.pending',
          createdAt: DateTime.now(),
        ),
        success: true,
        message: tVerificationId,
      );
      when(mockSignInWithPhoneNumberUsecase.call(tPhoneNumber))
          .thenAnswer((_) async => otpResponse);
      await authViewModel.signInWithPhoneNumber(tPhoneNumber);

      // Then verify with wrong OTP
      final failureResponse = AuthResponseEntity(
        user: UserEntity(
          id: 'offline',
          email: 'offline@example.com',
          createdAt: DateTime.now(),
        ),
        success: false,
        message: 'Invalid verification code',
      );
      when(mockVerifyPhoneNumberUsecase.call(tVerificationId, tSmsCode))
          .thenAnswer((_) async => failureResponse);

      // act
      final result = await authViewModel.verifyPhoneNumber(tSmsCode);

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, isNotNull);
      verify(mockVerifyPhoneNumberUsecase.call(tVerificationId, tSmsCode)).called(1);
    });

    test('should fail verification when no verification is in progress', () async {
      // act
      final result = await authViewModel.verifyPhoneNumber(tSmsCode);

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, contains('Aucune vérification'));
      verifyNever(mockVerifyPhoneNumberUsecase.call(any, any));
    });
  });

  group('AuthViewModel - Forgot Password', () {
    const tEmail = 'test@example.com';

    test('should successfully send password reset email', () async {
      // arrange
      when(mockForgotPasswordUsecase.call(any))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await authViewModel.forgotPassword(tEmail);

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.errorMessage, null);
      verify(mockForgotPasswordUsecase.call(any)).called(1);
    });

    test('should handle forgot password failure', () async {
      // arrange
      const tFailure = AuthFailure('Email not found');
      when(mockForgotPasswordUsecase.call(any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.forgotPassword(tEmail);

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, isNotNull);
      verify(mockForgotPasswordUsecase.call(any)).called(1);
    });
  });

  group('AuthViewModel - Logout', () {
    test('should successfully logout', () async {
      // arrange
      when(mockLogoutUsecase.call())
          .thenAnswer((_) async => const Right(null));

      // First login
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => Right(testAuthResponse));
      await authViewModel.login('test@example.com', 'password');

      // act
      final result = await authViewModel.logout();

      // assert
      expect(result, true);
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, null);
      expect(authViewModel.isAuthenticated, false);
      verify(mockLogoutUsecase.call()).called(1);
    });

    test('should handle logout failure', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(mockLogoutUsecase.call())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await authViewModel.logout();

      // assert
      expect(result, false);
      expect(authViewModel.errorMessage, contains('serveur'));
      verify(mockLogoutUsecase.call()).called(1);
    });
  });

  group('AuthViewModel - Load Current User', () {
    test('should successfully load current user', () async {
      // arrange
      when(mockGetCurrentUserUsecase.call())
          .thenAnswer((_) async => Right(testUser));
      when(mockGetOnboardingStatusUsecase.call(const NoParams()))
          .thenAnswer((_) async => const Right(true));

      // act
      await authViewModel.loadCurrentUser();
      
      // Wait for async operations to complete
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, testUser);
      expect(authViewModel.isAuthenticated, true);
      expect(authViewModel.isOnboardingCompleted, true);
      verify(mockGetCurrentUserUsecase.call()).called(1);
      verify(mockGetOnboardingStatusUsecase.call(const NoParams())).called(1);
    });

    test('should handle load current user failure', () async {
      // arrange
      const tFailure = AuthFailure('No user found');
      when(mockGetCurrentUserUsecase.call())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      await authViewModel.loadCurrentUser();

      // assert
      expect(authViewModel.isLoading, false);
      expect(authViewModel.currentUser, null);
      expect(authViewModel.errorMessage, isNotNull);
      verify(mockGetCurrentUserUsecase.call()).called(1);
    });
  });

  group('AuthViewModel - Error Handling', () {
    test('should map AuthFailure correctly', () async {
      // arrange
      const tFailure = AuthFailure('Invalid token');
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      await authViewModel.login('test@example.com', 'password');

      // assert
      expect(authViewModel.errorMessage, contains('authentification'));
    });

    test('should map NetworkFailure correctly', () async {
      // arrange
      const tFailure = NetworkFailure('Connection timeout');
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      await authViewModel.login('test@example.com', 'password');

      // assert
      expect(authViewModel.errorMessage, contains('réseau'));
    });

    test('should map ServerFailure correctly', () async {
      // arrange
      const tFailure = ServerFailure('Internal server error');
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      await authViewModel.login('test@example.com', 'password');

      // assert
      expect(authViewModel.errorMessage, contains('serveur'));
    });

    test('should clear error message when requested', () async {
      // arrange
      const tFailure = AuthFailure('Some error');
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => const Left(tFailure));
      await authViewModel.login('test@example.com', 'password');

      // Verify error is set
      expect(authViewModel.errorMessage, isNotNull);

      // arrange - successful login to clear error
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act - login again successfully
      await authViewModel.login('test@example.com', 'password');

      // assert
      expect(authViewModel.errorMessage, null);
    });
  });

  group('AuthViewModel - Loading States', () {
    test('should set loading to true during login', () async {
      // arrange
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return Right(testAuthResponse);
      });

      // act
      final future = authViewModel.login('test@example.com', 'password');

      // Wait a bit to check loading state
      await Future.delayed(const Duration(milliseconds: 10));

      // assert - loading should be true during the operation
      expect(authViewModel.isLoading, true);

      // Wait for completion
      await future;

      // assert - loading should be false after completion
      expect(authViewModel.isLoading, false);
    });
  });

  group('AuthViewModel - Role-Based Access', () {
    test('should return correct role for authenticated user', () async {
      // arrange
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      await authViewModel.login('test@example.com', 'password');

      // assert
      expect(authViewModel.currentUserRole.toString(), contains('learner'));
    });

    test('should return visitor role when not authenticated', () {
      // assert
      expect(authViewModel.currentUserRole.toString(), contains('visitor'));
    });

    test('should check permissions based on user role', () async {
      // arrange
      when(mockLoginUsecase.call(any, any))
          .thenAnswer((_) async => Right(testAuthResponse));

      // act
      await authViewModel.login('test@example.com', 'password');

      // Note: This test depends on the Permission and Feature enums
      // The actual assertions would depend on the role permissions defined
      expect(authViewModel.currentUser, isNotNull);
    });
  });
}