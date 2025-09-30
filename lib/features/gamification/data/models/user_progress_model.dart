import '../../domain/entities/gamification.dart';
import 'achievement_model.dart';

/// UserProgress model for data serialization
class UserProgressModel extends UserProgress {
  const UserProgressModel({
    required super.userId,
    required super.totalPoints,
    required super.currentLevel,
    required super.experiencePoints,
    required super.pointsToNextLevel,
    required super.coins,
    required super.ownedItems,
    required super.earnedBadges,
    required super.achievements,
    required super.lessonsCompleted,
    required super.coursesCompleted,
    required super.streakDays,
    required super.lastActivityDate,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create UserProgressModel from JSON
  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['userId'] as String,
      totalPoints: json['totalPoints'] as int,
      currentLevel: json['currentLevel'] as int,
      experiencePoints: json['experiencePoints'] as int,
      pointsToNextLevel: json['pointsToNextLevel'] as int,
      coins: json['coins'] as int? ?? 0,
      ownedItems: List<String>.from(json['ownedItems'] as List? ?? []),
      earnedBadges: List<String>.from(json['earnedBadges'] as List? ?? []),
      achievements: (json['achievements'] as List?)
              ?.map((a) => AchievementModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      lessonsCompleted: json['lessonsCompleted'] as int,
      coursesCompleted: json['coursesCompleted'] as int,
      streakDays: json['streakDays'] as int,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert UserProgressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
      'pointsToNextLevel': pointsToNextLevel,
      'coins': coins,
      'ownedItems': ownedItems,
      'earnedBadges': earnedBadges,
      'achievements': achievements
          .map((a) => AchievementModel.fromEntity(a).toJson())
          .toList(),
      'lessonsCompleted': lessonsCompleted,
      'coursesCompleted': coursesCompleted,
      'streakDays': streakDays,
      'lastActivityDate': lastActivityDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create UserProgressModel from UserProgress entity
  factory UserProgressModel.fromEntity(UserProgress progress) {
    return UserProgressModel(
      userId: progress.userId,
      totalPoints: progress.totalPoints,
      currentLevel: progress.currentLevel,
      experiencePoints: progress.experiencePoints,
      pointsToNextLevel: progress.pointsToNextLevel,
      coins: progress.coins,
      ownedItems: progress.ownedItems,
      earnedBadges: progress.earnedBadges,
      achievements: progress.achievements,
      lessonsCompleted: progress.lessonsCompleted,
      coursesCompleted: progress.coursesCompleted,
      streakDays: progress.streakDays,
      lastActivityDate: progress.lastActivityDate,
      createdAt: progress.createdAt,
      updatedAt: progress.updatedAt,
    );
  }

  /// Convert UserProgressModel to UserProgress entity
  UserProgress toEntity() {
    return UserProgress(
      userId: userId,
      totalPoints: totalPoints,
      currentLevel: currentLevel,
      experiencePoints: experiencePoints,
      pointsToNextLevel: pointsToNextLevel,
      coins: coins,
      ownedItems: ownedItems,
      earnedBadges: earnedBadges,
      achievements: achievements,
      lessonsCompleted: lessonsCompleted,
      coursesCompleted: coursesCompleted,
      streakDays: streakDays,
      lastActivityDate: lastActivityDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
