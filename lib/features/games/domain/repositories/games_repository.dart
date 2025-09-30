import '../entities/game_entity.dart';

/// Repository interface for games management
abstract class GamesRepository {
  /// Get all available games for a language
  Future<List<GameEntity>> getGamesByLanguage(String language);

  /// Get games by type
  Future<List<GameEntity>> getGamesByType(GameType type, String language);

  /// Get games by difficulty
  Future<List<GameEntity>> getGamesByDifficulty(GameDifficulty difficulty, String language);

  /// Get a specific game by ID
  Future<GameEntity?> getGameById(String gameId);

  /// Get recommended games based on user progress
  Future<List<GameEntity>> getRecommendedGames(String userId, String language);

  /// Get premium games
  Future<List<GameEntity>> getPremiumGames(String language);

  /// Get free games for guest users
  Future<List<GameEntity>> getFreeGames(String language);

  /// Get game progress for a user
  Future<GameProgressEntity?> getGameProgress(String userId, String gameId);

  /// Update game progress
  Future<void> updateGameProgress(GameProgressEntity progress);

  /// Get all game progress for a user
  Future<List<GameProgressEntity>> getUserGameProgress(String userId);

  /// Get user's game statistics
  Future<Map<String, dynamic>> getGameStatistics(String userId);

  /// Search games by title or description
  Future<List<GameEntity>> searchGames(String query, {String? language});

  /// Get daily challenges
  Future<List<GameEntity>> getDailyChallenges(String userId, String language);

  /// Check if game is unlocked for user
  Future<bool> isGameUnlocked(String userId, String gameId);

  /// Complete a game session
  Future<void> completeGameSession({
    required String userId,
    required String gameId,
    required int score,
    required int timeSpent,
    required bool isCompleted,
    Map<String, dynamic>? sessionData,
  });

  /// Get leaderboard for a game
  Future<List<Map<String, dynamic>>> getGameLeaderboard(
    String gameId, {
    int limit = 10,
    String period = 'all_time', // 'daily', 'weekly', 'monthly', 'all_time'
  });

  /// Get user's rank in a game
  Future<int> getUserGameRank(String userId, String gameId);

  /// Report a game issue or feedback
  Future<void> reportGameIssue({
    required String gameId,
    required String userId,
    required String issueType,
    required String description,
  });

  /// Get game achievements
  Future<List<Map<String, dynamic>>> getGameAchievements(String userId);

  /// Unlock achievement
  Future<void> unlockAchievement(String userId, String achievementId);

  /// Cache game for offline play
  Future<void> cacheGameForOffline(String gameId);

  /// Get cached games
  Future<List<GameEntity>> getCachedGames();

  /// Remove game from cache
  Future<void> removeCachedGame(String gameId);
}