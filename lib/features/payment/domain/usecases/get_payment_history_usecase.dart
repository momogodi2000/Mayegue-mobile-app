import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

/// Get Payment History Use Case
class GetPaymentHistoryUseCase implements UseCase<List<PaymentEntity>, GetPaymentHistoryParams> {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(GetPaymentHistoryParams params) async {
    return await repository.getPaymentHistory(params.userId);
  }
}

/// Parameters for GetPaymentHistoryUseCase
class GetPaymentHistoryParams extends Equatable {
  final String userId;

  const GetPaymentHistoryParams({required this.userId});

  @override
  List<Object> get props => [userId];
}