import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

/// Handle Payment Callback Use Case
class HandlePaymentCallbackUseCase implements UseCase<bool, HandlePaymentCallbackParams> {
  final PaymentRepository repository;

  HandlePaymentCallbackUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(HandlePaymentCallbackParams params) async {
    return await repository.handlePaymentCallback(params.callbackData);
  }
}

/// Parameters for HandlePaymentCallbackUseCase
class HandlePaymentCallbackParams extends Equatable {
  final Map<String, dynamic> callbackData;

  const HandlePaymentCallbackParams({required this.callbackData});

  @override
  List<Object> get props => [callbackData];
}