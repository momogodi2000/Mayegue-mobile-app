/// Onboarding entity representing user onboarding data
class OnboardingEntity {
  final String selectedLanguage;
  final String userName;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final DateTime completedAt;

  const OnboardingEntity({
    required this.selectedLanguage,
    required this.userName,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.completedAt,
  });

  // Create a copy with modified fields
  OnboardingEntity copyWith({
    String? selectedLanguage,
    String? userName,
    bool? notificationsEnabled,
    bool? soundEnabled,
    DateTime? completedAt,
  }) {
    return OnboardingEntity(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      userName: userName ?? this.userName,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'selectedLanguage': selectedLanguage,
      'userName': userName,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory OnboardingEntity.fromJson(Map<String, dynamic> json) {
    return OnboardingEntity(
      selectedLanguage: json['selectedLanguage'] as String? ?? 'ewondo',
      userName: json['userName'] as String? ?? '',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'OnboardingEntity(selectedLanguage: $selectedLanguage, userName: $userName, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OnboardingEntity &&
        other.selectedLanguage == selectedLanguage &&
        other.userName == userName &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return selectedLanguage.hashCode ^
        userName.hashCode ^
        notificationsEnabled.hashCode ^
        soundEnabled.hashCode ^
        completedAt.hashCode;
  }
}
