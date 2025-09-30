import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lesson.dart';

/// Abstract repository for lesson operations
abstract class LessonRepository {
  /// Get all lessons for a course
  Future<Either<Failure, List<Lesson>>> getLessonsByCourse(String courseId);

  /// Get a specific lesson by ID
  Future<Either<Failure, Lesson>> getLessonById(String lessonId);

  /// Get next lesson in a course
  Future<Either<Failure, Lesson?>> getNextLesson(String courseId, int currentOrder);

  /// Get previous lesson in a course
  Future<Either<Failure, Lesson?>> getPreviousLesson(String courseId, int currentOrder);

  /// Update lesson status
  Future<Either<Failure, bool>> updateLessonStatus(String lessonId, LessonStatus status);

  /// Mark lesson as completed
  Future<Either<Failure, bool>> completeLesson(String lessonId);

  /// Reset lesson progress
  Future<Either<Failure, bool>> resetLesson(String lessonId);

  /// Create a new lesson (for teachers)
  Future<Either<Failure, Lesson>> createLesson(Lesson lesson);

  /// Update an existing lesson (for teachers)
  Future<Either<Failure, Lesson>> updateLesson(String lessonId, Lesson lesson);

  /// Delete a lesson (for teachers)
  Future<Either<Failure, bool>> deleteLesson(String lessonId);
}
