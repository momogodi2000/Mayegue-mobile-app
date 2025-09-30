import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for saving a word to favorites
class SaveFavoriteWordUsecase implements UseCase<bool, SaveFavoriteWordParams> {
  final DictionaryRepository repository;

  SaveFavoriteWordUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveFavoriteWordParams params) async {
    return await repository.saveToFavorites(params.wordId, params.userId);
  }
}

/// Parameters for SaveFavoriteWordUsecase
class SaveFavoriteWordParams extends Equatable {
  final String wordId;
  final String userId;

  const SaveFavoriteWordParams({
    required this.wordId,
    required this.userId,
  });

  @override
  List<Object> get props => [wordId, userId];
}
