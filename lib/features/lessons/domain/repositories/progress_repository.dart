import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/progress.dart';

/// Abstract repository for progress operations
abstract class ProgressRepository {
  /// Get user progress for all lessons
  Future<Either<Failure, List<Progress>>> getUserProgress(String userId);

  /// Get progress for a specific lesson
  Future<Either<Failure, Progress?>> getLessonProgress(String userId, String lessonId);

  /// Get progress for a specific course
  Future<Either<Failure, List<Progress>>> getCourseProgress(String userId, String courseId);

  /// Save or update progress
  Future<Either<Failure, bool>> saveProgress(Progress progress);

  /// Update progress status
  Future<Either<Failure, bool>> updateProgressStatus(
    String progressId,
    ProgressStatus status,
  );

  /// Update current position in lesson
  Future<Either<Failure, bool>> updateCurrentPosition(
    String progressId,
    int position,
  );

  /// Update score for a lesson
  Future<Either<Failure, bool>> updateScore(String progressId, int score);

  /// Add time spent on a lesson
  Future<Either<Failure, bool>> addTimeSpent(String progressId, int seconds);

  /// Reset progress for a lesson
  Future<Either<Failure, bool>> resetProgress(String progressId);

  /// Delete progress record
  Future<Either<Failure, bool>> deleteProgress(String progressId);
}
