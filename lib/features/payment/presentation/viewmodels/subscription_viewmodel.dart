import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_subscription_plans_usecase.dart';
import '../../domain/usecases/get_user_subscription_usecase.dart';
import '../../domain/usecases/create_subscription_usecase.dart';
import '../../domain/usecases/cancel_subscription_usecase.dart';

/// Subscription ViewModel
class SubscriptionViewModel extends ChangeNotifier {
  final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;
  final GetUserSubscriptionUseCase getUserSubscriptionUseCase;
  final CreateSubscriptionUseCase createSubscriptionUseCase;
  final CancelSubscriptionUseCase cancelSubscriptionUseCase;

  SubscriptionViewModel({
    required this.getSubscriptionPlansUseCase,
    required this.getUserSubscriptionUseCase,
    required this.createSubscriptionUseCase,
    required this.cancelSubscriptionUseCase,
  });

  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _subscriptionPlans = [];
  Map<String, dynamic>? _userSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get subscriptionPlans => _subscriptionPlans;
  Map<String, dynamic>? get userSubscription => _userSubscription;

  Future<void> loadSubscriptionPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getSubscriptionPlansUseCase(const NoParams());

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (plans) {
        _subscriptionPlans = plans;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUserSubscription(String userId) async {
    final params = GetUserSubscriptionParams(userId: userId);
    final result = await getUserSubscriptionUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (subscription) {
        _userSubscription = subscription?.toJson();
      },
    );

    notifyListeners();
  }

  Future<void> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String interval,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final params = CreateSubscriptionParams(
      userId: userId,
      planId: planId,
      planName: planName,
      price: price,
      interval: interval,
    );

    final result = await createSubscriptionUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (subscription) {
        _userSubscription = subscription.toJson();
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final params = CancelSubscriptionParams(subscriptionId: subscriptionId);
    final result = await cancelSubscriptionUseCase(params);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (subscription) {
        _userSubscription = subscription.toJson();
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
