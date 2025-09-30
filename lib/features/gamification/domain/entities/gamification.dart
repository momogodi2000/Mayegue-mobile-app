import 'package:equatable/equatable.dart';

/// User progress and gamification data
class UserProgress extends Equatable {
  final String userId;
  final int totalPoints;
  final int currentLevel;
  final int experiencePoints;
  final int pointsToNextLevel;
  final int coins;
  final List<String> ownedItems;
  final List<String> earnedBadges;
  final List<Achievement> achievements;
  final int lessonsCompleted;
  final int coursesCompleted;
  final int streakDays;
  final DateTime lastActivityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProgress({
    required this.userId,
    required this.totalPoints,
    required this.currentLevel,
    required this.experiencePoints,
    required this.pointsToNextLevel,
    required this.coins,
    required this.ownedItems,
    required this.earnedBadges,
    required this.achievements,
    required this.lessonsCompleted,
    required this.coursesCompleted,
    required this.streakDays,
    required this.lastActivityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with updated fields
  UserProgress copyWith({
    String? userId,
    int? totalPoints,
    int? currentLevel,
    int? experiencePoints,
    int? pointsToNextLevel,
    int? coins,
    List<String>? ownedItems,
    List<String>? earnedBadges,
    List<Achievement>? achievements,
    int? lessonsCompleted,
    int? coursesCompleted,
    int? streakDays,
    DateTime? lastActivityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      coins: coins ?? this.coins,
      ownedItems: ownedItems ?? this.ownedItems,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      achievements: achievements ?? this.achievements,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
      streakDays: streakDays ?? this.streakDays,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        totalPoints,
        currentLevel,
        experiencePoints,
        pointsToNextLevel,
        coins,
        ownedItems,
        earnedBadges,
        achievements,
        lessonsCompleted,
        coursesCompleted,
        streakDays,
        lastActivityDate,
        createdAt,
        updatedAt,
      ];
}

/// Achievement entity
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementType type;
  final int pointsReward;
  final Map<String, dynamic> criteria;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    required this.pointsReward,
    required this.criteria,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// Create a copy with updated fields
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementType? type,
    int? pointsReward,
    Map<String, dynamic>? criteria,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      pointsReward: pointsReward ?? this.pointsReward,
      criteria: criteria ?? this.criteria,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconName,
        type,
        pointsReward,
        criteria,
        isUnlocked,
        unlockedAt,
      ];
}

/// Badge entity
class Badge extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final BadgeRarity rarity;
  final int pointsRequired;
  final BadgeCategory category;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.rarity,
    required this.pointsRequired,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconName,
        rarity,
        pointsRequired,
        category,
      ];
}

/// Leaderboard entry
class LeaderboardEntry extends Equatable {
  final String userId;
  final String userName;
  final String userAvatar;
  final int totalPoints;
  final int currentLevel;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.totalPoints,
    required this.currentLevel,
    required this.rank,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        userAvatar,
        totalPoints,
        currentLevel,
        rank,
      ];
}

/// Achievement types
enum AchievementType {
  lessonCompletion,
  courseCompletion,
  streak,
  pointsMilestone,
  social,
  special,
}

/// Badge rarity levels
enum BadgeRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

/// Badge categories
enum BadgeCategory {
  learning,
  social,
  achievement,
  special,
}

/// Point earning activities
enum PointActivity {
  lessonCompleted,
  courseCompleted,
  dailyStreak,
  perfectScore,
  helpOthers,
  shareAchievement,
  quizCompleted,
}

/// Point values for different activities
class PointValues {
  static const int lessonCompleted = 10;
  static const int courseCompleted = 50;
  static const int dailyStreak = 5;
  static const int perfectScore = 25;
  static const int helpOthers = 15;
  static const int shareAchievement = 10;
  static const int quizCompleted = 20;

  static int getPointsForActivity(PointActivity activity) {
    switch (activity) {
      case PointActivity.lessonCompleted:
        return lessonCompleted;
      case PointActivity.courseCompleted:
        return courseCompleted;
      case PointActivity.dailyStreak:
        return dailyStreak;
      case PointActivity.perfectScore:
        return perfectScore;
      case PointActivity.helpOthers:
        return helpOthers;
      case PointActivity.shareAchievement:
        return shareAchievement;
      case PointActivity.quizCompleted:
        return quizCompleted;
    }
  }
}

/// Shop item for virtual economy
class ShopItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int price;
  final ShopItemType type;
  final Map<String, dynamic> metadata;
  final bool isAvailable;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.price,
    required this.type,
    required this.metadata,
    required this.isAvailable,
  });

  @override
  List<Object?> get props =>
      [id, name, description, iconName, price, type, metadata, isAvailable];
}

/// Types of shop items
enum ShopItemType {
  avatar,
  theme,
  cosmetic,
  powerUp,
}
