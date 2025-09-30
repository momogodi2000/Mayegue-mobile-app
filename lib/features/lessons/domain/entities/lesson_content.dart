import 'package:equatable/equatable.dart';

/// Lesson content entity representing different types of content within a lesson
class LessonContent extends Equatable {
  final String id;
  final String lessonId;
  final ContentType type;
  final String content;
  final String? audioUrl;
  final String? imageUrl;
  final String? videoUrl;
  final Map<String, dynamic>? metadata;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonContent({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.content,
    this.audioUrl,
    this.imageUrl,
    this.videoUrl,
    this.metadata,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  LessonContent copyWith({
    String? id,
    String? lessonId,
    ContentType? type,
    String? content,
    String? audioUrl,
    String? imageUrl,
    String? videoUrl,
    Map<String, dynamic>? metadata,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonContent(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      metadata: metadata ?? this.metadata,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        lessonId,
        type,
        content,
        audioUrl,
        imageUrl,
        videoUrl,
        metadata,
        order,
        createdAt,
        updatedAt,
      ];
}

/// Content type enumeration
enum ContentType {
  text,
  audio,
  image,
  video,
  interactive,
  quiz,
  exercise,
  phonetic,
}
