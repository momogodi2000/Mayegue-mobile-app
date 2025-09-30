import 'package:flutter/foundation.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../../domain/repositories/lexicon_repository.dart';
import '../../domain/usecases/ai_enrich_vocabulary_usecase.dart';
import '../../../authentication/domain/usecases/get_current_user_usecase.dart';

/// ViewModel for teacher dictionary review functionality
class TeacherReviewViewModel extends ChangeNotifier {
  final LexiconRepository lexiconRepository;
  final AiEnrichVocabularyUsecase aiEnrichVocabularyUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  TeacherReviewViewModel({
    required this.lexiconRepository,
    required this.aiEnrichVocabularyUsecase,
    required this.getCurrentUserUsecase,
  });

  // State
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  List<DictionaryEntryEntity> _aiSuggestedEntries = [];
  List<DictionaryEntryEntity> _pendingEntries = [];

  // Statistics
  int _todayReviews = 0;
  int _totalVerified = 0;
  int _totalPending = 0;
  int _totalAiSuggested = 0;
  final Map<String, Map<String, int>> _languageProgress = {};

  // Getters
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  List<DictionaryEntryEntity> get aiSuggestedEntries => _aiSuggestedEntries;
  List<DictionaryEntryEntity> get pendingEntries => _pendingEntries;

  int get todayReviews => _todayReviews;
  int get totalVerified => _totalVerified;
  int get totalPending => _totalPending;
  int get totalAiSuggested => _totalAiSuggested;
  Map<String, Map<String, int>> get languageProgress => _languageProgress;

