import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/word_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for searching words in the dictionary
class SearchWords {
  final DictionaryRepository repository;

  SearchWords(this.repository);

  Future<Either<Failure, List<WordEntity>>> call(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  }) {
    return repository.searchWords(
      query,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      categories: categories,
      maxDifficulty: maxDifficulty,
    );
  }
}