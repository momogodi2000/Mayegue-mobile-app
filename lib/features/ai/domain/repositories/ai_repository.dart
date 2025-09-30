import 'package:dartz/dartz.dart';
import '../entities/ai_entities.dart';
import '../entities/ai_suggestion_entity.dart';
import '../../../../core/errors/failures.dart';

/// Abstract repository for AI operations
abstract class AiRepository {
  /// Start a new conversation
  Future<Either<Failure, ConversationEntity>> startConversation({
    required String userId,
    required String title,
  });

  /// Send message to AI
  Future<Either<Failure, AiResponseEntity>> sendMessage({
    required String conversationId,
    required String message,
    required String userId,
  });

  /// Get conversation history
  Future<Either<Failure, ConversationEntity>> getConversation(String conversationId);

  /// Get user conversations
  Future<Either<Failure, List<ConversationEntity>>> getUserConversations(String userId);

  /// Delete conversation
  Future<Either<Failure, bool>> deleteConversation(String conversationId);

  /// Get AI recommendations for user
  Future<Either<Failure, List<String>>> getRecommendations(String userId);

  /// Translate text between languages
  Future<Either<Failure, TranslationEntity>> translateText({
    required String userId,
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Assess pronunciation from audio
  Future<Either<Failure, PronunciationAssessmentEntity>> assessPronunciation({
    required String userId,
    required String word,
    required String language,
    required String audioUrl,
  });

  /// Generate learning content
  Future<Either<Failure, ContentGenerationEntity>> generateContent({
    required String userId,
    required String type,
    required String topic,
    required String language,
    required String difficulty,
  });

  /// Get personalized learning recommendations
  Future<Either<Failure, List<AiLearningRecommendationEntity>>> getPersonalizedRecommendations(String userId);

  /// Save translation history
  Future<Either<Failure, bool>> saveTranslation(TranslationEntity translation);

  /// Get translation history
  Future<Either<Failure, List<TranslationEntity>>> getTranslationHistory(String userId);

  /// Save pronunciation assessment
  Future<Either<Failure, bool>> savePronunciationAssessment(PronunciationAssessmentEntity assessment);

  /// Get pronunciation history
  Future<Either<Failure, List<PronunciationAssessmentEntity>>> getPronunciationHistory(String userId);

  /// Generate word suggestion with AI
  Future<Either<Failure, AiSuggestionEntity>> generateWordSuggestion({
    required String word,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
    bool includeIPA = true,
    bool includeExamples = true,
    String? difficultyLevel,
    String? userId,
  });

  /// Get pronunciation feedback
  Future<Either<Failure, PronunciationFeedbackEntity>> getPronunciationFeedback({
    required String userId,
    required String audioData,
    required String targetText,
    required String targetLanguage,
  });

  /// Get AI suggestions
  Future<Either<Failure, List<AiSuggestionEntity>>> getAISuggestions({
    required String userId,
    required String context,
    required String language,
  });

  /// Generate learning content
  Future<Either<Failure, LearningContentEntity>> generateLearningContent({
    required String userId,
    required String topic,
    required String language,
    required String difficulty,
  });

  /// Analyze user progress
  Future<Either<Failure, ProgressAnalysisEntity>> analyzeUserProgress({
    required String userId,
    required String language,
    required String timeRange,
  });
}