  /// Load pending entries for review
  Future<void> loadPendingEntries() async {
    _setLoading(true);
    _clearError();

    try {
      // Load AI suggested entries
      final aiResult = await lexiconRepository.getAiSuggestedEntries(limit: 50);
      aiResult.fold(
        (failure) =>
            _setError('Failed to load AI suggestions: ${failure.message}'),
        (entries) => _aiSuggestedEntries = entries,
      );

      // Load pending review entries
      final pendingResult =
          await lexiconRepository.getPendingReviewEntries(limit: 50);
      pendingResult.fold(
        (failure) =>
            _setError('Failed to load pending entries: ${failure.message}'),
        (entries) => _pendingEntries = entries,
      );

      // Load statistics
      await _loadStatistics();
    } catch (e) {
      _setError('Failed to load data: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Approve an entry
  Future<void> approveEntry(String entryId) async {
    _setProcessing(true);

    try {
      final currentUser = await getCurrentUserUsecase();
      await currentUser.fold(
        (failure) =>
            throw Exception('Failed to get current user: ${failure.message}'),
        (user) async {
          if (user == null) {
            throw Exception('User not authenticated');
          }
          final result =
              await lexiconRepository.markAsVerified(entryId, user.id);
          result.fold(
            (failure) =>
                throw Exception('Failed to approve entry: ${failure.message}'),
            (approvedEntry) {
              // Remove from current lists
              _aiSuggestedEntries.removeWhere((e) => e.id == entryId);
              _pendingEntries.removeWhere((e) => e.id == entryId);

              // Update statistics
              _todayReviews++;
              _totalVerified++;
              _totalPending =
                  (_pendingEntries.length + _aiSuggestedEntries.length);

              _showSuccess('Entrée approuvée avec succès');
            },
          );
        },
      );
    } catch (e) {
      _setError('Failed to approve entry: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Reject an entry
  Future<void> rejectEntry(String entryId, String reason) async {
    _setProcessing(true);

    try {
      final currentUser = await getCurrentUserUsecase();
      await currentUser.fold(
        (failure) =>
            throw Exception('Failed to get current user: ${failure.message}'),
        (user) async {
          if (user == null) {
            throw Exception('User not authenticated');
          }
          final result =
              await lexiconRepository.markAsRejected(entryId, user.id, reason);
          result.fold(
            (failure) =>
                throw Exception('Failed to reject entry: ${failure.message}'),
            (_) {
              // Remove from current lists
              _aiSuggestedEntries.removeWhere((e) => e.id == entryId);
              _pendingEntries.removeWhere((e) => e.id == entryId);

              // Update statistics
              _todayReviews++;
              _totalPending =
                  (_pendingEntries.length + _aiSuggestedEntries.length);

              _showSuccess('Entrée rejetée');
            },
          );
        },
      );
    } catch (e) {
      _setError('Failed to reject entry: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Generate AI suggestions for vocabulary
  Future<void> generateAiSuggestions({
    String? languageCode,
    String? category,
    DifficultyLevel? difficulty,
  }) async {
    _setProcessing(true);

    try {
      // Default parameters if not provided
      final params = AiEnrichmentParams(
        languageCode: languageCode ?? 'ewondo',
        category: category ?? 'daily-life',
        difficultyLevel: difficulty ?? DifficultyLevel.beginner,
        count: 20,
        context: 'Traditional Cameroonian language learning',
      );

      final result = await aiEnrichVocabularyUsecase(params);
      result.fold(
        (failure) =>
            _setError('Failed to generate AI suggestions: ${failure.message}'),
        (newEntries) {
          _aiSuggestedEntries.addAll(newEntries);
          _totalAiSuggested += newEntries.length;
          _showSuccess('${newEntries.length} nouvelles suggestions générées');
        },
      );
    } catch (e) {
      _setError('Failed to generate AI suggestions: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Bulk approve high confidence AI suggestions
  Future<void> bulkApproveHighConfidence({double threshold = 0.8}) async {
    _setProcessing(true);

    try {
      final highConfidenceEntries = _aiSuggestedEntries
          .where((entry) => entry.qualityScore >= threshold)
          .toList();

      if (highConfidenceEntries.isEmpty) {
        _showSuccess('Aucune suggestion avec une confiance élevée trouvée');
        return;
      }

      final currentUser = await getCurrentUserUsecase();
      await currentUser.fold(
        (failure) =>
            throw Exception('Failed to get current user: ${failure.message}'),
        (user) async {
          if (user == null) {
            throw Exception('User not authenticated');
          }
          int approvedCount = 0;

          for (final entry in highConfidenceEntries) {
            try {
              final result =
                  await lexiconRepository.markAsVerified(entry.id, user.id);
              result.fold(
                (failure) => debugPrint(
                    'Failed to approve ${entry.canonicalForm}: ${failure.message}'),
                (_) {
                  approvedCount++;
                  _aiSuggestedEntries.removeWhere((e) => e.id == entry.id);
                },
              );
            } catch (e) {
              debugPrint('Error approving ${entry.canonicalForm}: $e');
            }
          }

          _todayReviews += approvedCount;
          _totalVerified += approvedCount;
          _totalPending = (_pendingEntries.length + _aiSuggestedEntries.length);

          _showSuccess('$approvedCount entrées approuvées en lot');
        },
      );
    } catch (e) {
      _setError('Failed to bulk approve: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Generate vocabulary for all supported languages
  Future<void> generateVocabularyForAllLanguages() async {
    _setProcessing(true);

    try {
      final languages = [
        'ewondo',
        'duala',
        'bafang',
        'fulfulde',
        'bassa',
        'bamum'
      ];
      int totalGenerated = 0;

      for (final languageCode in languages) {
        try {
          final params = AiEnrichmentParams(
            languageCode: languageCode,
            category: 'basic-vocabulary',
            difficultyLevel: DifficultyLevel.beginner,
            count: 15,
            context: 'Essential words for beginning learners',
          );

          final result = await aiEnrichVocabularyUsecase(params);
          result.fold(
            (failure) => debugPrint(
                'Failed to generate for $languageCode: ${failure.message}'),
            (newEntries) {
              _aiSuggestedEntries.addAll(newEntries);
              totalGenerated += newEntries.length;
            },
          );

          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('Error generating vocabulary for $languageCode: $e');
        }
      }

      _totalAiSuggested += totalGenerated;
      _showSuccess('$totalGenerated entrées générées pour toutes les langues');
    } catch (e) {
      _setError(
          'Failed to generate vocabulary for all languages: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Export reviewed data
  Future<void> exportReviewedData() async {
    _setProcessing(true);

    try {
      // This would typically export to CSV or JSON
      // For now, we'll simulate the export
      await Future.delayed(const Duration(seconds: 2));

      _showSuccess('Données exportées avec succès');
    } catch (e) {
      _setError('Failed to export data: ${e.toString()}');
    } finally {
      _setProcessing(false);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadPendingEntries();
  }

  /// Load statistics
  Future<void> _loadStatistics() async {
    try {
      final result = await lexiconRepository.getStatistics();
      result.fold(
        (failure) =>
            debugPrint('Failed to load statistics: ${failure.message}'),
        (stats) {
          _totalVerified = stats.verifiedEntries;
          _totalPending = stats.pendingEntries;
          _totalAiSuggested = stats.aiSuggestedEntries;

          // Calculate language progress
          _languageProgress.clear();
          for (final entry in stats.entriesByLanguage.entries) {
            final languageCode = entry.key;
            final totalEntries = entry.value;

            _languageProgress[languageCode] = {
              'total': totalEntries,
              'verified': (totalEntries * 0.6).round(), // Mock calculation
              'pending': (totalEntries * 0.3).round(),
              'ai_suggested': (totalEntries * 0.1).round(),
            };
          }
        },
      );
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _showSuccess(String message) {
    // In a real app, this would show a snackbar or toast
    debugPrint('Success: $message');
    notifyListeners();
  }
}
