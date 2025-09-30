import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/gamification.dart';
import '../models/user_progress_model.dart';
import '../models/achievement_model.dart';
import 'gamification_datasource.dart';

/// Local data source implementation using Hive
class GamificationLocalDataSource implements GamificationDataSource {
  static const String _userProgressBoxName = 'user_progress';
  static const String _achievementsBoxName = 'achievements';

  late Box<UserProgressModel> _userProgressBox;
  late Box<AchievementModel> _achievementsBox;

  Future<void> initialize() async {
    _userProgressBox =
        await Hive.openBox<UserProgressModel>(_userProgressBoxName);
    _achievementsBox =
        await Hive.openBox<AchievementModel>(_achievementsBoxName);

    // Initialize with sample data if empty
    if (_achievementsBox.isEmpty) {
      await _initializeAchievements();
    }
  }

  Future<void> _initializeAchievements() async {
    final achievements = _getDefaultAchievements();
    for (final achievement in achievements) {
      await _achievementsBox.put(achievement.id, achievement);
    }
  }

  List<AchievementModel> _getDefaultAchievements() {
    return [
      // Learning achievements
      const AchievementModel(
        id: 'first_lesson',
        title: 'Premier pas',
        description: 'Complétez votre première leçon',
        iconName: 'school',
        type: AchievementType.lessonCompletion,
        pointsReward: 10,
        criteria: {'lessons_completed': 1},
        isUnlocked: false,
        unlockedAt: null,
      ),
      const AchievementModel(
        id: 'lesson_master',
        title: 'Maître des leçons',
        description: 'Complétez 10 leçons',
        iconName: 'local_library',
        type: AchievementType.lessonCompletion,
        pointsReward: 50,
        criteria: {'lessons_completed': 10},
        isUnlocked: false,
        unlockedAt: null,
      ),
      const AchievementModel(
        id: 'course_champion',
        title: 'Champion de cours',
        description: 'Terminez votre premier cours complet',
        iconName: 'emoji_events',
        type: AchievementType.courseCompletion,
        pointsReward: 100,
        criteria: {'courses_completed': 1},
        isUnlocked: false,
        unlockedAt: null,
      ),

      // Streak achievements
      const AchievementModel(
        id: 'streak_beginner',
        title: 'Débutant assidu',
        description: 'Maintenez une série de 3 jours',
        iconName: 'local_fire_department',
        type: AchievementType.streak,
        pointsReward: 15,
        criteria: {'streak_days': 3},
        isUnlocked: false,
        unlockedAt: null,
      ),
      const AchievementModel(
        id: 'streak_warrior',
        title: 'Guerrier de la série',
        description: 'Maintenez une série de 7 jours',
        iconName: 'whatshot',
        type: AchievementType.streak,
        pointsReward: 30,
        criteria: {'streak_days': 7},
        isUnlocked: false,
        unlockedAt: null,
      ),
      const AchievementModel(
        id: 'streak_legend',
        title: 'Légende de la série',
        description: 'Maintenez une série de 30 jours',
        iconName: 'local_fire_department',
        type: AchievementType.streak,
        pointsReward: 100,
        criteria: {'streak_days': 30},
        isUnlocked: false,
        unlockedAt: null,
      ),

      // Points milestones
      const AchievementModel(
        id: 'points_100',
        title: 'Centurion',
        description: 'Accumulez 100 points',
        iconName: 'stars',
        type: AchievementType.pointsMilestone,
        pointsReward: 25,
        criteria: {'total_points': 100},
        isUnlocked: false,
        unlockedAt: null,
      ),
      const AchievementModel(
        id: 'points_500',
        title: 'Maître des points',
        description: 'Accumulez 500 points',
        iconName: 'workspace_premium',
        type: AchievementType.pointsMilestone,
        pointsReward: 50,
        criteria: {'total_points': 500},
        isUnlocked: false,
        unlockedAt: null,
      ),
    ];
  }

