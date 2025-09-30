import '../../domain/entities/onboarding_entity.dart';

/// Onboarding model for data layer
class OnboardingModel extends OnboardingEntity {
  const OnboardingModel({
    required super.selectedLanguage,
    required super.userName,
    required super.notificationsEnabled,
    required super.soundEnabled,
    required super.completedAt,
  });

  // Create from entity
  factory OnboardingModel.fromEntity(OnboardingEntity entity) {
    return OnboardingModel(
      selectedLanguage: entity.selectedLanguage,
      userName: entity.userName,
      notificationsEnabled: entity.notificationsEnabled,
      soundEnabled: entity.soundEnabled,
      completedAt: entity.completedAt,
    );
  }

  // Create from JSON
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      selectedLanguage: json['selectedLanguage'] as String? ?? 'ewondo',
      userName: json['userName'] as String? ?? '',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  // Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'selectedLanguage': selectedLanguage,
      'userName': userName,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // Convert to entity
  OnboardingEntity toEntity() {
    return OnboardingEntity(
      selectedLanguage: selectedLanguage,
      userName: userName,
      notificationsEnabled: notificationsEnabled,
      soundEnabled: soundEnabled,
      completedAt: completedAt,
    );
  }
}
