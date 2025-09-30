import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for getting autocomplete suggestions
class GetAutocompleteSuggestions {
  final DictionaryRepository repository;

  GetAutocompleteSuggestions(this.repository);

  Future<Either<Failure, List<String>>> call(String query, String language, {int limit = 10}) {
    return repository.getAutocompleteSuggestions(query, language, limit: limit);
  }
}