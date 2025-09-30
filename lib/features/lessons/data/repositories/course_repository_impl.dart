import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';

/// Course repository implementation
class CourseRepositoryImpl implements CourseRepository {
  final CourseLocalDataSource localDataSource;

  CourseRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Course>>> getCourses() async {
    try {
      final courseModels = await localDataSource.getCourses();
      final courses = courseModels.map((model) => model.toEntity()).toList();
      return Right(courses);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getCoursesByLanguage(String language) async {
    try {
      final courseModels = await localDataSource.getCoursesByLanguage(language);
      final courses = courseModels.map((model) => model.toEntity()).toList();
      return Right(courses);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getCoursesByLevel(String level) async {
    try {
      final courseModels = await localDataSource.getCoursesByLevel(level);
      final courses = courseModels.map((model) => model.toEntity()).toList();
      return Right(courses);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Course>> getCourseById(String courseId) async {
    try {
      final courseModel = await localDataSource.getCourseById(courseId);
      return Right(courseModel.toEntity());
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Course>>> getEnrolledCourses(String userId) async {
    try {
      final courseModels = await localDataSource.getEnrolledCourses(userId);
      final courses = courseModels.map((model) => model.toEntity()).toList();
      return Right(courses);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> enrollInCourse(String userId, String courseId) async {
    try {
      final result = await localDataSource.enrollInCourse(userId, courseId);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> unenrollFromCourse(String userId, String courseId) async {
    try {
      final result = await localDataSource.unenrollFromCourse(userId, courseId);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> updateCourseProgress(String courseId, int completedLessons) async {
    try {
      final result = await localDataSource.updateCourseProgress(courseId, completedLessons);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }
}
