import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/ai_suggestion_entity.dart';
import '../../domain/repositories/ai_repository.dart';

class AiSuggestWordUsecase implements UseCase<AiSuggestionEntity, AiSuggestWordParams> {
  final AiRepository repository;

  AiSuggestWordUsecase(this.repository);

  @override
  Future<Either<Failure, AiSuggestionEntity>> call(AiSuggestWordParams params) async {
    try {
      // Validate input parameters
      if (params.word.trim().isEmpty) {
        return const Left(ValidationFailure('Word cannot be empty'));
      }

      if (!_isValidLanguageCode(params.sourceLanguage) ||
          !_isValidLanguageCode(params.targetLanguage)) {
        return const Left(ValidationFailure('Invalid language code'));
      }

      // Generate AI suggestion
      final result = await repository.generateWordSuggestion(
        word: params.word.trim(),
        sourceLanguage: params.sourceLanguage,
        targetLanguage: params.targetLanguage,
        context: params.context,
        includeIPA: params.includeIPA,
        includeExamples: params.includeExamples,
        difficultyLevel: params.difficultyLevel,
        userId: params.userId,
      );

      return result.fold(
        (failure) => Left(failure),
        (suggestion) {
          // The repository should directly return an AiSuggestionEntity
          return Right(suggestion);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Failed to generate AI suggestion: ${e.toString()}'));
    }
  }

  bool _isValidLanguageCode(String languageCode) {
    const validCodes = ['ewondo', 'duala', 'bafang', 'fulfulde', 'bassa', 'bamum', 'fr', 'en'];
    return validCodes.contains(languageCode.toLowerCase());
  }
}

class AiSuggestWordParams {
  final String word;
  final String sourceLanguage;
  final String targetLanguage;
  final String? context;
  final bool includeIPA;
  final bool includeExamples;
  final String? difficultyLevel;
  final String? userId;

  AiSuggestWordParams({
    required this.word,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.context,
    this.includeIPA = true,
    this.includeExamples = true,
    this.difficultyLevel,
    this.userId,
  });
}