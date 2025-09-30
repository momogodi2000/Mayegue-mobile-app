import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/ai_service.dart';
import '../entities/dictionary_entry_entity.dart';
import '../repositories/lexicon_repository.dart';

/// Use case for AI-driven vocabulary enrichment
class AiEnrichVocabularyUsecase implements UseCase<List<DictionaryEntryEntity>, AiEnrichmentParams> {
  final AIService aiService;
  final LexiconRepository lexiconRepository;

  AiEnrichVocabularyUsecase({
    required this.aiService,
    required this.lexiconRepository,
  });

  @override
  Future<Either<Failure, List<DictionaryEntryEntity>>> call(AiEnrichmentParams params) async {
    try {
      // Generate vocabulary suggestions using AI
      final aiResponse = await aiService.generateVocabulary(
        languageCode: params.languageCode,
        category: params.category,
        difficultyLevel: params.difficultyLevel.name,
        count: params.count,
        context: params.context,
      );

      if (aiResponse.isEmpty) {
        return const Right([]);
      }

      // Parse AI response and create dictionary entries
      final entries = <DictionaryEntryEntity>[];

      for (final suggestion in aiResponse) {
        try {
          final entry = _createEntryFromAiSuggestion(
            suggestion,
            params.languageCode,
            params.difficultyLevel,
          );

          entries.add(entry);
        } catch (e) {
          // Skip invalid suggestions but continue processing others
          debugPrint('Skipped invalid AI suggestion: $e');
        }
      }

      // Bulk create entries in repository
      if (entries.isNotEmpty) {
        final result = await lexiconRepository.bulkCreateEntries(entries);
        return result;
      }

      return const Right([]);
    } catch (e) {
      return Left(ServerFailure('AI enrichment failed: ${e.toString()}'));
    }
  }

  /// Create dictionary entry from AI suggestion
  DictionaryEntryEntity _createEntryFromAiSuggestion(
    Map<String, dynamic> suggestion,
    String languageCode,
    DifficultyLevel difficultyLevel,
  ) {
    final now = DateTime.now();

    return DictionaryEntryEntity(
      id: '', // Will be assigned by repository
      languageCode: languageCode,
      canonicalForm: suggestion['word'] as String,
      orthographyVariants: List<String>.from(suggestion['variants'] ?? []),
      ipa: suggestion['ipa'] as String?,
      audioFileReferences: const [], // To be populated later
      partOfSpeech: suggestion['partOfSpeech'] as String? ?? 'noun',
      translations: Map<String, String>.from(suggestion['translations'] ?? {}),
      exampleSentences: _parseExampleSentences(suggestion['examples']),
      tags: List<String>.from(suggestion['tags'] ?? []),
      difficultyLevel: difficultyLevel,
      contributorId: null, // AI generated
      reviewStatus: ReviewStatus.autoSuggested,
      qualityScore: (suggestion['confidence'] as num?)?.toDouble() ?? 0.5,
      lastUpdated: now,
      sourceReference: 'AI Generated',
      metadata: {
        'aiGenerated': true,
        'aiModel': 'gemini',
        'generatedAt': now.toIso8601String(),
        'confidence': suggestion['confidence'] ?? 0.5,
        'category': suggestion['category'],
      },
    );
  }

  /// Parse example sentences from AI response
  List<ExampleSentence> _parseExampleSentences(dynamic examples) {
    if (examples == null) return [];

    final sentences = <ExampleSentence>[];

    if (examples is List) {
      for (final example in examples) {
        if (example is Map<String, dynamic>) {
          sentences.add(
            ExampleSentence(
              sentence: example['sentence'] as String,
              translations: Map<String, String>.from(example['translations'] ?? {}),
              audioReference: example['audioReference'] as String?,
            ),
          );
        }
      }
    }

    return sentences;
  }
}

/// Parameters for AI vocabulary enrichment
class AiEnrichmentParams {
  final String languageCode;
  final String? category;
  final DifficultyLevel difficultyLevel;
  final int count;
  final String? context;

  const AiEnrichmentParams({
    required this.languageCode,
    this.category,
    required this.difficultyLevel,
    this.count = 10,
    this.context,
  });
}

/// Use case for expanding existing vocabulary entries with AI
class AiExpandEntryUsecase implements UseCase<DictionaryEntryEntity, AiExpansionParams> {
  final AIService aiService;
  final LexiconRepository lexiconRepository;

