import 'package:flutter/foundation.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/usecases/language_usecases.dart';

/// ViewModel for language management
class LanguageViewModel extends ChangeNotifier {
  final GetAllLanguagesUseCase getAllLanguagesUseCase;
  final GetLanguageByIdUseCase getLanguageByIdUseCase;
  final SearchLanguagesUseCase searchLanguagesUseCase;
  final GetLanguagesByRegionUseCase getLanguagesByRegionUseCase;
  final CreateLanguageUseCase createLanguageUseCase;
  final UpdateLanguageUseCase updateLanguageUseCase;
  final DeleteLanguageUseCase deleteLanguageUseCase;
  final GetLanguageStatisticsUseCase getLanguageStatisticsUseCase;
  final GeminiAIService? aiService;

  // State
  List<LanguageEntity> _languages = [];
  LanguageEntity? _selectedLanguage;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<LanguageEntity> get languages => _languages;
  LanguageEntity? get selectedLanguage => _selectedLanguage;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Filtered languages based on search
  List<LanguageEntity> get filteredLanguages {
    if (_searchQuery.isEmpty) return _languages;

    return _languages
        .where((language) =>
            language.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            language.region
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            language.group.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  LanguageViewModel({
    required this.getAllLanguagesUseCase,
    required this.getLanguageByIdUseCase,
    required this.searchLanguagesUseCase,
    required this.getLanguagesByRegionUseCase,
    required this.createLanguageUseCase,
    required this.updateLanguageUseCase,
    required this.deleteLanguageUseCase,
    required this.getLanguageStatisticsUseCase,
    this.aiService,
  });

  /// Load all languages
  Future<void> loadLanguages() async {
    _setLoading(true);
    _error = null;

    final result = await getAllLanguagesUseCase(const NoParams());

    result.fold(
      (failure) {
        _error = failure.message;
        _languages = [];
      },
      (languages) {
        _languages = languages;
      },
    );

    _setLoading(false);
  }

  /// Select a language
  void selectLanguage(LanguageEntity? language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  /// Set search query for filtering (synchronous)
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Search languages
  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      await loadLanguages();
      return;
    }

    _setLoading(true);
    _error = null;

    final result = await searchLanguagesUseCase(query);

    result.fold(
      (failure) {
        _error = failure.message;
        _languages = [];
      },
      (languages) {
        _languages = languages;
      },
    );

    _setLoading(false);
  }

  /// Get languages by region
  Future<void> loadLanguagesByRegion(String region) async {
    _setLoading(true);
    _error = null;

    final result = await getLanguagesByRegionUseCase(region);

    result.fold(
      (failure) {
        _error = failure.message;
        _languages = [];
      },
      (languages) {
        _languages = languages;
      },
    );

    _setLoading(false);
  }

  /// Load language statistics
  Future<void> loadStatistics() async {
    final result = await getLanguageStatisticsUseCase(const NoParams());

    result.fold(
      (failure) => _error = failure.message,
      (stats) => _statistics = stats,
    );

    notifyListeners();
  }

  /// Create a new language
  Future<bool> createLanguage(LanguageEntity language) async {
    _setLoading(true);
    _error = null;

    final result = await createLanguageUseCase(language);

    bool success = false;
    result.fold(
      (failure) {
        _error = failure.message;
        success = false;
      },
      (createdLanguage) {
        _languages.add(createdLanguage);
        success = true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Update a language
  Future<bool> updateLanguage(LanguageEntity language) async {
    _setLoading(true);
    _error = null;

    final result = await updateLanguageUseCase(language);

    bool success = false;
    result.fold(
      (failure) {
        _error = failure.message;
        success = false;
      },
      (updatedLanguage) {
        final index = _languages.indexWhere((l) => l.id == updatedLanguage.id);
        if (index != -1) {
          _languages[index] = updatedLanguage;
        }
        if (_selectedLanguage?.id == updatedLanguage.id) {
          _selectedLanguage = updatedLanguage;
        }
        success = true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete a language
  Future<bool> deleteLanguage(String id) async {
    _setLoading(true);
    _error = null;

    final result = await deleteLanguageUseCase(id);

    bool success = false;
    result.fold(
      (failure) {
        _error = failure.message;
        success = false;
      },
      (_) {
        _languages.removeWhere((l) => l.id == id);
        if (_selectedLanguage?.id == id) {
          _selectedLanguage = null;
        }
        success = true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Generate AI content for language learning
  Future<String?> generateAILesson({
    required String languageName,
    required String topic,
    String difficulty = 'intermediate',
  }) async {
    if (aiService == null) return null;

    try {
      return await aiService!.generateLanguageLesson(
        languageName: languageName,
        topic: topic,
        difficulty: difficulty,
      );
    } catch (e) {
      _error = 'Failed to generate AI content: $e';
      notifyListeners();
      return null;
    }
  }

  /// Generate AI translation
  Future<String?> generateAITranslation({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (aiService == null) return null;

    try {
      return await aiService!.translateText(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      _error = 'Failed to generate AI translation: $e';
      notifyListeners();
      return null;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
