/// User entity
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String role;
  final List<String> languages;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
    this.role = 'learner',
    this.languages = const [],
    required this.createdAt,
    this.lastLoginAt,
    this.isEmailVerified = false,
    this.preferences,
  });

  /// Create from Firebase User
  factory UserEntity.fromFirebaseUser(dynamic firebaseUser) {
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  /// Create from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      role: json['role'] as String? ?? 'learner',
      languages: List<String>.from(json['languages'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role,
      'languages': languages,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
    };
  }

  /// Copy with
  UserEntity copyWith({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? role,
    List<String>? languages,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      languages: languages ?? this.languages,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Check if user has role
  bool hasRole(String role) => this.role == role;

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is teacher
  bool get isTeacher => role == 'teacher';

  /// Check if user is learner
  bool get isLearner => role == 'learner';
}
