import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for saving word to favorites
class SaveToFavorites {
  final DictionaryRepository repository;

  SaveToFavorites(this.repository);

  Future<Either<Failure, bool>> call(String wordId, String userId) {
    return repository.saveToFavorites(wordId, userId);
  }
}