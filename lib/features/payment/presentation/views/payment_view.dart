import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../viewmodels/payment_viewmodel.dart';
import '../widgets/payment_form.dart';

/// Payment View
class PaymentView extends StatefulWidget {
  final Map<String, dynamic> selectedPlan;

  const PaymentView({
    super.key,
    required this.selectedPlan,
  });

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedMethod = 'campay';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Summary
                _buildPlanSummary(),
                const SizedBox(height: 24),

                // Payment Form
                PaymentForm(
                  formKey: _formKey,
                  phoneController: _phoneController,
                  selectedMethod: _selectedMethod,
                  onMethodChanged: (method) {
                    setState(() => _selectedMethod = method);
                  },
                ),
                const SizedBox(height: 32),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Payer maintenant'),
                  ),
                ),

                // Error Message
                if (viewModel.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Success Message
                if (viewModel.successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      viewModel.successMessage!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de la commande',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.selectedPlan['name'] ?? ''),
                Text(
                  '${widget.selectedPlan['price']} ${widget.selectedPlan['currency']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<PaymentViewModel>();
    viewModel
        .processPayment(
      userId: 'current_user_id', // TODO: Get from auth provider
      amount: widget.selectedPlan['price'] ?? 0.0,
      method: _selectedMethod,
      phoneNumber: _phoneController.text,
    )
        .then((_) {
      if (mounted &&
          viewModel.successMessage != null &&
          viewModel.lastProcessedPayment != null) {
        // Navigate to processing view with actual payment ID
        context.go(
          '${Routes.payment}/processing',
          extra: {
            'paymentId': viewModel.lastProcessedPayment!.id,
            'selectedPlan': widget.selectedPlan,
          },
        );
      }
    });
  }
}
