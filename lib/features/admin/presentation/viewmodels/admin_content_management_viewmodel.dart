import 'package:flutter/foundation.dart';
import '../../../../core/models/user_role.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../../dictionary/domain/entities/dictionary_entry_entity.dart';
import '../../../lessons/domain/entities/lesson_entity.dart';

/// ViewModel for admin content management functionality
class AdminContentManagementViewModel extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Content data
  List<DictionaryEntryEntity> _allDictionaryEntries = const <DictionaryEntryEntity>[];
  List<LessonEntity> _allLessons = const <LessonEntity>[];
  List<UserEntity> _allUsers = const <UserEntity>[];
  List<ModerationItem> _pendingModerations = const <ModerationItem>[];
  List<AdminActivity> _recentActivities = const <AdminActivity>[];
  ContentStatistics _contentStatistics = ContentStatistics.empty();

  // Filters
  String _searchQuery = '';
  String? _selectedLanguageFilter;
  String? _selectedRoleFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ContentStatistics get contentStatistics => _contentStatistics;
  List<AdminActivity> get recentActivities => _recentActivities;
  List<ModerationItem> get pendingModerations => _pendingModerations;

  // Filtered content getters
  List<DictionaryEntryEntity> get filteredDictionaryEntries {
    var filtered = _allDictionaryEntries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.canonicalForm.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.translations.values.any((translation) =>
              translation.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesLanguage = _selectedLanguageFilter == null ||
          _selectedLanguageFilter == 'Toutes' ||
          entry.languageCode == _selectedLanguageFilter!.toLowerCase();

      return matchesSearch && matchesLanguage;
    }).toList();

    return filtered;
  }

  List<LessonEntity> get filteredLessons {
    return _allLessons.where((lesson) {
      return _searchQuery.isEmpty ||
          lesson.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          lesson.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<UserEntity> get filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          (user.displayName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRole = _selectedRoleFilter == null ||
          _selectedRoleFilter == 'Tous' ||
          user.role.toLowerCase() == _selectedRoleFilter!.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }

  String? get selectedLanguageFilter => _selectedLanguageFilter;
  String? get selectedRoleFilter => _selectedRoleFilter;

  /// Initialize the admin content management
  Future<void> initialize() async {
    await _setLoading(true);

    try {
      await Future.wait([
        _loadDictionaryContent(),
        _loadLessonsContent(),
        _loadUsersContent(),
        _loadModerationContent(),
        _loadRecentActivities(),
        _loadStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to initialize admin content: $e');
    } finally {
      await _setLoading(false);
    }
  }

  /// Refresh all content
  Future<void> refresh() async {
    await initialize();
  }

  /// Search dictionary content
  void searchDictionaryContent(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Search lessons content
  void searchLessonsContent(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Search users
  void searchUsers(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set language filter
  void setLanguageFilter(String? language) {
    _selectedLanguageFilter = language;
    notifyListeners();
  }

  /// Set role filter
  void setRoleFilter(String? role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  /// Refresh dictionary content
  Future<void> refreshDictionaryContent() async {
    await _loadDictionaryContent();
  }

  /// Refresh lessons content
  Future<void> refreshLessonsContent() async {
    await _loadLessonsContent();
  }

  /// Refresh users content
  Future<void> refreshUsersContent() async {
    await _loadUsersContent();
  }

  /// Refresh games content
  Future<void> refreshGamesContent() async {
    // Implement when games module is ready
  }

  /// Refresh moderation content
  Future<void> refreshModerationContent() async {
    await _loadModerationContent();
  }

  /// Approve dictionary entry
  Future<void> approveDictionaryEntry(String entryId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _allDictionaryEntries = _allDictionaryEntries.map((entry) {
        if (entry.id == entryId) {
          return entry.copyWith(reviewStatus: ReviewStatus.humanVerified);
        }
        return entry;
      }).toList();

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Entrée de dictionnaire approuvée: ${_getDictionaryEntryTitle(entryId)}',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to approve dictionary entry: $e');
    }
  }

  /// Reject dictionary entry
  Future<void> rejectDictionaryEntry(String entryId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _allDictionaryEntries = _allDictionaryEntries.map((entry) {
        if (entry.id == entryId) {
          return entry.copyWith(reviewStatus: ReviewStatus.rejected);
        }
        return entry;
      }).toList();

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Entrée de dictionnaire rejetée: ${_getDictionaryEntryTitle(entryId)}',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to reject dictionary entry: $e');
    }
  }

  /// Edit dictionary entry
  Future<void> editDictionaryEntry(String entryId) async {
    // Implement dictionary entry editing
    debugPrint('Editing dictionary entry: $entryId');
  }

  /// Delete dictionary entry
  Future<void> deleteDictionaryEntry(String entryId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final entryTitle = _getDictionaryEntryTitle(entryId);
      _allDictionaryEntries.removeWhere((entry) => entry.id == entryId);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Entrée de dictionnaire supprimée: $entryTitle',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete dictionary entry: $e');
    }
  }

  /// Duplicate lesson
  Future<void> duplicateLesson(String lessonId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final originalLesson = _allLessons.firstWhere((lesson) => lesson.id == lessonId);
      final duplicatedLesson = originalLesson.copyWith(
        id: '${originalLesson.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
        title: '${originalLesson.title} (Copie)',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _allLessons.add(duplicatedLesson);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentCreation,
        description: 'Leçon dupliquée: ${duplicatedLesson.title}',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to duplicate lesson: $e');
    }
  }

  /// Delete lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final lessonTitle = _getLessonTitle(lessonId);
      _allLessons.removeWhere((lesson) => lesson.id == lessonId);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Leçon supprimée: $lessonTitle',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete lesson: $e');
    }
  }

  /// View user profile
  Future<void> viewUserProfile(String userId) async {
    debugPrint('Viewing user profile: $userId');
    // Implement navigation to user profile
  }

  /// Change user role
  Future<void> changeUserRole(String userId, UserRole newRole) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _allUsers = _allUsers.map((user) {
        if (user.id == userId) {
          return user.copyWith(role: newRole.value);
        }
        return user;
      }).toList();

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Rôle utilisateur changé: ${_getUserName(userId)} -> ${newRole.displayName}',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to change user role: $e');
    }
  }

  /// Suspend user
  Future<void> suspendUser(String userId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Utilisateur suspendu: ${_getUserName(userId)}',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to suspend user: $e');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final userName = _getUserName(userId);
      _allUsers.removeWhere((user) => user.id == userId);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Utilisateur supprimé: $userName',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to delete user: $e');
    }
  }

  /// Approve moderation item
  Future<void> approveModerationItem(String itemId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _pendingModerations.removeWhere((item) => item.id == itemId);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Contenu approuvé en modération',
        timestamp: DateTime.now(),
      ));

      await _loadStatistics(); // Refresh statistics
      notifyListeners();
    } catch (e) {
      _setError('Failed to approve moderation item: $e');
    }
  }

  /// Reject moderation item
  Future<void> rejectModerationItem(String itemId, String reason) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _pendingModerations.removeWhere((item) => item.id == itemId);

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.contentModeration,
        description: 'Contenu rejeté en modération: $reason',
        timestamp: DateTime.now(),
      ));

      await _loadStatistics(); // Refresh statistics
      notifyListeners();
    } catch (e) {
      _setError('Failed to reject moderation item: $e');
    }
  }

  /// Export data
  Future<void> exportData() async {
    try {
      // Simulate export process
      await Future.delayed(const Duration(seconds: 2));

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.systemUpdate,
        description: 'Données exportées',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to export data: $e');
    }
  }

  /// Import data
  Future<void> importData() async {
    try {
      // Simulate import process
      await Future.delayed(const Duration(seconds: 2));

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.systemUpdate,
        description: 'Données importées',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to import data: $e');
    }
  }

  /// Create backup
  Future<void> createBackup() async {
    try {
      // Simulate backup process
      await Future.delayed(const Duration(seconds: 3));

      _addActivity(AdminActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AdminActivityType.systemUpdate,
        description: 'Sauvegarde créée',
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _setError('Failed to create backup: $e');
    }
  }

  /// Private methods
  Future<void> _loadDictionaryContent() async {
    // Simulate loading dictionary entries
    await Future.delayed(const Duration(milliseconds: 500));

    _allDictionaryEntries = [
      // Mock data - replace with actual repository calls
      DictionaryEntryEntity(
        id: '1',
        languageCode: 'ewondo',
        canonicalForm: 'mbolo',
        translations: const {'fr': 'bonjour', 'en': 'hello'},
        partOfSpeech: 'noun',
        reviewStatus: ReviewStatus.pendingReview,
        difficultyLevel: DifficultyLevel.beginner,
        lastUpdated: DateTime.now(),
        orthographyVariants: const [],
        exampleSentences: const [],
        tags: const [],
        metadata: const {},
        audioFileReferences: const [],
        qualityScore: 0.8,
      ),
      // Add more mock entries...
    ];
  }

  Future<void> _loadLessonsContent() async {
    // Simulate loading lessons
    await Future.delayed(const Duration(milliseconds: 500));

    _allLessons = [
      // Mock data - replace with actual repository calls
      LessonEntity(
        id: '1',
        title: 'Salutations en Ewondo',
        description: 'Apprendre les salutations de base',
        language: 'ewondo',
        difficulty: 'beginner',
        duration: 15,
        category: 'greetings',
        objectives: const ['Apprendre les salutations de base'],
        isPremium: false,
        order: 1,
        chapterId: 'chapter-1',
        exercises: const [],
        metadata: const {},
        createdAt: DateTime.now(),
      ),
      // Add more mock lessons...
    ];
  }

  Future<void> _loadUsersContent() async {
    // Simulate loading users
    await Future.delayed(const Duration(milliseconds: 500));

    _allUsers = [
      // Mock data - replace with actual repository calls
      UserEntity(
        id: '1',
        email: 'user@example.com',
        displayName: 'Utilisateur Test',
        role: 'learner',
        createdAt: DateTime.now(),
      ),
      // Add more mock users...
    ];
  }

  Future<void> _loadModerationContent() async {
    // Simulate loading moderation items
    await Future.delayed(const Duration(milliseconds: 500));

    _pendingModerations = [
      // Mock data - replace with actual repository calls
      ModerationItem(
        id: '1',
        type: ModerationItemType.dictionaryEntry,
        title: 'Nouvelle entrée: mbolo',
        description: 'Demande d\'ajout au dictionnaire',
        submittedBy: 'user123',
        submittedAt: DateTime.now(),
        priority: ModerationPriority.medium,
      ),
      // Add more mock items...
    ];
  }

  Future<void> _loadRecentActivities() async {
    // Simulate loading recent activities
    await Future.delayed(const Duration(milliseconds: 300));

    _recentActivities = [
      AdminActivity(
        id: '1',
        type: AdminActivityType.userRegistration,
        description: 'Nouvel utilisateur inscrit: Jean Dupont',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AdminActivity(
        id: '2',
        type: AdminActivityType.contentCreation,
        description: 'Nouvelle leçon créée: Salutations en Duala',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      // Add more mock activities...
    ];
  }

  Future<void> _loadStatistics() async {
    // Simulate loading statistics
    await Future.delayed(const Duration(milliseconds: 300));

    _contentStatistics = ContentStatistics(
      dictionaryEntries: _allDictionaryEntries.length,
      activeLessons: _allLessons.length,
      activeUsers: _allUsers.length,
      pendingModerations: _pendingModerations.length,
      dailyActiveUsers: 45,
      weeklyActiveUsers: 120,
      monthlyActiveUsers: 380,
    );
  }

  void _addActivity(AdminActivity activity) {
    _recentActivities.insert(0, activity);
    if (_recentActivities.length > 50) {
      _recentActivities = _recentActivities.take(50).toList();
    }
  }

  String _getDictionaryEntryTitle(String entryId) {
    final entry = _allDictionaryEntries.firstWhere(
      (entry) => entry.id == entryId,
      orElse: () => DictionaryEntryEntity(
        id: entryId,
        languageCode: '',
        canonicalForm: 'Entrée inconnue',
        translations: const {},
        partOfSpeech: 'noun',
        reviewStatus: ReviewStatus.pendingReview,
        difficultyLevel: DifficultyLevel.beginner,
        lastUpdated: DateTime.now(),
        orthographyVariants: const [],
        exampleSentences: const [],
        tags: const [],
        audioFileReferences: const [],
        qualityScore: 0.0,
        metadata: const {},
      ),
    );
    return entry.canonicalForm;
  }

  String _getLessonTitle(String lessonId) {
    final lesson = _allLessons.firstWhere(
      (lesson) => lesson.id == lessonId,
      orElse: () => LessonEntity(
        id: lessonId,
        title: 'Leçon inconnue',
        description: '',
        language: '',
        difficulty: '',
        duration: 0,
        category: '',
        objectives: const [],
        isPremium: false,
        order: 0,
        chapterId: '',
        exercises: const [],
        metadata: const {},
        createdAt: DateTime.now(),
      ),
    );
    return lesson.title;
  }

  String _getUserName(String userId) {
    final user = _allUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => UserEntity(
        id: userId,
        email: '',
        displayName: 'Utilisateur inconnu',
        role: '',
        createdAt: DateTime.now(),
      ),
    );
    return user.displayName ?? user.email;
  }

  Future<void> _setLoading(bool loading) async {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}

/// Admin activity model
class AdminActivity {
  final String id;
  final AdminActivityType type;
  final String description;
  final DateTime timestamp;

  AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

enum AdminActivityType {
  userRegistration,
  contentCreation,
  contentModeration,
  systemUpdate,
}

/// Content statistics model
class ContentStatistics {
  final int dictionaryEntries;
  final int activeLessons;
  final int activeUsers;
  final int pendingModerations;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;

  const ContentStatistics({
    required this.dictionaryEntries,
    required this.activeLessons,
    required this.activeUsers,
    required this.pendingModerations,
    required this.dailyActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
  });

  static ContentStatistics empty() {
    return const ContentStatistics(
      dictionaryEntries: 0,
      activeLessons: 0,
      activeUsers: 0,
      pendingModerations: 0,
      dailyActiveUsers: 0,
      weeklyActiveUsers: 0,
      monthlyActiveUsers: 0,
    );
  }
}

/// Moderation item model
class ModerationItem {
  final String id;
  final ModerationItemType type;
  final String title;
  final String description;
  final String submittedBy;
  final DateTime submittedAt;
  final ModerationPriority priority;

  const ModerationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.submittedBy,
    required this.submittedAt,
    required this.priority,
  });
}

enum ModerationItemType {
  dictionaryEntry,
  lesson,
  userContent,
  communityPost,
}

enum ModerationPriority {
  low,
  medium,
  high,
  critical,
}