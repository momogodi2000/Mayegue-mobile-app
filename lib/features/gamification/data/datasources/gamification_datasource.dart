import '../../domain/entities/gamification.dart';

/// Abstract data source for gamification operations
abstract class GamificationDataSource {
  Future<UserProgress> getUserProgress(String userId);
  Future<UserProgress> updateUserProgress(String userId, UserProgress progress);
  Future<UserProgress> addPoints(String userId, int points, PointActivity activity);
  Future<Achievement> awardAchievement(String userId, String achievementId);
  Future<List<Achievement>> getAvailableAchievements();
  Future<List<Achievement>> getUserAchievements(String userId);
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50, String? language});
  Future<int> getUserRank(String userId);
  Future<List<Achievement>> checkAndUnlockAchievements(String userId);
  Future<UserProgress> updateDailyStreak(String userId);
}
