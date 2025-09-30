import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dictionary_entry_entity.dart';

/// Dictionary entry data model for Firebase Firestore
class DictionaryEntryModel extends DictionaryEntryEntity {
  const DictionaryEntryModel({
    required super.id,
    required super.languageCode,
    required super.canonicalForm,
    required super.orthographyVariants,
    super.ipa,
    required super.audioFileReferences,
    required super.partOfSpeech,
    required super.translations,
    required super.exampleSentences,
    required super.tags,
    required super.difficultyLevel,
    super.contributorId,
    required super.reviewStatus,
    required super.qualityScore,
    required super.lastUpdated,
    super.sourceReference,
    required super.metadata,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'languageCode': languageCode,
      'canonicalForm': canonicalForm,
      'orthographyVariants': orthographyVariants,
      'ipa': ipa,
      'audioFileReferences': audioFileReferences,
      'partOfSpeech': partOfSpeech,
      'translations': translations,
      'exampleSentences': exampleSentences.map((e) => e.toJson()).toList(),
      'tags': tags,
      'difficultyLevel': difficultyLevel.index,
      'contributorId': contributorId,
      'reviewStatus': reviewStatus.index,
      'qualityScore': qualityScore,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'sourceReference': sourceReference,
      'metadata': metadata,
      'searchTerms': _generateSearchTerms(),
    };
  }

