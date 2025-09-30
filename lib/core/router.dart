import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../features/authentication/presentation/views/login_view.dart';
import '../features/authentication/presentation/views/register_view.dart';
import '../features/authentication/presentation/views/forgot_password_view.dart';
import '../features/authentication/presentation/views/phone_auth_view.dart';
import '../features/onboarding/presentation/views/splash_view.dart';
import '../features/onboarding/presentation/views/terms_and_conditions_view.dart';
import '../features/onboarding/presentation/views/landing_view.dart';
import '../features/onboarding/presentation/views/onboarding_view.dart';
import '../features/profile/presentation/views/profile_view.dart';
import '../features/lessons/presentation/views/courses_view.dart';
import '../features/dictionary/presentation/views/dictionary_view.dart';
import '../features/games/presentation/views/games_view.dart';
import '../features/assessment/presentation/views/quiz_view.dart';
import '../features/payment/presentation/views/subscription_plans_view.dart';
import '../features/payment/presentation/views/payment_view.dart';
import '../features/payment/presentation/views/payment_processing_view.dart';
import '../features/payment/presentation/views/payment_history_view.dart';
import '../features/languages/presentation/views/languages_list_view.dart';
import '../features/community/presentation/views/social_view.dart';
import '../features/dashboard/presentation/views/admin_dashboard_view.dart';
import '../features/dashboard/presentation/views/teacher_dashboard_view.dart';
import '../features/dashboard/presentation/views/student_dashboard_view.dart';
import 'constants/routes.dart';

/// Global auth refresh notifier
final authRefreshNotifier = _AuthRefreshListenable();

/// App router configuration with Go Router
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: Routes.splash,
      routes: [
        // Authentication routes
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: Routes.register,
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          path: Routes.phoneAuth,
          builder: (context, state) => const PhoneAuthView(),
        ),
        GoRoute(
          path: Routes.forgotPassword,
          builder: (context, state) => const ForgotPasswordView(),
        ),

        // Main app routes (will be protected by auth guard)
        GoRoute(
          path: Routes.dashboard,
          builder: (context, state) => const StudentDashboardView(),
        ),
        GoRoute(
          path: Routes.adminDashboard,
          builder: (context, state) => const AdminDashboardView(),
        ),
        GoRoute(
          path: Routes.teacherDashboard,
          builder: (context, state) => const TeacherDashboardView(),
        ),
        GoRoute(
          path: Routes.languages,
          builder: (context, state) => const LanguagesListView(),
        ),
        GoRoute(
          path: Routes.home,
          redirect: (context, state) =>
              Routes.dashboard, // Redirect home to dashboard
        ),
        GoRoute(
          path: Routes.courses,
          builder: (context, state) => const CoursesView(),
        ),
        GoRoute(
          path: Routes.dictionary,
          builder: (context, state) => const DictionaryView(),
        ),
        GoRoute(
          path: Routes.games,
          builder: (context, state) => const GamesView(),
        ),
        GoRoute(
          path: Routes.quiz,
          builder: (context, state) => const QuizView(),
        ),
        GoRoute(
          path: Routes.community,
          builder: (context, state) => const SocialView(),
        ),
        GoRoute(
          path: Routes.subscriptions,
          builder: (context, state) => const SubscriptionPlansView(),
        ),
        GoRoute(
          path: Routes.payment,
          builder: (context, state) {
            final plan = state.extra as Map<String, dynamic>?;
            return PaymentView(selectedPlan: plan ?? {});
          },
        ),
        GoRoute(
          path: '${Routes.payment}/processing',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final paymentId = args?['paymentId'] as String? ?? '';
            final plan = args?['selectedPlan'] as Map<String, dynamic>? ?? {};
            return PaymentProcessingView(
              paymentId: paymentId,
              selectedPlan: plan,
            );
          },
        ),
        GoRoute(
          path: '${Routes.payment}/history',
          builder: (context, state) => const PaymentHistoryView(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfilPage(nomUtilisateur: 'User'),
        ),
        GoRoute(
          path: Routes.settings,
          builder: (context, state) => const _SettingsPlaceholder(),
        ),

        // Splash and initial flow
        GoRoute(
          path: Routes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: Routes.termsAndConditions,
          builder: (context, state) => const TermsAndConditionsView(),
        ),
        GoRoute(
          path: Routes.landing,
          builder: (context, state) => const LandingView(),
        ),
        GoRoute(
          path: Routes.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
      ],
      redirect: (context, state) {
        final authViewModel = Provider.of<AuthViewModel>(
          context,
          listen: false,
        );
        final isAuthenticated = authViewModel.isAuthenticated;
        final isOnboardingCompleted = authViewModel.isOnboardingCompleted;
        final currentUser = authViewModel.currentUser;

        final isAuthRoute =
            state.matchedLocation == Routes.login ||
            state.matchedLocation == Routes.register ||
            state.matchedLocation == Routes.forgotPassword ||
            state.matchedLocation == Routes.phoneAuth;

        final isSplashRoute = state.matchedLocation == Routes.splash;
        final isOnboardingRoute = state.matchedLocation == Routes.onboarding;
        final isTermsRoute = state.matchedLocation == Routes.termsAndConditions;
        final isLandingRoute = state.matchedLocation == Routes.landing;

        // Allow guest access to certain routes
        final isGuestAllowedRoute =
            isAuthRoute ||
            isSplashRoute ||
            isTermsRoute ||
            isLandingRoute ||
            state.matchedLocation == Routes.dashboard ||
            state.matchedLocation == Routes.languages ||
            state.matchedLocation == Routes.dictionary ||
            state.matchedLocation == Routes.courses;

        // If not authenticated and trying to access protected route, redirect to landing
        if (!isAuthenticated && !isGuestAllowedRoute && !isOnboardingRoute) {
          return Routes.landing;
        }

        // If authenticated and on auth routes, check onboarding status and role
        if (isAuthenticated && isAuthRoute) {
          if (!isOnboardingCompleted) {
            return Routes.onboarding;
          }
          // Redirect to role-based dashboard
          return _getRoleBasedDashboard(currentUser?.role ?? 'learner');
        }

        // If authenticated and on splash, check onboarding status and role
        if (isAuthenticated && isSplashRoute) {
          if (!isOnboardingCompleted) {
            return Routes.onboarding;
          }
          // Redirect to role-based dashboard
          return _getRoleBasedDashboard(currentUser?.role ?? 'learner');
        }

        // If authenticated and on onboarding but onboarding is completed, redirect to role-based dashboard
        if (isAuthenticated && isOnboardingRoute && isOnboardingCompleted) {
          return _getRoleBasedDashboard(currentUser?.role ?? 'learner');
        }

        return null;
      },
      refreshListenable: authRefreshNotifier,
    );
  }

  /// Get role-based dashboard route
  static String _getRoleBasedDashboard(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Routes.adminDashboard;
      case 'teacher':
      case 'instructor':
        return Routes.teacherDashboard;
      case 'learner':
      case 'student':
      default:
        return Routes.dashboard;
    }
  }
}

/// Refresh listener for auth state changes
class _AuthRefreshListenable extends ChangeNotifier {
  void notifyAuthChanged() {
    notifyListeners();
  }
}

/// Placeholder widget for settings route
class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings - Coming Soon')),
    );
  }
}
