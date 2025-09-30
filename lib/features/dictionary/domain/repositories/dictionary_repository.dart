import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/word_entity.dart';
import '../entities/pronunciation_entity.dart';
import '../entities/translation_entity.dart';

/// Abstract repository for dictionary operations
abstract class DictionaryRepository {
  /// Search for words by query across multiple languages
  Future<Either<Failure, List<WordEntity>>> searchWords(
    String query, {
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  });

  /// Get word by ID
  Future<Either<Failure, WordEntity>> getWord(String wordId);

  /// Get all translations for a word across all supported languages
  Future<Either<Failure, List<TranslationEntity>>> getAllTranslations(String wordId);

  /// Get translations for a word in specific target languages
  Future<Either<Failure, List<TranslationEntity>>> getTranslations(
    String wordId,
    List<String> targetLanguages,
  );

  /// Get pronunciation for a word in specific language
  Future<Either<Failure, PronunciationEntity>> getPronunciation(String wordId, String language);

  /// Add a new word to dictionary (admin/community)
  Future<Either<Failure, WordEntity>> addWord(WordEntity word);

  /// Add translation for an existing word
  Future<Either<Failure, TranslationEntity>> addTranslation(TranslationEntity translation);

  /// Update an existing word
  Future<Either<Failure, WordEntity>> updateWord(WordEntity word);

  /// Update translation
  Future<Either<Failure, TranslationEntity>> updateTranslation(TranslationEntity translation);

  /// Delete a word from dictionary
  Future<Either<Failure, void>> deleteWord(String wordId);

  /// Delete translation
  Future<Either<Failure, void>> deleteTranslation(String translationId);

  /// Get popular words (most searched/translated)
  Future<Either<Failure, List<WordEntity>>> getPopularWords({
    int limit = 20,
    String? language,
  });

  /// Get words by category
  Future<Either<Failure, List<WordEntity>>> getWordsByCategory(
    String category, {
    String? language,
    int limit = 50,
  });

  /// Get words by difficulty level
  Future<Either<Failure, List<WordEntity>>> getWordsByDifficulty(
    int difficulty, {
    String? language,
    int limit = 50,
  });

  /// Get dictionary statistics
  Future<Either<Failure, Map<String, dynamic>>> getDictionaryStatistics();

  /// Increment usage count for a word
  Future<Either<Failure, void>> incrementUsageCount(String wordId);

  /// Get autocomplete suggestions for search
  Future<Either<Failure, List<String>>> getAutocompleteSuggestions(
    String query,
    String language, {
    int limit = 10,
  });

  /// Get words starting with a letter
  Future<Either<Failure, List<WordEntity>>> getWordsByLetter(
    String letter,
    String language, {
    int limit = 100,
  });

  /// Translate a phrase/sentence (using AI for complex translations)
  Future<Either<Failure, String>> translatePhrase(
    String phrase,
    String sourceLanguage,
    String targetLanguage,
  );

  /// Get translation history for a user
  Future<Either<Failure, List<Map<String, dynamic>>>> getTranslationHistory(
    String userId, {
    int limit = 50,
  });

  /// Save word to user's favorites
  Future<Either<Failure, bool>> saveToFavorites(String wordId, String userId);

  /// Remove word from user's favorites
  Future<Either<Failure, bool>> removeFromFavorites(String wordId, String userId);

  /// Get user's favorite words
  Future<Either<Failure, List<WordEntity>>> getFavoriteWords(String userId);

  /// Report incorrect translation
  Future<Either<Failure, void>> reportIncorrectTranslation(
    String translationId,
    String userId,
    String reason,
  );
}
