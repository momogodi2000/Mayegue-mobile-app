import 'package:flutter/foundation.dart';
import '../../domain/entities/dictionary_entry_entity.dart';
import '../../domain/usecases/dictionary_entry_usecases.dart';
import '../../../authentication/domain/usecases/get_current_user_usecase.dart';

/// ViewModel for teacher dictionary management functionality
class TeacherDictionaryViewModel extends ChangeNotifier {
  final CreateDictionaryEntryUsecase createEntryUsecase;
  final UpdateDictionaryEntryUsecase updateEntryUsecase;
  final DeleteDictionaryEntryUsecase deleteEntryUsecase;
  final GetEntriesByContributorUsecase getEntriesByContributorUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  TeacherDictionaryViewModel({
    required this.createEntryUsecase,
    required this.updateEntryUsecase,
    required this.deleteEntryUsecase,
    required this.getEntriesByContributorUsecase,
    required this.getCurrentUserUsecase,
  });

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<DictionaryEntryEntity> _userEntries = [];
  DictionaryEntryEntity? _editingEntry;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<DictionaryEntryEntity> get userEntries => _userEntries;
  DictionaryEntryEntity? get editingEntry => _editingEntry;

  /// Load user's contributed entries
  Future<void> loadUserEntries() async {
    _setLoading(true);
    _clearMessages();

    try {
      final userResult = await getCurrentUserUsecase();
      await userResult.fold(
        (failure) async {
          _setError('Failed to get current user: ${failure.message}');
        },
        (user) async {
          if (user == null) {
            _setError('User not authenticated');
            return;
          }
          final entriesResult = await getEntriesByContributorUsecase(
            GetEntriesByContributorParams(contributorId: user.id),
          );

          entriesResult.fold(
            (failure) => _setError('Failed to load entries: ${failure.message}'),
            (entries) {
              _userEntries = entries;
              _setSuccess('Entries loaded successfully');
            },
          );
        },
      );
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new dictionary entry
  Future<bool> createEntry(DictionaryEntryEntity entry) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      final userResult = await getCurrentUserUsecase();
      final user = userResult.getOrElse(() => null);

      if (user == null) {
        _setError('User not authenticated');
        return false;
      }

      // Set contributor ID
      final entryWithContributor = entry.copyWith(contributorId: user.id);

      final result = await createEntryUsecase(
        CreateDictionaryEntryParams(entry: entryWithContributor),
      );

      return result.fold(
        (failure) {
          _setError('Failed to create entry: ${failure.message}');
          return false;
        },
        (createdEntry) {
          _userEntries.insert(0, createdEntry);
          _setSuccess('Entry created successfully');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Update an existing entry
  Future<bool> updateEntry(DictionaryEntryEntity entry) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      final result = await updateEntryUsecase(
        UpdateDictionaryEntryParams(entry: entry),
      );

      return result.fold(
        (failure) {
          _setError('Failed to update entry: ${failure.message}');
          return false;
        },
        (updatedEntry) {
          final index = _userEntries.indexWhere((e) => e.id == updatedEntry.id);
          if (index != -1) {
            _userEntries[index] = updatedEntry;
          }
          _editingEntry = null;
          _setSuccess('Entry updated successfully');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(String entryId) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      final result = await deleteEntryUsecase(
        DeleteDictionaryEntryParams(entryId: entryId),
      );

      return result.fold(
        (failure) {
          _setError('Failed to delete entry: ${failure.message}');
          return false;
        },
        (_) {
          _userEntries.removeWhere((e) => e.id == entryId);
          _setSuccess('Entry deleted successfully');
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Start editing an entry
  void startEditing(DictionaryEntryEntity entry) {
    _editingEntry = entry;
    _clearMessages();
    notifyListeners();
  }

  /// Cancel editing
  void cancelEditing() {
    _editingEntry = null;
    _clearMessages();
    notifyListeners();
  }

  /// Clear messages
  void clearMessages() {
    _clearMessages();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}