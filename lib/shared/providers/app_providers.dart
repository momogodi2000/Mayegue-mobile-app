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

/// List of all providers for the application
List<SingleChildWidget> appProviders = [
  // Core services
  Provider<EnvironmentConfig>(
    create: (_) => EnvironmentConfig(),
  ),
  Provider<FirebaseService>(
    create: (_) => FirebaseService(),
  ),
  Provider<StorageService>(
    create: (_) => StorageService(),
  ),
  Provider<DatabaseHelper>(
    create: (_) => DatabaseHelper.instance,
  ),
  Provider<GeneralSyncManager>(
    create: (_) => GeneralSyncManager(networkInfo: NetworkInfo(Connectivity())),
  ),
  Provider<AIService>(
    create: (_) => GeminiAIService(
        apiKey: 'your-gemini-api-key'), // TODO: Move to environment config
  ),
  Provider<DioClient>(
    create: (_) => DioClient(),
  ),
  Provider<NetworkInfo>(
    create: (_) => NetworkInfo(Connectivity()),
  ),

  // SharedPreferences
  Provider<Future<SharedPreferences>>(
    create: (_) => SharedPreferences.getInstance(),
  ),

  // Connectivity
  StreamProvider<ConnectivityResult>(
    create: (_) => Connectivity().onConnectivityChanged,
    initialData: ConnectivityResult.none,
  ),

  // Authentication providers
  Provider<AuthRemoteDataSource>(
    create: (_) => AuthRemoteDataSourceImpl(FirebaseService()),
  ),
  Provider<AuthLocalDataSource>(
    create: (_) => AuthLocalDataSourceImpl(),
  ),
  ProxyProvider4<AuthRemoteDataSource, AuthLocalDataSource, Connectivity,
      GeneralSyncManager, AuthRepository>(
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
  ChangeNotifierProvider<AuthViewModel>(
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
      signInWithPhoneNumberUsecase:
          context.read<SignInWithPhoneNumberUsecase>(),
      verifyPhoneNumberUsecase: context.read<VerifyPhoneNumberUsecase>(),
    ),
  ),

  // Onboarding providers
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
  ProxyProvider2<CompleteOnboardingUsecase, GetOnboardingStatusUsecase,
      OnboardingViewModel>(
    update: (_, complete, getStatus, __) => OnboardingViewModel(
      completeOnboardingUsecase: complete,
      getOnboardingStatusUsecase: getStatus,
    ),
  ),
];

/// Returns the list of app providers for dependency injection
List<SingleChildWidget> getProviders() {
  return appProviders;
}
