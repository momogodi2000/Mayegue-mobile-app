import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/admin_setup_service.dart';
import '../../core/services/two_factor_auth_service.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/reset_password_usecase.dart';
import '../../features/authentication/domain/usecases/google_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/facebook_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/verify_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/apple_sign_in_usecase.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import '../../features/dashboard/presentation/viewmodels/student_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/teacher_dashboard_viewmodel.dart';
import '../../features/guest/presentation/viewmodels/guest_dashboard_viewmodel.dart';
import 'theme_provider.dart';
import 'locale_provider.dart';

/// Centralized list of all app providers
List<SingleChildWidget> get appProviders => [
  // Core Services
  Provider<FirebaseService>(create: (_) => FirebaseService()),

  // Admin & Security Services
  ProxyProvider<FirebaseService, AdminSetupService>(
    update: (_, firebaseService, __) => AdminSetupService(firebaseService),
  ),
  ProxyProvider<FirebaseService, TwoFactorAuthService>(
    update: (_, firebaseService, __) => TwoFactorAuthService(firebaseService),
  ),

  // Theme & Locale
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),

  // Authentication Data Sources
  ProxyProvider<FirebaseService, AuthRemoteDataSource>(
    update: (_, firebaseService, __) =>
        AuthRemoteDataSourceImpl(firebaseService),
  ),
  Provider<AuthLocalDataSource>(create: (_) => AuthLocalDataSourceImpl()),

  // Authentication Repository
  ProxyProvider2<AuthRemoteDataSource, AuthLocalDataSource, AuthRepository>(
    update: (_, remoteDataSource, localDataSource, __) => AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    ),
  ),

  // Authentication Use Cases
  ProxyProvider<AuthRepository, LoginUsecase>(
    update: (_, repository, __) => LoginUsecase(repository),
  ),
  ProxyProvider<AuthRepository, RegisterUsecase>(
    update: (_, repository, __) => RegisterUsecase(repository),
  ),
  ProxyProvider<AuthRepository, LogoutUsecase>(
    update: (_, repository, __) => LogoutUsecase(repository),
  ),
  ProxyProvider<AuthRepository, GetCurrentUserUsecase>(
    update: (_, repository, __) => GetCurrentUserUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ResetPasswordUsecase>(
    update: (_, repository, __) => ResetPasswordUsecase(repository),
  ),
  ProxyProvider<AuthRepository, GoogleSignInUsecase>(
    update: (_, repository, __) => GoogleSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, FacebookSignInUsecase>(
    update: (_, repository, __) => FacebookSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, AppleSignInUsecase>(
    update: (_, repository, __) => AppleSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ForgotPasswordUsecase>(
    update: (_, repository, __) => ForgotPasswordUsecase(repository),
  ),
  ProxyProvider<AuthRepository, SignInWithPhoneNumberUsecase>(
    update: (_, repository, __) => SignInWithPhoneNumberUsecase(repository),
  ),
  ProxyProvider<AuthRepository, VerifyPhoneNumberUsecase>(
    update: (_, repository, __) => VerifyPhoneNumberUsecase(repository),
  ),

  // Onboarding Data Source
  Provider<OnboardingLocalDataSource>(
    create: (_) => OnboardingLocalDataSourceImpl(),
  ),

  // Onboarding Repository
  ProxyProvider<OnboardingLocalDataSource, OnboardingRepository>(
    update: (_, dataSource, __) =>
        OnboardingRepositoryImpl(localDataSource: dataSource),
  ),

  // Onboarding Use Cases
  ProxyProvider<OnboardingRepository, CompleteOnboardingUsecase>(
    update: (_, repository, __) => CompleteOnboardingUsecase(repository),
  ),
  ProxyProvider<OnboardingRepository, GetOnboardingStatusUsecase>(
    update: (_, repository, __) => GetOnboardingStatusUsecase(repository),
  ),

  // Authentication ViewModel
  ChangeNotifierProxyProvider<LoginUsecase, AuthViewModel>(
    create: (context) => AuthViewModel(
      loginUsecase: context.read<LoginUsecase>(),
      registerUsecase: context.read<RegisterUsecase>(),
      logoutUsecase: context.read<LogoutUsecase>(),
      resetPasswordUsecase: context.read<ResetPasswordUsecase>(),
      getCurrentUserUsecase: context.read<GetCurrentUserUsecase>(),
      googleSignInUsecase: context.read<GoogleSignInUsecase>(),
      facebookSignInUsecase: context.read<FacebookSignInUsecase>(),
      appleSignInUsecase: context.read<AppleSignInUsecase>(),
      forgotPasswordUsecase: context.read<ForgotPasswordUsecase>(),
      getOnboardingStatusUsecase: context.read<GetOnboardingStatusUsecase>(),
      signInWithPhoneNumberUsecase: context
          .read<SignInWithPhoneNumberUsecase>(),
      verifyPhoneNumberUsecase: context.read<VerifyPhoneNumberUsecase>(),
    ),
    update: (_, __, authViewModel) => authViewModel!,
  ),

  // Dashboard ViewModels
  ChangeNotifierProvider<StudentDashboardViewModel>(
    create: (_) => StudentDashboardViewModel(),
  ),
  ChangeNotifierProvider<AdminDashboardViewModel>(
    create: (_) => AdminDashboardViewModel(),
  ),
  ChangeNotifierProvider<TeacherDashboardViewModel>(
    create: (_) => TeacherDashboardViewModel(),
  ),
  ChangeNotifierProvider<GuestDashboardViewModel>(
    create: (_) => GuestDashboardViewModel(),
  ),
];
