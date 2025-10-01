class User {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final List<String> permissions;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.isActive = true,
    this.lastLoginAt,
    this.createdAt,
    this.permissions = const [],
  });

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isLearner => role == 'learner';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          role == other.role &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      role.hashCode ^
      isActive.hashCode;

  @override
  String toString() =>
      'User{uid: $uid, email: $email, displayName: $displayName, role: $role, isActive: $isActive}';
}
