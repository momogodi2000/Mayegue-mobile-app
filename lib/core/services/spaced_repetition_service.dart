import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'spaced_repetition_service.g.dart';

/// Service implementing the SM-2 (SuperMemo 2) spaced repetition algorithm
/// Optimized for language learning with pronunciation and cultural context
class SpacedRepetitionService extends ChangeNotifier {
  static const String _boxName = 'spaced_repetition';
  static const String _statisticsBoxName = 'sr_statistics';

  Box<SpacedRepetitionCard>? _cardsBox;
  Box<Map>? _statisticsBox;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _cardsBox = await Hive.openBox<SpacedRepetitionCard>(_boxName);
      } else {
        _cardsBox = Hive.box<SpacedRepetitionCard>(_boxName);
      }

      if (!Hive.isBoxOpen(_statisticsBoxName)) {
        _statisticsBox = await Hive.openBox<Map>(_statisticsBoxName);
      } else {
        _statisticsBox = Hive.box<Map>(_statisticsBoxName);
      }
    } catch (e) {
      debugPrint('Error initializing SpacedRepetitionService: $e');
    }
  }

  /// Add a new word/phrase to the spaced repetition system
  Future<void> addCard({
    required String id,
    required String word,
    required String translation,
    required String languageCode,
    String? pronunciation,
    String? partOfSpeech,
    List<String>? exampleSentences,
    Map<String, dynamic>? metadata,
  }) async {
    await _ensureInitialized();

    final card = SpacedRepetitionCard(
      id: id,
      word: word,
      translation: translation,
      languageCode: languageCode,
      pronunciation: pronunciation,
      partOfSpeech: partOfSpeech,
      exampleSentences: exampleSentences ?? [],
      metadata: metadata ?? {},
      easinessFactor: 2.5,
      interval: 1,
      repetition: 0,
      nextReviewDate: DateTime.now(),
      createdAt: DateTime.now(),
      lastReviewedAt: null,
    );

    await _cardsBox!.put(id, card);
    notifyListeners();
  }

  /// Get cards due for review
  Future<List<SpacedRepetitionCard>> getCardsForReview({
    String? languageCode,
    int? maxCards,
  }) async {
    await _ensureInitialized();

    final now = DateTime.now();
    final allCards = _cardsBox!.values.toList();

    var dueCards = allCards.where((card) {
      final isDue = card.nextReviewDate.isBefore(now) || card.nextReviewDate.isAtSameMomentAs(now);
      final languageMatch = languageCode == null || card.languageCode == languageCode;
      return isDue && languageMatch;
    }).toList();

    // Sort by priority: overdue cards first, then by next review date
    dueCards.sort((a, b) {
      final aOverdue = now.difference(a.nextReviewDate).inHours;
      final bOverdue = now.difference(b.nextReviewDate).inHours;

      // If both are overdue, prioritize the one that's more overdue
      if (aOverdue > 0 && bOverdue > 0) {
        return bOverdue.compareTo(aOverdue);
      }

      // If only one is overdue, prioritize the overdue one
      if (aOverdue > 0) return -1;
      if (bOverdue > 0) return 1;

      // If neither is overdue, sort by next review date
      return a.nextReviewDate.compareTo(b.nextReviewDate);
    });

    if (maxCards != null && dueCards.length > maxCards) {
      dueCards = dueCards.take(maxCards).toList();
    }

    return dueCards;
  }

  /// Review a card and update its scheduling based on user performance
  Future<void> reviewCard({
    required String cardId,
    required ReviewQuality quality,
    int? reviewTimeSeconds,
    bool? pronunciationCorrect,
    Map<String, dynamic>? additionalData,
  }) async {
    await _ensureInitialized();

    final card = _cardsBox!.get(cardId);
    if (card == null) {
      throw Exception('Card not found: $cardId');
    }

    final now = DateTime.now();
    final updatedCard = _calculateNextReview(card, quality, now);

    // Add review session data
    final reviewSession = ReviewSession(
      date: now,
      quality: quality,
      reviewTimeSeconds: reviewTimeSeconds,
      pronunciationCorrect: pronunciationCorrect,
      additionalData: additionalData,
    );

    updatedCard.reviewSessions.add(reviewSession);

    await _cardsBox!.put(cardId, updatedCard);
    await _updateStatistics(quality, reviewTimeSeconds);
    notifyListeners();
  }

  /// Calculate next review date using SM-2 algorithm with language learning optimizations
  SpacedRepetitionCard _calculateNextReview(
    SpacedRepetitionCard card,
    ReviewQuality quality,
    DateTime reviewDate,
  ) {
    final qualityValue = quality.value;

    // Update easiness factor
    double newEasinessFactor = card.easinessFactor +
        (0.1 - (5 - qualityValue) * (0.08 + (5 - qualityValue) * 0.02));

    // Ensure easiness factor doesn't go below 1.3
    newEasinessFactor = max(1.3, newEasinessFactor);

    int newInterval;
    int newRepetition = card.repetition;

    if (qualityValue < 3) {
      // If quality is poor, reset the card
      newInterval = 1;
      newRepetition = 0;
    } else {
      newRepetition += 1;

      if (newRepetition == 1) {
        newInterval = 1;
      } else if (newRepetition == 2) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * newEasinessFactor).round();
      }
    }

    // Language learning optimizations
    newInterval = _optimizeIntervalForLanguageLearning(
      newInterval,
      card,
      quality,
    );

    final nextReviewDate = reviewDate.add(Duration(days: newInterval));

    return card.copyWith(
      easinessFactor: newEasinessFactor,
      interval: newInterval,
      repetition: newRepetition,
      nextReviewDate: nextReviewDate,
      lastReviewedAt: reviewDate,
    );
  }

  /// Optimize interval specifically for language learning
  int _optimizeIntervalForLanguageLearning(
    int baseInterval,
    SpacedRepetitionCard card,
    ReviewQuality quality,
  ) {
    var optimizedInterval = baseInterval;

    // 1. Pronunciation-focused optimization
    final recentPronunciationIssues = card.reviewSessions
        .where((session) => session.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .where((session) => session.pronunciationCorrect == false)
        .length;

    if (recentPronunciationIssues > 0) {
      optimizedInterval = (optimizedInterval * 0.7).round();
    }

    // 2. Part of speech difficulty adjustment
    final difficultPOS = ['verb', 'adjective', 'adverb'];
    if (card.partOfSpeech != null && difficultPOS.contains(card.partOfSpeech!.toLowerCase())) {
      optimizedInterval = (optimizedInterval * 0.8).round();
    }

    // 3. Language-specific adjustments
    final tonalLanguages = ['ewondo', 'bamum', 'bassa'];
    if (tonalLanguages.contains(card.languageCode.toLowerCase())) {
      optimizedInterval = (optimizedInterval * 0.9).round();
    }

    // 4. Recent performance trend
    final recentSessions = card.reviewSessions
        .where((session) => session.date.isAfter(DateTime.now().subtract(const Duration(days: 14))))
        .toList();

    if (recentSessions.length >= 3) {
      final averageQuality = recentSessions
          .map((session) => session.quality.value)
          .reduce((a, b) => a + b) / recentSessions.length;

      if (averageQuality < 3.5) {
        optimizedInterval = (optimizedInterval * 0.6).round();
      } else if (averageQuality > 4.5) {
        optimizedInterval = (optimizedInterval * 1.2).round();
      }
    }

    // 5. Ensure minimum and maximum intervals
    optimizedInterval = max(1, optimizedInterval);
    optimizedInterval = min(365, optimizedInterval); // Max 1 year

    return optimizedInterval;
  }

  /// Get cards that are new (never reviewed)
  Future<List<SpacedRepetitionCard>> getNewCards({
    String? languageCode,
    int? maxCards,
  }) async {
    await _ensureInitialized();

    var newCards = _cardsBox!.values
        .where((card) => card.repetition == 0 && card.lastReviewedAt == null)
        .toList();

    if (languageCode != null) {
      newCards = newCards.where((card) => card.languageCode == languageCode).toList();
    }

    // Sort by creation date (oldest first)
    newCards.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (maxCards != null && newCards.length > maxCards) {
      newCards = newCards.take(maxCards).toList();
    }

    return newCards;
  }

  /// Get statistics for the spaced repetition system
  Future<SpacedRepetitionStatistics> getStatistics({String? languageCode}) async {
    await _ensureInitialized();

    final allCards = _cardsBox!.values.toList();
    final filteredCards = languageCode != null
        ? allCards.where((card) => card.languageCode == languageCode).toList()
        : allCards;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalCards = filteredCards.length;
    final newCards = filteredCards.where((card) => card.repetition == 0).length;
    final learningCards = filteredCards.where((card) => card.repetition > 0 && card.repetition < 3).length;
    final matureCards = filteredCards.where((card) => card.repetition >= 3).length;

    final dueCards = filteredCards.where((card) =>
        card.nextReviewDate.isBefore(now) || card.nextReviewDate.isAtSameMomentAs(now)
    ).length;

    final overdueCards = filteredCards.where((card) =>
        card.nextReviewDate.isBefore(today)
    ).length;

    final reviewedToday = filteredCards.where((card) =>
        card.lastReviewedAt != null &&
        card.lastReviewedAt!.isAfter(today)
    ).length;

    // Calculate retention rate (cards with quality >= 3 in last 30 days)
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    var totalReviews = 0;
    var successfulReviews = 0;

    for (final card in filteredCards) {
      final recentSessions = card.reviewSessions
          .where((session) => session.date.isAfter(thirtyDaysAgo))
          .toList();

      totalReviews += recentSessions.length;
      successfulReviews += recentSessions
          .where((session) => session.quality.value >= 3)
          .length;
    }

    final retentionRate = totalReviews > 0 ? successfulReviews / totalReviews : 0.0;

    return SpacedRepetitionStatistics(
      totalCards: totalCards,
      newCards: newCards,
      learningCards: learningCards,
      matureCards: matureCards,
      dueCards: dueCards,
      overdueCards: overdueCards,
      reviewedToday: reviewedToday,
      retentionRate: retentionRate,
      languageCode: languageCode,
    );
  }

  /// Get study session recommendation
  Future<StudySessionRecommendation> getStudyRecommendation({
    String? languageCode,
    int? targetMinutes,
  }) async {
    await _ensureInitialized();

    final dueCards = await getCardsForReview(languageCode: languageCode);
    final newCards = await getNewCards(languageCode: languageCode);

    const estimatedTimePerCard = 30; // seconds
    final availableTimeSeconds = (targetMinutes ?? 20) * 60;
    final maxCards = availableTimeSeconds ~/ estimatedTimePerCard;

    // Prioritize review cards over new cards
    final reviewCards = min(dueCards.length, (maxCards * 0.7).round());
    final newCardsToStudy = min(newCards.length, maxCards - reviewCards);

    return StudySessionRecommendation(
      reviewCards: reviewCards,
      newCards: newCardsToStudy,
      estimatedMinutes: ((reviewCards + newCardsToStudy) * estimatedTimePerCard / 60).round(),
      priorityLevel: _calculatePriorityLevel(dueCards.length, newCards.length),
    );
  }

  StudyPriority _calculatePriorityLevel(int dueCards, int newCards) {
    final totalCards = dueCards + newCards;

    if (totalCards == 0) return StudyPriority.none;
    if (dueCards > 20) return StudyPriority.critical;
    if (dueCards > 10 || totalCards > 30) return StudyPriority.high;
    if (totalCards > 15) return StudyPriority.medium;
    return StudyPriority.low;
  }

  /// Update system statistics
  Future<void> _updateStatistics(ReviewQuality quality, int? reviewTimeSeconds) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayStats = _statisticsBox!.get(today, defaultValue: <String, dynamic>{}) ?? <String, dynamic>{};

    final currentStats = Map<String, dynamic>.from(todayStats);
    currentStats['reviewCount'] = (currentStats['reviewCount'] ?? 0) + 1;
    currentStats['totalReviewTime'] = (currentStats['totalReviewTime'] ?? 0) + (reviewTimeSeconds ?? 0);

    final qualityKey = 'quality_${quality.value}';
    currentStats[qualityKey] = (currentStats[qualityKey] ?? 0) + 1;

    await _statisticsBox!.put(today, currentStats);
  }

  /// Remove a card from the system
  Future<void> removeCard(String cardId) async {
    await _ensureInitialized();
    await _cardsBox!.delete(cardId);
    notifyListeners();
  }

  /// Get a specific card by ID
  Future<SpacedRepetitionCard?> getCard(String cardId) async {
    await _ensureInitialized();
    return _cardsBox!.get(cardId);
  }

  /// Update card metadata without affecting review schedule
  Future<void> updateCardMetadata(String cardId, Map<String, dynamic> metadata) async {
    await _ensureInitialized();

    final card = _cardsBox!.get(cardId);
    if (card != null) {
      final updatedCard = card.copyWith(metadata: {...card.metadata, ...metadata});
      await _cardsBox!.put(cardId, updatedCard);
      notifyListeners();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_cardsBox == null || _statisticsBox == null) {
      await initialize();
    }
  }

  /// Export data for backup
  Future<Map<String, dynamic>> exportData() async {
    await _ensureInitialized();

    final cards = _cardsBox!.values.map((card) => card.toJson()).toList();
    final statistics = Map<String, dynamic>.from(_statisticsBox!.toMap());

    return {
      'cards': cards,
      'statistics': statistics,
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    await _ensureInitialized();

    if (data['cards'] != null) {
      final cardsData = List<Map<String, dynamic>>.from(data['cards']);
      for (final cardData in cardsData) {
        final card = SpacedRepetitionCard.fromJson(cardData);
        await _cardsBox!.put(card.id, card);
      }
    }

    if (data['statistics'] != null) {
      final statisticsData = Map<String, dynamic>.from(data['statistics']);
      for (final entry in statisticsData.entries) {
        await _statisticsBox!.put(entry.key, entry.value);
      }
    }

    notifyListeners();
  }
}

