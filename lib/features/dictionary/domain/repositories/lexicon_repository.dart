import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dictionary_entry_entity.dart';

/// Canonical lexicon repository interface - single source of truth for all words
abstract class LexiconRepository {
  /// Get dictionary entry by ID
  Future<Either<Failure, DictionaryEntryEntity>> getDictionaryEntry(String id);

  /// Search dictionary entries
  Future<Either<Failure, List<DictionaryEntryEntity>>> searchEntries({
    required String query,
    String? languageCode,
    List<String>? tags,
    DifficultyLevel? difficultyLevel,
    ReviewStatus? reviewStatus,
    int limit = 20,
    String? startAfter,
  });

  /// Get entries by language
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByLanguage(
    String languageCode, {
    int limit = 50,
    String? startAfter,
  });

  /// Get entries pending review
  Future<Either<Failure, List<DictionaryEntryEntity>>> getPendingReviewEntries({
    String? languageCode,
    int limit = 20,
  });

  /// Get AI suggested entries
  Future<Either<Failure, List<DictionaryEntryEntity>>> getAiSuggestedEntries({
    String? languageCode,
    int limit = 20,
  });

  /// Create dictionary entry
  Future<Either<Failure, DictionaryEntryEntity>> createEntry(
    DictionaryEntryEntity entry,
  );

  /// Update dictionary entry
  Future<Either<Failure, DictionaryEntryEntity>> updateEntry(
    DictionaryEntryEntity entry,
  );

  /// Delete dictionary entry
  Future<Either<Failure, void>> deleteEntry(String id);

  /// Bulk create entries (for AI import)
  Future<Either<Failure, List<DictionaryEntryEntity>>> bulkCreateEntries(
    List<DictionaryEntryEntity> entries,
  );

  /// Mark entry as verified
  Future<Either<Failure, DictionaryEntryEntity>> markAsVerified(
    String entryId,
    String reviewerId,
  );

  /// Mark entry as rejected
  Future<Either<Failure, void>> markAsRejected(
    String entryId,
    String reviewerId,
    String reason,
  );

  /// Get word suggestions for autocomplete
  Future<Either<Failure, List<String>>> getWordSuggestions(
    String query,
    String languageCode, {
    int limit = 10,
  });

  /// Get entries by contributor
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByContributor(
    String contributorId, {
    int limit = 20,
  });

  /// Get random entry for practice
  Future<Either<Failure, DictionaryEntryEntity>> getRandomEntry(
    String languageCode, {
    DifficultyLevel? difficultyLevel,
  });

  /// Get entries by difficulty level
  Future<Either<Failure, List<DictionaryEntryEntity>>> getEntriesByDifficulty(
    String languageCode,
    DifficultyLevel difficulty, {
    int limit = 20,
  });

  /// Get translation for word
  Future<Either<Failure, Map<String, String>>> getTranslations(
    String word,
    String fromLanguage,
    List<String> toLanguages,
  );

  /// Stream of real-time dictionary updates
  Stream<List<DictionaryEntryEntity>> watchEntries({
    String? languageCode,
    ReviewStatus? reviewStatus,
  });

  /// Get statistics
  Future<Either<Failure, LexiconStatistics>> getStatistics();

  /// Sync offline entries to remote
  Future<Either<Failure, void>> syncOfflineEntries();

  /// Download entries for offline use
  Future<Either<Failure, void>> downloadEntriesForOffline(
    String languageCode, {
    DifficultyLevel? maxDifficulty,
  });
}

/// Lexicon statistics
class LexiconStatistics {
  final int totalEntries;
  final int verifiedEntries;
  final int pendingEntries;
  final int aiSuggestedEntries;
  final Map<String, int> entriesByLanguage;
  final Map<String, int> entriesByDifficulty;
  final Map<String, int> entriesByPartOfSpeech;
  final DateTime lastUpdated;

  const LexiconStatistics({
    required this.totalEntries,
    required this.verifiedEntries,
    required this.pendingEntries,
    required this.aiSuggestedEntries,
    required this.entriesByLanguage,
    required this.entriesByDifficulty,
    required this.entriesByPartOfSpeech,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'verifiedEntries': verifiedEntries,
      'pendingEntries': pendingEntries,
      'aiSuggestedEntries': aiSuggestedEntries,
      'entriesByLanguage': entriesByLanguage,
      'entriesByDifficulty': entriesByDifficulty,
      'entriesByPartOfSpeech': entriesByPartOfSpeech,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LexiconStatistics.fromJson(Map<String, dynamic> json) {
    return LexiconStatistics(
      totalEntries: json['totalEntries'] as int,
      verifiedEntries: json['verifiedEntries'] as int,
      pendingEntries: json['pendingEntries'] as int,
      aiSuggestedEntries: json['aiSuggestedEntries'] as int,
      entriesByLanguage: Map<String, int>.from(json['entriesByLanguage'] as Map),
      entriesByDifficulty: Map<String, int>.from(json['entriesByDifficulty'] as Map),
      entriesByPartOfSpeech: Map<String, int>.from(json['entriesByPartOfSpeech'] as Map),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}