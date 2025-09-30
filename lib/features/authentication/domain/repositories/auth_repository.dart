import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_response_entity.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with email and password
  Future<AuthResponseEntity> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<AuthResponseEntity> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  );

  /// Sign in with Google
  Future<AuthResponseEntity> signInWithGoogle();

  /// Sign in with Facebook
  Future<AuthResponseEntity> signInWithFacebook();

  /// Sign in with Apple
  Future<AuthResponseEntity> signInWithApple();

  /// Sign in with phone number
  Future<AuthResponseEntity> signInWithPhoneNumber(String phoneNumber);

  /// Verify phone number with OTP
  Future<AuthResponseEntity> verifyPhoneNumber(String verificationId, String smsCode);

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Sign out
  Future<void> signOut();

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Update user profile
  Future<UserEntity> updateUserProfile(UserEntity user);

  /// Delete user account
  Future<void> deleteUserAccount();

  /// Stream of authentication state changes
  Stream<UserEntity?> get authStateChanges;
}
