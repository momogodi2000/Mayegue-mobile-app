import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course.dart';

/// Abstract repository for course operations
abstract class CourseRepository {
  /// Get all available courses
  Future<Either<Failure, List<Course>>> getCourses();

  /// Get courses by language
  Future<Either<Failure, List<Course>>> getCoursesByLanguage(String language);

  /// Get courses by level
  Future<Either<Failure, List<Course>>> getCoursesByLevel(String level);

  /// Get a specific course by ID
  Future<Either<Failure, Course>> getCourseById(String courseId);

  /// Get user's enrolled courses
  Future<Either<Failure, List<Course>>> getEnrolledCourses(String userId);

  /// Enroll user in a course
  Future<Either<Failure, bool>> enrollInCourse(String userId, String courseId);

  /// Unenroll user from a course
  Future<Either<Failure, bool>> unenrollFromCourse(String userId, String courseId);

  /// Update course progress
  Future<Either<Failure, bool>> updateCourseProgress(String courseId, int completedLessons);
}
