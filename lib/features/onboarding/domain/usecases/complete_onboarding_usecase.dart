import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/onboarding_entity.dart';
import '../repositories/onboarding_repository.dart';

/// Complete onboarding usecase
class CompleteOnboardingUsecase {
  final OnboardingRepository repository;

  CompleteOnboardingUsecase(this.repository);

  Future<Either<Failure, void>> call(OnboardingEntity onboardingData) async {
    try {
      return await repository.saveOnboardingData(onboardingData);
    } catch (e) {
      return const Left(CacheFailure('Échec de sauvegarde des données d\'onboarding'));
    }
  }
}

/// Get onboarding data usecase
class GetOnboardingDataUsecase {
  final OnboardingRepository repository;

  GetOnboardingDataUsecase(this.repository);

  Future<Either<Failure, OnboardingEntity?>> call() async {
    try {
      return await repository.getOnboardingData();
    } catch (e) {
      return const Left(CacheFailure('Échec de récupération des données d\'onboarding'));
    }
  }
}

/// Clear onboarding data usecase
class ClearOnboardingDataUsecase {
  final OnboardingRepository repository;

  ClearOnboardingDataUsecase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      return await repository.clearOnboardingData();
    } catch (e) {
      return const Left(CacheFailure('Échec de suppression des données d\'onboarding'));
    }
  }
}
