import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/word_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for adding a new word to the dictionary
class AddWordUsecase implements UseCase<WordEntity, AddWordParams> {
  final DictionaryRepository repository;

  AddWordUsecase(this.repository);

  @override
  Future<Either<Failure, WordEntity>> call(AddWordParams params) async {
    return await repository.addWord(params.word);
  }
}

/// Parameters for AddWordUsecase
class AddWordParams extends Equatable {
  final WordEntity word;

  const AddWordParams({
    required this.word,
  });

  @override
  List<Object?> get props => [word];
}