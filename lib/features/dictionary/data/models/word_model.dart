import '../../domain/entities/word_entity.dart';

/// Word model for data layer
class WordModel extends WordEntity {
  const WordModel({
    required super.id,
    required super.word,
    required super.language,
    required super.translation,
    required super.category,
    required super.difficulty,
    required super.createdAt,
    required super.updatedAt,
    super.pronunciation,
    super.phonetic,
    super.definition,
    super.example,
    super.audioUrl,
    super.synonyms,
    super.antonyms,
  });

  /// Create from JSON
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String,
      word: json['word'] as String,
      language: json['language'] as String,
      translation: json['translation'] as String,
      pronunciation: json['pronunciation'] as String?,
      phonetic: json['phonetic'] as String?,
      definition: json['definition'] as String?,
      example: json['example'] as String?,
      audioUrl: json['audioUrl'] as String?,
      synonyms: (json['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      antonyms: (json['antonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create from Firestore document
  factory WordModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WordModel(
      id: id,
      word: data['word'] as String,
      language: data['language'] as String,
      translation: data['translation'] as String,
      pronunciation: data['pronunciation'] as String?,
      phonetic: data['phonetic'] as String?,
      definition: data['definition'] as String?,
      example: data['example'] as String?,
      audioUrl: data['audioUrl'] as String?,
      synonyms: (data['synonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      antonyms: (data['antonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      category: data['category'] as String,
      difficulty: data['difficulty'] as int,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'language': language,
      'translation': translation,
      'pronunciation': pronunciation,
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'audioUrl': audioUrl,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'category': category,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'language': language,
      'translation': translation,
      'pronunciation': pronunciation,
      'phonetic': phonetic,
      'definition': definition,
      'example': example,
      'audioUrl': audioUrl,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'category': category,
      'difficulty': difficulty,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Convert to entity
  WordEntity toEntity() {
    return WordEntity(
      id: id,
      word: word,
      language: language,
      translation: translation,
      pronunciation: pronunciation,
      phonetic: phonetic,
      definition: definition,
      example: example,
      audioUrl: audioUrl,
      synonyms: synonyms,
      antonyms: antonyms,
      category: category,
      difficulty: difficulty,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  WordModel copyWith({
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
    return WordModel(
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
}