  @override
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final progressModel = _userProgressBox.get(userId);
      if (progressModel == null) {
        // Create default progress for new user
        final defaultProgress = UserProgressModel(
          userId: userId,
          totalPoints: 0,
          currentLevel: 1,
          experiencePoints: 0,
          pointsToNextLevel: 100,
          coins: 0,
          ownedItems: const [],
          earnedBadges: const [],
          achievements: const [],
          lessonsCompleted: 0,
          coursesCompleted: 0,
          streakDays: 0,
          lastActivityDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userProgressBox.put(userId, defaultProgress);
        return defaultProgress.toEntity();
      }
      return progressModel.toEntity();
    } catch (e) {
      throw CacheFailure('Failed to get user progress: $e');
    }
  }

  @override
  Future<UserProgress> updateUserProgress(
      String userId, UserProgress progress) async {
    try {
      final progressModel = UserProgressModel.fromEntity(progress);
      await _userProgressBox.put(userId, progressModel);
      return progress;
    } catch (e) {
      throw CacheFailure('Failed to update user progress: $e');
    }
  }

  @override
  Future<List<Achievement>> getAvailableAchievements() async {
    try {
      final achievementModels = _achievementsBox.values.toList();
      return achievementModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw CacheFailure('Failed to get achievements: $e');
    }
  }

  @override
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final userProgress = await getUserProgress(userId);
      return userProgress.achievements;
    } catch (e) {
      throw CacheFailure('Failed to get user achievements: $e');
    }
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    try {
      final userProgress = await getUserProgress(userId);
      final updatedAchievements =
          List<Achievement>.from(userProgress.achievements);

      // Check if achievement is already unlocked
      if (updatedAchievements.any((a) => a.id == achievementId)) {
        return; // Already unlocked
      }

      // Get the achievement to add
      final achievement = _achievementsBox.get(achievementId);
      if (achievement != null) {
        updatedAchievements.add(achievement.toEntity());

        final updatedProgress = UserProgress(
          userId: userProgress.userId,
          totalPoints: userProgress.totalPoints,
          currentLevel: userProgress.currentLevel,
          experiencePoints: userProgress.experiencePoints,
          pointsToNextLevel: userProgress.pointsToNextLevel,
          coins: userProgress.coins,
          ownedItems: userProgress.ownedItems,
          earnedBadges: userProgress.earnedBadges,
          achievements: updatedAchievements,
          lessonsCompleted: userProgress.lessonsCompleted,
          coursesCompleted: userProgress.coursesCompleted,
          streakDays: userProgress.streakDays,
          lastActivityDate: userProgress.lastActivityDate,
          createdAt: userProgress.createdAt,
          updatedAt: DateTime.now(),
        );

        await updateUserProgress(userId, updatedProgress);
      }
    } catch (e) {
      throw CacheFailure('Failed to unlock achievement: $e');
    }
  }

  @override
  Future<UserProgress> addPoints(
      String userId, int points, PointActivity activity) async {
    try {
      final userProgress = await getUserProgress(userId);
      final newTotalPoints = userProgress.totalPoints + points;
      int newExperiencePoints = userProgress.experiencePoints + points;

      // Calculate level progression
      int newLevel = userProgress.currentLevel;
      int newPointsToNextLevel = userProgress.pointsToNextLevel;

      while (newExperiencePoints >= newPointsToNextLevel) {
        newExperiencePoints -= newPointsToNextLevel;
        newLevel++;
        newPointsToNextLevel = (newLevel * 100).toInt(); // 100 points per level
      }

      final updatedProgress = UserProgress(
        userId: userProgress.userId,
        totalPoints: newTotalPoints,
        currentLevel: newLevel,
        experiencePoints: newExperiencePoints,
        pointsToNextLevel: newPointsToNextLevel,
        coins: userProgress.coins,
        ownedItems: userProgress.ownedItems,
        earnedBadges: userProgress.earnedBadges,
        achievements: userProgress.achievements,
        lessonsCompleted: userProgress.lessonsCompleted,
        coursesCompleted: userProgress.coursesCompleted,
        streakDays: userProgress.streakDays,
        lastActivityDate: DateTime.now(),
        createdAt: userProgress.createdAt,
        updatedAt: DateTime.now(),
      );

      return await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw CacheFailure('Failed to add points: $e');
    }
  }

  Future<void> updateStreak(String userId, int streakDays) async {
    try {
      final userProgress = await getUserProgress(userId);
      final updatedProgress = UserProgress(
        userId: userProgress.userId,
        totalPoints: userProgress.totalPoints,
        currentLevel: userProgress.currentLevel,
        experiencePoints: userProgress.experiencePoints,
        pointsToNextLevel: userProgress.pointsToNextLevel,
        coins: userProgress.coins,
        ownedItems: userProgress.ownedItems,
        earnedBadges: userProgress.earnedBadges,
        achievements: userProgress.achievements,
        lessonsCompleted: userProgress.lessonsCompleted,
        coursesCompleted: userProgress.coursesCompleted,
        streakDays: streakDays,
        lastActivityDate: DateTime.now(),
        createdAt: userProgress.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw CacheFailure('Failed to update streak: $e');
    }
  }

  Future<void> completeLesson(String userId, String lessonId) async {
    try {
      final userProgress = await getUserProgress(userId);
      final updatedProgress = UserProgress(
        userId: userProgress.userId,
        totalPoints: userProgress.totalPoints,
        currentLevel: userProgress.currentLevel,
        experiencePoints: userProgress.experiencePoints,
        pointsToNextLevel: userProgress.pointsToNextLevel,
        coins: userProgress.coins,
        ownedItems: userProgress.ownedItems,
        earnedBadges: userProgress.earnedBadges,
        achievements: userProgress.achievements,
        lessonsCompleted: userProgress.lessonsCompleted + 1,
        coursesCompleted: userProgress.coursesCompleted,
        streakDays: userProgress.streakDays,
        lastActivityDate: DateTime.now(),
        createdAt: userProgress.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw CacheFailure('Failed to complete lesson: $e');
    }
  }

  Future<void> completeCourse(String userId, String courseId) async {
    try {
      final userProgress = await getUserProgress(userId);
      final updatedProgress = UserProgress(
        userId: userProgress.userId,
        totalPoints: userProgress.totalPoints,
        currentLevel: userProgress.currentLevel,
        experiencePoints: userProgress.experiencePoints,
        pointsToNextLevel: userProgress.pointsToNextLevel,
        coins: userProgress.coins,
        ownedItems: userProgress.ownedItems,
        earnedBadges: userProgress.earnedBadges,
        achievements: userProgress.achievements,
        lessonsCompleted: userProgress.lessonsCompleted,
        coursesCompleted: userProgress.coursesCompleted + 1,
        streakDays: userProgress.streakDays,
        lastActivityDate: DateTime.now(),
        createdAt: userProgress.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw CacheFailure('Failed to complete course: $e');
    }
  }

  @override
  Future<Achievement> awardAchievement(
      String userId, String achievementId) async {
    try {
      final achievement = _achievementsBox.get(achievementId);
      if (achievement == null) {
        throw CacheFailure('Achievement not found: $achievementId');
      }

      await unlockAchievement(userId, achievementId);
      return achievement.toEntity();
    } catch (e) {
      throw CacheFailure('Failed to award achievement: $e');
    }
  }

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(
      {int limit = 50, String? language}) async {
    try {
      final allProgress = _userProgressBox.values.toList();
      final sortedProgress = allProgress
        ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

      return sortedProgress
          .take(limit)
          .map((progress) => LeaderboardEntry(
                userId: progress.userId,
                userName: progress.userId, // In real app, get from user service
                userAvatar: '', // In real app, get from user service
                totalPoints: progress.totalPoints,
                currentLevel: progress.currentLevel,
                rank: sortedProgress.indexOf(progress) + 1,
              ))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get leaderboard: $e');
    }
  }

  @override
  Future<int> getUserRank(String userId) async {
    try {
      final leaderboard = await getLeaderboard();
      final userEntry = leaderboard.firstWhere(
        (entry) => entry.userId == userId,
        orElse: () => LeaderboardEntry(
          userId: userId,
          userName: userId,
          userAvatar: '',
          totalPoints: 0,
          currentLevel: 1,
          rank: leaderboard.length + 1,
        ),
      );
      return userEntry.rank;
    } catch (e) {
      throw CacheFailure('Failed to get user rank: $e');
    }
  }

  @override
  Future<List<Achievement>> checkAndUnlockAchievements(String userId) async {
    try {
      final userProgress = await getUserProgress(userId);
      final allAchievements = await getAvailableAchievements();
      final unlockedAchievements = <Achievement>[];

      for (final achievement in allAchievements) {
        if (!userProgress.achievements.any((a) => a.id == achievement.id)) {
          bool shouldUnlock = false;

          switch (achievement.type) {
            case AchievementType.lessonCompletion:
              shouldUnlock = userProgress.lessonsCompleted >=
                  (achievement.criteria['lessons_completed'] as int? ?? 0);
              break;
            case AchievementType.courseCompletion:
              shouldUnlock = userProgress.coursesCompleted >=
                  (achievement.criteria['courses_completed'] as int? ?? 0);
              break;
            case AchievementType.streak:
              shouldUnlock = userProgress.streakDays >=
                  (achievement.criteria['streak_days'] as int? ?? 0);
              break;
            case AchievementType.pointsMilestone:
              shouldUnlock = userProgress.totalPoints >=
                  (achievement.criteria['total_points'] as int? ?? 0);
              break;
            case AchievementType.social:
              // Social achievements are typically unlocked through specific actions
              // For now, we don't auto-unlock them in this check
              shouldUnlock = false;
              break;
            case AchievementType.special:
              // Special achievements are typically unlocked through specific actions
              // For now, we don't auto-unlock them in this check
              shouldUnlock = false;
              break;
          }

          if (shouldUnlock) {
            await unlockAchievement(userId, achievement.id);
            unlockedAchievements.add(achievement);
          }
        }
      }

      return unlockedAchievements;
    } catch (e) {
      throw CacheFailure('Failed to check and unlock achievements: $e');
    }
  }

  @override
  Future<UserProgress> updateDailyStreak(String userId) async {
    try {
      final userProgress = await getUserProgress(userId);
      final now = DateTime.now();
      final lastActivity = userProgress.lastActivityDate;

      int newStreakDays = userProgress.streakDays;

      // Check if it's a new day
      if (lastActivity.day != now.day ||
          lastActivity.month != now.month ||
          lastActivity.year != now.year) {
        // Check if it's consecutive (within 24 hours + 1 day grace period)
        final daysDifference = now.difference(lastActivity).inDays;
        if (daysDifference == 1) {
          newStreakDays++;
        } else if (daysDifference > 1) {
          newStreakDays = 1; // Reset streak
        }
      }

      final updatedProgress = UserProgress(
        userId: userProgress.userId,
        totalPoints: userProgress.totalPoints,
        currentLevel: userProgress.currentLevel,
        experiencePoints: userProgress.experiencePoints,
        pointsToNextLevel: userProgress.pointsToNextLevel,
        coins: userProgress.coins,
        ownedItems: userProgress.ownedItems,
        earnedBadges: userProgress.earnedBadges,
        achievements: userProgress.achievements,
        lessonsCompleted: userProgress.lessonsCompleted,
        coursesCompleted: userProgress.coursesCompleted,
        streakDays: newStreakDays,
        lastActivityDate: now,
        createdAt: userProgress.createdAt,
        updatedAt: now,
      );

      return await updateUserProgress(userId, updatedProgress);
    } catch (e) {
      throw CacheFailure('Failed to update daily streak: $e');
    }
  }

  Future<void> dispose() async {
    await _userProgressBox.close();
    await _achievementsBox.close();
  }
}
