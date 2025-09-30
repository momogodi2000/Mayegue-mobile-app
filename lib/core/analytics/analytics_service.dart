import 'package:flutter/foundation.dart';
import '../monitoring/app_monitoring.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _initialized = false;
  final AppMonitoring _monitoring = AppMonitoring();

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _monitoring.initialize();
      _initialized = true;
      debugPrint('📊 Analytics service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize analytics: $e');
    }
  }

  // User Journey Analytics
  Future<void> trackUserRegistration({
    required String method, // email, google, facebook
    String? referrer,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('user_registration', parameters: {
      'method': method,
      if (referrer != null) 'referrer': referrer,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> trackUserLogin({
    required String method,
    bool isFirstTime = false,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('user_login', parameters: {
      'method': method,
      'is_first_time': isFirstTime,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> trackOnboardingStep({
    required int stepNumber,
    required String stepName,
    required String action, // start, complete, skip
    Map<String, dynamic>? stepData,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('onboarding_step', parameters: {
      'step_number': stepNumber,
      'step_name': stepName,
      'action': action,
      ...?stepData,
    });
  }

  Future<void> trackOnboardingCompletion({
    required String selectedLanguage,
    String? learningGoal,
    String? experienceLevel,
    Duration? timeSpent,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('onboarding_completed', parameters: {
      'selected_language': selectedLanguage,
      if (learningGoal != null) 'learning_goal': learningGoal,
      if (experienceLevel != null) 'experience_level': experienceLevel,
      if (timeSpent != null) 'time_spent_seconds': timeSpent.inSeconds,
    });
  }

  // Learning Analytics
  Future<void> trackLessonStart({
    required String lessonId,
    required String language,
    required String lessonType,
    int? difficultyLevel,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('lesson_start', parameters: {
      'lesson_id': lessonId,
      'language': language,
      'lesson_type': lessonType,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
    });
  }

  Future<void> trackLessonComplete({
    required String lessonId,
    required String language,
    required Duration timeSpent,
    required double accuracy,
    int? score,
    int? mistakes,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('lesson_completed', parameters: {
      'lesson_id': lessonId,
      'language': language,
      'time_spent_seconds': timeSpent.inSeconds,
      'accuracy': accuracy,
      if (score != null) 'score': score,
      if (mistakes != null) 'mistakes': mistakes,
    });

    // Track learning progress
    await _monitoring.logLearningProgress(
      language: language,
      action: 'lesson_completed',
      lessonId: lessonId,
      score: score,
      duration: timeSpent,
    );
  }

  Future<void> trackWordLearned({
    required String wordId,
    required String language,
    required String word,
    String? partOfSpeech,
    int? difficultyLevel,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('word_learned', parameters: {
      'word_id': wordId,
      'language': language,
      'word': word,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
    });

    // Track learning progress
    await _monitoring.logLearningProgress(
      language: language,
      action: 'word_learned',
      wordId: wordId,
    );
  }

  Future<void> trackQuizAttempt({
    required String quizId,
    required String language,
    required int totalQuestions,
    required int correctAnswers,
    required Duration timeSpent,
  }) async {
    if (!_initialized) return;

    final accuracy = correctAnswers / totalQuestions;
    final passed = accuracy >= 0.7; // 70% passing grade

    await _monitoring.logEvent('quiz_attempt', parameters: {
      'quiz_id': quizId,
      'language': language,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'accuracy': accuracy,
      'passed': passed,
      'time_spent_seconds': timeSpent.inSeconds,
    });

    if (passed) {
      await _monitoring.logLearningProgress(
        language: language,
        action: 'quiz_passed',
        score: (accuracy * 100).round(),
        duration: timeSpent,
      );
    }
  }

  // Dictionary Analytics
  Future<void> trackDictionarySearch({
    required String searchTerm,
    required String language,
    int? resultsCount,
    bool? foundExactMatch,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('dictionary_search', parameters: {
      'search_term_length': searchTerm.length, // Don't log actual term for privacy
      'language': language,
      if (resultsCount != null) 'results_count': resultsCount,
      if (foundExactMatch != null) 'found_exact_match': foundExactMatch,
    });
  }

  Future<void> trackWordView({
    required String wordId,
    required String language,
    String? source, // search, lesson, random
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('word_view', parameters: {
      'word_id': wordId,
      'language': language,
      if (source != null) 'source': source,
    });
  }

  Future<void> trackAudioPlayback({
    required String wordId,
    required String language,
    required String audioType, // pronunciation, example
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('audio_playback', parameters: {
      'word_id': wordId,
      'language': language,
      'audio_type': audioType,
    });
  }

  // Feature Usage Analytics
  Future<void> trackFeatureUsage({
    required String featureName,
    String? screen,
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('feature_usage', parameters: {
      'feature_name': featureName,
      if (screen != null) 'screen': screen,
      ...?context,
    });
  }

  Future<void> trackScreenView({
    required String screenName,
    String? previousScreen,
    Duration? timeOnPreviousScreen,
  }) async {
    if (!_initialized) return;

    await _monitoring.logScreenView(screenName);

    if (previousScreen != null && timeOnPreviousScreen != null) {
      await _monitoring.logEvent('screen_time', parameters: {
        'screen': previousScreen,
        'time_spent_seconds': timeOnPreviousScreen.inSeconds,
      });
    }
  }

  Future<void> trackOfflineModeUsage({
    required bool enabled,
    String? trigger, // user_choice, auto_fallback
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('offline_mode', parameters: {
      'enabled': enabled,
      if (trigger != null) 'trigger': trigger,
    });
  }

  // Subscription Analytics
  Future<void> trackSubscriptionView({
    required String source, // paywall, settings, promotion
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('subscription_view', parameters: {
      'source': source,
    });
  }

  Future<void> trackSubscriptionPurchase({
    required String planType, // monthly, yearly, family
    required double price,
    required String currency,
    String? source,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('subscription_purchase', parameters: {
      'plan_type': planType,
      'price': price,
      'currency': currency,
      if (source != null) 'source': source,
    });
  }

  Future<void> trackSubscriptionCancel({
    required String planType,
    required String reason,
    int? daysActive,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('subscription_cancel', parameters: {
      'plan_type': planType,
      'reason': reason,
      if (daysActive != null) 'days_active': daysActive,
    });
  }

  // Social Features Analytics
  Future<void> trackContentContribution({
    required String contentType, // word, translation, audio
    required String language,
    String? userId,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('content_contribution', parameters: {
      'content_type': contentType,
      'language': language,
      'has_user_id': userId != null,
    });
  }

  Future<void> trackSocialShare({
    required String contentType, // progress, word, achievement
    required String platform, // facebook, twitter, whatsapp
    String? language,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('social_share', parameters: {
      'content_type': contentType,
      'platform': platform,
      if (language != null) 'language': language,
    });
  }

  // Error and Performance Analytics
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screen,
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized) return;

    await _monitoring.recordError(
      Exception(errorMessage),
      StackTrace.current,
      reason: errorType,
      context: {
        'error_type': errorType,
        if (screen != null) 'screen': screen,
        'user_facing': true,
        ...?context,
      },
    );
  }

  Future<void> trackPerformanceIssue({
    required String issueType, // slow_load, crash, freeze
    required Duration duration,
    String? screen,
  }) async {
    if (!_initialized) return;

    await _monitoring.logPerformanceMetric(
      metricName: 'performance_issue',
      value: duration.inMilliseconds,
      unit: 'milliseconds',
      context: {
        'issue_type': issueType,
        if (screen != null) 'screen': screen,
      },
    );
  }

  // User Engagement Analytics
  Future<void> trackSessionStart() async {
    if (!_initialized) return;

    await _monitoring.logAppLifecycle(event: 'app_start');
  }

  Future<void> trackSessionEnd(Duration sessionDuration) async {
    if (!_initialized) return;

    await _monitoring.logAppLifecycle(
      event: 'app_background',
      sessionDuration: sessionDuration,
    );
  }

  Future<void> trackUserRetention({
    required int daysSinceInstall,
    required int daysSinceLastUse,
    required int totalSessions,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent('user_retention', parameters: {
      'days_since_install': daysSinceInstall,
      'days_since_last_use': daysSinceLastUse,
      'total_sessions': totalSessions,
    });
  }

  // Custom Events
  Future<void> trackCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_initialized) return;

    await _monitoring.logEvent(eventName, parameters: parameters);
  }

  // Batch Analytics for Performance
  final List<Map<String, dynamic>> _eventQueue = [];
  static const int maxQueueSize = 50;

  Future<void> queueEvent(String eventName, Map<String, dynamic>? parameters) async {
    _eventQueue.add({
      'event': eventName,
      'parameters': parameters,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_eventQueue.length >= maxQueueSize) {
      await _flushEventQueue();
    }
  }

  Future<void> _flushEventQueue() async {
    if (_eventQueue.isEmpty) return;

    try {
      for (final event in _eventQueue) {
        await _monitoring.logEvent(
          event['event'] as String,
          parameters: event['parameters'] as Map<String, dynamic>?,
        );
      }
      _eventQueue.clear();
      debugPrint('📊 Flushed ${_eventQueue.length} analytics events');
    } catch (e) {
      debugPrint('❌ Failed to flush analytics events: $e');
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _flushEventQueue();
    debugPrint('📊 Analytics service disposed');
  }
}