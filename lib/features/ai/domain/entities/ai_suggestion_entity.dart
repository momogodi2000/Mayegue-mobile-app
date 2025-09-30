import 'package:equatable/equatable.dart';

class AiSuggestionEntity extends Equatable {
  final String id;
  final String originalWord;
  final String sourceLanguage;
  final String targetLanguage;
  final String translation;
  final String? pronunciation;
  final String? phoneticTranscription;
  final String? partOfSpeech;
  final String? definition;
  final List<String> examples;
  final String? culturalNotes;
  final String? difficultyLevel;
  final double confidence;
  final ReviewStatus reviewStatus;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewComments;
  final Map<String, dynamic> metadata;

  const AiSuggestionEntity({
    required this.id,
    required this.originalWord,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.translation,
    this.pronunciation,
    this.phoneticTranscription,
    this.partOfSpeech,
    this.definition,
    this.examples = const [],
    this.culturalNotes,
    this.difficultyLevel,
    required this.confidence,
    required this.reviewStatus,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewComments,
    this.metadata = const {},
  });

  AiSuggestionEntity copyWith({
    String? id,
    String? originalWord,
    String? sourceLanguage,
    String? targetLanguage,
    String? translation,
    String? pronunciation,
    String? phoneticTranscription,
    String? partOfSpeech,
    String? definition,
    List<String>? examples,
    String? culturalNotes,
    String? difficultyLevel,
    double? confidence,
    ReviewStatus? reviewStatus,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewComments,
    Map<String, dynamic>? metadata,
  }) {
    return AiSuggestionEntity(
      id: id ?? this.id,
      originalWord: originalWord ?? this.originalWord,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
      phoneticTranscription: phoneticTranscription ?? this.phoneticTranscription,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      definition: definition ?? this.definition,
      examples: examples ?? this.examples,
      culturalNotes: culturalNotes ?? this.culturalNotes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      confidence: confidence ?? this.confidence,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewComments: reviewComments ?? this.reviewComments,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isPendingReview => reviewStatus == ReviewStatus.autoSuggested || reviewStatus == ReviewStatus.pendingReview;
  bool get isApproved => reviewStatus == ReviewStatus.approved || reviewStatus == ReviewStatus.verified;
  bool get isRejected => reviewStatus == ReviewStatus.rejected;
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.6 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.6;

  String get confidenceLabel {
    if (isHighConfidence) return 'High';
    if (isMediumConfidence) return 'Medium';
    return 'Low';
  }

  String get statusLabel {
    switch (reviewStatus) {
      case ReviewStatus.autoSuggested:
        return 'AI Suggested';
      case ReviewStatus.pendingReview:
        return 'Pending Review';
      case ReviewStatus.approved:
        return 'Approved';
      case ReviewStatus.rejected:
        return 'Rejected';
      case ReviewStatus.verified:
        return 'Verified';
    }
  }

  @override
  List<Object?> get props => [
        id,
        originalWord,
        sourceLanguage,
        targetLanguage,
        translation,
        pronunciation,
        phoneticTranscription,
        partOfSpeech,
        definition,
        examples,
        culturalNotes,
        difficultyLevel,
        confidence,
        reviewStatus,
        createdAt,
        reviewedAt,
        reviewedBy,
        reviewComments,
        metadata,
      ];
}

enum ReviewStatus {
  autoSuggested,
  pendingReview,
  approved,
  rejected,
  verified,
}