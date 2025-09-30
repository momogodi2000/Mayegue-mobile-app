import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_entities.dart';
import '../entities/ai_suggestion_entity.dart';
import '../repositories/ai_repository.dart';

/// Use case for sending a message to AI
class SendMessageToAI implements UseCase<AiResponseEntity, SendMessageParams> {
  final AiRepository repository;

  SendMessageToAI(this.repository);

  @override
  Future<Either<Failure, AiResponseEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      conversationId: params.conversationId,
      message: params.message,
      userId: params.userId,
    );
  }
}

/// Parameters for SendMessageToAI use case
class SendMessageParams {
  final String conversationId;
  final String message;
  final String userId;

  const SendMessageParams({
    required this.conversationId,
    required this.message,
    required this.userId,
  });
}

/// Use case for starting a new conversation
class StartConversation
    implements UseCase<ConversationEntity, StartConversationParams> {
  final AiRepository repository;

  StartConversation(this.repository);

  @override
  Future<Either<Failure, ConversationEntity>> call(
      StartConversationParams params) {
    return repository.startConversation(
      userId: params.userId,
      title: params.title,
    );
  }
}

/// Parameters for StartConversation use case
class StartConversationParams {
  final String userId;
  final String title;

  const StartConversationParams({
    required this.userId,
    required this.title,
  });
}

/// Use case for getting user conversations
class GetUserConversations
    implements UseCase<List<ConversationEntity>, GetUserConversationsParams> {
  final AiRepository repository;

  GetUserConversations(this.repository);

  @override
  Future<Either<Failure, List<ConversationEntity>>> call(
      GetUserConversationsParams params) {
    return repository.getUserConversations(params.userId);
  }
}

/// Parameters for GetUserConversations use case
class GetUserConversationsParams {
  final String userId;

  const GetUserConversationsParams({
    required this.userId,
  });
}

/// Use case for translating text
class TranslateText implements UseCase<TranslationEntity, TranslateTextParams> {
  final AiRepository repository;

  TranslateText(this.repository);

  @override
  Future<Either<Failure, TranslationEntity>> call(TranslateTextParams params) {
    return repository.translateText(
      userId: params.userId,
      sourceText: params.sourceText,
      sourceLanguage: params.sourceLanguage,
      targetLanguage: params.targetLanguage,
    );
  }
}

/// Parameters for TranslateText use case
class TranslateTextParams {
  final String userId;
  final String sourceText;
  final String sourceLanguage;
  final String targetLanguage;

  const TranslateTextParams({
    required this.userId,
    required this.sourceText,
    required this.sourceLanguage,
    required this.targetLanguage,
  });
}

/// Use case for getting pronunciation feedback
class GetPronunciationFeedback
    implements
        UseCase<PronunciationFeedbackEntity, GetPronunciationFeedbackParams> {
  final AiRepository repository;

  GetPronunciationFeedback(this.repository);

  @override
  Future<Either<Failure, PronunciationFeedbackEntity>> call(
      GetPronunciationFeedbackParams params) {
    return repository.getPronunciationFeedback(
      userId: params.userId,
      audioData: params.audioData,
      targetText: params.targetText,
      targetLanguage: params.targetLanguage,
    );
  }
}

/// Parameters for GetPronunciationFeedback use case
class GetPronunciationFeedbackParams {
  final String userId;
  final String audioData;
  final String targetText;
  final String targetLanguage;

  const GetPronunciationFeedbackParams({
    required this.userId,
    required this.audioData,
    required this.targetText,
    required this.targetLanguage,
  });
}

/// Use case for getting AI suggestions
class GetAISuggestions
    implements UseCase<List<AiSuggestionEntity>, GetAISuggestionsParams> {
  final AiRepository repository;

  GetAISuggestions(this.repository);

  @override
  Future<Either<Failure, List<AiSuggestionEntity>>> call(
      GetAISuggestionsParams params) {
    return repository.getAISuggestions(
      userId: params.userId,
      context: params.context,
      language: params.language,
    );
  }
}

/// Parameters for GetAISuggestions use case
class GetAISuggestionsParams {
  final String userId;
  final String context;
  final String language;

  const GetAISuggestionsParams({
    required this.userId,
    required this.context,
    required this.language,
  });
}

/// Use case for generating learning content
class GenerateLearningContent
    implements UseCase<LearningContentEntity, GenerateLearningContentParams> {
  final AiRepository repository;

  GenerateLearningContent(this.repository);

  @override
  Future<Either<Failure, LearningContentEntity>> call(
      GenerateLearningContentParams params) {
    return repository.generateLearningContent(
      userId: params.userId,
      topic: params.topic,
      language: params.language,
      difficulty: params.difficulty,
    );
  }
}

