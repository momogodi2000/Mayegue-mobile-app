import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/models/user_role.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_response_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/facebook_sign_in_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../domain/usecases/verify_phone_number_usecase.dart';
import '../../domain/usecases/apple_sign_in_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../onboarding/domain/usecases/get_onboarding_status_usecase.dart';

/// Authentication view model
class AuthViewModel extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;
  final GoogleSignInUsecase googleSignInUsecase;
  final FacebookSignInUsecase facebookSignInUsecase;
  final AppleSignInUsecase appleSignInUsecase;
  final ForgotPasswordUsecase forgotPasswordUsecase;
  final GetOnboardingStatusUsecase getOnboardingStatusUsecase;
  final SignInWithPhoneNumberUsecase signInWithPhoneNumberUsecase;
  final VerifyPhoneNumberUsecase verifyPhoneNumberUsecase;

  AuthViewModel({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.resetPasswordUsecase,
    required this.getCurrentUserUsecase,
    required this.googleSignInUsecase,
    required this.facebookSignInUsecase,
    required this.appleSignInUsecase,
    required this.forgotPasswordUsecase,
    required this.getOnboardingStatusUsecase,
    required this.signInWithPhoneNumberUsecase,
    required this.verifyPhoneNumberUsecase,
  });

  // State
  bool _isLoading = false;
  String? _errorMessage;
  UserEntity? _currentUser;
  bool _isOnboardingCompleted = false;
  // Phone number sign-in state
  String? _phoneNumber;
  String? _smsCode;
  String? _verificationId;
  bool _isPhoneAuthInProgress = false;

  String? get phoneNumber => _phoneNumber;
  String? get smsCode => _smsCode;
  String? get verificationId => _verificationId;
  bool get isPhoneAuthInProgress => _isPhoneAuthInProgress;

  // Start phone number sign-in (request OTP)
  Future<bool> signInWithPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();
    _isPhoneAuthInProgress = true;
    _phoneNumber = phoneNumber;
    try {
      final response = await signInWithPhoneNumberUsecase(phoneNumber);
      // Assume response.message contains verificationId if success
      if (response.success == true && response.message != null) {
        _verificationId = response.message;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Erreur lors de l’envoi du code.');
        _setLoading(false);
        _isPhoneAuthInProgress = false;
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      _setLoading(false);
      _isPhoneAuthInProgress = false;
      return false;
    }
  }

  // Verify OTP code
  Future<bool> verifyPhoneNumber(String smsCode) async {
    _setLoading(true);
    _clearError();
    _smsCode = smsCode;
    if (_verificationId == null) {
      _setError('Aucune vérification en cours.');
      _setLoading(false);
      return false;
    }
    try {
      final response = await verifyPhoneNumberUsecase(
        _verificationId!,
        smsCode,
      );
      if (response.success == true) {
        _currentUser = response.user;
        _setLoading(false);
        _isPhoneAuthInProgress = false;
        authRefreshNotifier.notifyAuthChanged();
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Vérification échouée.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur: $e');
      _setLoading(false);
      return false;
    }
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  // Login
  Future<bool> login(String email, String password) async {
    _updateAuthState(loading: true, clearError: true);

    final result = await loginUsecase(email, password);

    return result.fold(
      (failure) {
        _updateAuthState(loading: false, error: _mapFailureToMessage(failure));
        return false;
      },
      (authResponse) {
        _updateAuthState(loading: false, user: authResponse.user);
        authRefreshNotifier.notifyAuthChanged();
        return true;
      },
    );
  }

  // Register
  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    _clearError();

    final result = await registerUsecase(email, password, displayName);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (authResponse) {
        _currentUser = authResponse.user;
        _setLoading(false);
        authRefreshNotifier.notifyAuthChanged();
        notifyListeners();
        return true;
      },
    );
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    return _handleOAuthAuthentication(
      () => googleSignInUsecase(const NoParams()),
    );
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook() async {
    return _handleOAuthAuthentication(
      () => facebookSignInUsecase(const NoParams()),
    );
  }

  // Apple Sign In
  Future<bool> signInWithApple() async {
    return _handleOAuthAuthentication(
      () => appleSignInUsecase(const NoParams()),
    );
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await forgotPasswordUsecase(
      ForgotPasswordParams(email: email),
    );

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  // Logout - Enhanced with proper session clearing
  Future<bool> logout() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await logoutUsecase();

      return result.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          _setLoading(false);
          return false;
        },
        (_) async {
          // Clear all user state
          _currentUser = null;
          _isOnboardingCompleted = false;
          _errorMessage = null;

          // Clear any local storage/cache if needed
          // await _clearLocalCache();

          _setLoading(false);

          // Notify router for redirect
          authRefreshNotifier.notifyAuthChanged();
          notifyListeners();

          if (kDebugMode) {
            print('User logged out successfully, session cleared');
          }

          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
      _setError('Erreur lors de la déconnexion');
      _setLoading(false);
      return false;
    }
  }

  /// Clear local cache/storage (implement if using Hive/SharedPreferences)
  Future<void> _clearLocalCache() async {
    try {
      // Add your cache clearing logic here
      // Example:
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();
      // await Hive.deleteBoxFromDisk('userBox');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing local cache: $e');
      }
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    final result = await resetPasswordUsecase(email);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  // Get current user
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _clearError();

    final result = await getCurrentUserUsecase();

    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
      },
      (user) async {
        _currentUser = user;
        // Check onboarding status when user is loaded
        await checkOnboardingStatus();
        _setLoading(false);
        authRefreshNotifier.notifyAuthChanged();
        notifyListeners();
      },
    );
  }

  // Check onboarding status
  Future<void> checkOnboardingStatus() async {
    final result = await getOnboardingStatusUsecase(const NoParams());

    result.fold(
      (failure) {
        // If there's an error checking onboarding status, assume it's not completed
        _isOnboardingCompleted = false;
      },
      (isCompleted) {
        _isOnboardingCompleted = isCompleted;
      },
    );
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Unified method to handle authentication state changes
  void _updateAuthState({
    UserEntity? user,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    bool shouldNotify = false;

    if (loading != null && _isLoading != loading) {
      _isLoading = loading;
      shouldNotify = true;
    }

    if (clearError && _errorMessage != null) {
      _errorMessage = null;
      shouldNotify = true;
    } else if (error != null && _errorMessage != error) {
      _errorMessage = error;
      shouldNotify = true;
    }

    if (user != _currentUser) {
      _currentUser = user;
      shouldNotify = true;
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Helper method for OAuth authentication
  Future<bool> _handleOAuthAuthentication(
    Future<Either<Failure, AuthResponseEntity>> Function() authFunction,
  ) async {
    _updateAuthState(loading: true, clearError: true);

    final result = await authFunction();

    return result.fold(
      (failure) {
        _updateAuthState(loading: false, error: _mapFailureToMessage(failure));
        return false;
      },
      (authResponse) {
        _updateAuthState(loading: false, user: authResponse.user);
        authRefreshNotifier.notifyAuthChanged();
        return true;
      },
    );
  }

  // Get current user role
  UserRole get currentUserRole {
    if (_currentUser == null) return UserRole.visitor;
    return UserRoleExtension.fromString(_currentUser!.role);
  }

  // Check if user has permission
  bool hasPermission(Permission permission) {
    return currentUserRole.hasPermission(permission);
  }

  // Check if user can access feature
  bool canAccess(Feature feature) {
    return currentUserRole.canAccess(feature);
  }

  // Get appropriate route based on user role
  String getRoleBasedRoute() {
    if (_currentUser == null) return Routes.login;
    return currentUserRole.defaultDashboardRoute;
  }

  // Get navigation items for current user
  List<NavigationItem> getNavigationItems() {
    return currentUserRole.navigationItems;
  }

  // Navigate to role-based dashboard
  void navigateToRoleBasedDashboard(BuildContext context) {
    final route = getRoleBasedRoute();
    GoRouter.of(context).go(route);
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthFailure) {
      return 'Erreur d\'authentification: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Erreur réseau: ${failure.message}';
    } else if (failure is ServerFailure) {
      return 'Erreur serveur: ${failure.message}';
    } else {
      return 'Une erreur s\'est produite: ${failure.message}';
    }
  }
}
