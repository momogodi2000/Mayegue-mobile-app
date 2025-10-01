import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/environment_config.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/database/database_helper.dart';
import '../../core/sync/general_sync_manager.dart';
import '../../core/services/ai_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/reset_password_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/google_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/facebook_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/apple_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/verify_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import '../../features/onboarding/presentation/viewmodels/onboarding_viewmodel.dart';
import '../providers/theme_provider.dart';
import '../../features/dashboard/presentation/viewmodels/student_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/teacher_dashboard_viewmodel.dart';

/// List of all providers for the application
List<SingleChildWidget> appProviders = [
  // Theme Provider
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),

  // Core services
  Provider<EnvironmentConfig>(create: (_) => EnvironmentConfig()),
  Provider<FirebaseService>(create: (_) => FirebaseService()),
  Provider<StorageService>(create: (_) => StorageService()),
  Provider<DatabaseHelper>(create: (_) => DatabaseHelper.instance),
  Provider<GeneralSyncManager>(
    create: (_) => GeneralSyncManager(networkInfo: NetworkInfo(Connectivity())),
  ),
  Provider<AIService>(
    create: (_) => GeminiAIService(
      apiKey: EnvironmentConfig.geminiApiKey,
    ),
  ),
  Provider<DioClient>(create: (_) => DioClient()),
  Provider<NetworkInfo>(create: (_) => NetworkInfo(Connectivity())),

  // SharedPreferences
  Provider<Future<SharedPreferences>>(
    create: (_) => SharedPreferences.getInstance(),
  ),

  // Connectivity instance
  Provider<Connectivity>(create: (_) => Connectivity()),

  // Connectivity stream
  ProxyProvider<Connectivity, Stream<ConnectivityResult>>(
    update: (_, connectivity, __) => connectivity.onConnectivityChanged,
  ),

  // Onboarding providers - MUST BE BEFORE AuthViewModel
  Provider<OnboardingLocalDataSource>(
    create: (_) => OnboardingLocalDataSourceImpl(),
  ),
  ProxyProvider<OnboardingLocalDataSource, OnboardingRepository>(
    update: (_, localDataSource, __) =>
        OnboardingRepositoryImpl(localDataSource),
  ),
  ProxyProvider<OnboardingRepository, CompleteOnboardingUsecase>(
    update: (_, repository, __) => CompleteOnboardingUsecase(repository),
  ),
  ProxyProvider<OnboardingRepository, GetOnboardingStatusUsecase>(
    update: (_, repository, __) => GetOnboardingStatusUsecase(repository),
  ),
  ProxyProvider2<
    CompleteOnboardingUsecase,
    GetOnboardingStatusUsecase,
    OnboardingViewModel
  >(
    update: (_, complete, getStatus, __) => OnboardingViewModel(
      completeOnboardingUsecase: complete,
      getOnboardingStatusUsecase: getStatus,
    ),
  ),

  // Authentication providers
  ProxyProvider<FirebaseService, AuthRemoteDataSource>(
    update: (_, firebaseService, __) =>
        AuthRemoteDataSourceImpl(firebaseService),
  ),
  Provider<AuthLocalDataSource>(create: (_) => AuthLocalDataSourceImpl()),
  ProxyProvider4<
    AuthRemoteDataSource,
    AuthLocalDataSource,
    Connectivity,
    GeneralSyncManager,
    AuthRepository
  >(
    update: (_, remote, local, connectivity, syncManager, __) =>
        AuthRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: local,
          connectivity: connectivity,
          syncManager: syncManager,
        ),
  ),
  ProxyProvider<AuthRepository, LoginUsecase>(
    update: (_, repository, __) => LoginUsecase(repository),
  ),
  ProxyProvider<AuthRepository, RegisterUsecase>(
    update: (_, repository, __) => RegisterUsecase(repository),
  ),
  ProxyProvider<AuthRepository, LogoutUsecase>(
    update: (_, repository, __) => LogoutUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ResetPasswordUsecase>(
    update: (_, repository, __) => ResetPasswordUsecase(repository),
  ),
  ProxyProvider<AuthRepository, GetCurrentUserUsecase>(
    update: (_, repository, __) => GetCurrentUserUsecase(repository),
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
  ProxyProvider<AuthRepository, SignInWithPhoneNumberUsecase>(
    update: (_, repository, __) => SignInWithPhoneNumberUsecase(repository),
  ),
  ProxyProvider<AuthRepository, VerifyPhoneNumberUsecase>(
    update: (_, repository, __) => VerifyPhoneNumberUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ForgotPasswordUsecase>(
    update: (_, repository, __) => ForgotPasswordUsecase(repository),
  ),
  ChangeNotifierProxyProvider2<
    AuthRepository,
    OnboardingRepository,
    AuthViewModel
  >(
    create: (context) {
      // Create all usecases from repositories
      final authRepo = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(FirebaseService()),
        localDataSource: AuthLocalDataSourceImpl(),
        connectivity: Connectivity(),
        syncManager: GeneralSyncManager(
          networkInfo: NetworkInfo(Connectivity()),
        ),
      );
      final onboardingRepo = OnboardingRepositoryImpl(
        OnboardingLocalDataSourceImpl(),
      );

      return AuthViewModel(
        loginUsecase: LoginUsecase(authRepo),
        registerUsecase: RegisterUsecase(authRepo),
        logoutUsecase: LogoutUsecase(authRepo),
        resetPasswordUsecase: ResetPasswordUsecase(authRepo),
        getCurrentUserUsecase: GetCurrentUserUsecase(authRepo),
        googleSignInUsecase: GoogleSignInUsecase(authRepo),
        facebookSignInUsecase: FacebookSignInUsecase(authRepo),
        appleSignInUsecase: AppleSignInUsecase(authRepo),
        forgotPasswordUsecase: ForgotPasswordUsecase(authRepo),
        getOnboardingStatusUsecase: GetOnboardingStatusUsecase(onboardingRepo),
        signInWithPhoneNumberUsecase: SignInWithPhoneNumberUsecase(authRepo),
        verifyPhoneNumberUsecase: VerifyPhoneNumberUsecase(authRepo),
      );
    },
    update: (context, authRepo, onboardingRepo, previous) {
      // Return existing instance if available, otherwise create new
      if (previous != null) return previous;

      return AuthViewModel(
        loginUsecase: LoginUsecase(authRepo),
        registerUsecase: RegisterUsecase(authRepo),
        logoutUsecase: LogoutUsecase(authRepo),
        resetPasswordUsecase: ResetPasswordUsecase(authRepo),
        getCurrentUserUsecase: GetCurrentUserUsecase(authRepo),
        googleSignInUsecase: GoogleSignInUsecase(authRepo),
        facebookSignInUsecase: FacebookSignInUsecase(authRepo),
        appleSignInUsecase: AppleSignInUsecase(authRepo),
        forgotPasswordUsecase: ForgotPasswordUsecase(authRepo),
        getOnboardingStatusUsecase: GetOnboardingStatusUsecase(onboardingRepo),
        signInWithPhoneNumberUsecase: SignInWithPhoneNumberUsecase(authRepo),
        verifyPhoneNumberUsecase: VerifyPhoneNumberUsecase(authRepo),
      );
    },
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
];

/// Returns the list of app providers for dependency injection
List<SingleChildWidget> getProviders() {
  return appProviders;
}
