import 'package:dartz/dartz.dart';
import '../entities/payment_entity.dart';
import '../entities/subscription_entity.dart';
import '../../../../core/errors/failures.dart';

/// Abstract repository for payment operations
abstract class PaymentRepository {
  /// Process a payment with CamPay
  Future<Either<Failure, PaymentEntity>> processPayment({
    required String userId,
    required double amount,
    required String method,
    required String phoneNumber,
  });

  /// Get payment status by ID
  Future<Either<Failure, PaymentEntity>> getPaymentStatus(String paymentId);

  /// Get user payment history
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory(String userId);

  /// Create subscription
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String interval,
  });

  /// Get user active subscription
  Future<Either<Failure, SubscriptionEntity?>> getUserSubscription(String userId);

  /// Cancel subscription
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription(String subscriptionId);

  /// Get available subscription plans
  Future<Either<Failure, List<Map<String, dynamic>>>> getSubscriptionPlans();

  /// Handle payment callback/webhook
  Future<Either<Failure, bool>> handlePaymentCallback(Map<String, dynamic> callbackData);
}
