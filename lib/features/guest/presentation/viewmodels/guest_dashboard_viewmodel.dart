import 'package:flutter/material.dart';
import '../../../../core/services/guest_content_service.dart';

/// ViewModel for Guest Dashboard - Uses real SQLite + Firebase data
class GuestDashboardViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _availableLanguages = [];
  List<Map<String, dynamic>> _demoLessons = [];
  List<Map<String, dynamic>> _basicWords = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, int> _contentStats = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get availableLanguages => _availableLanguages;
  List<Map<String, dynamic>> get demoLessons => _demoLessons;
  List<Map<String, dynamic>> get basicWords => _basicWords;
  List<Map<String, dynamic>> get categories => _categories;
  Map<String, int> get contentStats => _contentStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Initialize guest content from SQLite + Firebase
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load all guest content in parallel
      final results = await Future.wait([
        GuestContentService.getAvailableLanguages(),
        GuestContentService.getDemoLessons(languageCode: 'fr', limit: 5),
        GuestContentService.getBasicWords(languageCode: 'fr'),
        GuestContentService.getCategories(languageCode: 'fr'),
        GuestContentService.getContentStats(languageCode: 'fr'),
      ]);

      _availableLanguages = results[0] as List<Map<String, dynamic>>;
      _demoLessons = results[1] as List<Map<String, dynamic>>;
      _basicWords = results[2] as List<Map<String, dynamic>>;
      _categories = results[3] as List<Map<String, dynamic>>;
      _contentStats = results[4] as Map<String, int>;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement du contenu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load words by language
  Future<void> loadWordsByLanguage(String languageCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      _basicWords = await GuestContentService.getBasicWords(
        languageCode: languageCode,
      );
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des mots: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load words by category
  Future<void> loadWordsByCategory(int categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _basicWords = await GuestContentService.getWordsByCategory(
        categoryId,
        limit: 50,
      );
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des mots: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get basic words for a language
  Future<List<Map<String, dynamic>>> getBasicWords({
    String? languageCode,
  }) async {
    try {
      return await GuestContentService.getBasicWords(
        languageCode: languageCode ?? 'fr',
      );
    } catch (e) {
      return [];
    }
  }

  /// Search words
  Future<List<Map<String, dynamic>>> searchWords(String searchTerm) async {
    try {
      return await GuestContentService.searchWords(
        query: searchTerm,
        languageCode: 'fr',
        limit: 30,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get lesson content/chapters
  Future<List<Map<String, dynamic>>> getLessonContent(int lessonId) async {
    try {
      final lesson = await GuestContentService.getLessonContent(lessonId);
      return [lesson]; // Wrap in list as expected by return type
    } catch (e) {
      return [];
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh all content
  Future<void> refresh() async {
    await initialize();
  }
}
