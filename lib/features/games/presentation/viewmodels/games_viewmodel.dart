import 'package:flutter/foundation.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/usecases/games_usecases.dart';

/// ViewModel for games management
class GamesViewModel extends ChangeNotifier {
  final GetGamesByLanguageUseCase getGamesByLanguageUseCase;
  final GetGamesByTypeUseCase getGamesByTypeUseCase;
  final GetGameByIdUseCase getGameByIdUseCase;
  final GetRecommendedGamesUseCase getRecommendedGamesUseCase;
  final GetGameProgressUseCase getGameProgressUseCase;
  final UpdateGameProgressUseCase updateGameProgressUseCase;
  final CompleteGameSessionUseCase completeGameSessionUseCase;
  final SearchGamesUseCase searchGamesUseCase;
  final GetDailyChallengesUseCase getDailyChallengesUseCase;
  final IsGameUnlockedUseCase isGameUnlockedUseCase;
  final GetGameLeaderboardUseCase getGameLeaderboardUseCase;
  final GetUserGameRankUseCase getUserGameRankUseCase;
  final GetGameStatisticsUseCase getGameStatisticsUseCase;
  final GetFreeGamesUseCase getFreeGamesUseCase;
  final GetGameAchievementsUseCase getGameAchievementsUseCase;

  GamesViewModel({
    required this.getGamesByLanguageUseCase,
    required this.getGamesByTypeUseCase,
    required this.getGameByIdUseCase,
    required this.getRecommendedGamesUseCase,
    required this.getGameProgressUseCase,
    required this.updateGameProgressUseCase,
    required this.completeGameSessionUseCase,
    required this.searchGamesUseCase,
    required this.getDailyChallengesUseCase,
    required this.isGameUnlockedUseCase,
    required this.getGameLeaderboardUseCase,
    required this.getUserGameRankUseCase,
    required this.getGameStatisticsUseCase,
    required this.getFreeGamesUseCase,
    required this.getGameAchievementsUseCase,
  });

  // State
  List<GameEntity> _games = [];
  List<GameEntity> _recommendedGames = [];
  List<GameEntity> _dailyChallenges = [];
  List<GameEntity> _searchResults = [];
  GameEntity? _currentGame;
  GameProgressEntity? _currentGameProgress;
  Map<String, dynamic> _gameStatistics = {};
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = false;
  bool _isLoadingProgress = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _currentLanguage = 'ewondo';
  String _searchQuery = '';
  String? _selectedLanguage;

  // Getters
  List<GameEntity> get games => _games;
  List<GameEntity> get recommendedGames => _recommendedGames;
  List<GameEntity> get dailyChallenges => _dailyChallenges;
  List<GameEntity> get searchResults => _searchResults;
  GameEntity? get currentGame => _currentGame;
  GameProgressEntity? get currentGameProgress => _currentGameProgress;
  Map<String, dynamic> get gameStatistics => _gameStatistics;
  List<Map<String, dynamic>> get achievements => _achievements;
  bool get isLoading => _isLoading;
  bool get isLoadingProgress => _isLoadingProgress;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for compatibility
  String get currentLanguage => _currentLanguage;
  String get searchQuery => _searchQuery;
  String? get selectedLanguage => _selectedLanguage;

  // Computed getters
  List<GameEntity> get memoryGames =>
      _games.where((game) => game.type == GameType.memory).toList();

  List<GameEntity> get quizGames =>
      _games.where((game) => game.type == GameType.quiz).toList();

  List<GameEntity> get wordMatchingGames =>
      _games.where((game) => game.type == GameType.wordMatching).toList();

  List<GameEntity> get puzzleGames =>
      _games.where((game) => game.type == GameType.wordPuzzle).toList();

  List<GameEntity> get freeGames =>
      _games.where((game) => !game.isPremium).toList();

  List<GameEntity> get premiumGames =>
      _games.where((game) => game.isPremium).toList();

  bool get hasError => _errorMessage != null;

  int get totalGamesPlayed => _gameStatistics['totalGames'] ?? 0;
  int get completedGames => _gameStatistics['completedGames'] ?? 0;
  int get totalScore => _gameStatistics['totalScore'] ?? 0;
  int get currentStreak => _gameStatistics['currentStreak'] ?? 0;

