import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage Terms & Conditions acceptance
class TermsService {
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _termsAcceptedDateKey = 'terms_accepted_date';
  static const String _termsVersionKey = 'terms_version';

  /// Current version of terms - increment this when terms change
  static const String _currentTermsVersion = '1.0.0';

  /// Check if user has accepted the current version of terms
  static Future<bool> hasAcceptedTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accepted = prefs.getBool(_termsAcceptedKey) ?? false;
      final version = prefs.getString(_termsVersionKey) ?? '';

      // User must have accepted AND must have accepted the current version
      return accepted && version == _currentTermsVersion;
    } catch (e) {
      return false;
    }
  }

  /// Mark terms as accepted
  static Future<bool> acceptTerms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_termsAcceptedKey, true);
      await prefs.setString(_termsVersionKey, _currentTermsVersion);
      await prefs.setString(
        _termsAcceptedDateKey,
        DateTime.now().toIso8601String(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset terms acceptance (for testing or when terms change)
  static Future<bool> resetTermsAcceptance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_termsAcceptedKey);
      await prefs.remove(_termsVersionKey);
      await prefs.remove(_termsAcceptedDateKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get the date when terms were accepted
  static Future<DateTime?> getAcceptanceDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateString = prefs.getString(_termsAcceptedDateKey);
      if (dateString != null) {
        return DateTime.parse(dateString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
