import 'package:flutter/foundation.dart';
import '../../../../core/services/ai_service.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/entities/translation_entity.dart';
import '../../domain/usecases/search_words.dart';
import '../../domain/usecases/get_all_translations.dart';
import '../../domain/usecases/get_autocomplete_suggestions.dart';
import '../../domain/usecases/increment_usage_count.dart';
import '../../domain/usecases/save_to_favorites.dart';
import '../../domain/usecases/remove_from_favorites.dart';
import '../../domain/usecases/get_favorite_words.dart';

/// ViewModel for managing dictionary state and operations
class DictionaryViewModel extends ChangeNotifier {
  final SearchWords searchWords;
  final GetAllTranslations getAllTranslations;
  final GetAutocompleteSuggestions getAutocompleteSuggestions;
  final IncrementUsageCount incrementUsageCount;
  final SaveToFavorites saveToFavorites;
  final RemoveFromFavorites removeFromFavorites;
  final GetFavoriteWords getFavoriteWords;
  final GeminiAIService aiService;

  // State
  List<WordEntity> _searchResults = [];
  List<TranslationEntity> _translations = [];
  List<String> _suggestions = [];
  List<WordEntity> _favoriteWords = [];
  bool _isLoading = false;
  bool _isLoadingTranslations = false;
  bool _isLoadingSuggestions = false;
  String? _error;
  String _searchQuery = '';
  String _selectedSourceLanguage = 'fr'; // Default to French
  String _selectedTargetLanguage = 'ewondo'; // Default to Ewondo
  List<String> _selectedCategories = [];
  int? _maxDifficulty;

  // Getters
  List<WordEntity> get searchResults => _searchResults;
  List<TranslationEntity> get translations => _translations;
  List<String> get suggestions => _suggestions;
  List<WordEntity> get favoriteWords => _favoriteWords;
  bool get isLoading => _isLoading;
  bool get isLoadingTranslations => _isLoadingTranslations;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  String? get error => _error;
  bool get hasError => _error != null;
  String? get errorMessage => _error;
  String get searchQuery => _searchQuery;
  String get selectedSourceLanguage => _selectedSourceLanguage;
  String get selectedTargetLanguage => _selectedTargetLanguage;
  List<String> get selectedCategories => _selectedCategories;
  int? get maxDifficulty => _maxDifficulty;

