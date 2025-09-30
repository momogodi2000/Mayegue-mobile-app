import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/word_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for getting a word by ID
class GetWordUsecase implements UseCase<WordEntity, GetWordParams> {
  final DictionaryRepository repository;

  GetWordUsecase(this.repository);

  @override
  Future<Either<Failure, WordEntity>> call(GetWordParams params) async {
    return await repository.getWord(params.wordId);
  }
}

/// Parameters for GetWordUsecase
class GetWordParams extends Equatable {
  final String wordId;

  const GetWordParams({
    required this.wordId,
  });

  @override
  List<Object> get props => [wordId];
}
