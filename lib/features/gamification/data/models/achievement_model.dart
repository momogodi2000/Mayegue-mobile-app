import '../../domain/entities/gamification.dart';

/// Achievement model for data serialization
class AchievementModel extends Achievement {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconName,
    required super.type,
    required super.pointsReward,
    required super.criteria,
    required super.isUnlocked,
    super.unlockedAt,
  });

  /// Create AchievementModel from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      type: AchievementType.values[json['type'] as int],
      pointsReward: json['pointsReward'] as int,
      criteria: json['criteria'] as Map<String, dynamic>,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  /// Convert AchievementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'type': type.index,
      'pointsReward': pointsReward,
      'criteria': criteria,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  /// Create AchievementModel from Achievement entity
  factory AchievementModel.fromEntity(Achievement achievement) {
    return AchievementModel(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      iconName: achievement.iconName,
      type: achievement.type,
      pointsReward: achievement.pointsReward,
      criteria: achievement.criteria,
      isUnlocked: achievement.isUnlocked,
      unlockedAt: achievement.unlockedAt,
    );
  }

  /// Convert AchievementModel to Achievement entity
  Achievement toEntity() {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      type: type,
      pointsReward: pointsReward,
      criteria: criteria,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }
}