  /// Set current language
  void setLanguage(String language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      loadGames();
      loadRecommendedGames('current_user'); // TODO: Get actual user ID
      loadDailyChallenges('current_user'); // TODO: Get actual user ID
      notifyListeners();
    }
  }

  /// Load games by current language
  Future<void> loadGames() async {
    _setLoading(true);
    _clearError();

    try {
      _games = await getGamesByLanguageUseCase(_currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load games: $e');
    }

    _setLoading(false);
  }

  /// Load games by type
  Future<void> loadGamesByType(GameType type) async {
    _setLoading(true);
    _clearError();

    try {
      _games = await getGamesByTypeUseCase(type, _currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load games by type: $e');
    }

    _setLoading(false);
  }

  /// Load recommended games
  Future<void> loadRecommendedGames(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _recommendedGames =
          await getRecommendedGamesUseCase(userId, _currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recommended games: $e');
    }

    _setLoading(false);
  }

  /// Load daily challenges
  Future<void> loadDailyChallenges(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _dailyChallenges =
          await getDailyChallengesUseCase(userId, _currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load daily challenges: $e');
    }

    _setLoading(false);
  }

  /// Load a specific game
  Future<void> loadGame(String gameId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentGame = await getGameByIdUseCase(gameId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load game: $e');
    }

    _setLoading(false);
  }

  /// Set current game
  void setCurrentGame(GameEntity game) {
    _currentGame = game;
    notifyListeners();
  }

  /// Load game progress
  Future<void> loadGameProgress(String userId, String gameId) async {
    _setLoadingProgress(true);
    _clearError();

    try {
      _currentGameProgress = await getGameProgressUseCase(userId, gameId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load game progress: $e');
    }

    _setLoadingProgress(false);
  }

  /// Complete game session
  Future<bool> completeGameSession({
    required String userId,
    required String gameId,
    required int score,
    required int timeSpent,
    required bool isCompleted,
    Map<String, dynamic>? sessionData,
  }) async {
    _setLoadingProgress(true);
    _clearError();

    try {
      await completeGameSessionUseCase(
        userId: userId,
        gameId: gameId,
        score: score,
        timeSpent: timeSpent,
        isCompleted: isCompleted,
        sessionData: sessionData,
      );

      // Reload game progress
      await loadGameProgress(userId, gameId);

      // Reload statistics
      await loadGameStatistics(userId);

      _setLoadingProgress(false);
      return true;
    } catch (e) {
      _setError('Failed to complete game session: $e');
      _setLoadingProgress(false);
      return false;
    }
  }

  /// Search games
  Future<void> searchGames(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _setSearching(true);
    _searchQuery = query;
    _clearError();

    try {
      _searchResults =
          await searchGamesUseCase(query, language: _currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search games: $e');
    }

    _setSearching(false);
  }

  /// Clear search
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  /// Check if game is unlocked
  Future<bool> isGameUnlocked(String userId, String gameId) async {
    try {
      return await isGameUnlockedUseCase(userId, gameId);
    } catch (e) {
      return false;
    }
  }

  /// Load game statistics
  Future<void> loadGameStatistics(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _gameStatistics = await getGameStatisticsUseCase(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load game statistics: $e');
    }

    _setLoading(false);
  }

  /// Load achievements
  Future<void> loadAchievements(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _achievements = await getGameAchievementsUseCase(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load achievements: $e');
    }

    _setLoading(false);
  }

  /// Get leaderboard for a game
  Future<List<Map<String, dynamic>>> getGameLeaderboard(
    String gameId, {
    int limit = 10,
    String period = 'all_time',
  }) async {
    try {
      return await getGameLeaderboardUseCase(gameId,
          limit: limit, period: period);
    } catch (e) {
      _setError('Failed to get leaderboard: $e');
      return [];
    }
  }

  /// Get user rank for a game
  Future<int> getUserGameRank(String userId, String gameId) async {
    try {
      return await getUserGameRankUseCase(userId, gameId);
    } catch (e) {
      return 0;
    }
  }

  /// Load free games for guest users
  Future<void> loadFreeGames() async {
    _setLoading(true);
    _clearError();

    try {
      _games = await getFreeGamesUseCase(_currentLanguage);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load free games: $e');
    }

    _setLoading(false);
  }

  /// Get games by difficulty
  List<GameEntity> getGamesByDifficulty(GameDifficulty difficulty) {
    return _games.where((game) => game.difficulty == difficulty).toList();
  }

  /// Get games count by type
  Map<GameType, int> getGamesCountByType() {
    final counts = <GameType, int>{};
    for (final game in _games) {
      counts[game.type] = (counts[game.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Get average game duration
  double getAverageGameDuration() {
    if (_games.isEmpty) return 0;
    final totalDuration =
        _games.fold<int>(0, (sum, game) => sum + game.estimatedDuration);
    return totalDuration / _games.length;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingProgress(bool loading) {
    _isLoadingProgress = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all data (useful for logout)
  void clearAllData() {
    _games = [];
    _recommendedGames = [];
    _dailyChallenges = [];
    _searchResults = [];
    _currentGame = null;
    _currentGameProgress = null;
    _gameStatistics = {};
    _achievements = [];
    _errorMessage = null;
    _searchQuery = '';
    _currentLanguage = 'ewondo';
    _selectedLanguage = null;
    notifyListeners();
  }

  /// Load available games (simplified method for the view)
  Future<void> loadAvailableGames() async {
    await loadGames();
  }

  /// Set selected language
  void setSelectedLanguage(String? language) {
    _selectedLanguage = language;
    notifyListeners();
  }
}
