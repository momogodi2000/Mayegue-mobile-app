import '../../domain/entities/pronunciation_entity.dart';

/// Pronunciation model for data layer
class PronunciationModel extends PronunciationEntity {
  const PronunciationModel({
    required super.id,
    required super.wordId,
    required super.language,
    required super.audioUrl,
    required super.duration,
    required super.createdAt,
    super.phonetic,
  });

  /// Create from JSON
  factory PronunciationModel.fromJson(Map<String, dynamic> json) {
    return PronunciationModel(
      id: json['id'] as String,
      wordId: json['wordId'] as String,
      language: json['language'] as String,
      audioUrl: json['audioUrl'] as String,
      phonetic: json['phonetic'] as String?,
      duration: json['duration'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create from Firestore document
  factory PronunciationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PronunciationModel(
      id: id,
      wordId: data['wordId'] as String,
      language: data['language'] as String,
      audioUrl: data['audioUrl'] as String,
      phonetic: data['phonetic'] as String?,
      duration: data['duration'] as int,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wordId': wordId,
      'language': language,
      'audioUrl': audioUrl,
      'phonetic': phonetic,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'wordId': wordId,
      'language': language,
      'audioUrl': audioUrl,
      'phonetic': phonetic,
      'duration': duration,
      'createdAt': createdAt,
    };
  }

  /// Convert to entity
  PronunciationEntity toEntity() {
    return PronunciationEntity(
      id: id,
      wordId: wordId,
      language: language,
      audioUrl: audioUrl,
      phonetic: phonetic,
      duration: duration,
      createdAt: createdAt,
    );
  }
}