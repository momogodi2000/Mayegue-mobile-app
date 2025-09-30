import 'user_entity.dart';

/// Authentication response entity
class AuthResponseEntity {
  final UserEntity user;
  final String? token;
  final bool success;
  final String? message;

  const AuthResponseEntity({
    required this.user,
    this.token,
    this.success = true,
    this.message,
  });

  /// Create from JSON
  factory AuthResponseEntity.fromJson(Map<String, dynamic> json) {
    return AuthResponseEntity(
      user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'success': success,
      'message': message,
    };
  }
}
