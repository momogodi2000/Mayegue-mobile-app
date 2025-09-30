import 'package:equatable/equatable.dart';

/// Canonical dictionary entry entity - single source of truth for words
class DictionaryEntryEntity extends Equatable {
  final String id;
  final String languageCode;
  final String canonicalForm;
  final List<String> orthographyVariants;
  final String? ipa; // International Phonetic Alphabet
  final List<String> audioFileReferences;
  final String partOfSpeech;
  final Map<String, String> translations; // language_code -> translation
  final List<ExampleSentence> exampleSentences;
  final List<String> tags;
  final DifficultyLevel difficultyLevel;
  final String? contributorId;
  final ReviewStatus reviewStatus;
  final double qualityScore;
  final DateTime lastUpdated;
  final String? sourceReference;
  final Map<String, dynamic> metadata;

  const DictionaryEntryEntity({
    required this.id,
    required this.languageCode,
    required this.canonicalForm,
    required this.orthographyVariants,
    this.ipa,
    required this.audioFileReferences,
    required this.partOfSpeech,
    required this.translations,
    required this.exampleSentences,
    required this.tags,
    required this.difficultyLevel,
    this.contributorId,
    required this.reviewStatus,
    required this.qualityScore,
    required this.lastUpdated,
    this.sourceReference,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        languageCode,
        canonicalForm,
        orthographyVariants,
        ipa,
        audioFileReferences,
        partOfSpeech,
        translations,
        exampleSentences,
        tags,
        difficultyLevel,
        contributorId,
        reviewStatus,
        qualityScore,
        lastUpdated,
        sourceReference,
        metadata,
      ];

  DictionaryEntryEntity copyWith({
    String? id,
    String? languageCode,
    String? canonicalForm,
    List<String>? orthographyVariants,
    String? ipa,
    List<String>? audioFileReferences,
    String? partOfSpeech,
    Map<String, String>? translations,
    List<ExampleSentence>? exampleSentences,
    List<String>? tags,
    DifficultyLevel? difficultyLevel,
    String? contributorId,
    ReviewStatus? reviewStatus,
    double? qualityScore,
    DateTime? lastUpdated,
    String? sourceReference,
    Map<String, dynamic>? metadata,
  }) {
    return DictionaryEntryEntity(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      canonicalForm: canonicalForm ?? this.canonicalForm,
      orthographyVariants: orthographyVariants ?? this.orthographyVariants,
      ipa: ipa ?? this.ipa,
      audioFileReferences: audioFileReferences ?? this.audioFileReferences,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      translations: translations ?? this.translations,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      tags: tags ?? this.tags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      contributorId: contributorId ?? this.contributorId,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      qualityScore: qualityScore ?? this.qualityScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sourceReference: sourceReference ?? this.sourceReference,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Example sentence with translation
class ExampleSentence extends Equatable {
  final String sentence;
  final Map<String, String> translations; // language_code -> translation
  final String? audioReference;

  const ExampleSentence({
    required this.sentence,
    required this.translations,
    this.audioReference,
  });

  @override
  List<Object?> get props => [sentence, translations, audioReference];

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'translations': translations,
      'audioReference': audioReference,
    };
  }

  factory ExampleSentence.fromJson(Map<String, dynamic> json) {
    return ExampleSentence(
      sentence: json['sentence'] as String,
      translations: Map<String, String>.from(json['translations'] as Map),
      audioReference: json['audioReference'] as String?,
    );
  }
}

/// Review status for dictionary entries
enum ReviewStatus {
  autoSuggested,
  humanVerified,
  rejected,
  pendingReview,
}

/// Difficulty levels for words
enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

/// Parts of speech for dictionary entries
enum PartOfSpeech {
  noun,
  verb,
  adjective,
  adverb,
  pronoun,
  preposition,
  conjunction,
  interjection,
  article,
  determiner,
  particle,
}

/// Extension for ReviewStatus display
extension ReviewStatusExtension on ReviewStatus {
  String get displayName {
    switch (this) {
      case ReviewStatus.autoSuggested:
        return 'Suggestion IA';
      case ReviewStatus.humanVerified:
        return 'Vérifié';
      case ReviewStatus.rejected:
        return 'Rejeté';
      case ReviewStatus.pendingReview:
        return 'En attente';
    }
  }

  bool get isVerified => this == ReviewStatus.humanVerified;
  bool get isPending => this == ReviewStatus.pendingReview;
  bool get isAiSuggested => this == ReviewStatus.autoSuggested;
}

/// Extension for DifficultyLevel display
extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Débutant';
      case DifficultyLevel.intermediate:
        return 'Intermédiaire';
      case DifficultyLevel.advanced:
        return 'Avancé';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  int get level => index + 1;
}

/// Extension for PartOfSpeech display
extension PartOfSpeechExtension on PartOfSpeech {
  String get displayName {
    switch (this) {
      case PartOfSpeech.noun:
        return 'Nom';
      case PartOfSpeech.verb:
        return 'Verbe';
      case PartOfSpeech.adjective:
        return 'Adjectif';
      case PartOfSpeech.adverb:
        return 'Adverbe';
      case PartOfSpeech.pronoun:
        return 'Pronom';
      case PartOfSpeech.preposition:
        return 'Préposition';
      case PartOfSpeech.conjunction:
        return 'Conjonction';
      case PartOfSpeech.interjection:
        return 'Interjection';
      case PartOfSpeech.article:
        return 'Article';
      case PartOfSpeech.determiner:
        return 'Déterminant';
      case PartOfSpeech.particle:
        return 'Particule';
    }
  }

  String get englishName => name;
}