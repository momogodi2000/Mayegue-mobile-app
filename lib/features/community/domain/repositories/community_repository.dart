import '../entities/community_entity.dart';

/// Repository interface for community management
abstract class CommunityRepository {
  // Forum operations
  Future<List<ForumEntity>> getForums(String language);
  Future<ForumEntity?> getForumById(String forumId);
  Future<List<TopicEntity>> getTopics(String forumId, {int limit = 20, int offset = 0});
  Future<TopicEntity?> getTopicById(String topicId);
  Future<List<PostEntity>> getPosts(String topicId, {int limit = 20, int offset = 0});
  Future<PostEntity?> getPostById(String postId);

  // Forum content creation
  Future<TopicEntity> createTopic(TopicEntity topic);
  Future<PostEntity> createPost(PostEntity post);
  Future<TopicEntity> updateTopic(String topicId, Map<String, dynamic> updates);
  Future<PostEntity> updatePost(String postId, Map<String, dynamic> updates);
  Future<void> deleteTopic(String topicId);
  Future<void> deletePost(String postId);

  // Forum interactions
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<void> markTopicAsSolved(String topicId);
  Future<void> pinTopic(String topicId);
  Future<void> unpinTopic(String topicId);
  Future<void> lockTopic(String topicId);
  Future<void> unlockTopic(String topicId);

  // Chat operations
  Future<List<ChatConversationEntity>> getConversations(String userId);
  Future<ChatConversationEntity?> getConversationById(String conversationId);
  Future<List<ChatMessageEntity>> getMessages(String conversationId, {int limit = 50, int offset = 0});
  Future<ChatMessageEntity> sendMessage(ChatMessageEntity message);
  Future<ChatConversationEntity> createConversation(ChatConversationEntity conversation);
  Future<void> updateMessage(String messageId, String content);
  Future<void> deleteMessage(String messageId);

  // Chat interactions
  Future<void> markMessageAsRead(String conversationId, String userId);
  Future<void> markConversationAsRead(String conversationId, String userId);
  Future<void> archiveConversation(String conversationId, String userId);
  Future<void> unarchiveConversation(String conversationId, String userId);
  Future<void> muteConversation(String conversationId, String userId);
  Future<void> unmuteConversation(String conversationId, String userId);

  // User operations
  Future<List<CommunityUserEntity>> getUsers({int limit = 20, int offset = 0});
  Future<CommunityUserEntity?> getUserById(String userId);
  Future<List<CommunityUserEntity>> searchUsers(String query);
  Future<List<CommunityUserEntity>> getOnlineUsers();
  Future<CommunityUserEntity> updateUserProfile(String userId, Map<String, dynamic> updates);

  // Following operations
  Future<void> followUser(String followerId, String followedId);
  Future<void> unfollowUser(String followerId, String followedId);
  Future<List<CommunityUserEntity>> getFollowers(String userId);
  Future<List<CommunityUserEntity>> getFollowing(String userId);
  Future<bool> isFollowing(String followerId, String followedId);

  // Progress sharing operations
  Future<void> shareProgress(String userId, Map<String, dynamic> progressData);
  Future<List<Map<String, dynamic>>> getProgressFeed(String userId, {int limit = 20});

  // Search operations
  Future<List<TopicEntity>> searchTopics(String query, {String? forumId});
  Future<List<PostEntity>> searchPosts(String query, {String? topicId});
  Future<List<ChatMessageEntity>> searchMessages(String query, String conversationId);

  // Moderation operations
  Future<void> reportContent(String contentId, String contentType, String reason, String reporterId);
  Future<List<Map<String, dynamic>>> getReports({int limit = 20, int offset = 0});
  Future<void> moderateContent(String contentId, String action, String moderatorId);
  Future<void> banUser(String userId, String reason, DateTime until, String moderatorId);
  Future<void> unbanUser(String userId, String moderatorId);

  // Statistics
  Future<Map<String, dynamic>> getCommunityStats();
  Future<Map<String, dynamic>> getUserStats(String userId);
  Future<List<Map<String, dynamic>>> getTopContributors({int limit = 10});

  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications(String userId, {int limit = 20, int offset = 0});
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);

  // Language exchange
  Future<List<CommunityUserEntity>> findLanguagePartners(String userId, String targetLanguage);
  Future<void> requestLanguagePartnership(String requesterId, String partnerId, String language);
  Future<void> acceptLanguagePartnership(String partnershipId);
  Future<void> declineLanguagePartnership(String partnershipId);

  // Events
  Future<List<Map<String, dynamic>>> getCommunityEvents({int limit = 20, int offset = 0});
  Future<Map<String, dynamic>?> getEventById(String eventId);
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}