import 'package:flutter/foundation.dart';
import 'package:mayegue/core/errors/failures.dart';
import 'package:mayegue/features/gamification/domain/entities/gamification.dart';
import 'package:mayegue/features/gamification/domain/usecases/gamification_usecases.dart';

/// ViewModel for gamification features
class GamificationViewModel extends ChangeNotifier {
  final GetUserProgressUsecase getUserProgressUsecase;
  final AddPointsUsecase addPointsUsecase;
  final AwardAchievementUsecase awardAchievementUsecase;
  final GetLeaderboardUsecase getLeaderboardUsecase;
  final GetUserAchievementsUsecase getUserAchievementsUsecase;
  final CheckAndUnlockAchievementsUsecase checkAndUnlockAchievementsUsecase;
  final UpdateDailyStreakUsecase updateDailyStreakUsecase;

  GamificationViewModel({
    required this.getUserProgressUsecase,
    required this.addPointsUsecase,
    required this.awardAchievementUsecase,
    required this.getLeaderboardUsecase,
    required this.getUserAchievementsUsecase,
    required this.checkAndUnlockAchievementsUsecase,
    required this.updateDailyStreakUsecase,
  });

  // State
  UserProgress? _userProgress;
  List<LeaderboardEntry> _leaderboard = [];
  List<Achievement> _userAchievements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserProgress? get userProgress => _userProgress;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  List<Achievement> get userAchievements => _userAchievements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed getters
  int get userRank {
    if (_userProgress == null) return 0;
    final userEntry = _leaderboard
        .where((entry) => entry.userId == _userProgress!.userId)
        .firstOrNull;
    return userEntry?.rank ?? 0;
  }

  double get levelProgress {
    if (_userProgress == null) return 0.0;
    final currentLevelXP = _calculateXPForLevel(_userProgress!.currentLevel);
    final nextLevelXP = _calculateXPForLevel(_userProgress!.currentLevel + 1);
    final progressXP = _userProgress!.experiencePoints - currentLevelXP;
    final requiredXP = nextLevelXP - currentLevelXP;
    return progressXP / requiredXP;
  }

  int _calculateXPForLevel(int level) {
    if (level <= 1) return 0;
    // Same calculation as in datasource
    return (level * 100) + ((level - 1) * level * 25);
  }

  /// Load user progress
  Future<void> loadUserProgress(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getUserProgressUsecase(userId);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (progress) {
        _userProgress = progress;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Add points for an activity
  Future<bool> addPoints(String userId, PointActivity activity) async {
    if (_userProgress == null) return false;

    _setLoading(true);
    _clearError();

    final points = PointValues.getPointsForActivity(activity);
    final result = await addPointsUsecase(AddPointsParams(
      userId: userId,
      points: points,
      activity: activity,
    ));

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (updatedProgress) {
        _userProgress = updatedProgress;
        notifyListeners();
        _setLoading(false);
        return true;
      },
    );
  }

  /// Award achievement
  Future<Achievement?> awardAchievement(
      String userId, String achievementId) async {
    _setLoading(true);
    _clearError();

    final result = await awardAchievementUsecase(
      AwardAchievementParams(
        userId: userId,
        achievementId: achievementId,
      ),
    );

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return null;
      },
      (achievement) {
        // Refresh user progress and achievements
        loadUserProgress(userId);
        loadUserAchievements(userId);
        _setLoading(false);
        return achievement;
      },
    );
  }

  /// Load leaderboard
  Future<void> loadLeaderboard({int limit = 50, String? language}) async {
    _setLoading(true);
    _clearError();

    final result = await getLeaderboardUsecase(
      GetLeaderboardParams(
        limit: limit,
        language: language,
      ),
    );

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (leaderboard) {
        _leaderboard = leaderboard;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Load user achievements
  Future<void> loadUserAchievements(String userId) async {
    final result = await getUserAchievementsUsecase(userId);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (achievements) {
        _userAchievements = achievements;
        notifyListeners();
      },
    );
  }

  /// Check and unlock achievements
  Future<List<Achievement>> checkAndUnlockAchievements(String userId) async {
    final result = await checkAndUnlockAchievementsUsecase(userId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        return [];
      },
      (unlockedAchievements) {
        if (unlockedAchievements.isNotEmpty) {
          // Refresh user progress and achievements
          loadUserProgress(userId);
          loadUserAchievements(userId);
        }
        return unlockedAchievements;
      },
    );
  }

  /// Update daily streak
  Future<bool> updateDailyStreak(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await updateDailyStreakUsecase(userId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (updatedProgress) {
        _userProgress = updatedProgress;
        notifyListeners();
        _setLoading(false);
        return true;
      },
    );
  }

  /// Handle lesson completion (gamification logic)
  Future<void> onLessonCompleted(String userId) async {
    await addPoints(userId, PointActivity.lessonCompleted);
    await updateDailyStreak(userId);
    await checkAndUnlockAchievements(userId);
  }

  /// Handle course completion (gamification logic)
  Future<void> onCourseCompleted(String userId) async {
    await addPoints(userId, PointActivity.courseCompleted);
    await checkAndUnlockAchievements(userId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Erreur de cache: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Erreur réseau: ${failure.message}';
    } else {
      return 'Une erreur s\'est produite: ${failure.message}';
    }
  }
}
