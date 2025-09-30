import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/themes/colors.dart';
import '../viewmodels/auth_viewmodel.dart';

class PhoneAuthView extends StatefulWidget {
  const PhoneAuthView({super.key});

  @override
  State<PhoneAuthView> createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  final _phoneFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _isOtpSent = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final phoneNumber =
        '+237${phoneController.text.trim()}'; // Assuming Cameroon prefix

    final success = await authViewModel.signInWithPhoneNumber(phoneNumber);

    if (success && mounted) {
      setState(() {
        _isOtpSent = true;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success =
        await authViewModel.verifyPhoneNumber(otpController.text.trim());

    if (success && mounted) {
      // Navigation will be handled by the router
      authViewModel.navigateToRoleBasedDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Authentification Téléphone"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.login),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryLight, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isOtpSent
                    ? _buildOtpForm(authViewModel)
                    : _buildPhoneForm(authViewModel),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneForm(AuthViewModel authViewModel) {
    return Form(
      key: _phoneFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.phone_android,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Connexion par SMS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Entrez votre numéro de téléphone pour recevoir un code de vérification',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '6XXXXXXXX',
              prefixText: '+237 ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro';
              }
              if (value.length != 9) {
                return 'Numéro invalide (9 chiffres)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (authViewModel.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.76)),
              ),
              child: Text(
                authViewModel.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: authViewModel.isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: authViewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Envoyer le code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(AuthViewModel authViewModel) {
    return Form(
      key: _otpFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sms,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          const Text(
            'Vérification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Code envoyé au +237${phoneController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Code de vérification',
              hintText: '000000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le code';
              }
              if (value.length != 6) {
                return 'Code invalide (6 chiffres)';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (authViewModel.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.76)),
              ),
              child: Text(
                authViewModel.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: authViewModel.isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: authViewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Vérifier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _isOtpSent = false;
              });
            },
            child: const Text(
              'Changer de numéro',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
