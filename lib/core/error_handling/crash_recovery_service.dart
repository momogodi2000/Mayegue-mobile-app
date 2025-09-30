import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../monitoring/app_monitoring.dart';

class CrashRecoveryService {
  static const String _crashCountKey = 'crash_count';
  static const String _lastCrashTimeKey = 'last_crash_time';
  static const String _appStateKey = 'app_state_backup';
  static const String _isRecoveringKey = 'is_recovering';

  static const int maxCrashCount = 3;
  static const Duration crashResetTime = Duration(hours: 24);

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if app is in recovery mode
    final isRecovering = prefs.getBool(_isRecoveringKey) ?? false;

    if (isRecovering) {
      await _handleRecoveryMode(prefs);
    } else {
      await _recordSuccessfulStartup(prefs);
    }
  }

  static Future<void> recordCrash({
    required dynamic exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Increment crash count
      final currentCount = prefs.getInt(_crashCountKey) ?? 0;
      final newCount = currentCount + 1;

      await prefs.setInt(_crashCountKey, newCount);
      await prefs.setInt(_lastCrashTimeKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool(_isRecoveringKey, true);

      // Record crash details for analytics
      await AppMonitoring().recordError(
        exception,
        stackTrace,
        reason: 'Application crash',
        context: {
          'crash_count': newCount,
          'recovery_mode': true,
          ...?context,
        },
        fatal: true,
      );

      debugPrint('🚨 Crash recorded: Count $newCount');

      // If crash count exceeds threshold, trigger safe mode
      if (newCount >= maxCrashCount) {
        await _enableSafeMode(prefs);
      }

    } catch (e) {
      debugPrint('❌ Failed to record crash: $e');
    }
  }

  static Future<void> saveAppState(Map<String, dynamic> state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appStateKey, state.toString());
      debugPrint('💾 App state saved for recovery');
    } catch (e) {
      debugPrint('❌ Failed to save app state: $e');
    }
  }

  static Future<Map<String, dynamic>?> getLastAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateString = prefs.getString(_appStateKey);

      if (stateString != null) {
        // Parse the saved state (simplified version)
        return {'saved_state': stateString};
      }
    } catch (e) {
      debugPrint('❌ Failed to get last app state: $e');
    }

    return null;
  }

  static Future<bool> isInSafeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('safe_mode_enabled') ?? false;
  }

  static Future<bool> shouldShowRecoveryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final isRecovering = prefs.getBool(_isRecoveringKey) ?? false;
    final crashCount = prefs.getInt(_crashCountKey) ?? 0;

    return isRecovering && crashCount > 0;
  }

  static Future<RecoveryInfo> getRecoveryInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final crashCount = prefs.getInt(_crashCountKey) ?? 0;
    final lastCrashTime = prefs.getInt(_lastCrashTimeKey);
    final isInSafeMode = prefs.getBool('safe_mode_enabled') ?? false;

    DateTime? lastCrashDateTime;
    if (lastCrashTime != null) {
      lastCrashDateTime = DateTime.fromMillisecondsSinceEpoch(lastCrashTime);
    }

    return RecoveryInfo(
      crashCount: crashCount,
      lastCrashTime: lastCrashDateTime,
      isInSafeMode: isInSafeMode,
      canResetCrashes: _canResetCrashes(lastCrashDateTime),
    );
  }

  static Future<void> clearRecoveryState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_isRecoveringKey);
    await prefs.remove(_appStateKey);

    debugPrint('✅ Recovery state cleared');

    AppMonitoring().logEvent('crash_recovery_cleared', parameters: {
      'manual_clear': true,
    });
  }

  static Future<void> resetCrashCount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_crashCountKey);
    await prefs.remove(_lastCrashTimeKey);
    await prefs.remove('safe_mode_enabled');
    await clearRecoveryState();

    debugPrint('🔄 Crash count reset');

    AppMonitoring().logEvent('crash_count_reset', parameters: {
      'manual_reset': true,
    });
  }

  static Future<void> disableSafeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safe_mode_enabled', false);

    debugPrint('🟢 Safe mode disabled');

    AppMonitoring().logEvent('safe_mode_disabled', parameters: {
      'user_action': true,
    });
  }

  static Future<void> _handleRecoveryMode(SharedPreferences prefs) async {
    final crashCount = prefs.getInt(_crashCountKey) ?? 0;

    debugPrint('🔄 App started in recovery mode (crashes: $crashCount)');

    AppMonitoring().logEvent('app_recovery_mode', parameters: {
      'crash_count': crashCount,
      'recovery_startup': true,
    });
  }

  static Future<void> _recordSuccessfulStartup(SharedPreferences prefs) async {
    // Check if enough time has passed to reset crash count
    final lastCrashTime = prefs.getInt(_lastCrashTimeKey);

    if (lastCrashTime != null) {
      final lastCrash = DateTime.fromMillisecondsSinceEpoch(lastCrashTime);

      if (_canResetCrashes(lastCrash)) {
        await resetCrashCount();
        debugPrint('🔄 Crash count auto-reset after 24h');
      }
    }

    AppMonitoring().logEvent('app_successful_startup', parameters: {
      'clean_startup': true,
    });
  }

  static Future<void> _enableSafeMode(SharedPreferences prefs) async {
    await prefs.setBool('safe_mode_enabled', true);

    debugPrint('🛡️ Safe mode enabled due to multiple crashes');

    AppMonitoring().logEvent('safe_mode_enabled', parameters: {
      'trigger': 'multiple_crashes',
      'crash_threshold': maxCrashCount,
    });
  }

  static bool _canResetCrashes(DateTime? lastCrashTime) {
    if (lastCrashTime == null) return false;

    final timeSinceLastCrash = DateTime.now().difference(lastCrashTime);
    return timeSinceLastCrash >= crashResetTime;
  }
}

class RecoveryInfo {
  final int crashCount;
  final DateTime? lastCrashTime;
  final bool isInSafeMode;
  final bool canResetCrashes;

  const RecoveryInfo({
    required this.crashCount,
    this.lastCrashTime,
    required this.isInSafeMode,
    required this.canResetCrashes,
  });

  bool get hasRecentCrashes => crashCount > 0;

  bool get shouldShowWarning => crashCount >= 2;

  String get statusMessage {
    if (isInSafeMode) {
      return 'L\'application fonctionne en mode sécurisé après $crashCount plantages récents.';
    } else if (crashCount > 0) {
      return 'L\'application a planté $crashCount fois récemment.';
    } else {
      return 'L\'application fonctionne normalement.';
    }
  }

  String get recommendedAction {
    if (isInSafeMode) {
      return 'Certaines fonctionnalités sont désactivées pour assurer la stabilité.';
    } else if (crashCount >= 2) {
      return 'Essayez de redémarrer l\'application ou contactez le support.';
    } else if (crashCount == 1) {
      return 'Surveillez la stabilité de l\'application.';
    } else {
      return 'Aucune action requise.';
    }
  }
}