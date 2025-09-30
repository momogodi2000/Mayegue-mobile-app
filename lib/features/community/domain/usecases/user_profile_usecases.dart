import '../entities/community_entity.dart';
import '../repositories/community_repository.dart';

/// Usecase for getting user profile
class GetUserProfileUseCase {
  final CommunityRepository repository;

  GetUserProfileUseCase(this.repository);

  Future<CommunityUserEntity?> execute(String userId) async {
    return await repository.getUserById(userId);
  }
}

/// Usecase for updating user profile
class UpdateUserProfileUseCase {
  final CommunityRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<CommunityUserEntity> execute(String userId, Map<String, dynamic> updates) async {
    return await repository.updateUserProfile(userId, updates);
  }
}

/// Usecase for searching users
class SearchUsersUseCase {
  final CommunityRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<CommunityUserEntity>> execute(String query) async {
    return await repository.searchUsers(query);
  }
}

/// Usecase for getting online users
class GetOnlineUsersUseCase {
  final CommunityRepository repository;

  GetOnlineUsersUseCase(this.repository);

  Future<List<CommunityUserEntity>> execute() async {
    return await repository.getOnlineUsers();
  }
}