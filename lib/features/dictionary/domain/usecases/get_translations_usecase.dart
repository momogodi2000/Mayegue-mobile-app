import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/translation_entity.dart';
import '../repositories/dictionary_repository.dart';

/// Use case for getting translations for a word
class GetTranslationsUsecase implements UseCase<List<TranslationEntity>, GetTranslationsParams> {
  final DictionaryRepository repository;

  GetTranslationsUsecase(this.repository);

  @override
  Future<Either<Failure, List<TranslationEntity>>> call(GetTranslationsParams params) async {
    return await repository.getTranslations(params.wordId, params.targetLanguages);
  }
}

/// Parameters for GetTranslationsUsecase
class GetTranslationsParams extends Equatable {
  final String wordId;
  final List<String> targetLanguages;

  const GetTranslationsParams({
    required this.wordId,
    required this.targetLanguages,
  });

  @override
  List<Object?> get props => [wordId, targetLanguages];
}