  AiExpandEntryUsecase({
    required this.aiService,
    required this.lexiconRepository,
  });

  @override
  Future<Either<Failure, DictionaryEntryEntity>> call(AiExpansionParams params) async {
    try {
      // Get current entry
      final entryResult = await lexiconRepository.getDictionaryEntry(params.entryId);

      return await entryResult.fold(
        (failure) async => Left(failure),
        (entry) async {
          // Generate additional content using AI
          final expansion = await aiService.expandVocabularyEntry(
            word: entry.canonicalForm,
            languageCode: entry.languageCode,
            currentData: {
              'translations': entry.translations,
              'examples': entry.exampleSentences.map((e) => e.toJson()).toList(),
              'ipa': entry.ipa,
              'partOfSpeech': entry.partOfSpeech,
            },
            expansionType: params.expansionType.name,
          );

          // Update entry with AI-generated content
          final expandedEntry = _updateEntryWithExpansion(entry, expansion);

          // Update in repository
          final updateResult = await lexiconRepository.updateEntry(expandedEntry);
          return updateResult;
        },
      );
    } catch (e) {
      return Left(ServerFailure('AI expansion failed: ${e.toString()}'));
    }
  }

  /// Update entry with AI expansion
  DictionaryEntryEntity _updateEntryWithExpansion(
    DictionaryEntryEntity entry,
    Map<String, dynamic> expansion,
  ) {
    final now = DateTime.now();

    // Merge translations
    final newTranslations = Map<String, String>.from(entry.translations);
    if (expansion['translations'] != null) {
      newTranslations.addAll(Map<String, String>.from(expansion['translations']));
    }

    // Add new example sentences
    final newExamples = List<ExampleSentence>.from(entry.exampleSentences);
    if (expansion['examples'] != null) {
      for (final example in expansion['examples'] as List) {
        if (example is Map<String, dynamic>) {
          newExamples.add(
            ExampleSentence(
              sentence: example['sentence'] as String,
              translations: Map<String, String>.from(example['translations'] ?? {}),
              audioReference: example['audioReference'] as String?,
            ),
          );
        }
      }
    }

    // Update orthography variants
    final newVariants = List<String>.from(entry.orthographyVariants);
    if (expansion['variants'] != null) {
      newVariants.addAll(List<String>.from(expansion['variants']));
    }

    // Update metadata
    final newMetadata = Map<String, dynamic>.from(entry.metadata);
    newMetadata.addAll({
      'aiExpanded': true,
      'lastAiExpansion': now.toIso8601String(),
      'expansionType': expansion['type'],
      'expansionConfidence': expansion['confidence'] ?? 0.5,
    });

    return entry.copyWith(
      translations: newTranslations,
      exampleSentences: newExamples,
      orthographyVariants: newVariants.toSet().toList(), // Remove duplicates
      ipa: expansion['ipa'] as String? ?? entry.ipa,
      lastUpdated: now,
      metadata: newMetadata,
      reviewStatus: ReviewStatus.autoSuggested, // Needs review after AI expansion
    );
  }
}

/// Parameters for AI entry expansion
class AiExpansionParams {
  final String entryId;
  final AiExpansionType expansionType;

  const AiExpansionParams({
    required this.entryId,
    required this.expansionType,
  });
}

/// Types of AI expansion
enum AiExpansionType {
  translations,
  examples,
  pronunciation,
  orthographyVariants,
  comprehensive,
}

/// Use case for AI-generated pronunciation guides
class AiGeneratePronunciationUsecase implements UseCase<String, PronunciationParams> {
  final AIService aiService;

  AiGeneratePronunciationUsecase({required this.aiService});

  @override
  Future<Either<Failure, String>> call(PronunciationParams params) async {
    try {
      final pronunciationGuide = await aiService.generatePronunciationGuide(
        word: params.word,
        languageCode: params.languageCode,
        includeIPA: params.includeIPA,
        includeDescription: params.includeDescription,
      );

      return Right(pronunciationGuide);
    } catch (e) {
      return Left(ServerFailure('Pronunciation generation failed: ${e.toString()}'));
    }
  }
}

/// Parameters for pronunciation generation
class PronunciationParams {
  final String word;
  final String languageCode;
  final bool includeIPA;
  final bool includeDescription;

  const PronunciationParams({
    required this.word,
    required this.languageCode,
    this.includeIPA = true,
    this.includeDescription = true,
  });
}