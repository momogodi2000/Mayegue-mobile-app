/// Pronunciation entity for word audio pronunciation
class PronunciationEntity {
  final String id;
  final String wordId;
  final String language;
  final String audioUrl;
  final String? phonetic;
  final int duration; // in milliseconds
  final DateTime createdAt;

  const PronunciationEntity({
    required this.id,
    required this.wordId,
    required this.language,
    required this.audioUrl,
    required this.duration,
    required this.createdAt,
    this.phonetic,
  });

  /// Create a copy with updated fields
  PronunciationEntity copyWith({
    String? id,
    String? wordId,
    String? language,
    String? audioUrl,
    String? phonetic,
    int? duration,
    DateTime? createdAt,
  }) {
    return PronunciationEntity(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      language: language ?? this.language,
      audioUrl: audioUrl ?? this.audioUrl,
      phonetic: phonetic ?? this.phonetic,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PronunciationEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
