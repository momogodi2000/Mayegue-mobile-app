import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/gamification.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../datasources/gamification_datasource.dart';

/// Gamification repository implementation
class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationDataSource localDataSource;

  GamificationRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, UserProgress>> getUserProgress(String userId) async {
    try {
      final progress = await localDataSource.getUserProgress(userId);
      return Right(progress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, UserProgress>> updateUserProgress(
    String userId,
    UserProgress progress,
  ) async {
    try {
      final updatedProgress =
          await localDataSource.updateUserProgress(userId, progress);
      return Right(updatedProgress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, UserProgress>> addPoints(
    String userId,
    int points,
    PointActivity activity,
  ) async {
    try {
      final updatedProgress =
          await localDataSource.addPoints(userId, points, activity);
      return Right(updatedProgress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, Achievement>> awardAchievement(
    String userId,
    String achievementId,
  ) async {
    try {
      final achievement =
          await localDataSource.awardAchievement(userId, achievementId);
      return Right(achievement);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getAvailableAchievements() async {
    try {
      final achievements = await localDataSource.getAvailableAchievements();
      return Right(achievements);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> getUserAchievements(
      String userId) async {
    try {
      final achievements = await localDataSource.getUserAchievements(userId);
      return Right(achievements);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    int limit = 50,
    String? language,
  }) async {
    try {
      final leaderboard = await localDataSource.getLeaderboard(
        limit: limit,
        language: language,
      );
      return Right(leaderboard);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, int>> getUserRank(String userId) async {
    try {
      final rank = await localDataSource.getUserRank(userId);
      return Right(rank);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, List<Achievement>>> checkAndUnlockAchievements(
    String userId,
  ) async {
    try {
      final achievements =
          await localDataSource.checkAndUnlockAchievements(userId);
      return Right(achievements);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }

  @override
  Future<Either<Failure, UserProgress>> updateDailyStreak(String userId) async {
    try {
      final progress = await localDataSource.updateDailyStreak(userId);
      return Right(progress);
    } on CacheFailure catch (e) {
      return Left(e);
    }
  }
}
