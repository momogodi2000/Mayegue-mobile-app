import '../../domain/entities/progress.dart';

/// Progress model for data serialization
class ProgressModel extends Progress {
  const ProgressModel({
    required super.id,
    required super.userId,
    required super.lessonId,
    required super.courseId,
    required super.status,
    required super.currentPosition,
    required super.score,
    required super.timeSpent,
    required super.startedAt,
    super.completedAt,
    required super.lastAccessedAt,
  });

  /// Create ProgressModel from JSON
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      lessonId: json['lessonId'] as String,
      courseId: json['courseId'] as String,
      status: ProgressStatus.values[json['status'] as int],
      currentPosition: json['currentPosition'] as int,
      score: json['score'] as int,
      timeSpent: json['timeSpent'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] as String),
    );
  }

  /// Convert ProgressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'courseId': courseId,
      'status': status.index,
      'currentPosition': currentPosition,
      'score': score,
      'timeSpent': timeSpent,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
    };
  }

  /// Create ProgressModel from Progress entity
  factory ProgressModel.fromEntity(Progress progress) {
    return ProgressModel(
      id: progress.id,
      userId: progress.userId,
      lessonId: progress.lessonId,
      courseId: progress.courseId,
      status: progress.status,
      currentPosition: progress.currentPosition,
      score: progress.score,
      timeSpent: progress.timeSpent,
      startedAt: progress.startedAt,
      completedAt: progress.completedAt,
      lastAccessedAt: progress.lastAccessedAt,
    );
  }

  /// Convert to Progress entity
  Progress toEntity() {
    return Progress(
      id: id,
      userId: userId,
      lessonId: lessonId,
      courseId: courseId,
      status: status,
      currentPosition: currentPosition,
      score: score,
      timeSpent: timeSpent,
      startedAt: startedAt,
      completedAt: completedAt,
      lastAccessedAt: lastAccessedAt,
    );
  }
}
