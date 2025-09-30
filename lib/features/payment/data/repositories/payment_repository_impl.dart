import 'package:dartz/dartz.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/payment_remote_datasource.dart';

/// Implementation of PaymentRepository
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaymentEntity>> processPayment({
    required String userId,
    required double amount,
    required String method,
    required String phoneNumber,
  }) async {
    try {
      final payment = await remoteDataSource.initiatePayment(
        userId: userId,
        amount: amount,
        method: method,
        phoneNumber: phoneNumber,
        description: 'Mayegue App Subscription',
      );
      return Right(payment);
    } catch (e) {
      return Left(PaymentFailure('Payment processing failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentStatus(
      String paymentId) async {
    try {
      final payment = await remoteDataSource.getPaymentById(paymentId);
      return Right(payment);
    } catch (e) {
      return Left(ServerFailure('Failed to get payment status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory(
      String userId) async {
    try {
      final payments = await remoteDataSource.getUserPayments(userId);
      return Right(payments);
    } catch (e) {
      return Left(ServerFailure('Failed to get payment history: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required String userId,
    required String planId,
    required String planName,
    required double price,
    required String interval,
  }) async {
    try {
      final subscription = await remoteDataSource.createSubscription(
        userId: userId,
        planId: planId,
        planName: planName,
        price: price,
        interval: interval,
      );
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure('Failed to create subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getUserSubscription(
      String userId) async {
    try {
      final subscription = await remoteDataSource.getUserSubscription(userId);
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure('Failed to get user subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription(
      String subscriptionId) async {
    try {
      final subscription = await remoteDataSource.updateSubscriptionStatus(
          subscriptionId, 'cancelled');
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure('Failed to cancel subscription: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getSubscriptionPlans() async {
    try {
      final plans = await remoteDataSource.getSubscriptionPlans();
      return Right(plans);
    } catch (e) {
      return Left(ServerFailure('Failed to get subscription plans: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> handlePaymentCallback(
      Map<String, dynamic> callbackData) async {
    try {
      // Extract payment ID from callback
      final paymentId =
          callbackData['external_reference'] ?? callbackData['reference'];
      final status = callbackData['status'];

      if (paymentId != null && status != null) {
        // Update payment status
        await remoteDataSource.updatePaymentStatus(paymentId, status);

        // If payment completed, create/update subscription
        if (status == 'completed') {
          // TODO: Create subscription based on payment amount
        }

        return const Right(true);
      }

      return const Right(false);
    } catch (e) {
      return Left(ServerFailure('Failed to handle payment callback: $e'));
    }
  }
}
