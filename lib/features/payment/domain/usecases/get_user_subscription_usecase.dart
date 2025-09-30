import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/subscription_entity.dart';
import '../repositories/payment_repository.dart';

/// Get User Subscription Use Case
class GetUserSubscriptionUseCase implements UseCase<SubscriptionEntity?, GetUserSubscriptionParams> {
  final PaymentRepository repository;

  GetUserSubscriptionUseCase(this.repository);

  @override
  Future<Either<Failure, SubscriptionEntity?>> call(GetUserSubscriptionParams params) async {
    return await repository.getUserSubscription(params.userId);
  }
}

/// Parameters for GetUserSubscriptionUseCase
class GetUserSubscriptionParams extends Equatable {
  final String userId;

  const GetUserSubscriptionParams({required this.userId});

  @override
  List<Object> get props => [userId];
}