/// Represents a card in the spaced repetition system
@HiveType(typeId: 0)
class SpacedRepetitionCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String translation;

  @HiveField(3)
  final String languageCode;

  @HiveField(4)
  final String? pronunciation;

  @HiveField(5)
  final String? partOfSpeech;

  @HiveField(6)
  final List<String> exampleSentences;

  @HiveField(7)
  final Map<String, dynamic> metadata;

  @HiveField(8)
  final double easinessFactor;

  @HiveField(9)
  final int interval;

  @HiveField(10)
  final int repetition;

  @HiveField(11)
  final DateTime nextReviewDate;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime? lastReviewedAt;

  @HiveField(14)
  final List<ReviewSession> reviewSessions;

  SpacedRepetitionCard({
    required this.id,
    required this.word,
    required this.translation,
    required this.languageCode,
    this.pronunciation,
    this.partOfSpeech,
    required this.exampleSentences,
    required this.metadata,
    required this.easinessFactor,
    required this.interval,
    required this.repetition,
    required this.nextReviewDate,
    required this.createdAt,
    this.lastReviewedAt,
    List<ReviewSession>? reviewSessions,
  }) : reviewSessions = reviewSessions ?? [];

  SpacedRepetitionCard copyWith({
    String? id,
    String? word,
    String? translation,
    String? languageCode,
    String? pronunciation,
    String? partOfSpeech,
    List<String>? exampleSentences,
    Map<String, dynamic>? metadata,
    double? easinessFactor,
    int? interval,
    int? repetition,
    DateTime? nextReviewDate,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    List<ReviewSession>? reviewSessions,
  }) {
    return SpacedRepetitionCard(
      id: id ?? this.id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      languageCode: languageCode ?? this.languageCode,
      pronunciation: pronunciation ?? this.pronunciation,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      exampleSentences: exampleSentences ?? this.exampleSentences,
      metadata: metadata ?? this.metadata,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      reviewSessions: reviewSessions ?? this.reviewSessions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'languageCode': languageCode,
      'pronunciation': pronunciation,
      'partOfSpeech': partOfSpeech,
      'exampleSentences': exampleSentences,
      'metadata': metadata,
      'easinessFactor': easinessFactor,
      'interval': interval,
      'repetition': repetition,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewSessions': reviewSessions.map((session) => session.toJson()).toList(),
    };
  }

  factory SpacedRepetitionCard.fromJson(Map<String, dynamic> json) {
    return SpacedRepetitionCard(
      id: json['id'],
      word: json['word'],
      translation: json['translation'],
      languageCode: json['languageCode'],
      pronunciation: json['pronunciation'],
      partOfSpeech: json['partOfSpeech'],
      exampleSentences: List<String>.from(json['exampleSentences'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      easinessFactor: json['easinessFactor']?.toDouble() ?? 2.5,
      interval: json['interval'] ?? 1,
      repetition: json['repetition'] ?? 0,
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      createdAt: DateTime.parse(json['createdAt']),
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'])
          : null,
      reviewSessions: (json['reviewSessions'] as List<dynamic>?)
          ?.map((session) => ReviewSession.fromJson(session))
          .toList() ?? [],
    );
  }
}

/// Represents a review session
@HiveType(typeId: 1)
class ReviewSession extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final ReviewQuality quality;

  @HiveField(2)
  final int? reviewTimeSeconds;

  @HiveField(3)
  final bool? pronunciationCorrect;

  @HiveField(4)
  final Map<String, dynamic>? additionalData;

  ReviewSession({
    required this.date,
    required this.quality,
    this.reviewTimeSeconds,
    this.pronunciationCorrect,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'quality': quality.value,
      'reviewTimeSeconds': reviewTimeSeconds,
      'pronunciationCorrect': pronunciationCorrect,
      'additionalData': additionalData,
    };
  }

  factory ReviewSession.fromJson(Map<String, dynamic> json) {
    return ReviewSession(
      date: DateTime.parse(json['date']),
      quality: ReviewQuality.fromValue(json['quality']),
      reviewTimeSeconds: json['reviewTimeSeconds'],
      pronunciationCorrect: json['pronunciationCorrect'],
      additionalData: json['additionalData'] != null
          ? Map<String, dynamic>.from(json['additionalData'])
          : null,
    );
  }
}

