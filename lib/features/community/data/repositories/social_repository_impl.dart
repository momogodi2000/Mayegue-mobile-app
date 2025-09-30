import '../../domain/entities/community_entity.dart';
import '../../domain/repositories/social_repository.dart';
import '../datasources/community_remote_datasource.dart';
import '../models/community_user_model.dart';

/// Implementation of SocialRepository
class SocialRepositoryImpl implements SocialRepository {
  final CommunityRemoteDataSource _remoteDataSource;

  SocialRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> followUser(String followerId, String followedId) async {
    await _remoteDataSource.followUser(followerId, followedId);
  }

  @override
  Future<void> unfollowUser(String followerId, String followedId) async {
    await _remoteDataSource.unfollowUser(followerId, followedId);
  }

  @override
  Future<List<CommunityUserEntity>> getFollowers(String userId) async {
    final models = await _remoteDataSource.getFollowers(userId);
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<CommunityUserEntity>> getFollowing(String userId) async {
    final models = await _remoteDataSource.getFollowing(userId);
    return models.map(_mapModelToEntity).toList();
  }

  @override
  Future<bool> isFollowing(String followerId, String followedId) async {
    return await _remoteDataSource.isFollowing(followerId, followedId);
  }

  @override
  Future<void> shareProgress(
      String userId, Map<String, dynamic> progressData) async {
    await _remoteDataSource.shareProgress(userId, progressData);
  }

  @override
  Future<List<Map<String, dynamic>>> getProgressFeed(String userId,
      {int limit = 20}) async {
    return await _remoteDataSource.getProgressFeed(userId, limit: limit);
  }

  // Helper method to map model to entity
  CommunityUserEntity _mapModelToEntity(CommunityUserModel model) {
    return CommunityUserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      avatar: model.avatar,
      bio: model.bio,
      location: model.location,
      languages: model.languages,
      role: _mapStringToUserRole(model.role),
      reputation: model.reputation,
      postsCount: model.postsCount,
      likesReceived: model.likesReceived,
      joinedAt: model.joinedAt,
      lastSeenAt: model.lastSeenAt,
      isOnline: model.isOnline,
      preferences: model.preferences,
    );
  }

  UserRole _mapStringToUserRole(String role) {
    switch (role) {
      case 'moderator':
        return UserRole.moderator;
      case 'admin':
        return UserRole.admin;
      case 'superAdmin':
        return UserRole.superAdmin;
      default:
        return UserRole.member;
    }
  }
}
