import 'package:flutter/foundation.dart';
import '../../domain/entities/community_entity.dart';
import '../../domain/usecases/social_usecases.dart';
import '../../domain/usecases/user_profile_usecases.dart';

/// ViewModel for social features
class SocialViewModel extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final FollowUserUseCase _followUserUseCase;
  final UnfollowUserUseCase _unfollowUserUseCase;
  final GetFollowersUseCase _getFollowersUseCase;
  final GetFollowingUseCase _getFollowingUseCase;
  final IsFollowingUseCase _isFollowingUseCase;
  final ShareProgressUseCase _shareProgressUseCase;
  final GetProgressFeedUseCase _getProgressFeedUseCase;

  SocialViewModel(
    this._getUserProfileUseCase,
    this._updateUserProfileUseCase,
    this._followUserUseCase,
    this._unfollowUserUseCase,
    this._getFollowersUseCase,
    this._getFollowingUseCase,
    this._isFollowingUseCase,
    this._shareProgressUseCase,
    this._getProgressFeedUseCase,
  );

  // State
  CommunityUserEntity? _currentUserProfile;
  List<CommunityUserEntity> _followers = [];
  List<CommunityUserEntity> _following = [];
  List<CommunityUserEntity> _users = [];
  List<Map<String, dynamic>> _progressFeed = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  CommunityUserEntity? get currentUserProfile => _currentUserProfile;
  List<CommunityUserEntity> get followers => _followers;
  List<CommunityUserEntity> get following => _following;
  List<CommunityUserEntity> get users => _users;
  List<Map<String, dynamic>> get progressFeed => _progressFeed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUserProfile = await _getUserProfileUseCase.execute(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUserProfile =
          await _updateUserProfileUseCase.execute(userId, updates);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Follow user
  Future<void> followUser(String followerId, String followedId) async {
    try {
      await _followUserUseCase.execute(followerId, followedId);
      // Reload following list if current user is following
      if (followerId == _currentUserProfile?.id) {
        await loadFollowing(followerId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Unfollow user
  Future<void> unfollowUser(String followerId, String followedId) async {
    try {
      await _unfollowUserUseCase.execute(followerId, followedId);
      // Reload following list if current user is unfollowing
      if (followerId == _currentUserProfile?.id) {
        await loadFollowing(followerId);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load followers
  Future<void> loadFollowers(String userId) async {
    try {
      _followers = await _getFollowersUseCase.execute(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load following
  Future<void> loadFollowing(String userId) async {
    try {
      _following = await _getFollowingUseCase.execute(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check if following
  Future<bool> isFollowing(String followerId, String followedId) async {
    try {
      return await _isFollowingUseCase.execute(followerId, followedId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Share progress
  Future<void> shareProgress(
      String userId, Map<String, dynamic> progressData) async {
    try {
      await _shareProgressUseCase.execute(userId, progressData);
      // Reload progress feed
      await loadProgressFeed(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load progress feed
  Future<void> loadProgressFeed(String userId) async {
    try {
      _progressFeed = await _getProgressFeedUseCase.execute(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load users for discovery
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual user loading from repository
      // For now, using mock data
      _users = [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh users
  Future<void> refreshUsers() async {
    await loadUsers();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