  // Supported languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'Français', 'nativeName': 'Français'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'ewondo', 'name': 'Ewondo', 'nativeName': 'Kolo'},
    {'code': 'dual', 'name': 'Duala', 'nativeName': 'Duala'},
    {'code': 'bafang', 'name': 'Bafang/Fe\'efe\'e', 'nativeName': 'Bafang'},
    {'code': 'fulfulde', 'name': 'Fulfulde', 'nativeName': 'Fulfulde'},
    {'code': 'bassa', 'name': 'Bassa', 'nativeName': 'Bassa'},
    {'code': 'bamum', 'name': 'Bamum', 'nativeName': 'Bamum'},
  ];

  // Word categories
  static const List<String> categories = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'preposition',
    'conjunction',
    'interjection',
    'phrase',
    'expression',
  ];

  DictionaryViewModel({
    required this.searchWords,
    required this.getAllTranslations,
    required this.getAutocompleteSuggestions,
    required this.incrementUsageCount,
    required this.saveToFavorites,
    required this.removeFromFavorites,
    required this.getFavoriteWords,
    required this.aiService,
  });

  /// Search for words
  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await searchWords(
      query,
      sourceLanguage: _selectedSourceLanguage,
      targetLanguage: _selectedTargetLanguage,
      categories: _selectedCategories.isNotEmpty ? _selectedCategories : null,
      maxDifficulty: _maxDifficulty,
    );

    result.fold(
      (failure) {
        _error = failure.message;
        _searchResults = [];
      },
      (words) {
        _searchResults = words;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Load translations for a word
  Future<void> loadTranslations(String wordId) async {
    _isLoadingTranslations = true;
    _error = null;
    notifyListeners();

    final result = await getAllTranslations(wordId);

    result.fold(
      (failure) {
        _error = failure.message;
        _translations = [];
      },
      (translations) {
        _translations = translations;
        // Increment usage count
        incrementUsageCount(wordId);
      },
    );

    _isLoadingTranslations = false;
    notifyListeners();
  }

  /// Get autocomplete suggestions
  Future<void> loadSuggestions(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _isLoadingSuggestions = true;
    notifyListeners();

    final result =
        await getAutocompleteSuggestions(query, _selectedSourceLanguage);

    result.fold(
      (failure) {
        _suggestions = [];
      },
      (suggestions) {
        _suggestions = suggestions;
      },
    );

    _isLoadingSuggestions = false;
    notifyListeners();
  }

  /// Load user's favorite words
  Future<void> loadFavoriteWords(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getFavoriteWords(userId);

    result.fold(
      (failure) {
        _error = failure.message;
        _favoriteWords = [];
      },
      (words) {
        _favoriteWords = words;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle favorite status for a word
  Future<void> toggleFavorite(
      String wordId, String userId, bool isCurrentlyFavorite) async {
    final result = isCurrentlyFavorite
        ? await removeFromFavorites(wordId, userId)
        : await saveToFavorites(wordId, userId);

    result.fold(
      (failure) {
        _error = failure.message;
      },
      (success) {
        if (success) {
          // Update local favorite words list if needed
          loadFavoriteWords(userId);
        }
      },
    );

    notifyListeners();
  }

  /// Translate text using AI (for complex phrases)
  Future<String?> translateWithAI(
      String text, String sourceLang, String targetLang) async {
    try {
      return await aiService.translateText(
        text: text,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    } catch (e) {
      _error = 'Translation failed: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set source language
  void setSourceLanguage(String language) {
    _selectedSourceLanguage = language;
    notifyListeners();
  }

  /// Set target language
  void setTargetLanguage(String language) {
    _selectedTargetLanguage = language;
    notifyListeners();
  }

  /// Set selected categories
  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }

  /// Set maximum difficulty
  void setMaxDifficulty(int? difficulty) {
    _maxDifficulty = difficulty;
    notifyListeners();
  }

  /// Clear search results
  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _error = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get language name by code
  String getLanguageName(String code) {
    final lang = supportedLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'name': code},
    );
    return lang['name'] ?? code;
  }

  /// Get native language name by code
  String getNativeLanguageName(String code) {
    final lang = supportedLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'nativeName': code},
    );
    return lang['nativeName'] ?? code;
  }

  /// Check if a language is a Cameroonian language
  bool isCameroonianLanguage(String code) {
    return !['fr', 'en'].contains(code);
  }

  /// Get word details
  Future<void> getWordDetails(String wordId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // For now, we'll get the word from search results
    // In a real implementation, you'd have a separate usecase for this
    _searchResults.firstWhere(
      (w) => w.id == wordId,
      orElse: () => throw Exception('Word not found'),
    );

    // Load translations for this word
    await loadTranslations(wordId);

    _isLoading = false;
    notifyListeners();
  }

  /// Save word to favorites
  Future<bool> saveToFavoritesMethod(String wordId, String userId) async {
    final result = await saveToFavorites(wordId, userId);

    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (success) => true,
    );
  }

  /// Remove word from favorites
  Future<bool> removeFromFavoritesMethod(String wordId, String userId) async {
    final result = await removeFromFavorites(wordId, userId);

    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (success) => true,
    );
  }

  /// Increment usage count for a word
  Future<void> incrementUsageCountMethod(String wordId) async {
    await incrementUsageCount(wordId);
  }

  /// Update search filters
  void updateSearchFilters({
    String? sourceLanguage,
    String? targetLanguage,
    List<String>? categories,
    int? maxDifficulty,
  }) {
    if (sourceLanguage != null) _selectedSourceLanguage = sourceLanguage;
    if (targetLanguage != null) _selectedTargetLanguage = targetLanguage;
    if (categories != null) _selectedCategories = categories;
    if (maxDifficulty != null) _maxDifficulty = maxDifficulty;
    notifyListeners();
  }

  /// Get supported language native name
  String getLanguageNativeName(String code) {
    final lang = supportedLanguages.firstWhere(
      (lang) => lang['code'] == code,
      orElse: () => {'nativeName': code},
    );
    return lang['nativeName'] ?? code;
  }
}
