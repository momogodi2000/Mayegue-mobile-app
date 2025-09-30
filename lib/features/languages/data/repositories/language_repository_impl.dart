import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/repositories/language_repository.dart';
import '../datasources/language_remote_datasource.dart';
import '../models/language_model.dart';

/// Implementation of LanguageRepository
class LanguageRepositoryImpl implements LanguageRepository {
  final LanguageRemoteDataSource remoteDataSource;

  LanguageRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<LanguageEntity>>> getAllLanguages() async {
    try {
      final languageModels = await remoteDataSource.getAllLanguages();
      final languageEntities = languageModels
          .map((model) => model.toEntity())
          .toList();

      return Right(languageEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LanguageEntity>> getLanguageById(String id) async {
    try {
      final languageModel = await remoteDataSource.getLanguageById(id);
      if (languageModel == null) {
        return const Left(NotFoundFailure('Language not found'));
      }

      return Right(languageModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LanguageEntity>>> getLanguagesByRegion(String region) async {
    try {
      final languageModels = await remoteDataSource.getLanguagesByRegion(region);
      final languageEntities = languageModels
          .map((model) => model.toEntity())
          .toList();

      return Right(languageEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LanguageEntity>>> getLanguagesByStatus(String status) async {
    try {
      final languageModels = await remoteDataSource.getLanguagesByStatus(status);
      final languageEntities = languageModels
          .map((model) => model.toEntity())
          .toList();

      return Right(languageEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LanguageEntity>>> searchLanguages(String query) async {
    try {
      final languageModels = await remoteDataSource.searchLanguages(query);
      final languageEntities = languageModels
          .map((model) => model.toEntity())
          .toList();

      return Right(languageEntities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LanguageEntity>> createLanguage(LanguageEntity language) async {
    try {
      final languageModel = LanguageModel.fromEntity(language);
      final createdModel = await remoteDataSource.createLanguage(languageModel);

      return Right(createdModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LanguageEntity>> updateLanguage(LanguageEntity language) async {
    try {
      final languageModel = LanguageModel.fromEntity(language);
      final updatedModel = await remoteDataSource.updateLanguage(languageModel);

      return Right(updatedModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLanguage(String id) async {
    try {
      await remoteDataSource.deleteLanguage(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLanguageStatistics() async {
    try {
      final stats = await remoteDataSource.getLanguageStatistics();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
