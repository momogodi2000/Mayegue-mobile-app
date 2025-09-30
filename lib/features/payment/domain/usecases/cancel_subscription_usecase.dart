import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';

/// Cancel Subscription Use Case
class CancelSubscriptionUseCase implements UseCase<SubscriptionEntity, CancelSubscriptionParams> {
  final PaymentRepository repository;

  CancelSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(CancelSubscriptionParams params) async {
    return await repository.cancelSubscription(params.subscriptionId);
  }
}

/// Parameters for CancelSubscriptionUseCase
class CancelSubscriptionParams extends Equatable {
  final String subscriptionId;

  const CancelSubscriptionParams({required this.subscriptionId});

  @override
  List<Object> get props => [subscriptionId];
}