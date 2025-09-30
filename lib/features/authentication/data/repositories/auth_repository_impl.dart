import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/sync/general_sync_manager.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository with offline support
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;
  final GeneralSyncManager syncManager;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
    required this.syncManager,
  });

  /// Helper method to create offline error response
  AuthResponseEntity _createOfflineErrorResponse(String message, {String? email}) {
    final dummyUser = UserEntity(
      id: 'offline',
      email: email ?? 'offline@example.com',
      createdAt: DateTime.now(),
    );
    return AuthResponseEntity(
      user: dummyUser,
      success: false,
      message: message,
    );
  }

  /// Helper method to handle successful authentication and sync
  Future<void> _handleSuccessfulAuth(AuthResponseEntity result) async {
    if (result.success) {
      await localDataSource.saveUser(result.user);
      await _queueUserSyncOperation(result.user, SyncOperationType.update);
    }
  }

  /// Helper method to queue sync operation for user
  Future<void> _queueUserSyncOperation(UserEntity user, SyncOperationType operationType) async {
    await syncManager.queueOperation(SyncOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      operationType: operationType,
      tableName: 'users',
      recordId: user.id,
      data: {
        'email': user.email,
        'displayName': user.displayName,
        'lastLoginAt': DateTime.now().toIso8601String(),
        if (operationType == SyncOperationType.insert) 'createdAt': user.createdAt.toIso8601String(),
      },
      timestamp: DateTime.now(),
    ));
  }

  /// Helper method to check connectivity
  Future<bool> _isOffline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }

  /// Helper method for OAuth sign-in methods
  Future<AuthResponseEntity> _handleOAuthSignIn(
    Future<AuthResponseEntity> Function() remoteSignIn,
    String serviceName,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for $serviceName sign-in',
      );
    }

    final result = await remoteSignIn();
    await _handleSuccessfulAuth(result);
    return result;
  }

  @override
  Future<AuthResponseEntity> signInWithEmailAndPassword(String email, String password) async {
    if (await _isOffline()) {
      // Offline mode - try to get cached user
      final cachedUser = await localDataSource.getCurrentUser();
      if (cachedUser != null && cachedUser.email == email) {
        return AuthResponseEntity(
          user: cachedUser,
          success: true,
          message: 'Signed in offline',
        );
      } else {
        return _createOfflineErrorResponse(
          'No internet connection and no cached credentials',
          email: email,
        );
      }
    }

    // Online mode
    final result = await remoteDataSource.signInWithEmailAndPassword(email, password);
    await _handleSuccessfulAuth(result);
    return result;
  }

  @override
  Future<AuthResponseEntity> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse(
        'Internet connection required for registration',
        email: email,
      );
    }

    final result = await remoteDataSource.signUpWithEmailAndPassword(
      email,
      password,
      displayName,
    );

    if (result.success) {
      await localDataSource.saveUser(result.user);
      await _queueUserSyncOperation(result.user, SyncOperationType.insert);
    }

    return result;
  }

  @override
  Future<AuthResponseEntity> signInWithGoogle() async {
    return _handleOAuthSignIn(() => remoteDataSource.signInWithGoogle(), 'Google');
  }

  @override
  Future<AuthResponseEntity> signInWithFacebook() async {
    return _handleOAuthSignIn(() => remoteDataSource.signInWithFacebook(), 'Facebook');
  }

  @override
  Future<AuthResponseEntity> signInWithApple() async {
    return _handleOAuthSignIn(() => remoteDataSource.signInWithApple(), 'Apple');
  }

  // Add remaining methods from the interface
  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    // Clear local user data
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await localDataSource.deleteUser(currentUser.id);
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return await localDataSource.getCurrentUser();
    }

    final remoteUser = await remoteDataSource.getCurrentUser();
    if (remoteUser != null) {
      await localDataSource.saveUser(remoteUser);
    }
    return remoteUser;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await remoteDataSource.isAuthenticated();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<UserEntity> updateUserProfile(UserEntity user) async {
    final result = await remoteDataSource.updateUserProfile(
      UserModel(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoUrl,
        role: user.role,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
        isEmailVerified: user.isEmailVerified,
        preferences: user.preferences,
      ),
    );

    await localDataSource.saveUser(result);
    return result;
  }

  @override
  Future<void> deleteUserAccount() async {
    await remoteDataSource.deleteUserAccount();
    final currentUser = await localDataSource.getCurrentUser();
    if (currentUser != null) {
      await localDataSource.deleteUser(currentUser.id);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        localDataSource.saveUser(userModel);
      }
      return userModel;
    });
  }

  @override
  Future<AuthResponseEntity> signInWithPhoneNumber(String phoneNumber) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse('Internet connection required for phone sign-in');
    }

    try {
      // Call remote datasource to send OTP and get verification ID
      final verificationId = await remoteDataSource.signInWithPhoneNumber(phoneNumber);

      // Return a response with the verification ID in the message
      // The UI will use this to proceed to the OTP verification screen
      final dummyUser = UserEntity(
        id: 'phone_verification_pending',
        email: 'phone@verification.pending',
        createdAt: DateTime.now(),
      );

      return AuthResponseEntity(
        user: dummyUser,
        success: true,
        message: verificationId, // Return verification ID in message field
      );
    } catch (e) {
      return _createOfflineErrorResponse(
        'Failed to send verification code: ${e.toString()}',
      );
    }
  }

  @override
  Future<AuthResponseEntity> verifyPhoneNumber(String verificationId, String smsCode) async {
    if (await _isOffline()) {
      return _createOfflineErrorResponse('Internet connection required for phone verification');
    }

    try {
      // Call remote datasource to verify the OTP code
      final result = await remoteDataSource.verifyPhoneNumber(verificationId, smsCode);

      // Handle successful authentication
      await _handleSuccessfulAuth(result);

      return result;
    } catch (e) {
      return _createOfflineErrorResponse(
        'Failed to verify code: ${e.toString()}',
      );
    }
  }
}
