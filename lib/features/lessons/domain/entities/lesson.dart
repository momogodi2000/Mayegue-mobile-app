import 'package:equatable/equatable.dart';
import 'lesson_content.dart';

/// Lesson entity representing an individual lesson within a course
class Lesson extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int order;
  final LessonType type;
  final LessonStatus status;
  final int estimatedDuration; // in minutes
  final String thumbnailUrl;
  final List<LessonContent> contents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.order,
    required this.type,
    required this.status,
    required this.estimatedDuration,
    required this.thumbnailUrl,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if lesson is completed
  bool get isCompleted => status == LessonStatus.completed;

  /// Check if lesson is in progress
  bool get isInProgress => status == LessonStatus.inProgress;

  /// Check if lesson is locked
  bool get isLocked => status == LessonStatus.locked;

  /// Create a copy with updated fields
  Lesson copyWith({
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
    return Lesson(
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

  @override
  List<Object?> get props => [
        id,
        courseId,
        title,
        description,
        order,
        type,
        status,
        estimatedDuration,
        thumbnailUrl,
        contents,
        createdAt,
        updatedAt,
      ];
}

/// Lesson type enumeration
enum LessonType {
  vocabulary,
  grammar,
  conversation,
  pronunciation,
  culture,
  assessment,
}

/// Lesson status enumeration
enum LessonStatus {
  locked,
  available,
  inProgress,
  completed,
}
