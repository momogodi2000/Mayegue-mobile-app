import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/language_entity.dart';

/// Abstract repository for language operations
abstract class LanguageRepository {
  /// Get all available languages
  Future<Either<Failure, List<LanguageEntity>>> getAllLanguages();

  /// Get language by ID
  Future<Either<Failure, LanguageEntity>> getLanguageById(String id);

  /// Get languages by region
  Future<Either<Failure, List<LanguageEntity>>> getLanguagesByRegion(String region);

  /// Get languages by status
  Future<Either<Failure, List<LanguageEntity>>> getLanguagesByStatus(String status);

  /// Search languages by name or code
  Future<Either<Failure, List<LanguageEntity>>> searchLanguages(String query);

  /// Create a new language (admin only)
  Future<Either<Failure, LanguageEntity>> createLanguage(LanguageEntity language);

  /// Update an existing language (admin only)
  Future<Either<Failure, LanguageEntity>> updateLanguage(LanguageEntity language);

  /// Delete a language (admin only)
  Future<Either<Failure, void>> deleteLanguage(String id);

  /// Get language statistics
  Future<Either<Failure, Map<String, dynamic>>> getLanguageStatistics();
}