  /// Create from Firestore document
  factory DictionaryEntryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    return DictionaryEntryModel(
      id: snapshot.id,
      languageCode: data['languageCode'] as String,
      canonicalForm: data['canonicalForm'] as String,
      orthographyVariants: List<String>.from(data['orthographyVariants'] as List),
      ipa: data['ipa'] as String?,
      audioFileReferences: List<String>.from(data['audioFileReferences'] as List),
      partOfSpeech: data['partOfSpeech'] as String,
      translations: Map<String, String>.from(data['translations'] as Map),
      exampleSentences: (data['exampleSentences'] as List)
          .map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: List<String>.from(data['tags'] as List),
      difficultyLevel: DifficultyLevel.values[data['difficultyLevel'] as int],
      contributorId: data['contributorId'] as String?,
      reviewStatus: ReviewStatus.values[data['reviewStatus'] as int],
      qualityScore: (data['qualityScore'] as num).toDouble(),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      sourceReference: data['sourceReference'] as String?,
      metadata: Map<String, dynamic>.from(data['metadata'] as Map? ?? {}),
    );
  }

  /// Create from SQLite row
  factory DictionaryEntryModel.fromSQLite(Map<String, dynamic> map) {
    return DictionaryEntryModel(
      id: map['id'] as String,
      languageCode: map['language_code'] as String,
      canonicalForm: map['canonical_form'] as String,
      orthographyVariants: map['orthography_variants'] != null
          ? List<String>.from(jsonDecode(map['orthography_variants'] as String))
          : [],
      ipa: map['ipa'] as String?,
      audioFileReferences: map['audio_file_references'] != null
          ? List<String>.from(jsonDecode(map['audio_file_references'] as String))
          : [],
      partOfSpeech: map['part_of_speech'] as String,
      translations: map['translations'] != null
          ? Map<String, String>.from(jsonDecode(map['translations'] as String))
          : {},
      exampleSentences: map['example_sentences'] != null
          ? (jsonDecode(map['example_sentences'] as String) as List)
              .map((e) => ExampleSentence.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      tags: map['tags'] != null
          ? List<String>.from(jsonDecode(map['tags'] as String))
          : [],
      difficultyLevel: DifficultyLevel.values.firstWhere(
        (e) => e.toString().split('.').last == map['difficulty_level'],
        orElse: () => DifficultyLevel.beginner,
      ),
      contributorId: map['contributor_id'] as String?,
      reviewStatus: ReviewStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['review_status'],
        orElse: () => ReviewStatus.autoSuggested,
      ),
      qualityScore: (map['quality_score'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['last_updated'] as int),
      sourceReference: map['source_reference'] as String?,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(jsonDecode(map['metadata'] as String))
          : {},
    );
  }

  /// Create from domain entity
  factory DictionaryEntryModel.fromEntity(DictionaryEntryEntity entity) {
    return DictionaryEntryModel(
      id: entity.id,
      languageCode: entity.languageCode,
      canonicalForm: entity.canonicalForm,
      orthographyVariants: entity.orthographyVariants,
      ipa: entity.ipa,
      audioFileReferences: entity.audioFileReferences,
      partOfSpeech: entity.partOfSpeech,
      translations: entity.translations,
      exampleSentences: entity.exampleSentences,
      tags: entity.tags,
      difficultyLevel: entity.difficultyLevel,
      contributorId: entity.contributorId,
      reviewStatus: entity.reviewStatus,
      qualityScore: entity.qualityScore,
      lastUpdated: entity.lastUpdated,
      sourceReference: entity.sourceReference,
      metadata: entity.metadata,
    );
  }

  /// Convert to domain entity
  DictionaryEntryEntity toEntity() {
    return DictionaryEntryEntity(
      id: id,
      languageCode: languageCode,
      canonicalForm: canonicalForm,
      orthographyVariants: orthographyVariants,
      ipa: ipa,
      audioFileReferences: audioFileReferences,
      partOfSpeech: partOfSpeech,
      translations: translations,
      exampleSentences: exampleSentences,
      tags: tags,
      difficultyLevel: difficultyLevel,
      contributorId: contributorId,
      reviewStatus: reviewStatus,
      qualityScore: qualityScore,
      lastUpdated: lastUpdated,
      sourceReference: sourceReference,
      metadata: metadata,
    );
  }

  /// Convert to SQLite row
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'language_code': languageCode,
      'canonical_form': canonicalForm,
      'orthography_variants': jsonEncode(orthographyVariants),
      'ipa': ipa,
      'audio_file_references': jsonEncode(audioFileReferences),
      'part_of_speech': partOfSpeech,
      'translations': jsonEncode(translations),
      'example_sentences': jsonEncode(exampleSentences.map((e) => e.toJson()).toList()),
      'tags': jsonEncode(tags),
      'difficulty_level': difficultyLevel.toString().split('.').last,
      'contributor_id': contributorId,
      'review_status': reviewStatus.toString().split('.').last,
      'quality_score': qualityScore,
      'last_updated': lastUpdated.millisecondsSinceEpoch,
      'source_reference': sourceReference,
      'metadata': jsonEncode(metadata),
      'search_terms': jsonEncode(_generateSearchTerms()),
    };
  }

  /// Generate search terms for full-text search
  List<String> _generateSearchTerms() {
    final terms = <String>[];

    // Add canonical form and variants
    terms.add(canonicalForm.toLowerCase());
    terms.addAll(orthographyVariants.map((v) => v.toLowerCase()));

    // Add translations
    terms.addAll(translations.values.map((t) => t.toLowerCase()));

    // Add tags
    terms.addAll(tags.map((t) => t.toLowerCase()));

    // Add part of speech
    terms.add(partOfSpeech.toLowerCase());

    // Add language code
    terms.add(languageCode.toLowerCase());

    // Generate n-grams for partial matching
    for (final term in [canonicalForm, ...orthographyVariants, ...translations.values]) {
      terms.addAll(_generateNGrams(term.toLowerCase(), 2));
      terms.addAll(_generateNGrams(term.toLowerCase(), 3));
    }

    return terms.toSet().toList(); // Remove duplicates
  }

  /// Generate n-grams for partial text matching
  List<String> _generateNGrams(String text, int n) {
    if (text.length < n) return [text];

    final ngrams = <String>[];
    for (int i = 0; i <= text.length - n; i++) {
      ngrams.add(text.substring(i, i + n));
    }
    return ngrams;
  }

  /// Create a new entry with AI suggestion metadata
  DictionaryEntryModel withAiSuggestion({
    required String aiModel,
    required double confidence,
    Map<String, dynamic>? additionalMetadata,
  }) {
    final aiMetadata = {
      'aiGenerated': true,
      'aiModel': aiModel,
      'confidence': confidence,
      'generatedAt': DateTime.now().toIso8601String(),
      ...?additionalMetadata,
    };

    return DictionaryEntryModel(
      id: id,
      languageCode: languageCode,
      canonicalForm: canonicalForm,
      orthographyVariants: orthographyVariants,
      ipa: ipa,
      audioFileReferences: audioFileReferences,
      partOfSpeech: partOfSpeech,
      translations: translations,
      exampleSentences: exampleSentences,
      tags: tags,
      difficultyLevel: difficultyLevel,
      contributorId: contributorId,
      reviewStatus: ReviewStatus.autoSuggested,
      qualityScore: confidence,
      lastUpdated: DateTime.now(),
      sourceReference: sourceReference,
      metadata: {...metadata, ...aiMetadata},
    );
  }

  /// Mark as human verified
  DictionaryEntryModel markAsVerified(String reviewerId) {
    return DictionaryEntryModel(
      id: id,
      languageCode: languageCode,
      canonicalForm: canonicalForm,
      orthographyVariants: orthographyVariants,
      ipa: ipa,
      audioFileReferences: audioFileReferences,
      partOfSpeech: partOfSpeech,
      translations: translations,
      exampleSentences: exampleSentences,
      tags: tags,
      difficultyLevel: difficultyLevel,
      contributorId: contributorId,
      reviewStatus: ReviewStatus.humanVerified,
      qualityScore: qualityScore,
      lastUpdated: DateTime.now(),
      sourceReference: sourceReference,
      metadata: {
        ...metadata,
        'reviewedBy': reviewerId,
        'reviewedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}