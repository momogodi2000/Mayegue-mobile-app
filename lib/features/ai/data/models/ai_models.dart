import '../../domain/entities/ai_entities.dart';

/// Conversation model
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.messages,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? 'New Conversation',
      messages: (json['messages'] as List<dynamic>?)
          ?.map((msg) => MessageModel.fromMap(msg))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'messages': messages.map((msg) => (msg as MessageModel).toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Message model
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.sender,
    required super.content,
    required super.timestamp,
    super.metadata,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      sender: map['sender'] ?? 'user',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  Map<String, dynamic> toJson() => toMap();
}

/// AI Response model
class AiResponseModel {
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const AiResponseModel({
    required this.content,
    this.metadata,
    required this.timestamp,
  });

  factory AiResponseModel.fromMap(Map<String, dynamic> map) {
    return AiResponseModel(
      content: map['content'] ?? '',
      metadata: map['metadata'],
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// AI Translation model for AI-powered translations
class AiTranslationModel extends TranslationEntity {
  const AiTranslationModel({
    required super.id,
    required super.userId,
    required super.sourceText,
    required super.sourceLanguage,
    required super.targetText,
    required super.targetLanguage,
    required super.confidence,
    required super.createdAt,
    super.metadata,
  });

  factory AiTranslationModel.fromJson(Map<String, dynamic> json) {
    return AiTranslationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      sourceText: json['sourceText'] ?? '',
      sourceLanguage: json['sourceLanguage'] ?? '',
      targetText: json['targetText'] ?? '',
      targetLanguage: json['targetLanguage'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sourceText': sourceText,
      'sourceLanguage': sourceLanguage,
      'targetText': targetText,
      'targetLanguage': targetLanguage,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Pronunciation assessment model
class PronunciationAssessmentModel extends PronunciationAssessmentEntity {
  const PronunciationAssessmentModel({
    required super.id,
    required super.userId,
    required super.word,
    required super.language,
    required super.audioUrl,
    required super.score,
    required super.feedback,
    required super.issues,
    required super.assessedAt,
    super.metadata,
  });

  factory PronunciationAssessmentModel.fromJson(Map<String, dynamic> json) {
    return PronunciationAssessmentModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      word: json['word'] ?? '',
      language: json['language'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      feedback: json['feedback'] ?? '',
      issues: (json['issues'] as List<dynamic>?)
          ?.map((issue) => PronunciationIssue.fromJson(issue))
          .toList() ?? [],
      assessedAt: DateTime.parse(json['assessedAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'word': word,
      'language': language,
      'audioUrl': audioUrl,
      'score': score,
      'feedback': feedback,
      'issues': issues.map((issue) => issue.toJson()).toList(),
      'assessedAt': assessedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Content generation model
class ContentGenerationModel extends ContentGenerationEntity {
  const ContentGenerationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.topic,
    required super.language,
    required super.difficulty,
    required super.generatedContent,
    required super.tags,
    required super.generatedAt,
    super.metadata,
  });

  factory ContentGenerationModel.fromJson(Map<String, dynamic> json) {
    return ContentGenerationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      topic: json['topic'] ?? '',
      language: json['language'] ?? '',
      difficulty: json['difficulty'] ?? '',
      generatedContent: json['generatedContent'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'topic': topic,
      'language': language,
      'difficulty': difficulty,
      'generatedContent': generatedContent,
      'tags': tags,
      'generatedAt': generatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// AI Learning Recommendation model
class AiLearningRecommendationModel extends AiLearningRecommendationEntity {
  const AiLearningRecommendationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.description,
    required super.reason,
    required super.priority,
    required super.isCompleted,
    required super.createdAt,
    super.metadata,
  });

  factory AiLearningRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiLearningRecommendationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      reason: json['reason'] ?? '',
      priority: json['priority'] ?? 1,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'reason': reason,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
