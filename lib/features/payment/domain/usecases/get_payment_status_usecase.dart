import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

/// Get Payment Status Use Case
class GetPaymentStatusUseCase implements UseCase<PaymentEntity, GetPaymentStatusParams> {
  final PaymentRepository repository;

  GetPaymentStatusUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(GetPaymentStatusParams params) async {
    return await repository.getPaymentStatus(params.paymentId);
  }
}

/// Parameters for GetPaymentStatusUseCase
class GetPaymentStatusParams extends Equatable {
  final String paymentId;

  const GetPaymentStatusParams({required this.paymentId});

  @override
  List<Object> get props => [paymentId];
}