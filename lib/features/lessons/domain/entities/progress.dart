import 'package:equatable/equatable.dart';

/// Progress entity representing user progress in lessons and courses
class Progress extends Equatable {
  final String id;
  final String userId;
  final String lessonId;
  final String courseId;
  final ProgressStatus status;
  final int
      currentPosition; // current position in lesson content (for videos/audio)
  final int score; // score for quizzes/exercises
  final int timeSpent; // time spent in seconds
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime lastAccessedAt;

  const Progress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.courseId,
    required this.status,
    required this.currentPosition,
    required this.score,
    required this.timeSpent,
    required this.startedAt,
    this.completedAt,
    required this.lastAccessedAt,
  });

  /// Check if progress is completed
  bool get isCompleted => status == ProgressStatus.completed;

  /// Check if progress is in progress
  bool get isInProgress => status == ProgressStatus.inProgress;

  /// Calculate completion percentage (0-100)
  double get completionPercentage {
    // For now, simple binary completion. Could be enhanced for partial completion
    return isCompleted ? 100.0 : 0.0;
  }

  /// Create a copy with updated fields
  Progress copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? courseId,
    ProgressStatus? status,
    int? currentPosition,
    int? score,
    int? timeSpent,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return Progress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      courseId: courseId ?? this.courseId,
      status: status ?? this.status,
      currentPosition: currentPosition ?? this.currentPosition,
      score: score ?? this.score,
      timeSpent: timeSpent ?? this.timeSpent,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        lessonId,
        courseId,
        status,
        currentPosition,
        score,
        timeSpent,
        startedAt,
        completedAt,
        lastAccessedAt,
      ];
}

/// Enum for progress status
enum ProgressStatus {
  notStarted, // Not started yet
  inProgress, // Currently working on it
  completed, // Finished successfully
  skipped, // Skipped by user
}
