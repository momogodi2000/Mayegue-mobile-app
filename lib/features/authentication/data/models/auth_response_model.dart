import '../../domain/entities/auth_response_entity.dart';
import 'user_model.dart';

/// Auth response model for data layer
class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    super.token,
    super.success,
    super.message,
  });

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: UserModel.fromEntity(AuthResponseEntity.fromJson(json).user),
      token: json['token'],
      success: json['success'] ?? true,
      message: json['message'],
    );
  }

  /// Convert to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
      'success': success,
      'message': message,
    };
  }
}
