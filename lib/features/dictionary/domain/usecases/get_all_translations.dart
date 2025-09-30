import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/translation_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for getting all translations for a word
class GetAllTranslations {
  final DictionaryRepository repository;

  GetAllTranslations(this.repository);

  Future<Either<Failure, List<TranslationEntity>>> call(String wordId) {
    return repository.getAllTranslations(wordId);
  }
}