import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onboarding_repository.dart';

/// Get onboarding status usecase
class GetOnboardingStatusUsecase implements UseCase<bool, NoParams> {
  final OnboardingRepository repository;

  GetOnboardingStatusUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.getOnboardingStatus();
  }
}
