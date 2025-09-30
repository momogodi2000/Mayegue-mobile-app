import '../../domain/entities/translation_entity.dart';

/// Translation model for data layer
class TranslationModel extends TranslationEntity {
  const TranslationModel({
    required super.id,
    required super.wordId,
    required super.sourceLanguage,
    required super.targetLanguage,
    required super.translation,
    required super.isPrimary,
    required super.createdAt,
    super.context,
  });

  /// Create from JSON
  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] as String,
      wordId: json['wordId'] as String,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      translation: json['translation'] as String,
      context: json['context'] as String?,
      isPrimary: json['isPrimary'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create from Firestore document
  factory TranslationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TranslationModel(
      id: id,
      wordId: data['wordId'] as String,
      sourceLanguage: data['sourceLanguage'] as String,
      targetLanguage: data['targetLanguage'] as String,
      translation: data['translation'] as String,
      context: data['context'] as String?,
      isPrimary: data['isPrimary'] as bool,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wordId': wordId,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'translation': translation,
      'context': context,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'wordId': wordId,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'translation': translation,
      'context': context,
      'isPrimary': isPrimary,
      'createdAt': createdAt,
    };
  }

  /// Convert to entity
  TranslationEntity toEntity() {
    return TranslationEntity(
      id: id,
      wordId: wordId,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translation: translation,
      context: context,
      isPrimary: isPrimary,
      createdAt: createdAt,
    );
  }

  /// Create a copy with updated fields
  @override
  TranslationModel copyWith({
    String? id,
    String? wordId,
    String? sourceLanguage,
    String? targetLanguage,
    String? translation,
    String? context,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return TranslationModel(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translation: translation ?? this.translation,
      context: context ?? this.context,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
