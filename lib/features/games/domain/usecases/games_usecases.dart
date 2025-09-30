import '../entities/game_entity.dart';
import '../repositories/games_repository.dart';

/// Use case for getting games by language
class GetGamesByLanguageUseCase {
  final GamesRepository repository;

  GetGamesByLanguageUseCase(this.repository);

  Future<List<GameEntity>> call(String language) async {
    try {
      return await repository.getGamesByLanguage(language);
    } catch (e) {
      throw Exception('Failed to get games by language: $e');
    }
  }
}

/// Use case for getting games by type
class GetGamesByTypeUseCase {
  final GamesRepository repository;

  GetGamesByTypeUseCase(this.repository);

  Future<List<GameEntity>> call(GameType type, String language) async {
    try {
      return await repository.getGamesByType(type, language);
    } catch (e) {
      throw Exception('Failed to get games by type: $e');
    }
  }
}

/// Use case for getting a specific game
class GetGameByIdUseCase {
  final GamesRepository repository;

  GetGameByIdUseCase(this.repository);

  Future<GameEntity?> call(String gameId) async {
    try {
      return await repository.getGameById(gameId);
    } catch (e) {
      throw Exception('Failed to get game: $e');
    }
  }
}

/// Use case for getting recommended games
class GetRecommendedGamesUseCase {
  final GamesRepository repository;

  GetRecommendedGamesUseCase(this.repository);

  Future<List<GameEntity>> call(String userId, String language) async {
    try {
      return await repository.getRecommendedGames(userId, language);
    } catch (e) {
      throw Exception('Failed to get recommended games: $e');
    }
  }
}

/// Use case for getting game progress
class GetGameProgressUseCase {
  final GamesRepository repository;

  GetGameProgressUseCase(this.repository);

  Future<GameProgressEntity?> call(String userId, String gameId) async {
    try {
      return await repository.getGameProgress(userId, gameId);
    } catch (e) {
      throw Exception('Failed to get game progress: $e');
    }
  }
}

/// Use case for updating game progress
class UpdateGameProgressUseCase {
  final GamesRepository repository;

  UpdateGameProgressUseCase(this.repository);

  Future<void> call(GameProgressEntity progress) async {
    try {
      await repository.updateGameProgress(progress);
    } catch (e) {
      throw Exception('Failed to update game progress: $e');
    }
  }
}

/// Use case for completing a game session
class CompleteGameSessionUseCase {
  final GamesRepository repository;

  CompleteGameSessionUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String gameId,
    required int score,
    required int timeSpent,
    required bool isCompleted,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      await repository.completeGameSession(
        userId: userId,
        gameId: gameId,
        score: score,
        timeSpent: timeSpent,
        isCompleted: isCompleted,
        sessionData: sessionData,
      );
    } catch (e) {
      throw Exception('Failed to complete game session: $e');
    }
  }
}

/// Use case for searching games
class SearchGamesUseCase {
  final GamesRepository repository;

  SearchGamesUseCase(this.repository);

  Future<List<GameEntity>> call(String query, {String? language}) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }
      return await repository.searchGames(query, language: language);
    } catch (e) {
      throw Exception('Failed to search games: $e');
    }
  }
}

/// Use case for getting daily challenges
class GetDailyChallengesUseCase {
  final GamesRepository repository;

  GetDailyChallengesUseCase(this.repository);

  Future<List<GameEntity>> call(String userId, String language) async {
    try {
      return await repository.getDailyChallenges(userId, language);
    } catch (e) {
      throw Exception('Failed to get daily challenges: $e');
    }
  }
}

/// Use case for checking if game is unlocked
class IsGameUnlockedUseCase {
  final GamesRepository repository;

  IsGameUnlockedUseCase(this.repository);

  Future<bool> call(String userId, String gameId) async {
    try {
      return await repository.isGameUnlocked(userId, gameId);
    } catch (e) {
      // If error occurs, assume game is locked
      return false;
    }
  }
}

/// Use case for getting game leaderboard
class GetGameLeaderboardUseCase {
  final GamesRepository repository;

  GetGameLeaderboardUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(
    String gameId, {
    int limit = 10,
    String period = 'all_time',
  }) async {
    try {
      return await repository.getGameLeaderboard(gameId,
          limit: limit, period: period);
    } catch (e) {
      throw Exception('Failed to get game leaderboard: $e');
    }
  }
}

/// Use case for getting user game rank
class GetUserGameRankUseCase {
  final GamesRepository repository;

  GetUserGameRankUseCase(this.repository);

  Future<int> call(String userId, String gameId) async {
    try {
      return await repository.getUserGameRank(userId, gameId);
    } catch (e) {
      throw Exception('Failed to get user game rank: $e');
    }
  }
}

/// Use case for getting game statistics
class GetGameStatisticsUseCase {
  final GamesRepository repository;

  GetGameStatisticsUseCase(this.repository);

  Future<Map<String, dynamic>> call(String userId) async {
    try {
      return await repository.getGameStatistics(userId);
    } catch (e) {
      throw Exception('Failed to get game statistics: $e');
    }
  }
}

/// Use case for getting free games for guests
class GetFreeGamesUseCase {
  final GamesRepository repository;

  GetFreeGamesUseCase(this.repository);

  Future<List<GameEntity>> call(String language) async {
    try {
      final games = await repository.getFreeGames(language);
      // Limit to first 3 games for guests
      return games.take(3).toList();
    } catch (e) {
      throw Exception('Failed to get free games: $e');
    }
  }
}

/// Use case for getting game achievements
class GetGameAchievementsUseCase {
  final GamesRepository repository;

  GetGameAchievementsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(String userId) async {
    try {
      return await repository.getGameAchievements(userId);
    } catch (e) {
      throw Exception('Failed to get game achievements: $e');
    }
  }
}

/// Use case for unlocking achievement
class UnlockAchievementUseCase {
  final GamesRepository repository;

  UnlockAchievementUseCase(this.repository);

  Future<void> call(String userId, String achievementId) async {
    try {
      await repository.unlockAchievement(userId, achievementId);
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }
}

/// Use case for reporting game issue
class ReportGameIssueUseCase {
  final GamesRepository repository;

  ReportGameIssueUseCase(this.repository);

  Future<void> call({
    required String gameId,
    required String userId,
    required String issueType,
    required String description,
  }) async {
    try {
      await repository.reportGameIssue(
        gameId: gameId,
        userId: userId,
        issueType: issueType,
        description: description,
      );
    } catch (e) {
      throw Exception('Failed to report game issue: $e');
    }
  }
}
