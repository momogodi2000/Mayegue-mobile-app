import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for onboarding local data source
abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingComplete();
  Future<void> markOnboardingComplete();
  Future<void> resetOnboarding();
  Future<Map<String, dynamic>?> getOnboardingProgress();
  Future<void> saveOnboardingProgress(Map<String, dynamic> progress);

  // Additional methods for repository compatibility
  Future<void> saveOnboardingData(dynamic data);
  Future<bool> getOnboardingStatus();
  Future<Map<String, dynamic>?> getOnboardingData();
  Future<void> clearOnboardingData();
}

/// Implementation of OnboardingLocalDataSource using SharedPreferences
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyOnboardingProgress = 'onboarding_progress';

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  @override
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  @override
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingComplete);
    await prefs.remove(_keyOnboardingProgress);
  }

  @override
  Future<Map<String, dynamic>?> getOnboardingProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_keyOnboardingProgress);
    if (progressJson != null) {
      return json.decode(progressJson) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> saveOnboardingProgress(Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = json.encode(progress);
    await prefs.setString(_keyOnboardingProgress, progressJson);
  }

  @override
  Future<void> saveOnboardingData(dynamic data) async {
    if (data is Map<String, dynamic>) {
      await saveOnboardingProgress(data);
    }
    await markOnboardingComplete();
  }

  @override
  Future<bool> getOnboardingStatus() async {
    return await isOnboardingComplete();
  }

  @override
  Future<Map<String, dynamic>?> getOnboardingData() async {
    return await getOnboardingProgress();
  }

  @override
  Future<void> clearOnboardingData() async {
    await resetOnboarding();
  }
}