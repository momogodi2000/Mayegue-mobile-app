import '../../domain/entities/game_entity.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_local_datasource.dart';
import '../models/game_model.dart';
import 'package:flutter/foundation.dart';

/// Games repository implementation
class GamesRepositoryImpl implements GamesRepository {
  final GamesLocalDatasource localDataSource;

  GamesRepositoryImpl(this.localDataSource);

  @override
  Future<List<GameEntity>> getGamesByLanguage(String language) async {
    try {
      final gameModels = await localDataSource.getGamesByLanguage(language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get games by language: $e');
    }
  }

  @override
  Future<List<GameEntity>> getGamesByType(
      GameType type, String language) async {
    try {
      final gameModels = await localDataSource.getGamesByType(type, language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get games by type: $e');
    }
  }

  @override
  Future<List<GameEntity>> getGamesByDifficulty(
      GameDifficulty difficulty, String language) async {
    try {
      final gameModels =
          await localDataSource.getGamesByDifficulty(difficulty, language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get games by difficulty: $e');
    }
  }

  @override
  Future<GameEntity?> getGameById(String gameId) async {
    try {
      final gameModel = await localDataSource.getGameById(gameId);
      return gameModel;
    } catch (e) {
      throw Exception('Failed to get game: $e');
    }
  }

  @override
  Future<List<GameEntity>> getRecommendedGames(
      String userId, String language) async {
    try {
      final gameModels =
          await localDataSource.getRecommendedGames(userId, language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get recommended games: $e');
    }
  }

  @override
  Future<List<GameEntity>> getPremiumGames(String language) async {
    try {
      final gameModels = await localDataSource.getPremiumGames(language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get premium games: $e');
    }
  }

  @override
  Future<List<GameEntity>> getFreeGames(String language) async {
    try {
      final gameModels = await localDataSource.getFreeGames(language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get free games: $e');
    }
  }

  @override
  Future<GameProgressEntity?> getGameProgress(
      String userId, String gameId) async {
    try {
      final progressModel =
          await localDataSource.getGameProgress(userId, gameId);
      return progressModel;
    } catch (e) {
      throw Exception('Failed to get game progress: $e');
    }
  }

  @override
  Future<void> updateGameProgress(GameProgressEntity progress) async {
    try {
      final progressModel = GameProgressModel.fromEntity(progress);
      await localDataSource.updateGameProgress(progressModel);
    } catch (e) {
      throw Exception('Failed to update game progress: $e');
    }
  }

  @override
  Future<List<GameProgressEntity>> getUserGameProgress(String userId) async {
    try {
      final progressModels = await localDataSource.getUserGameProgress(userId);
      return progressModels
          .map((model) => model as GameProgressEntity)
          .toList();
    } catch (e) {
      throw Exception('Failed to get user game progress: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getGameStatistics(String userId) async {
    try {
      return await localDataSource.getGameStatistics(userId);
    } catch (e) {
      throw Exception('Failed to get game statistics: $e');
    }
  }

  @override
  Future<List<GameEntity>> searchGames(String query, {String? language}) async {
    try {
      final gameModels =
          await localDataSource.searchGames(query, language: language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to search games: $e');
    }
  }

  @override
  Future<List<GameEntity>> getDailyChallenges(
      String userId, String language) async {
    try {
      final gameModels =
          await localDataSource.getDailyChallenges(userId, language);
      return gameModels.map((model) => model as GameEntity).toList();
    } catch (e) {
      throw Exception('Failed to get daily challenges: $e');
    }
  }

  @override
  Future<bool> isGameUnlocked(String userId, String gameId) async {
    try {
      return await localDataSource.isGameUnlocked(userId, gameId);
    } catch (e) {
      // If error occurs, assume game is locked
      return false;
    }
  }

  @override
  Future<void> completeGameSession({
    required String userId,
    required String gameId,
    required int score,
    required int timeSpent,
    required bool isCompleted,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      await localDataSource.completeGameSession(
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

  @override
  Future<List<Map<String, dynamic>>> getGameLeaderboard(
    String gameId, {
    int limit = 10,
    String period = 'all_time',
  }) async {
    try {
      return await localDataSource.getGameLeaderboard(
        gameId,
        limit: limit,
        period: period,
      );
    } catch (e) {
      throw Exception('Failed to get game leaderboard: $e');
    }
  }

  @override
  Future<int> getUserGameRank(String userId, String gameId) async {
    try {
      return await localDataSource.getUserGameRank(userId, gameId);
    } catch (e) {
      throw Exception('Failed to get user game rank: $e');
    }
  }

  @override
  Future<void> reportGameIssue({
    required String gameId,
    required String userId,
    required String issueType,
    required String description,
  }) async {
    try {
      // In a real implementation, this would send the report to a backend service
      // For now, we'll just log it locally or store it for later sync
      debugPrint('Game Issue Reported:');
      debugPrint('Game ID: $gameId');
      debugPrint('User ID: $userId');
      debugPrint('Issue Type: $issueType');
      debugPrint('Description: $description');
    } catch (e) {
      throw Exception('Failed to report game issue: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGameAchievements(String userId) async {
    try {
      // Simple achievement system based on user progress
      final userProgress = await getUserGameProgress(userId);
      final statistics = await getGameStatistics(userId);

      final achievements = <Map<String, dynamic>>[];

      // First game achievement
      if (userProgress.isNotEmpty) {
        achievements.add({
          'id': 'first_game',
          'title': 'Premier pas',
          'description': 'Jouer votre premier jeu',
          'icon': 'first_game',
          'unlocked': true,
          'unlockedAt': userProgress.first.lastPlayedAt.toIso8601String(),
        });
      }

      // Complete 5 games achievement
      final completedCount = statistics['completedGames'] as int;
      if (completedCount >= 5) {
        achievements.add({
          'id': 'complete_5_games',
          'title': 'Débutant accompli',
          'description': 'Terminer 5 jeux',
          'icon': 'complete_5_games',
          'unlocked': true,
          'unlockedAt': DateTime.now().toIso8601String(),
        });
      }

      // High score achievement
      final bestScore = userProgress.fold<int>(
        0,
        (max, progress) => progress.bestScore > max ? progress.bestScore : max,
      );
      if (bestScore >= 150) {
        achievements.add({
          'id': 'high_score',
          'title': 'Champion',
          'description': 'Obtenir un score de 150 ou plus',
          'icon': 'high_score',
          'unlocked': true,
          'unlockedAt': DateTime.now().toIso8601String(),
        });
      }

      // Streak achievement
      final streak = statistics['currentStreak'] as int;
      if (streak >= 3) {
        achievements.add({
          'id': 'streak_3',
          'title': 'Régularité',
          'description': 'Jouer 3 jours consécutifs',
          'icon': 'streak_3',
          'unlocked': true,
          'unlockedAt': DateTime.now().toIso8601String(),
        });
      }

      return achievements;
    } catch (e) {
      throw Exception('Failed to get game achievements: $e');
    }
  }

  @override
  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      // In a real implementation, this would update the user's achievement status
      debugPrint('Achievement unlocked for user $userId: $achievementId');
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  @override
  Future<void> cacheGameForOffline(String gameId) async {
    try {
      // In a real implementation, this would download game assets for offline play
      debugPrint('Caching game for offline: $gameId');
    } catch (e) {
      throw Exception('Failed to cache game for offline: $e');
    }
  }

  @override
  Future<List<GameEntity>> getCachedGames() async {
    try {
      // For now, return all games as they're already cached locally
      final allGames = <GameEntity>[];

      // Get all languages
      const languages = [
        'ewondo',
        'bafang',
        'duala',
        'fulfulde',
        'bassa',
        'bamum'
      ];

      for (final language in languages) {
        final languageGames = await getGamesByLanguage(language);
        allGames.addAll(languageGames);
      }

      return allGames;
    } catch (e) {
      throw Exception('Failed to get cached games: $e');
    }
  }

  @override
  Future<void> removeCachedGame(String gameId) async {
    try {
      // In a real implementation, this would remove cached game assets
      debugPrint('Removing cached game: $gameId');
    } catch (e) {
      throw Exception('Failed to remove cached game: $e');
    }
  }
}
