import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/game_entity.dart';
import '../models/game_model.dart';

class GamesLocalDatasource {
  static const String _gamesKey = 'games';
  static const String _userProgressKey = 'user_progress';
  static const String _gameHistoryKey = 'game_history';
  static const String _gameProgressPrefix = 'game_progress_';
  static const String _gameStatisticsKey = 'game_statistics';
  static const String _unlockedGamesKey = 'unlocked_games';
  static const String _leaderboardKey = 'leaderboard';

  Future<List<GameModel>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getStringList(_gamesKey) ?? [];

    return gamesJson.map((gameJson) => GameModel.fromJson(Map<String, dynamic>.from(gameJson as Map))).toList();
  }

  Future<void> saveGames(List<GameModel> games) async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = games.map((game) => game.toJson().toString()).toList();
    await prefs.setStringList(_gamesKey, gamesJson);
  }

  Future<GameModel?> getGameById(String gameId) async {
    final games = await getGames();
    try {
      return games.firstWhere((game) => game.id == gameId);
    } catch (e) {
      return null;
    }
  }

  Future<List<GameModel>> getGamesByLanguage(String language) async {
    final games = await getGames();
    return games.where((game) => game.language == language).toList();
  }

  Future<List<GameModel>> getGamesByType(GameType type, String language) async {
    final games = await getGamesByLanguage(language);
    return games.where((game) => game.type == type).toList();
  }

  Future<List<GameModel>> getGamesByDifficulty(GameDifficulty difficulty, String language) async {
    final games = await getGamesByLanguage(language);
    return games.where((game) => game.difficulty == difficulty).toList();
  }

  Future<List<GameModel>> getRecommendedGames(String userId, String language) async {
    // Simple implementation: return intermediate and beginner games
    final games = await getGamesByLanguage(language);
    return games.where((game) =>
      game.difficulty == GameDifficulty.beginner ||
      game.difficulty == GameDifficulty.intermediate
    ).toList();
  }

  Future<List<GameModel>> getPremiumGames(String language) async {
    final games = await getGamesByLanguage(language);
    return games.where((game) => game.isPremium).toList();
  }

  Future<List<GameModel>> getFreeGames(String language) async {
    final games = await getGamesByLanguage(language);
    return games.where((game) => !game.isPremium).toList();
  }

  Future<GameProgressModel?> getGameProgress(String userId, String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_gameProgressPrefix${userId}_$gameId';
    final progressJson = prefs.getString(key);

    if (progressJson != null) {
      try {
        return GameProgressModel.fromJson(jsonDecode(progressJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> updateGameProgress(GameProgressModel progress) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_gameProgressPrefix${progress.userId}_${progress.gameId}';
    await prefs.setString(key, jsonEncode(progress.toJson()));
  }

  Future<List<GameProgressModel>> getUserGameProgress(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('$_gameProgressPrefix$userId'));

    final progressList = <GameProgressModel>[];
    for (final key in keys) {
      final progressJson = prefs.getString(key);
      if (progressJson != null) {
        try {
          progressList.add(GameProgressModel.fromJson(jsonDecode(progressJson)));
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    return progressList;
  }

  Future<Map<String, dynamic>> getGameStatistics(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString('$_gameStatisticsKey$userId');

    if (statsJson != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(statsJson));
      } catch (e) {
        return _getDefaultStatistics();
      }
    }

    return _getDefaultStatistics();
  }

  Map<String, dynamic> _getDefaultStatistics() {
    return {
      'completedGames': 0,
      'totalScore': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'gamesPlayed': 0,
      'averageScore': 0,
    };
  }

  Future<List<GameModel>> searchGames(String query, {String? language}) async {
    final games = language != null
      ? await getGamesByLanguage(language)
      : await getGames();

    final lowerQuery = query.toLowerCase();
    return games.where((game) =>
      game.title.toLowerCase().contains(lowerQuery) ||
      game.description.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<List<GameModel>> getDailyChallenges(String userId, String language) async {
    // Simple implementation: return 3 random games
    final games = await getGamesByLanguage(language);
    if (games.isEmpty) return [];

    final challenges = games.take(3).toList();
    return challenges;
  }

  Future<bool> isGameUnlocked(String userId, String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedGames = prefs.getStringList('$_unlockedGamesKey$userId') ?? [];

    // Check if game is free or unlocked
    final game = await getGameById(gameId);
    if (game == null) return false;
    if (!game.isPremium) return true;

    return unlockedGames.contains(gameId);
  }

  Future<void> completeGameSession({
    required String userId,
    required String gameId,
    required int score,
    required int timeSpent,
    required bool isCompleted,
    Map<String, dynamic>? sessionData,
  }) async {
    // Update game progress
    final existingProgress = await getGameProgress(userId, gameId);

    final progress = GameProgressModel(
      id: existingProgress?.id ?? '${userId}_$gameId',
      userId: userId,
      gameId: gameId,
      currentScore: score,
      bestScore: existingProgress != null
        ? (score > existingProgress.bestScore ? score : existingProgress.bestScore)
        : score,
      attemptsCount: (existingProgress?.attemptsCount ?? 0) + 1,
      isCompleted: isCompleted,
      lastPlayedAt: DateTime.now(),
      progressData: sessionData ?? {},
    );

    await updateGameProgress(progress);

    // Update statistics
    await _updateGameStatistics(userId, score, isCompleted);
  }

  Future<void> _updateGameStatistics(String userId, int score, bool isCompleted) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await getGameStatistics(userId);

    stats['gamesPlayed'] = (stats['gamesPlayed'] as int) + 1;
    stats['totalScore'] = (stats['totalScore'] as int) + score;
    stats['averageScore'] = (stats['totalScore'] as int) ~/ (stats['gamesPlayed'] as int);

    if (isCompleted) {
      stats['completedGames'] = (stats['completedGames'] as int) + 1;
    }

    await prefs.setString('$_gameStatisticsKey$userId', jsonEncode(stats));
  }

  Future<List<Map<String, dynamic>>> getGameLeaderboard(
    String gameId, {
    int limit = 10,
    String period = 'all_time',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = prefs.getString('$_leaderboardKey$gameId');

    if (leaderboardJson != null) {
      try {
        final List<dynamic> entries = jsonDecode(leaderboardJson);
        return entries
          .map((e) => Map<String, dynamic>.from(e))
          .take(limit)
          .toList();
      } catch (e) {
        return [];
      }
    }

    return [];
  }

  Future<int> getUserGameRank(String userId, String gameId) async {
    final leaderboard = await getGameLeaderboard(gameId, limit: 100);

    for (int i = 0; i < leaderboard.length; i++) {
      if (leaderboard[i]['userId'] == userId) {
        return i + 1;
      }
    }

    return leaderboard.length + 1;
  }

  Future<List<GameModel>> getGamesByCategory(String category) async {
    final games = await getGames();
    return games.where((game) => game.type.name == category).toList();
  }

  Future<void> saveUserProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProgressKey, progress.toString());
  }

  Future<Map<String, dynamic>?> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_userProgressKey);
    if (progressJson != null) {
      // Simple implementation - in real app, you'd parse JSON properly
      return {};
    }
    return null;
  }

  Future<void> saveGameHistory(Map<String, dynamic> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_gameHistoryKey) ?? [];
    historyList.add(history.toString());
    await prefs.setStringList(_gameHistoryKey, historyList);
  }

  Future<List<Map<String, dynamic>>> getGameHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyList = prefs.getStringList(_gameHistoryKey) ?? [];
    // Simple implementation - in real app, you'd parse JSON properly
    return historyList.map((item) => <String, dynamic>{}).toList();
  }
}
