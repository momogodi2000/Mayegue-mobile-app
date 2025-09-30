import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dictionary_entity.dart';

/// Dictionary model for Firestore operations
class DictionaryModel {
  final String id;
  final String word;
  final String sourceLanguage;
  final Map<String, String> translations;
  final Map<String, String>? pronunciations;
  final Map<String, List<String>>? examples;
  final List<String>? categories;
  final String? partOfSpeech;
  final String? definition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final int usageCount;

  const DictionaryModel({
    required this.id,
    required this.word,
    required this.sourceLanguage,
    required this.translations,
    this.pronunciations,
    this.examples,
    this.categories,
    this.partOfSpeech,
    this.definition,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.usageCount = 0,
  });

  /// Create model from Firestore document
  factory DictionaryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DictionaryModel(
      id: doc.id,
      word: data['word'] ?? '',
      sourceLanguage: data['sourceLanguage'] ?? '',
      translations: Map<String, String>.from(data['translations'] ?? {}),
      pronunciations: data['pronunciations'] != null
          ? Map<String, String>.from(data['pronunciations'])
          : null,
      examples: data['examples'] != null
          ? Map<String, List<String>>.from(
              data['examples'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
      categories: data['categories'] != null
          ? List<String>.from(data['categories'])
          : null,
      partOfSpeech: data['partOfSpeech'],
      definition: data['definition'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'],
      usageCount: data['usageCount'] ?? 0,
    );
  }

  /// Convert model to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'sourceLanguage': sourceLanguage,
      'translations': translations,
      'pronunciations': pronunciations,
      'examples': examples,
      'categories': categories,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'usageCount': usageCount,
    };
  }

  /// Create model from JSON
  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      sourceLanguage: json['sourceLanguage'] ?? '',
      translations: Map<String, String>.from(json['translations'] ?? {}),
      pronunciations: json['pronunciations'] != null
          ? Map<String, String>.from(json['pronunciations'])
          : null,
      examples: json['examples'] != null
          ? Map<String, List<String>>.from(
              json['examples'].map((key, value) =>
                  MapEntry(key, List<String>.from(value))))
          : null,
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      partOfSpeech: json['partOfSpeech'],
      definition: json['definition'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'],
      usageCount: json['usageCount'] ?? 0,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'sourceLanguage': sourceLanguage,
      'translations': translations,
      'pronunciations': pronunciations,
      'examples': examples,
      'categories': categories,
      'partOfSpeech': partOfSpeech,
      'definition': definition,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'usageCount': usageCount,
    };
  }

  /// Convert to domain entity
  DictionaryEntity toEntity() {
    return DictionaryEntity(
      id: id,
      word: word,
      sourceLanguage: sourceLanguage,
      translations: translations,
      pronunciations: pronunciations,
      examples: examples,
      categories: categories,
      partOfSpeech: partOfSpeech,
      definition: definition,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      usageCount: usageCount,
    );
  }

  /// Create model from domain entity
  factory DictionaryModel.fromEntity(DictionaryEntity entity) {
    return DictionaryModel(
      id: entity.id,
      word: entity.word,
      sourceLanguage: entity.sourceLanguage,
      translations: entity.translations,
      pronunciations: entity.pronunciations,
      examples: entity.examples,
      categories: entity.categories,
      partOfSpeech: entity.partOfSpeech,
      definition: entity.definition,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      usageCount: entity.usageCount,
    );
  }
}