import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for removing word from favorites
class RemoveFromFavorites {
  final DictionaryRepository repository;

  RemoveFromFavorites(this.repository);

  Future<Either<Failure, bool>> call(String wordId, String userId) {
    return repository.removeFromFavorites(wordId, userId);
  }
}