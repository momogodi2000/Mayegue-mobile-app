import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/subscription_viewmodel.dart';
import '../widgets/subscription_card.dart';

/// Subscription Plans View
class SubscriptionPlansView extends StatelessWidget {
  const SubscriptionPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans d\'abonnement'),
      ),
      body: Consumer<SubscriptionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadSubscriptionPlans,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final plans = viewModel.subscriptionPlans;
          if (plans.isEmpty) {
            return const Center(child: Text('Aucun plan disponible'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SubscriptionCard(
                  plan: plan,
                  onSelect: () => _onPlanSelected(context, plan),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onPlanSelected(BuildContext context, Map<String, dynamic> plan) {
    // Navigate to payment view with selected plan
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: plan,
    );
  }
}