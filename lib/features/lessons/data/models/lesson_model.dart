import '../../domain/entities/lesson.dart';
import '../../domain/entities/lesson_content.dart';
import 'lesson_content_model.dart';

/// Lesson model for data serialization
class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.description,
    required super.order,
    required super.type,
    required super.status,
    required super.estimatedDuration,
    required super.thumbnailUrl,
    required super.contents,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create LessonModel from JSON
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      type: LessonType.values[json['type'] as int],
      status: LessonStatus.values[json['status'] as int],
      estimatedDuration: json['estimatedDuration'] as int,
      thumbnailUrl: json['thumbnailUrl'] as String,
      contents: (json['contents'] as List)
          .map((content) =>
              LessonContentModel.fromJson(content as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert LessonModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'order': order,
      'type': type.index,
      'status': status.index,
      'estimatedDuration': estimatedDuration,
      'thumbnailUrl': thumbnailUrl,
      'contents': contents
          .map((content) => (content as LessonContentModel).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create LessonModel from Lesson entity
  factory LessonModel.fromEntity(Lesson lesson) {
    return LessonModel(
      id: lesson.id,
      courseId: lesson.courseId,
      title: lesson.title,
      description: lesson.description,
      order: lesson.order,
      type: lesson.type,
      status: lesson.status,
      estimatedDuration: lesson.estimatedDuration,
      thumbnailUrl: lesson.thumbnailUrl,
      contents: lesson.contents,
      createdAt: lesson.createdAt,
      updatedAt: lesson.updatedAt,
    );
  }

  /// Convert to Lesson entity
  Lesson toEntity() {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      description: description,
      order: order,
      type: type,
      status: status,
      estimatedDuration: estimatedDuration,
      thumbnailUrl: thumbnailUrl,
      contents: contents,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'lesson_id': int.tryParse(id) ?? 0,
      'language_id': courseId,
      'title': title,
      'description': description,
      'order_index': order,
      'type': type.name,
      'status': status.name,
      'estimated_duration': estimatedDuration,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  @override
  LessonModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? order,
    LessonType? type,
    LessonStatus? status,
    int? estimatedDuration,
    String? thumbnailUrl,
    List<LessonContent>? contents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      type: type ?? this.type,
      status: status ?? this.status,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
