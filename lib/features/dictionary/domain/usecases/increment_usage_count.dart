import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for incrementing usage count
class IncrementUsageCount {
  final DictionaryRepository repository;

  IncrementUsageCount(this.repository);

  Future<Either<Failure, void>> call(String wordId) {
    return repository.incrementUsageCount(wordId);
  }
}