/// Review quality levels based on SM-2 algorithm
enum ReviewQuality {
  blackout(0),     // Complete blackout
  incorrect(1),    // Incorrect response; the correct one remembered
  difficult(2),    // Correct response recalled with serious difficulty
  hesitant(3),     // Correct response after a hesitation
  easy(4),         // Correct response with some effort
  perfect(5);      // Perfect response

  const ReviewQuality(this.value);
  final int value;

  static ReviewQuality fromValue(int value) {
    return ReviewQuality.values.firstWhere((quality) => quality.value == value);
  }
}

/// Study session recommendation
class StudySessionRecommendation {
  final int reviewCards;
  final int newCards;
  final int estimatedMinutes;
  final StudyPriority priorityLevel;

  const StudySessionRecommendation({
    required this.reviewCards,
    required this.newCards,
    required this.estimatedMinutes,
    required this.priorityLevel,
  });
}

/// Study priority levels
enum StudyPriority {
  none,
  low,
  medium,
  high,
  critical;

  String get displayName {
    switch (this) {
      case StudyPriority.none:
        return 'Aucune urgence';
      case StudyPriority.low:
        return 'Faible priorité';
      case StudyPriority.medium:
        return 'Priorité moyenne';
      case StudyPriority.high:
        return 'Priorité élevée';
      case StudyPriority.critical:
        return 'Priorité critique';
    }
  }

  Color get color {
    switch (this) {
      case StudyPriority.none:
        return Colors.grey;
      case StudyPriority.low:
        return Colors.green;
      case StudyPriority.medium:
        return Colors.orange;
      case StudyPriority.high:
        return Colors.red;
      case StudyPriority.critical:
        return Colors.red.shade800;
    }
  }
}

/// Statistics for the spaced repetition system
class SpacedRepetitionStatistics {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int matureCards;
  final int dueCards;
  final int overdueCards;
  final int reviewedToday;
  final double retentionRate;
  final String? languageCode;

  const SpacedRepetitionStatistics({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.matureCards,
    required this.dueCards,
    required this.overdueCards,
    required this.reviewedToday,
    required this.retentionRate,
    this.languageCode,
  });
}