import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprehensive analytics service for tracking user behavior and learning progress
class AnalyticsService extends ChangeNotifier {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  SharedPreferences? _prefs;

  bool _isInitialized = false;
  bool _analyticsEnabled = true;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _analyticsEnabled = _prefs?.getBool('analytics_enabled') ?? true;

      await _analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);
      _isInitialized = true;

      if (_analyticsEnabled) {
        await _trackAppStart();
      }
    } catch (e) {
      debugPrint('Error initializing AnalyticsService: $e');
    }
  }

  /// Enable or disable analytics collection
  Future<void> setAnalyticsEnabled(bool enabled) async {
    _analyticsEnabled = enabled;
    await _prefs?.setBool('analytics_enabled', enabled);
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    notifyListeners();
  }

  bool get analyticsEnabled => _analyticsEnabled;

  /// Track app lifecycle events
  Future<void> _trackAppStart() async {
    if (!_analyticsEnabled) return;

    await _analytics.logAppOpen();
    await _setUserProperties();
  }

  Future<void> trackAppBackground() async {
    if (!_analyticsEnabled) return;
    await _analytics.logEvent(name: 'app_background');
  }

  Future<void> trackAppForeground() async {
    if (!_analyticsEnabled) return;
    await _analytics.logEvent(name: 'app_foreground');
  }

  /// Set user properties for analytics
  Future<void> _setUserProperties() async {
    if (!_analyticsEnabled) return;

    try {
      final userRole = _prefs?.getString('user_role') ?? 'unknown';
      final preferredLanguage =
          _prefs?.getString('preferred_language') ?? 'unknown';
      final appVersion = _prefs?.getString('app_version') ?? 'unknown';

      await _analytics.setUserProperty(name: 'user_role', value: userRole);
      await _analytics.setUserProperty(
          name: 'preferred_language', value: preferredLanguage);
      await _analytics.setUserProperty(name: 'app_version', value: appVersion);
    } catch (e) {
      debugPrint('Error setting user properties: $e');
    }
  }

  /// Authentication Events
  Future<void> trackUserRegistration({
    required String method,
    required String userRole,
    List<String>? languages,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logSignUp(signUpMethod: method);
    await _analytics.logEvent(
      name: 'user_registration',
      parameters: {
        'method': method,
        'user_role': userRole,
        'languages': languages?.join(',') ?? 'none',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackUserLogin({
    required String method,
    String? userId,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logLogin(loginMethod: method);
    if (userId != null) {
      await _analytics.setUserId(id: userId);
    }
  }

  Future<void> trackUserLogout() async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(name: 'user_logout');
    await _analytics.setUserId(id: null);
  }

  /// Learning Events
  Future<void> trackLessonStarted({
    required String lessonId,
    required String lessonTitle,
    required String languageCode,
    required String difficultyLevel,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'lesson_started',
      parameters: {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
        'language_code': languageCode,
        'difficulty_level': difficultyLevel,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackLessonCompleted({
    required String lessonId,
    required String lessonTitle,
    required String languageCode,
    required Duration timeSpent,
    required double completionPercentage,
    double? score,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'lesson_completed',
      parameters: {
        'lesson_id': lessonId,
        'lesson_title': lessonTitle,
        'language_code': languageCode,
        'time_spent_seconds': timeSpent.inSeconds,
        'completion_percentage': completionPercentage,
        'score': score ?? 0.0,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track level up if applicable
    if (completionPercentage >= 100) {
      await _analytics.logLevelUp(level: 1, character: languageCode);
    }
  }

  Future<void> trackLessonAbandoned({
    required String lessonId,
    required Duration timeSpent,
    required double progressPercentage,
    String? reason,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'lesson_abandoned',
      parameters: {
        'lesson_id': lessonId,
        'time_spent_seconds': timeSpent.inSeconds,
        'progress_percentage': progressPercentage,
        'reason': reason ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Dictionary Events
  Future<void> trackDictionarySearch({
    required String searchQuery,
    required String languageCode,
    required int resultsCount,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logSearch(searchTerm: searchQuery);

    await _analytics.logEvent(
      name: 'dictionary_search',
      parameters: {
        'search_query': searchQuery,
        'language_code': languageCode,
        'results_count': resultsCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackDictionaryEntryViewed({
    required String entryId,
    required String word,
    required String languageCode,
    required Duration timeSpent,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'view_item',
      parameters: {
        'item_id': entryId,
        'item_name': word,
        'item_category': 'dictionary_entry',
        'item_list_name': languageCode,
      },
    );

    await _analytics.logEvent(
      name: 'dictionary_entry_viewed',
      parameters: {
        'entry_id': entryId,
        'word': word,
        'language_code': languageCode,
        'time_spent_seconds': timeSpent.inSeconds,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackPronunciationPractice({
    required String entryId,
    required String word,
    required String languageCode,
    required Duration recordingDuration,
    required double pronunciationScore,
    required int attemptNumber,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'pronunciation_practice',
      parameters: {
        'entry_id': entryId,
        'word': word,
        'language_code': languageCode,
        'recording_duration_seconds': recordingDuration.inSeconds,
        'pronunciation_score': pronunciationScore,
        'attempt_number': attemptNumber,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track achievement if score is high
    if (pronunciationScore >= 0.9) {
      await trackAchievementUnlocked(
        achievementId: 'perfect_pronunciation',
        achievementName: 'Perfect Pronunciation',
      );
    }
  }

  /// Spaced Repetition Events
  Future<void> trackSpacedRepetitionSession({
    required int cardsReviewed,
    required int newCards,
    required Duration sessionDuration,
    required String languageCode,
    required Map<String, int> qualityDistribution,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'spaced_repetition_session',
      parameters: {
        'cards_reviewed': cardsReviewed,
        'new_cards': newCards,
        'session_duration_seconds': sessionDuration.inSeconds,
        'language_code': languageCode,
        'quality_distribution': jsonEncode(qualityDistribution),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackCardReview({
    required String cardId,
    required String word,
    required String languageCode,
    required int quality,
    required Duration reviewTime,
    required int newInterval,
    required bool pronunciationCorrect,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'card_review',
      parameters: {
        'card_id': cardId,
        'word': word,
        'language_code': languageCode,
        'quality': quality,
        'review_time_seconds': reviewTime.inSeconds,
        'new_interval_days': newInterval,
        'pronunciation_correct': pronunciationCorrect,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Teacher Content Creation Events
  Future<void> trackDictionaryEntryContribution({
    required String entryId,
    required String word,
    required String languageCode,
    required String contributorRole,
    required bool isAIAssisted,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'dictionary_entry_contribution',
      parameters: {
        'entry_id': entryId,
        'word': word,
        'language_code': languageCode,
        'contributor_role': contributorRole,
        'is_ai_assisted': isAIAssisted,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackAIReviewAction({
    required String entryId,
    required String action, // 'approve', 'reject', 'edit'
    required double aiConfidenceScore,
    required String teacherId,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'ai_review_action',
      parameters: {
        'entry_id': entryId,
        'action': action,
        'ai_confidence_score': aiConfidenceScore,
        'teacher_id': teacherId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Game Events
  Future<void> trackGameStarted({
    required String gameType,
    required String languageCode,
    required String difficultyLevel,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'game_type': gameType,
        'language_code': languageCode,
        'difficulty_level': difficultyLevel,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackGameCompleted({
    required String gameType,
    required String languageCode,
    required Duration gameDuration,
    required int score,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logPostScore(
      score: score,
      level: 1,
      character: gameType,
    );

    await _analytics.logEvent(
      name: 'game_completed',
      parameters: {
        'game_type': gameType,
        'language_code': languageCode,
        'game_duration_seconds': gameDuration.inSeconds,
        'score': score,
        'correct_answers': correctAnswers,
        'total_questions': totalQuestions,
        'accuracy_percentage': (correctAnswers / totalQuestions * 100).round(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Achievement Events
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
    String? category,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'category': category ?? 'general',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackStreakMilestone({
    required int streakDays,
    required String activity, // 'daily_study', 'pronunciation_practice', etc.
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {
        'streak_days': streakDays,
        'activity': activity,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Track special achievements for long streaks
    if (streakDays % 7 == 0) {
      await trackAchievementUnlocked(
        achievementId: '${activity}_streak_$streakDays',
        achievementName: '$streakDays Day $activity Streak',
        category: 'streak',
      );
    }
  }

  /// Community Events
  Future<void> trackCommunityInteraction({
    required String interactionType, // 'post', 'comment', 'like', 'share'
    required String contentType, // 'discussion', 'question', 'lesson_share'
    String? contentId,
    String? languageCode,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'community_interaction',
      parameters: {
        'interaction_type': interactionType,
        'content_type': contentType,
        'content_id': contentId ?? 'unknown',
        'language_code': languageCode ?? 'unknown',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Error and Performance Events
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screenName,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'screen_name': screenName ?? 'unknown',
        'additional_data': jsonEncode(additionalData ?? {}),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackPerformanceMetric({
    required String metricName,
    required double value,
    String? screenName,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value': value,
        'screen_name': screenName ?? 'unknown',
        'additional_data': jsonEncode(additionalData ?? {}),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Navigation Events
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );

    if (parameters != null) {
      await _analytics.logEvent(
        name: 'screen_view_detailed',
        parameters: {
          'screen_name': screenName,
          'screen_class': screenClass ?? 'unknown',
          ...parameters,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  /// Custom Events for Specific Features
  Future<void> trackFeatureUsage({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> trackSettingsChange({
    required String settingName,
    required String oldValue,
    required String newValue,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'settings_change',
      parameters: {
        'setting_name': settingName,
        'old_value': oldValue,
        'new_value': newValue,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Learning Progress Analytics
  Future<void> trackLearningProgress({
    required String languageCode,
    required int wordsLearned,
    required int lessonsCompleted,
    required Duration totalStudyTime,
    required double averageSessionDuration,
    required Map<String, dynamic> skillLevels,
  }) async {
    if (!_analyticsEnabled) return;

    await _analytics.logEvent(
      name: 'learning_progress',
      parameters: {
        'language_code': languageCode,
        'words_learned': wordsLearned,
        'lessons_completed': lessonsCompleted,
        'total_study_time_seconds': totalStudyTime.inSeconds,
        'average_session_duration_seconds': averageSessionDuration,
        'skill_levels': jsonEncode(skillLevels),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Batch Events for Offline Analytics
  final List<Map<String, dynamic>> _queuedEvents = [];

  Future<void> queueEvent(
      String eventName, Map<String, dynamic> parameters) async {
    _queuedEvents.add({
      'event_name': eventName,
      'parameters': parameters,
      'queued_at': DateTime.now().toIso8601String(),
    });

    // Save to local storage
    await _saveQueuedEvents();
  }

  Future<void> flushQueuedEvents() async {
    if (!_analyticsEnabled || _queuedEvents.isEmpty) return;

    try {
      for (final event in _queuedEvents) {
        await _analytics.logEvent(
          name: event['event_name'],
          parameters: Map<String, dynamic>.from(event['parameters']),
        );
      }

      _queuedEvents.clear();
      await _clearQueuedEvents();
    } catch (e) {
      debugPrint('Error flushing queued events: $e');
    }
  }

  Future<void> _saveQueuedEvents() async {
    final eventsJson = jsonEncode(_queuedEvents);
    await _prefs?.setString('queued_analytics_events', eventsJson);
  }

  Future<void> _clearQueuedEvents() async {
    await _prefs?.remove('queued_analytics_events');
  }

  /// Debugging and Development
  Future<void> logDebugEvent(
      String eventName, Map<String, dynamic> parameters) async {
    if (kDebugMode) {
      debugPrint('Analytics Event: $eventName');
      debugPrint('Parameters: $parameters');
    }

    if (_analyticsEnabled) {
      await _analytics.logEvent(name: eventName, parameters: parameters);
    }
  }

  /// Get analytics summary for user insights
  Future<Map<String, dynamic>> getAnalyticsSummary() async {
    // This would typically fetch from a backend analytics service
    // For now, return local summary data
    return {
      'total_study_time': _prefs?.getInt('total_study_time_seconds') ?? 0,
      'words_learned': _prefs?.getInt('words_learned_count') ?? 0,
      'lessons_completed': _prefs?.getInt('lessons_completed_count') ?? 0,
      'current_streak': _prefs?.getInt('current_study_streak') ?? 0,
      'achievements_unlocked':
          _prefs?.getStringList('achievements_unlocked') ?? [],
    };
  }
}
