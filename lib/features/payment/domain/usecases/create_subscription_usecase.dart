import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';

/// Create Subscription Use Case
class CreateSubscriptionUseCase
    implements UseCase<SubscriptionEntity, CreateSubscriptionParams> {
  final PaymentRepository repository;

  CreateSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity>> call(
      CreateSubscriptionParams params) async {
    return await repository.createSubscription(
      userId: params.userId,
      planId: params.planId,
      planName: params.planName,
      price: params.price,
      interval: params.interval,
    );
  }
}

/// Parameters for CreateSubscriptionUseCase
class CreateSubscriptionParams extends Equatable {
  final String userId;
  final String planId;
  final String planName;
  final double price;
  final String interval;

  const CreateSubscriptionParams({
    required this.userId,
    required this.planId,
    required this.planName,
    required this.price,
    required this.interval,
  });

  @override
  List<Object> get props => [userId, planId, planName, price, interval];
}
