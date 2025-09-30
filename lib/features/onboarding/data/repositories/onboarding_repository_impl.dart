import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';
import '../models/onboarding_model.dart';

/// Implementation of OnboardingRepository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> saveOnboardingData(OnboardingEntity data) async {
    try {
      final model = OnboardingModel.fromEntity(data);
      await localDataSource.saveOnboardingData(model);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Erreur lors de la sauvegarde des données d\'onboarding'));
    }
  }

  @override
  Future<Either<Failure, bool>> getOnboardingStatus() async {
    try {
      final status = await localDataSource.getOnboardingStatus();
      return Right(status);
    } catch (e) {
      return const Left(CacheFailure('Erreur lors de la récupération du statut d\'onboarding'));
    }
  }

  @override
  Future<Either<Failure, OnboardingEntity?>> getOnboardingData() async {
    try {
      final data = await localDataSource.getOnboardingData();
      if (data != null) {
        final model = OnboardingModel.fromJson(data);
        return Right(model.toEntity());
      } else {
        return const Right(null);
      }
    } catch (e) {
      return const Left(CacheFailure('Erreur lors de la récupération des données d\'onboarding'));
    }
  }

  @override
  Future<Either<Failure, void>> clearOnboardingData() async {
    try {
      await localDataSource.clearOnboardingData();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Erreur lors de la suppression des données d\'onboarding'));
    }
  }
}
