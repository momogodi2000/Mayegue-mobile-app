import '../../domain/entities/lesson_content.dart';

/// LessonContent model for data serialization
class LessonContentModel extends LessonContent {
  const LessonContentModel({
    required String id,
    required String lessonId,
    required ContentType type,
    required String content,
    String? audioUrl,
    String? imageUrl,
    String? videoUrl,
    Map<String, dynamic>? metadata,
    required int order,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          lessonId: lessonId,
          type: type,
          content: content,
          audioUrl: audioUrl,
          imageUrl: imageUrl,
          videoUrl: videoUrl,
          metadata: metadata,
          order: order,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Create LessonContentModel from JSON
  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: ContentType.values[json['type'] as int],
      content: json['content'] as String,
      audioUrl: json['audioUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert LessonContentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'type': type.index,
      'content': content,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'metadata': metadata,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create LessonContentModel from LessonContent entity
  factory LessonContentModel.fromEntity(LessonContent content) {
    return LessonContentModel(
      id: content.id,
      lessonId: content.lessonId,
      type: content.type,
      content: content.content,
      audioUrl: content.audioUrl,
      imageUrl: content.imageUrl,
      videoUrl: content.videoUrl,
      metadata: content.metadata,
      order: content.order,
      createdAt: content.createdAt,
      updatedAt: content.updatedAt,
    );
  }

  /// Convert to LessonContent entity
  LessonContent toEntity() {
    return LessonContent(
      id: id,
      lessonId: lessonId,
      type: type,
      content: content,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      metadata: metadata,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
