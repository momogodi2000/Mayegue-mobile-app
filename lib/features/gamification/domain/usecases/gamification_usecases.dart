import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gamification.dart';
import '../repositories/gamification_repository.dart';

/// Get user progress usecase
class GetUserProgressUsecase implements UseCase<UserProgress, String> {
  final GamificationRepository repository;

  GetUserProgressUsecase(this.repository);

  @override
  Future<Either<Failure, UserProgress>> call(String userId) {
    return repository.getUserProgress(userId);
  }
}

/// Add points usecase
class AddPointsUsecase implements UseCase<UserProgress, AddPointsParams> {
  final GamificationRepository repository;

  AddPointsUsecase(this.repository);

  @override
  Future<Either<Failure, UserProgress>> call(AddPointsParams params) {
    return repository.addPoints(params.userId, params.points, params.activity);
  }
}

/// Parameters for AddPointsUsecase
class AddPointsParams {
  final String userId;
  final int points;
  final PointActivity activity;

  const AddPointsParams({
    required this.userId,
    required this.points,
    required this.activity,
  });
}

/// Award achievement usecase
class AwardAchievementUsecase
    implements UseCase<Achievement, AwardAchievementParams> {
  final GamificationRepository repository;

  AwardAchievementUsecase(this.repository);

  @override
  Future<Either<Failure, Achievement>> call(AwardAchievementParams params) {
    return repository.awardAchievement(params.userId, params.achievementId);
  }
}

/// Parameters for AwardAchievementUsecase
class AwardAchievementParams {
  final String userId;
  final String achievementId;

  const AwardAchievementParams({
    required this.userId,
    required this.achievementId,
  });
}

/// Get leaderboard usecase
class GetLeaderboardUsecase
    implements UseCase<List<LeaderboardEntry>, GetLeaderboardParams> {
  final GamificationRepository repository;

  GetLeaderboardUsecase(this.repository);

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> call(
      GetLeaderboardParams params) {
    return repository.getLeaderboard(
      limit: params.limit,
      language: params.language,
    );
  }
}

/// Parameters for GetLeaderboardUsecase
class GetLeaderboardParams {
  final int limit;
  final String? language;

  const GetLeaderboardParams({
    this.limit = 50,
    this.language,
  });
}

/// Get user achievements usecase
class GetUserAchievementsUsecase implements UseCase<List<Achievement>, String> {
  final GamificationRepository repository;

  GetUserAchievementsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Achievement>>> call(String userId) {
    return repository.getUserAchievements(userId);
  }
}

/// Check and unlock achievements usecase
class CheckAndUnlockAchievementsUsecase
    implements UseCase<List<Achievement>, String> {
  final GamificationRepository repository;

  CheckAndUnlockAchievementsUsecase(this.repository);

  @override
  Future<Either<Failure, List<Achievement>>> call(String userId) {
    return repository.checkAndUnlockAchievements(userId);
  }
}

/// Update daily streak usecase
class UpdateDailyStreakUsecase implements UseCase<UserProgress, String> {
  final GamificationRepository repository;

  UpdateDailyStreakUsecase(this.repository);

  @override
  Future<Either<Failure, UserProgress>> call(String userId) {
    return repository.updateDailyStreak(userId);
  }
}
