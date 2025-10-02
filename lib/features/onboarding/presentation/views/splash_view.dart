import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../core/services/terms_service.dart';
import '../../../../core/services/admin_initialization_service.dart';

/// Splash screen with Lottie animation
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    final authViewModel = context.read<AuthViewModel>();

    try {
      // PRIORITY 1: Check if admin setup is needed (first launch)
      final needsAdminSetup =
          await AdminInitializationService.checkAndInitializeAdmin().catchError((error) {
        debugPrint('Error checking admin initialization: $error');
        return false; // Default to no admin setup needed
      });

      if (!mounted) return;

      if (needsAdminSetup) {
        // No admin exists - redirect to admin setup
        context.go('/admin-setup');
        return;
      }

      // PRIORITY 2: Check if user has accepted terms
      final hasAcceptedTerms = await TermsService.hasAcceptedTerms().catchError((error) {
        debugPrint('Error checking terms acceptance: $error');
        return false; // Default to terms not accepted
      });

      if (!mounted) return;

      // PRIORITY 3: Check if user is already authenticated
      if (authViewModel.isAuthenticated) {
        // Navigate to role-based dashboard
        final userRole = authViewModel.currentUser?.role ?? 'learner';
        switch (userRole.toLowerCase()) {
          case 'admin':
            context.go('/admin-dashboard');
            break;
          case 'teacher':
          case 'instructor':
            context.go('/teacher-dashboard');
            break;
          case 'learner':
          case 'student':
          default:
            context.go('/dashboard');
            break;
        }
      } else {
        // Show terms only if not yet accepted
        if (!hasAcceptedTerms) {
          context.go('/terms-and-conditions');
        } else {
          // Skip terms and go to landing page
          context.go('/landing');
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Critical error in navigation: $error');
      debugPrint('Stack trace: $stackTrace');

      // Fallback navigation - go to landing page if everything fails
      if (mounted) {
        context.go('/landing');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    'assets/logo/logo.jpg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return const Icon(
                        Icons.language,
                        size: 100,
                        color: Colors.green,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App name
              Text(
                'Ma\'a yegue',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                ),
              ),

              const SizedBox(height: 8),

              // App tagline
              Text(
                'Langues Traditionnelles Camerounaises',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
