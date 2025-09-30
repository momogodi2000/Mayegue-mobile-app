import 'package:equatable/equatable.dart';

/// Community user model for data serialization
class CommunityUserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final String? location;
  final List<String> languages;
  final String role;
  final int reputation;
  final int postsCount;
  final int likesReceived;
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool isOnline;
  final Map<String, dynamic> preferences;

  const CommunityUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    this.location,
    required this.languages,
    required this.role,
    required this.reputation,
    required this.postsCount,
    required this.likesReceived,
    required this.joinedAt,
    this.lastSeenAt,
    required this.isOnline,
    required this.preferences,
  });

  /// Create from JSON
  factory CommunityUserModel.fromJson(Map<String, dynamic> json) {
    return CommunityUserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      languages: List<String>.from(json['languages'] ?? []),
      role: json['role'] as String? ?? 'member',
      reputation: json['reputation'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      likesReceived: json['likesReceived'] as int? ?? 0,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'] as String)
          : null,
      isOnline: json['isOnline'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'languages': languages,
      'role': role,
      'reputation': reputation,
      'postsCount': postsCount,
      'likesReceived': likesReceived,
      'joinedAt': joinedAt.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'isOnline': isOnline,
      'preferences': preferences,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatar,
        bio,
        location,
        languages,
        role,
        reputation,
        postsCount,
        likesReceived,
        joinedAt,
        lastSeenAt,
        isOnline,
        preferences,
      ];
}
