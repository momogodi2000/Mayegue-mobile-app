import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/payment_viewmodel.dart';

/// Payment Processing View - Shows payment status and polls for updates
class PaymentProcessingView extends StatefulWidget {
  final String paymentId;
  final Map<String, dynamic> selectedPlan;

  const PaymentProcessingView({
    super.key,
    required this.paymentId,
    required this.selectedPlan,
  });

  @override
  State<PaymentProcessingView> createState() => _PaymentProcessingViewState();
}

class _PaymentProcessingViewState extends State<PaymentProcessingView> {
  Timer? _statusTimer;
  int _pollingCount = 0;
  static const int maxPollingAttempts = 30; // 30 attempts = ~2.5 minutes
  static const Duration pollingInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _statusTimer = Timer.periodic(pollingInterval, (timer) async {
      if (!mounted) return;

      _pollingCount++;
      final viewModel = context.read<PaymentViewModel>();

      final status = await viewModel.getPaymentStatus(widget.paymentId);

      if (status != null) {
        final statusLower = status.toLowerCase();
        if (statusLower == 'completed' || statusLower == 'success') {
          _onPaymentSuccess();
        } else if (statusLower == 'failed' || statusLower == 'cancelled') {
          _onPaymentFailed();
        }
      }

      // Stop polling after max attempts
      if (_pollingCount >= maxPollingAttempts) {
        _onPaymentTimeout();
      }
    });
  }

  void _onPaymentSuccess() {
    _statusTimer?.cancel();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/payment/success',
        arguments: widget.selectedPlan,
      );
    }
  }

  void _onPaymentFailed() {
    _statusTimer?.cancel();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le paiement a échoué. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // Go back to payment form
    }
  }

  void _onPaymentTimeout() {
    _statusTimer?.cancel();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Paiement en attente'),
          content: const Text(
            'Le paiement prend plus de temps que prévu. Vérifiez votre application mobile money et réessayez plus tard.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to payment form
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Processing Animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(height: 32),

              // Processing Title
              Text(
                'Traitement du paiement...',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Processing Message
              Text(
                'Veuillez confirmer le paiement sur votre application mobile money.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Plan Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Montant: ${widget.selectedPlan['price']} ${widget.selectedPlan['currency']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plan: ${widget.selectedPlan['name']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Ouvrez votre application mobile money\n'
                      '2. Acceptez la demande de paiement\n'
                      '3. Entrez votre code PIN\n'
                      '4. Attendez la confirmation',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Cancel Button
              TextButton(
                onPressed: () {
                  _statusTimer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Annuler le paiement',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
