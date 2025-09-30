import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/language_entity.dart';
import '../repositories/language_repository.dart';

/// Use case for getting all languages
class GetAllLanguagesUseCase implements UseCase<List<LanguageEntity>, NoParams> {
  final LanguageRepository repository;

  GetAllLanguagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LanguageEntity>>> call(NoParams params) {
    return repository.getAllLanguages();
  }
}

/// Use case for getting language by ID
class GetLanguageByIdUseCase implements UseCase<LanguageEntity, String> {
  final LanguageRepository repository;

  GetLanguageByIdUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageEntity>> call(String id) {
    return repository.getLanguageById(id);
  }
}

/// Use case for searching languages
class SearchLanguagesUseCase implements UseCase<List<LanguageEntity>, String> {
  final LanguageRepository repository;

  SearchLanguagesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LanguageEntity>>> call(String query) {
    return repository.searchLanguages(query);
  }
}

/// Use case for getting languages by region
class GetLanguagesByRegionUseCase implements UseCase<List<LanguageEntity>, String> {
  final LanguageRepository repository;

  GetLanguagesByRegionUseCase(this.repository);

  @override
  Future<Either<Failure, List<LanguageEntity>>> call(String region) {
    return repository.getLanguagesByRegion(region);
  }
}

/// Use case for creating a language
class CreateLanguageUseCase implements UseCase<LanguageEntity, LanguageEntity> {
  final LanguageRepository repository;

  CreateLanguageUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageEntity>> call(LanguageEntity language) {
    return repository.createLanguage(language);
  }
}

/// Use case for updating a language
class UpdateLanguageUseCase implements UseCase<LanguageEntity, LanguageEntity> {
  final LanguageRepository repository;

  UpdateLanguageUseCase(this.repository);

  @override
  Future<Either<Failure, LanguageEntity>> call(LanguageEntity language) {
    return repository.updateLanguage(language);
  }
}

/// Use case for deleting a language
class DeleteLanguageUseCase implements UseCase<void, String> {
  final LanguageRepository repository;

  DeleteLanguageUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteLanguage(id);
  }
}

/// Use case for getting language statistics
class GetLanguageStatisticsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final LanguageRepository repository;

  GetLanguageStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) {
    return repository.getLanguageStatistics();
  }
}
