import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';
import '../models/progress_model.dart';

/// Progress repository implementation
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource localDataSource;

  ProgressRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Progress>>> getUserProgress(String userId) async {
    try {
      final progressModels = await localDataSource.getUserProgress(userId);
      final progress = progressModels.map((model) => model.toEntity()).toList();
      return Right(progress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Progress?>> getLessonProgress(String userId, String lessonId) async {
    try {
      final progressModel = await localDataSource.getLessonProgress(userId, lessonId);
      return Right(progressModel?.toEntity());
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Progress>>> getCourseProgress(String userId, String courseId) async {
    try {
      final progressModels = await localDataSource.getCourseProgress(userId, courseId);
      final progress = progressModels.map((model) => model.toEntity()).toList();
      return Right(progress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> saveProgress(Progress progress) async {
    try {
      final progressModel = ProgressModel.fromEntity(progress);
      final result = await localDataSource.saveProgress(progressModel);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> updateProgressStatus(String progressId, ProgressStatus status) async {
    try {
      final result = await localDataSource.updateProgressStatus(progressId, status);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> updateCurrentPosition(String progressId, int position) async {
    try {
      final result = await localDataSource.updateCurrentPosition(progressId, position);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> updateScore(String progressId, int score) async {
    try {
      final result = await localDataSource.updateScore(progressId, score);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> addTimeSpent(String progressId, int seconds) async {
    try {
      final result = await localDataSource.addTimeSpent(progressId, seconds);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> resetProgress(String progressId) async {
    try {
      final result = await localDataSource.resetProgress(progressId);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProgress(String progressId) async {
    try {
      final result = await localDataSource.deleteProgress(progressId);
      return Right(result);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }
}
