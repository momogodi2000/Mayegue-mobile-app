import '../entities/community_entity.dart';
import '../repositories/social_repository.dart';

/// Usecase for following a user
class FollowUserUseCase {
  final SocialRepository repository;

  FollowUserUseCase(this.repository);

  Future<void> execute(String followerId, String followedId) async {
    await repository.followUser(followerId, followedId);
  }
}

/// Usecase for unfollowing a user
class UnfollowUserUseCase {
  final SocialRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<void> execute(String followerId, String followedId) async {
    await repository.unfollowUser(followerId, followedId);
  }
}

/// Usecase for getting followers
class GetFollowersUseCase {
  final SocialRepository repository;

  GetFollowersUseCase(this.repository);

  Future<List<CommunityUserEntity>> execute(String userId) async {
    return await repository.getFollowers(userId);
  }
}

/// Usecase for getting following
class GetFollowingUseCase {
  final SocialRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<CommunityUserEntity>> execute(String userId) async {
    return await repository.getFollowing(userId);
  }
}

/// Usecase for checking if user is following another
class IsFollowingUseCase {
  final SocialRepository repository;

  IsFollowingUseCase(this.repository);

  Future<bool> execute(String followerId, String followedId) async {
    return await repository.isFollowing(followerId, followedId);
  }
}

/// Usecase for sharing progress
class ShareProgressUseCase {
  final SocialRepository repository;

  ShareProgressUseCase(this.repository);

  Future<void> execute(String userId, Map<String, dynamic> progressData) async {
    await repository.shareProgress(userId, progressData);
  }
}

/// Usecase for getting progress feed
class GetProgressFeedUseCase {
  final SocialRepository repository;

  GetProgressFeedUseCase(this.repository);

  Future<List<Map<String, dynamic>>> execute(String userId, {int limit = 20}) async {
    return await repository.getProgressFeed(userId, limit: limit);
  }
}