/// Parameters for GenerateLearningContent use case
class GenerateLearningContentParams {
  final String userId;
  final String topic;
  final String language;
  final String difficulty;

  const GenerateLearningContentParams({
    required this.userId,
    required this.topic,
    required this.language,
    required this.difficulty,
  });
}

/// Use case for analyzing user progress
class AnalyzeUserProgress
    implements UseCase<ProgressAnalysisEntity, AnalyzeUserProgressParams> {
  final AiRepository repository;

  AnalyzeUserProgress(this.repository);

  @override
  Future<Either<Failure, ProgressAnalysisEntity>> call(
      AnalyzeUserProgressParams params) {
    return repository.analyzeUserProgress(
      userId: params.userId,
      language: params.language,
      timeRange: params.timeRange,
    );
  }
}

/// Parameters for AnalyzeUserProgress use case
class AnalyzeUserProgressParams {
  final String userId;
  final String language;
  final String timeRange;

  const AnalyzeUserProgressParams({
    required this.userId,
    required this.language,
    required this.timeRange,
  });
}

/// Use case for getting translation history
class GetTranslationHistory
    implements UseCase<List<TranslationEntity>, GetTranslationHistoryParams> {
  final AiRepository repository;

  GetTranslationHistory(this.repository);

  @override
  Future<Either<Failure, List<TranslationEntity>>> call(
      GetTranslationHistoryParams params) {
    return repository.getTranslationHistory(params.userId);
  }
}

/// Parameters for GetTranslationHistory use case
class GetTranslationHistoryParams {
  final String userId;

  const GetTranslationHistoryParams({
    required this.userId,
  });
}

/// Use case for assessing pronunciation
class AssessPronunciation
    implements UseCase<PronunciationAssessmentEntity, AssessPronunciationParams> {
  final AiRepository repository;

  AssessPronunciation(this.repository);

  @override
  Future<Either<Failure, PronunciationAssessmentEntity>> call(
      AssessPronunciationParams params) {
    return repository.assessPronunciation(
      userId: params.userId,
      word: params.word,
      language: params.language,
      audioUrl: params.audioUrl,
    );
  }
}

/// Parameters for AssessPronunciation use case
class AssessPronunciationParams {
  final String userId;
  final String word;
  final String language;
  final String audioUrl;

  const AssessPronunciationParams({
    required this.userId,
    required this.word,
    required this.language,
    required this.audioUrl,
  });
}

/// Use case for getting pronunciation history
class GetPronunciationHistory
    implements UseCase<List<PronunciationAssessmentEntity>, GetPronunciationHistoryParams> {
  final AiRepository repository;

  GetPronunciationHistory(this.repository);

  @override
  Future<Either<Failure, List<PronunciationAssessmentEntity>>> call(
      GetPronunciationHistoryParams params) {
    return repository.getPronunciationHistory(params.userId);
  }
}

/// Parameters for GetPronunciationHistory use case
class GetPronunciationHistoryParams {
  final String userId;

  const GetPronunciationHistoryParams({
    required this.userId,
  });
}

/// Use case for generating content
class GenerateContent
    implements UseCase<ContentGenerationEntity, GenerateContentParams> {
  final AiRepository repository;

  GenerateContent(this.repository);

  @override
  Future<Either<Failure, ContentGenerationEntity>> call(
      GenerateContentParams params) {
    return repository.generateContent(
      userId: params.userId,
      type: params.type,
      topic: params.topic,
      language: params.language,
      difficulty: params.difficulty,
    );
  }
}

/// Parameters for GenerateContent use case
class GenerateContentParams {
  final String userId;
  final String type;
  final String topic;
  final String language;
  final String difficulty;

  const GenerateContentParams({
    required this.userId,
    required this.type,
    required this.topic,
    required this.language,
    required this.difficulty,
  });
}

/// Use case for getting personalized recommendations
class GetPersonalizedRecommendations
    implements UseCase<List<AiLearningRecommendationEntity>, GetPersonalizedRecommendationsParams> {
  final AiRepository repository;

  GetPersonalizedRecommendations(this.repository);

  @override
  Future<Either<Failure, List<AiLearningRecommendationEntity>>> call(
      GetPersonalizedRecommendationsParams params) {
    return repository.getPersonalizedRecommendations(params.userId);
  }
}

/// Parameters for GetPersonalizedRecommendations use case
class GetPersonalizedRecommendationsParams {
  final String userId;

  const GetPersonalizedRecommendationsParams({
    required this.userId,
  });
}