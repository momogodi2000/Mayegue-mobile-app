import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';

/// Course model for data serialization
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.languageCode,
    required super.thumbnailUrl,
    required super.lessons,
    required super.estimatedDuration,
    required super.level,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create CourseModel from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      languageCode: json['languageCode'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      lessons: List<Lesson>.from(json['lessons'] as List),
      estimatedDuration: json['estimatedDuration'] as int,
      level: CourseLevel.values.firstWhere((e) => e.name == json['level']),
      status: CourseStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert CourseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'languageCode': languageCode,
      'thumbnailUrl': thumbnailUrl,
      'lessons': lessons,
      'estimatedDuration': estimatedDuration,
      'level': level.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create CourseModel from Course entity
  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      title: course.title,
      description: course.description,
      languageCode: course.languageCode,
      thumbnailUrl: course.thumbnailUrl,
      lessons: course.lessons,
      estimatedDuration: course.estimatedDuration,
      level: course.level,
      status: course.status,
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
    );
  }

  /// Convert to Course entity
  Course toEntity() {
    return Course(
      id: id,
      title: title,
      description: description,
      languageCode: languageCode,
      thumbnailUrl: thumbnailUrl,
      lessons: lessons,
      estimatedDuration: estimatedDuration,
      level: level,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
