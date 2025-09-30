import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/word_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for getting user's favorite words
class GetFavoriteWords {
  final DictionaryRepository repository;

  GetFavoriteWords(this.repository);

  Future<Either<Failure, List<WordEntity>>> call(String userId) {
    return repository.getFavoriteWords(userId);
  }
}