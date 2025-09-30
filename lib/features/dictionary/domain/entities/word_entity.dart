/// Word entity representing a dictionary entry
class WordEntity {
  final String id;
  final String word;
  final String language;
  final String translation;
  final String? pronunciation;
  final String? phonetic;
  final String? definition;
  final String? example;
  final String? audioUrl;
  final List<String> synonyms;
  final List<String> antonyms;
  final String category;
  final int difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WordEntity({
    required this.id,
    required this.word,
    required this.language,
    required this.translation,
    required this.category,
    required this.difficulty,
    required this.createdAt,
    required this.updatedAt,
    this.pronunciation,
    this.phonetic,
    this.definition,
    this.example,
    this.audioUrl,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  /// Create a copy with updated fields
  WordEntity copyWith({
    String? id,
    String? word,
    String? language,
    String? translation,
    String? pronunciation,
    String? phonetic,
    String? definition,
    String? example,
    String? audioUrl,
    List<String>? synonyms,
    List<String>? antonyms,
    String? category,
    int? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WordEntity(
      id: id ?? this.id,
      word: word ?? this.word,
      language: language ?? this.language,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      phonetic: phonetic ?? this.phonetic,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      audioUrl: audioUrl ?? this.audioUrl,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
