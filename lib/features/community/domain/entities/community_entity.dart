import 'package:equatable/equatable.dart';

/// Forum entity
class ForumEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String language;
  final String category;
  final int topicsCount;
  final int postsCount;
  final DateTime lastActivity;
  final String? lastPostBy;
  final String? moderatorId;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ForumEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.category,
    required this.topicsCount,
    required this.postsCount,
    required this.lastActivity,
    this.lastPostBy,
    this.moderatorId,
    required this.isActive,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        language,
        category,
        topicsCount,
        postsCount,
        lastActivity,
        lastPostBy,
        moderatorId,
        isActive,
        metadata,
        createdAt,
        updatedAt,
      ];

  ForumEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    String? category,
    int? topicsCount,
    int? postsCount,
    DateTime? lastActivity,
    String? lastPostBy,
    String? moderatorId,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForumEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      category: category ?? this.category,
      topicsCount: topicsCount ?? this.topicsCount,
      postsCount: postsCount ?? this.postsCount,
      lastActivity: lastActivity ?? this.lastActivity,
      lastPostBy: lastPostBy ?? this.lastPostBy,
      moderatorId: moderatorId ?? this.moderatorId,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Topic entity
class TopicEntity extends Equatable {
  final String id;
  final String forumId;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final int repliesCount;
  final int viewsCount;
  final bool isSticky;
  final bool isLocked;
  final bool isSolved;
  final DateTime lastReplyAt;
  final String? lastReplyBy;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TopicEntity({
    required this.id,
    required this.forumId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.repliesCount,
    required this.viewsCount,
    required this.isSticky,
    required this.isLocked,
    required this.isSolved,
    required this.lastReplyAt,
    this.lastReplyBy,
    required this.tags,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        forumId,
        title,
        content,
        authorId,
        authorName,
        authorAvatar,
        repliesCount,
        viewsCount,
        isSticky,
        isLocked,
        isSolved,
        lastReplyAt,
        lastReplyBy,
        tags,
        metadata,
        createdAt,
        updatedAt,
      ];

  TopicEntity copyWith({
    String? id,
    String? forumId,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    int? repliesCount,
    int? viewsCount,
    bool? isSticky,
    bool? isLocked,
    bool? isSolved,
    DateTime? lastReplyAt,
    String? lastReplyBy,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopicEntity(
      id: id ?? this.id,
      forumId: forumId ?? this.forumId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      repliesCount: repliesCount ?? this.repliesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isSticky: isSticky ?? this.isSticky,
      isLocked: isLocked ?? this.isLocked,
      isSolved: isSolved ?? this.isSolved,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      lastReplyBy: lastReplyBy ?? this.lastReplyBy,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Post entity
class PostEntity extends Equatable {
  final String id;
  final String topicId;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? parentPostId;
  final int likesCount;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> attachments;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostEntity({
    required this.id,
    required this.topicId,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.parentPostId,
    required this.likesCount,
    required this.isEdited,
    this.editedAt,
    required this.attachments,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        topicId,
        content,
        authorId,
        authorName,
        authorAvatar,
        parentPostId,
        likesCount,
        isEdited,
        editedAt,
        attachments,
        metadata,
        createdAt,
        updatedAt,
      ];

  PostEntity copyWith({
    String? id,
    String? topicId,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? parentPostId,
    int? likesCount,
    bool? isEdited,
    DateTime? editedAt,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      parentPostId: parentPostId ?? this.parentPostId,
      likesCount: likesCount ?? this.likesCount,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Chat conversation entity
class ChatConversationEntity extends Equatable {
  final String id;
  final String title;
  final ChatType type;
  final List<String> participants;
  final String? lastMessageId;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final int unreadCount;
  final bool isArchived;
  final bool isMuted;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChatConversationEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.participants,
    this.lastMessageId,
    this.lastMessageText,
    this.lastMessageAt,
    this.lastMessageBy,
    required this.unreadCount,
    required this.isArchived,
    required this.isMuted,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        participants,
        lastMessageId,
        lastMessageText,
        lastMessageAt,
        lastMessageBy,
        unreadCount,
        isArchived,
        isMuted,
        metadata,
        createdAt,
        updatedAt,
      ];

  ChatConversationEntity copyWith({
    String? id,
    String? title,
    ChatType? type,
    List<String>? participants,
    String? lastMessageId,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    int? unreadCount,
    bool? isArchived,
    bool? isMuted,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Chat message entity
class ChatMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType messageType;
  final String? replyToId;
  final List<String> attachments;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isDeleted;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.messageType,
    this.replyToId,
    required this.attachments,
    required this.isEdited,
    this.editedAt,
    required this.isDeleted,
    required this.metadata,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        senderName,
        senderAvatar,
        content,
        messageType,
        replyToId,
        attachments,
        isEdited,
        editedAt,
        isDeleted,
        metadata,
        createdAt,
      ];

  ChatMessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    MessageType? messageType,
    String? replyToId,
    List<String>? attachments,
    bool? isEdited,
    DateTime? editedAt,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      replyToId: replyToId ?? this.replyToId,
      attachments: attachments ?? this.attachments,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Community user entity
class CommunityUserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final String? location;
  final List<String> languages;
  final UserRole role;
  final int reputation;
  final int postsCount;
  final int likesReceived;
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool isOnline;
  final Map<String, dynamic> preferences;

  const CommunityUserEntity({
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

  CommunityUserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? bio,
    String? location,
    List<String>? languages,
    UserRole? role,
    int? reputation,
    int? postsCount,
    int? likesReceived,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
    bool? isOnline,
    Map<String, dynamic>? preferences,
  }) {
    return CommunityUserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      languages: languages ?? this.languages,
      role: role ?? this.role,
      reputation: reputation ?? this.reputation,
      postsCount: postsCount ?? this.postsCount,
      likesReceived: likesReceived ?? this.likesReceived,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isOnline: isOnline ?? this.isOnline,
      preferences: preferences ?? this.preferences,
    );
  }
}

/// Enums
enum ChatType {
  direct,
  group,
  channel,
}

enum MessageType {
  text,
  image,
  audio,
  video,
  file,
  location,
  sticker,
}

enum UserRole {
  member,
  moderator,
  admin,
  superAdmin,
}

/// Forum categories
enum ForumCategory {
  general,
  questions,
  culture,
  pronunciation,
  grammar,
  resources,
  events,
  introductions,
}
