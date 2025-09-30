import 'package:equatable/equatable.dart';
import 'lesson.dart';

/// Course entity representing a collection of lessons
class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String languageCode;
  final String thumbnailUrl;
  final List<Lesson> lessons;
  final int estimatedDuration; // in minutes
  final CourseLevel level;
  final CourseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.thumbnailUrl,
    required this.lessons,
    required this.estimatedDuration,
    required this.level,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get completed lessons count
  int get completedLessonsCount => lessons.where((l) => l.isCompleted).length;

  /// Get total lessons count
  int get totalLessonsCount => lessons.length;

  /// Get progress percentage
  double get progressPercentage {
    if (totalLessonsCount == 0) return 0.0;
    return completedLessonsCount / totalLessonsCount;
  }

  /// Check if course is completed
  bool get isCompleted => progressPercentage >= 1.0;

  /// Check if course is in progress
  bool get isInProgress => progressPercentage > 0.0 && !isCompleted;

  /// Create a copy with updated fields
  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? languageCode,
    String? thumbnailUrl,
    List<Lesson>? lessons,
    int? estimatedDuration,
    CourseLevel? level,
    CourseStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      languageCode: languageCode ?? this.languageCode,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lessons: lessons ?? this.lessons,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      level: level ?? this.level,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        languageCode,
        thumbnailUrl,
        lessons,
        estimatedDuration,
        level,
        status,
        createdAt,
        updatedAt,
      ];
}

/// Course level enumeration
enum CourseLevel {
  beginner,
  intermediate,
  advanced,
}

/// Course status enumeration
enum CourseStatus {
  draft,
  published,
  archived,
}
