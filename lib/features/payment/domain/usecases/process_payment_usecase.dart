import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

/// Process Payment Use Case
class ProcessPaymentUseCase
    implements UseCase<PaymentEntity, ProcessPaymentParams> {
  final PaymentRepository repository;

  ProcessPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(
      ProcessPaymentParams params) async {
    return await repository.processPayment(
      userId: params.userId,
      amount: params.amount,
      method: params.method,
      phoneNumber: params.phoneNumber,
    );
  }
}

/// Parameters for ProcessPaymentUseCase
class ProcessPaymentParams extends Equatable {
  final String userId;
  final double amount;
  final String method;
  final String phoneNumber;

  const ProcessPaymentParams({
    required this.userId,
    required this.amount,
    required this.method,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [userId, amount, method, phoneNumber];
}
