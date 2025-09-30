import '../../../features/dictionary/data/models/dictionary_entry_model.dart';
import '../../../features/dictionary/data/models/word_model.dart';
import '../../../features/dictionary/data/models/translation_model.dart';
import '../../../features/dictionary/domain/entities/dictionary_entry_entity.dart';

/// Migration utilities for consolidating legacy dictionary system to canonical lexicon
class DictionaryMigration {

  /// Convert legacy WordModel to canonical DictionaryEntryModel
  static DictionaryEntryModel migrateWordModel(WordModel wordModel, List<TranslationModel>? translations) {
    final now = DateTime.now();

    // Map legacy difficulty (int) to new enum
    DifficultyLevel difficultyLevel;
    switch (wordModel.difficulty) {
      case 1:
        difficultyLevel = DifficultyLevel.beginner;
        break;
      case 2:
        difficultyLevel = DifficultyLevel.intermediate;
        break;
      case 3:
        difficultyLevel = DifficultyLevel.advanced;
        break;
      case 4:
        difficultyLevel = DifficultyLevel.expert;
        break;
      default:
        difficultyLevel = DifficultyLevel.beginner;
    }

    // Convert translations to new format
    final Map<String, String> translationMap = {};
    if (translations != null) {
      for (final translation in translations) {
        translationMap[translation.targetLanguage] = translation.translation;
      }
    }

    // Create example sentences from legacy fields
    final exampleSentences = <ExampleSentence>[];
    if (wordModel.example != null && wordModel.example!.isNotEmpty) {
      exampleSentences.add(
        ExampleSentence(
          sentence: wordModel.example!,
          translations: const {},
          audioReference: null,
        ),
      );
    }

    return DictionaryEntryModel(
      id: wordModel.id,
      languageCode: wordModel.language,
      canonicalForm: wordModel.word,
      orthographyVariants: const [], // Legacy system didn't track variants
      ipa: wordModel.phonetic,
      audioFileReferences: wordModel.audioUrl != null ? [wordModel.audioUrl!] : const [],
      partOfSpeech: _inferPartOfSpeech(wordModel.category),
      translations: translationMap,
      exampleSentences: exampleSentences,
      tags: [wordModel.category],
      difficultyLevel: difficultyLevel,
      contributorId: null, // Legacy system didn't track contributors
      reviewStatus: ReviewStatus.humanVerified, // Assume legacy entries are verified
      qualityScore: _calculateQualityScore(wordModel),
      lastUpdated: wordModel.updatedAt,
      sourceReference: 'Migrated from legacy dictionary',
      metadata: {
        'migrated': true,
        'migratedAt': now.toIso8601String(),
        'legacyId': wordModel.id,
        'definition': wordModel.definition,
        'synonyms': wordModel.synonyms,
        'antonyms': wordModel.antonyms,
      },
    );
  }

  /// Infer part of speech from legacy category
  static String _inferPartOfSpeech(String? category) {
    if (category == null) return 'noun';

    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('verb')) return 'verb';
    if (categoryLower.contains('adjective') || categoryLower.contains('adj')) return 'adjective';
    if (categoryLower.contains('adverb')) return 'adverb';
    if (categoryLower.contains('pronoun')) return 'pronoun';
    if (categoryLower.contains('preposition')) return 'preposition';
    if (categoryLower.contains('conjunction')) return 'conjunction';
    if (categoryLower.contains('interjection')) return 'interjection';

    // Default to noun for unknown categories
    return 'noun';
  }

  /// Calculate quality score based on legacy data completeness
  static double _calculateQualityScore(WordModel wordModel) {
    double score = 0.5; // Base score

    // Boost score based on available data
    if (wordModel.definition != null && wordModel.definition!.isNotEmpty) {
      score += 0.1;
    }

    if (wordModel.example != null && wordModel.example!.isNotEmpty) {
      score += 0.1;
    }

    if (wordModel.phonetic != null && wordModel.phonetic!.isNotEmpty) {
      score += 0.1;
    }

    if (wordModel.audioUrl != null && wordModel.audioUrl!.isNotEmpty) {
      score += 0.1;
    }

    if (wordModel.synonyms.isNotEmpty) {
      score += 0.05;
    }

    if (wordModel.antonyms.isNotEmpty) {
      score += 0.05;
    }

    // Cap at 1.0
    return score > 1.0 ? 1.0 : score;
  }

  /// Create mapping from legacy to canonical field names
  static Map<String, String> get fieldMappings => {
    'word': 'canonicalForm',
    'language': 'languageCode',
    'phonetic': 'ipa',
    'category': 'tags',
    'difficulty': 'difficultyLevel',
  };

  /// Get list of deprecated fields that should not be migrated directly
  static Set<String> get deprecatedFields => {
    'translation', // Now handled in translations map
    'pronunciation', // Replaced by IPA
    'usageCount', // Moved to metadata
    'definition', // Moved to metadata
    'synonyms', // Moved to metadata
    'antonyms', // Moved to metadata
  };

  /// Validate migration compatibility
  static bool canMigrate(WordModel wordModel) {
    // Basic validation for migration
    return wordModel.word.isNotEmpty &&
           wordModel.language.isNotEmpty &&
           wordModel.id.isNotEmpty;
  }

  /// Generate migration report
  static Map<String, dynamic> generateMigrationReport(
    List<WordModel> legacyWords,
    List<TranslationModel> legacyTranslations,
  ) {
    final migratable = legacyWords.where(canMigrate).length;
    final totalTranslations = legacyTranslations.length;

    final languageDistribution = <String, int>{};
    for (final word in legacyWords) {
      languageDistribution[word.language] =
          (languageDistribution[word.language] ?? 0) + 1;
    }

    final categoryDistribution = <String, int>{};
    for (final word in legacyWords) {
      categoryDistribution[word.category] =
          (categoryDistribution[word.category] ?? 0) + 1;
    }

    return {
      'totalLegacyWords': legacyWords.length,
      'migratableWords': migratable,
      'nonMigratableWords': legacyWords.length - migratable,
      'totalTranslations': totalTranslations,
      'languageDistribution': languageDistribution,
      'categoryDistribution': categoryDistribution,
      'estimatedNewEntries': migratable,
      'migrationDate': DateTime.now().toIso8601String(),
    };
  }
}