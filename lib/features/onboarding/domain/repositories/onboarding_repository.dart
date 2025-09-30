import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/onboarding_entity.dart';

/// Abstract repository for onboarding operations
abstract class OnboardingRepository {
  /// Save onboarding data
  Future<Either<Failure, void>> saveOnboardingData(OnboardingEntity data);

  /// Get onboarding status (whether completed or not)
  Future<Either<Failure, bool>> getOnboardingStatus();

  /// Get saved onboarding data
  Future<Either<Failure, OnboardingEntity?>> getOnboardingData();

  /// Clear onboarding data (for reset)
  Future<Either<Failure, void>> clearOnboardingData();
}
