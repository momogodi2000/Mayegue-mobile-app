import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Comprehensive monitoring system for Mayegue app
class AppMonitoring {
  static final AppMonitoring _instance = AppMonitoring._internal();
  factory AppMonitoring() => _instance;
  AppMonitoring._internal();

  late final FirebaseCrashlytics _crashlytics;
  late final FirebaseAnalytics _analytics;
  late final FirebasePerformance _performance;

  bool _initialized = false;
  final Map<String, Trace> _activeTraces = {};
  final Map<String, HttpMetric> _activeHttpMetrics = {};

  /// Initialize monitoring system
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _crashlytics = FirebaseCrashlytics.instance;
      _analytics = FirebaseAnalytics.instance;
      _performance = FirebasePerformance.instance;

      // Configure crashlytics
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Set up analytics
      await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);

      // Configure performance monitoring
      await _performance.setPerformanceCollectionEnabled(!kDebugMode);

      _initialized = true;
      debugPrint('🔍 App monitoring initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize monitoring: $e');
    }
  }

  /// Record custom error with context
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    if (!_initialized) return;

    try {
      // Add custom keys for context
      if (context != null) {
        for (final entry in context.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value.toString());
        }
      }

      // Record the error
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      // Also log to analytics for non-fatal errors
      if (!fatal) {
        await _analytics.logEvent(
          name: 'app_error',
          parameters: {
            'error_type': exception.runtimeType.toString(),
            'error_message': exception.toString(),
            'fatal': fatal,
            if (reason != null) 'reason': reason,
          },
        );
      }

      debugPrint('🔍 Error recorded: $exception');
    } catch (e) {
      debugPrint('❌ Failed to record error: $e');
    }
  }

  /// Log analytics event
  Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_initialized) return;

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );

      debugPrint('📊 Event logged: $name');
    } catch (e) {
      debugPrint('❌ Failed to log event: $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperties({
    String? userId,
    String? userRole,
    String? subscriptionType,
    Map<String, String>? customProperties,
  }) async {
    if (!_initialized) return;

    try {
      if (userId != null) {
        await _crashlytics.setUserIdentifier(userId);
        await _analytics.setUserId(id: userId);
      }

      if (userRole != null) {
        await _analytics.setUserProperty(name: 'user_role', value: userRole);
        await _crashlytics.setCustomKey('user_role', userRole);
      }

      if (subscriptionType != null) {
        await _analytics.setUserProperty(name: 'subscription_type', value: subscriptionType);
        await _crashlytics.setCustomKey('subscription_type', subscriptionType);
      }

      if (customProperties != null) {
        for (final entry in customProperties.entries) {
          await _analytics.setUserProperty(name: entry.key, value: entry.value);
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      debugPrint('👤 User properties updated');
    } catch (e) {
      debugPrint('❌ Failed to set user properties: $e');
    }
  }

  /// Start performance trace
  Future<void> startTrace(String traceName) async {
    if (!_initialized) return;

    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;

      debugPrint('⏱️ Trace started: $traceName');
    } catch (e) {
      debugPrint('❌ Failed to start trace: $e');
    }
  }

  /// Stop performance trace
  Future<void> stopTrace(String traceName, {Map<String, int>? metrics}) async {
    if (!_initialized) return;

    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        // Add custom metrics
        if (metrics != null) {
          for (final entry in metrics.entries) {
            trace.setMetric(entry.key, entry.value);
          }
        }

        await trace.stop();
        _activeTraces.remove(traceName);

        debugPrint('⏹️ Trace stopped: $traceName');
      }
    } catch (e) {
      debugPrint('❌ Failed to stop trace: $e');
    }
  }

  /// Start HTTP metric tracking
  Future<void> startHttpMetric(String url, HttpMethod method) async {
    if (!_initialized) return;

    try {
      final metric = _performance.newHttpMetric(url, method);
      await metric.start();
      _activeHttpMetrics[url] = metric;

      debugPrint('🌐 HTTP metric started: $url');
    } catch (e) {
      debugPrint('❌ Failed to start HTTP metric: $e');
    }
  }

  /// Stop HTTP metric tracking
  Future<void> stopHttpMetric(
    String url, {
    int? responseCode,
    int? requestPayloadSize,
    int? responsePayloadSize,
  }) async {
    if (!_initialized) return;

    try {
      final metric = _activeHttpMetrics[url];
      if (metric != null) {
        if (responseCode != null) {
          metric.httpResponseCode = responseCode;
        }
        if (requestPayloadSize != null) {
          metric.requestPayloadSize = requestPayloadSize;
        }
        if (responsePayloadSize != null) {
          metric.responsePayloadSize = responsePayloadSize;
        }

        await metric.stop();
        _activeHttpMetrics.remove(url);

        debugPrint('🌐 HTTP metric stopped: $url');
      }
    } catch (e) {
      debugPrint('❌ Failed to stop HTTP metric: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!_initialized) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      debugPrint('📱 Screen view logged: $screenName');
    } catch (e) {
      debugPrint('❌ Failed to log screen view: $e');
    }
  }

  /// Log user engagement events
  Future<void> logUserEngagement({
    required String action,
    String? category,
    String? label,
    int? value,
    Map<String, dynamic>? additionalParams,
  }) async {
    if (!_initialized) return;

    try {
      final parameters = <String, dynamic>{
        'action': action,
        if (category != null) 'category': category,
        if (label != null) 'label': label,
        if (value != null) 'value': value,
        ...?additionalParams,
      };

      await _analytics.logEvent(
        name: 'user_engagement',
        parameters: parameters,
      );

      debugPrint('👥 User engagement logged: $action');
    } catch (e) {
      debugPrint('❌ Failed to log user engagement: $e');
    }
  }

  /// Log learning progress events
  Future<void> logLearningProgress({
    required String language,
    required String action, // lesson_completed, word_learned, quiz_passed
    String? lessonId,
    String? wordId,
    int? score,
    Duration? duration,
  }) async {
    if (!_initialized) return;

    try {
      final parameters = <String, dynamic>{
        'language': language,
        'action': action,
        if (lessonId != null) 'lesson_id': lessonId,
        if (wordId != null) 'word_id': wordId,
        if (score != null) 'score': score,
        if (duration != null) 'duration_seconds': duration.inSeconds,
      };

      await _analytics.logEvent(
        name: 'learning_progress',
        parameters: parameters,
      );

      debugPrint('📚 Learning progress logged: $action');
    } catch (e) {
      debugPrint('❌ Failed to log learning progress: $e');
    }
  }

  /// Log app performance metrics
  Future<void> logPerformanceMetric({
    required String metricName,
    required num value,
    String? unit,
    Map<String, dynamic>? context,
  }) async {
    if (!_initialized) return;

    try {
      final parameters = <String, dynamic>{
        'metric_name': metricName,
        'value': value,
        if (unit != null) 'unit': unit,
        ...?context,
      };

      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: parameters,
      );

      debugPrint('⚡ Performance metric logged: $metricName = $value');
    } catch (e) {
      debugPrint('❌ Failed to log performance metric: $e');
    }
  }

  /// Track app lifecycle events
  Future<void> logAppLifecycle({
    required String event, // app_start, app_background, app_foreground
    Duration? sessionDuration,
  }) async {
    if (!_initialized) return;

    try {
      final parameters = <String, dynamic>{
        'lifecycle_event': event,
        if (sessionDuration != null) 'session_duration': sessionDuration.inSeconds,
      };

      await _analytics.logEvent(
        name: 'app_lifecycle',
        parameters: parameters,
      );

      debugPrint('🔄 App lifecycle logged: $event');
    } catch (e) {
      debugPrint('❌ Failed to log app lifecycle: $e');
    }
  }

  /// Monitor app health
  Future<void> recordHealthCheck({
    required String component,
    required bool isHealthy,
    String? details,
    Map<String, dynamic>? metrics,
  }) async {
    if (!_initialized) return;

    try {
      if (!isHealthy) {
        // Record as non-fatal error for unhealthy components
        await recordError(
          Exception('Health check failed for $component'),
          StackTrace.current,
          reason: details ?? 'Component health check failed',
          context: {
            'component': component,
            'is_healthy': false,
            ...?metrics,
          },
          fatal: false,
        );
      }

      // Also log as analytics event
      await logEvent(
        'health_check',
        parameters: {
          'component': component,
          'is_healthy': isHealthy,
          if (details != null) 'details': details,
          ...?metrics,
        },
      );

      debugPrint('💊 Health check: $component - ${isHealthy ? 'Healthy' : 'Unhealthy'}');
    } catch (e) {
      debugPrint('❌ Failed to record health check: $e');
    }
  }

  /// Get monitoring status
  Map<String, dynamic> getStatus() {
    return {
      'initialized': _initialized,
      'active_traces': _activeTraces.keys.toList(),
      'active_http_metrics': _activeHttpMetrics.keys.toList(),
      'crashlytics_enabled': !kDebugMode,
      'analytics_enabled': !kDebugMode,
      'performance_enabled': !kDebugMode,
    };
  }

  /// Cleanup resources
  Future<void> dispose() async {
    // Stop all active traces
    for (final traceName in _activeTraces.keys.toList()) {
      await stopTrace(traceName);
    }

    // Stop all active HTTP metrics
    for (final url in _activeHttpMetrics.keys.toList()) {
      await stopHttpMetric(url);
    }

    debugPrint('🔍 App monitoring disposed');
  }
}