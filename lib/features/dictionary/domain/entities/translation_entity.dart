/// Translation entity for word translations
class TranslationEntity {
  final String id;
  final String wordId;
  final String sourceLanguage;
  final String targetLanguage;
  final String translation;
  final String? context;
  final bool isPrimary;
  final DateTime createdAt;

  const TranslationEntity({
    required this.id,
    required this.wordId,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translation,
    required this.isPrimary,
    required this.createdAt,
    this.context,
  });

  /// Create a copy with updated fields
  TranslationEntity copyWith({
    String? id,
    String? wordId,
    String? sourceLanguage,
    String? targetLanguage,
    String? translation,
    String? context,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return TranslationEntity(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TranslationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
