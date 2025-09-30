import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../shared/themes/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithFacebook();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    }
  }

  Future<void> _handleAppleSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithApple();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(Icons.lock, size: 100, color: AppColors.onPrimary),
              const SizedBox(height: 20),

              // Error message display
              if (authViewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (authViewModel.errorMessage != null) const SizedBox(height: 15),

              // Email field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => Validators.getEmailError(value ?? ''),
              ),
              const SizedBox(height: 15),

              // Password field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrez votre mot de passe";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: authViewModel.isLoading ? null : _handleLogin,
                child: authViewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Se connecter",
                        style: TextStyle(fontSize: 18, color: AppColors.onPrimary),
                      ),
              ),
              const SizedBox(height: 15),

              // Social Sign In Buttons
              const Text(
                'Ou continuer avec',
                style: TextStyle(color: AppColors.onPrimary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Google Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/icons/google.png', // You'll need to add this asset
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata),
                ),
                label: const Text('Continuer avec Google'),
              ),
              const SizedBox(height: 10),

              // Facebook Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : _handleFacebookSignIn,
                icon: const Icon(Icons.facebook),
                label: const Text('Continuer avec Facebook'),
              ),
              const SizedBox(height: 10),

              // Apple Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : _handleAppleSignIn,
                icon: const Icon(Icons.apple),
                label: const Text('Continuer avec Apple'),
              ),
              const SizedBox(height: 10),

              // Phone Auth Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary, width: 2),
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : () => context.go(Routes.phoneAuth),
                icon: const Icon(Icons.phone),
                label: const Text('Connexion par SMS'),
              ),
              const SizedBox(height: 15),

              // Register navigation
              TextButton(
                onPressed: () {
                  context.go(Routes.register);
                },
                child: const Text(
                  "Pas encore de compte ? S'inscrire",
                  style: TextStyle(color: AppColors.secondary, fontSize: 16),
                ),
              ),

              // Forgot password
              TextButton(
                onPressed: () {
                  context.go(Routes.forgotPassword);
                },
                child: const Text(
                  "Mot de passe oublié ?",
                  style: TextStyle(color: AppColors.secondary, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
