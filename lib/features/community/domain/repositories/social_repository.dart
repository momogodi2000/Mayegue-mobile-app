import '../entities/community_entity.dart';

/// Repository interface for social operations
abstract class SocialRepository {
  // Following operations
  Future<void> followUser(String followerId, String followedId);
  Future<void> unfollowUser(String followerId, String followedId);
  Future<List<CommunityUserEntity>> getFollowers(String userId);
  Future<List<CommunityUserEntity>> getFollowing(String userId);
  Future<bool> isFollowing(String followerId, String followedId);

  // Progress sharing operations
  Future<void> shareProgress(String userId, Map<String, dynamic> progressData);
  Future<List<Map<String, dynamic>>> getProgressFeed(String userId, {int limit = 20});
}