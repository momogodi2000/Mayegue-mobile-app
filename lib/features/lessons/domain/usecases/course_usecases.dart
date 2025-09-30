import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

/// Get all courses usecase
class GetCoursesUsecase {
  final CourseRepository repository;

  GetCoursesUsecase(this.repository);

  Future<Either<Failure, List<Course>>> call() async {
    return await repository.getCourses();
  }
}

/// Get courses by language usecase
class GetCoursesByLanguageUsecase {
  final CourseRepository repository;

  GetCoursesByLanguageUsecase(this.repository);

  Future<Either<Failure, List<Course>>> call(String language) async {
    return await repository.getCoursesByLanguage(language);
  }
}

/// Get courses by level usecase
class GetCoursesByLevelUsecase {
  final CourseRepository repository;

  GetCoursesByLevelUsecase(this.repository);

  Future<Either<Failure, List<Course>>> call(String level) async {
    return await repository.getCoursesByLevel(level);
  }
}

/// Get course by ID usecase
class GetCourseByIdUsecase {
  final CourseRepository repository;

  GetCourseByIdUsecase(this.repository);

  Future<Either<Failure, Course>> call(String courseId) async {
    return await repository.getCourseById(courseId);
  }
}

/// Get enrolled courses usecase
class GetEnrolledCoursesUsecase {
  final CourseRepository repository;

  GetEnrolledCoursesUsecase(this.repository);

  Future<Either<Failure, List<Course>>> call(String userId) async {
    return await repository.getEnrolledCourses(userId);
  }
}

/// Enroll in course usecase
class EnrollInCourseUsecase {
  final CourseRepository repository;

  EnrollInCourseUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userId, String courseId) async {
    return await repository.enrollInCourse(userId, courseId);
  }
}

/// Unenroll from course usecase
class UnenrollFromCourseUsecase {
  final CourseRepository repository;

  UnenrollFromCourseUsecase(this.repository);

  Future<Either<Failure, bool>> call(String userId, String courseId) async {
    return await repository.unenrollFromCourse(userId, courseId);
  }
}

/// Update course progress usecase
class UpdateCourseProgressUsecase {
  final CourseRepository repository;

  UpdateCourseProgressUsecase(this.repository);

  Future<Either<Failure, bool>> call(String courseId, int completedLessons) async {
    return await repository.updateCourseProgress(courseId, completedLessons);
  }
}
