import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../viewmodels/subscription_viewmodel.dart';

/// Payment Success View
class PaymentSuccessView extends StatefulWidget {
  final Map<String, dynamic> selectedPlan;
  const PaymentSuccessView({
    super.key,
    required this.selectedPlan,
  });
  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
  @override
  void initState() {
    super.initState();
    // Create subscription when success view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createSubscription();
    });
  }

  Future<void> _createSubscription() async {
    final subscriptionViewModel = context.read<SubscriptionViewModel>();
    try {
      await subscriptionViewModel.createSubscription(
        userId: 'current_user_id', // TODO: Get from auth
        planId: widget.selectedPlan['id'] ?? '',
        planName: widget.selectedPlan['name'] ?? '',
        price: (widget.selectedPlan['price'] ?? 0).toDouble(),
        interval: widget.selectedPlan['interval'] ?? 'monthly',
      );
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to activate subscription: '),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your subscription has been activated.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subscription Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                        'Plan', widget.selectedPlan['name'] ?? 'N/A'),
                    _buildDetailRow(
                        'Amount', '${widget.selectedPlan['price']} XAF'),
                    _buildDetailRow(
                        'Duration', widget.selectedPlan['duration'] ?? 'N/A'),
                    _buildDetailRow('Features',
                        widget.selectedPlan['features']?.join(', ') ?? 'N/A'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go(Routes.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue to Dashboard'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go(Routes.subscriptions);
              },
              child: const Text('View Subscriptions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
