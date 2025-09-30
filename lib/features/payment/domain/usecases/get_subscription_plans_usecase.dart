import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

/// Get Subscription Plans Use Case
class GetSubscriptionPlansUseCase implements UseCase<List<Map<String, dynamic>>, NoParams> {
  final PaymentRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) async {
    return await repository.getSubscriptionPlans();
  }
}