import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/gamification.dart';

/// Abstract repository for gamification operations
abstract class GamificationRepository {
  /// Get user progress
  Future<Either<Failure, UserProgress>> getUserProgress(String userId);

  /// Update user progress
  Future<Either<Failure, UserProgress>> updateUserProgress(
    String userId,
    UserProgress progress,
  );

  /// Add points to user
  Future<Either<Failure, UserProgress>> addPoints(
    String userId,
    int points,
    PointActivity activity,
  );

  /// Award achievement to user
  Future<Either<Failure, Achievement>> awardAchievement(
    String userId,
    String achievementId,
  );

  /// Get all available achievements
  Future<Either<Failure, List<Achievement>>> getAvailableAchievements();

  /// Get user achievements
  Future<Either<Failure, List<Achievement>>> getUserAchievements(String userId);

  /// Get leaderboard
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    int limit = 50,
    String? language,
  });

  /// Get user rank
  Future<Either<Failure, int>> getUserRank(String userId);

  /// Check and unlock achievements
  Future<Either<Failure, List<Achievement>>> checkAndUnlockAchievements(
    String userId,
  );

  /// Update daily streak
  Future<Either<Failure, UserProgress>> updateDailyStreak(String userId);
}
