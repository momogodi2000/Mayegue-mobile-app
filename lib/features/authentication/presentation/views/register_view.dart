import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../shared/themes/colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final displayName = '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.register(
      emailController.text.trim(),
      passwordController.text,
      displayName,
    );

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
        title: const Text("Inscription"),
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
              const Icon(Icons.school, size: 100, color: AppColors.onPrimary),
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

              // First name field
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  labelText: "Prénom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => Validators.getNameError(value ?? ''),
              ),
              const SizedBox(height: 15),

              // Last name field
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline),
                  labelText: "Nom",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => Validators.getNameError(value ?? ''),
              ),
              const SizedBox(height: 15),

              // Age field
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.cake),
                  labelText: "Âge (optionnel)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // Age is optional
                  final age = int.tryParse(value);
                  if (age == null || age < 5 || age > 120) {
                    return "Entrez un âge valide (5-120)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

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
                validator: (value) => Validators.getPasswordError(value ?? ''),
              ),
              const SizedBox(height: 25),

              // Register button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: authViewModel.isLoading ? null : _handleRegister,
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
                        "S'inscrire",
                        style: TextStyle(fontSize: 18, color: AppColors.onPrimary),
                      ),
              ),
              const SizedBox(height: 15),

              // Login navigation
              TextButton(
                onPressed: () {
                  context.go(Routes.login);
                },
                child: const Text(
                  "Déjà inscrit ? Se connecter",
                  style: TextStyle(color: AppColors.secondary, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
