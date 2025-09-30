import 'package:flutter/foundation.dart';
import '../../../../core/constants/supported_languages.dart';

/// ViewModel for Student Dashboard
class StudentDashboardViewModel extends ChangeNotifier {
  // State
  bool _isLoading = false;
  String? _errorMessage;

  // Student Profile Data
  String _studentName = 'Étudiant Mayegue';
  String _email = 'etudiant@mayegue.com';
  String? _profilePicture;
  String _currentLevel = 'Débutant';
  int _totalExperience = 0;

  // Learning Progress Data
  double _overallProgress = 0.0;
  int _currentStreak = 0;
  int _streakGoal = 7;
  int _completedLessons = 0;
  int _gamesPlayed = 0;
  int _quizzesTaken = 0;

  // Language Learning Data
  List<String> _currentLearningLanguages = [];
  List<String> _completedLanguages = [];
  Map<String, double> _languageProgress = {};
  Map<String, int> _languageExperience = {};

  // Content Data
  List<Map<String, dynamic>> _availableLessons = [];
  List<Map<String, dynamic>> _availableGames = [];
  List<Map<String, dynamic>> _availableQuizzes = [];

  // Activity Data
  List<Map<String, dynamic>> _recentActivities = [];
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _notifications = [];

  // Settings
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _interfaceLanguage = 'Français';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // Profile Getters
  String get studentName => _studentName;
  String get email => _email;
  String? get profilePicture => _profilePicture;
  String get currentLevel => _currentLevel;
  int get totalExperience => _totalExperience;

  // Progress Getters
  double get overallProgress => _overallProgress;
  int get currentStreak => _currentStreak;
  int get streakGoal => _streakGoal;
  int get completedLessons => _completedLessons;
  int get gamesPlayed => _gamesPlayed;
  int get quizzesTaken => _quizzesTaken;

  // Language Getters
  List<String> get currentLearningLanguages => _currentLearningLanguages;
  List<String> get completedLanguages => _completedLanguages;
  Map<String, double> get languageProgress => _languageProgress;

  // Content Getters
  List<Map<String, dynamic>> get availableLessons => _availableLessons;
  List<Map<String, dynamic>> get availableGames => _availableGames;
  List<Map<String, dynamic>> get availableQuizzes => _availableQuizzes;

  // Activity Getters
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get notifications => _notifications;

  // Settings Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get interfaceLanguage => _interfaceLanguage;

  /// Load student dashboard data
  Future<void> loadStudentDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      await _loadStudentProfile();
      await _loadLearningProgress();
      await _loadLanguageData();
      await _loadContentData();
      await _loadActivityData();
      await _loadSettings();

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement du tableau de bord: $e');
    }

    _setLoading(false);
  }

  Future<void> _loadStudentProfile() async {
    _studentName = 'Jean Kamga';
    _email = 'jean.kamga@email.com';
    _profilePicture = null; // URL de l'image de profil si disponible
    _currentLevel = 'Intermédiaire';
    _totalExperience = 2485;
  }

  Future<void> _loadLearningProgress() async {
    _overallProgress = 67.5;
    _currentStreak = 12;
    _streakGoal = 30;
    _completedLessons = 45;
    _gamesPlayed = 23;
    _quizzesTaken = 18;
  }

  Future<void> _loadLanguageData() async {
    _currentLearningLanguages = ['ewondo', 'duala'];
    _completedLanguages = ['bafang'];

    _languageProgress = {
      'ewondo': 78.5,
      'duala': 45.2,
      'bafang': 100.0,
      'fulfulde': 0.0,
      'bassa': 0.0,
      'bamum': 0.0,
    };

    _languageExperience = {
      'ewondo': 1450,
      'duala': 680,
      'bafang': 2100,
      'fulfulde': 0,
      'bassa': 0,
      'bamum': 0,
    };
  }

  Future<void> _loadContentData() async {
    // Load available lessons
    _availableLessons = [
      {
        'id': 'lesson_ewondo_1',
        'title': 'Salutations en Ewondo',
        'description': 'Apprenez les salutations de base en langue Ewondo',
        'language': 'ewondo',
        'difficulty': 'Débutant',
        'duration': 15,
        'isCompleted': true,
        'isLocked': false,
        'progress': 100.0,
        'experience': 150,
      },
      {
        'id': 'lesson_ewondo_2',
        'title': 'Famille en Ewondo',
        'description': 'Vocabulaire familial et relations en Ewondo',
        'language': 'ewondo',
        'difficulty': 'Débutant',
        'duration': 20,
        'isCompleted': true,
        'isLocked': false,
        'progress': 100.0,
        'experience': 200,
      },
      {
        'id': 'lesson_ewondo_3',
        'title': 'Chiffres et Nombres',
        'description': 'Apprendre à compter en Ewondo',
        'language': 'ewondo',
        'difficulty': 'Intermédiaire',
        'duration': 18,
        'isCompleted': false,
        'isLocked': false,
        'progress': 65.0,
        'experience': 0,
      },
      {
        'id': 'lesson_duala_1',
        'title': 'Salutations en Duala',
        'description': 'Les premières expressions en langue Duala',
        'language': 'duala',
        'difficulty': 'Débutant',
        'duration': 15,
        'isCompleted': true,
        'isLocked': false,
        'progress': 100.0,
        'experience': 150,
      },
      {
        'id': 'lesson_duala_2',
        'title': 'Nourriture Traditionnelle',
        'description': 'Vocabulaire culinaire en Duala',
        'language': 'duala',
        'difficulty': 'Intermédiaire',
        'duration': 25,
        'isCompleted': false,
        'isLocked': false,
        'progress': 30.0,
        'experience': 0,
      },
      {
        'id': 'lesson_bafang_1',
        'title': 'Introduction au Bafang',
        'description': 'Découverte de la langue Bafang',
        'language': 'bafang',
        'difficulty': 'Débutant',
        'duration': 12,
        'isCompleted': false,
        'isLocked': true,
        'progress': 0.0,
        'experience': 0,
      },
    ];

    // Load available games
    _availableGames = [
      {
        'id': 'game_memory_1',
        'title': 'Mémoire des Mots',
        'description': 'Jeu de mémoire avec le vocabulaire appris',
        'language': 'all',
        'difficulty': 'Facile',
        'isUnlocked': true,
        'bestScore': 85,
        'timesPlayed': 12,
      },
      {
        'id': 'game_matching_1',
        'title': 'Association Mots-Images',
        'description': 'Associez les mots aux bonnes images',
        'language': 'ewondo',
        'difficulty': 'Facile',
        'isUnlocked': true,
        'bestScore': 92,
        'timesPlayed': 8,
      },
      {
        'id': 'game_pronunciation_1',
        'title': 'Défi Prononciation',
        'description': 'Testez votre prononciation avec l\'IA',
        'language': 'duala',
        'difficulty': 'Moyen',
        'isUnlocked': true,
        'bestScore': 76,
        'timesPlayed': 5,
      },
      {
        'id': 'game_story_1',
        'title': 'Conte Interactif',
        'description': 'Participez à un conte traditionnel',
        'language': 'ewondo',
        'difficulty': 'Difficile',
        'isUnlocked': false,
        'bestScore': 0,
        'timesPlayed': 0,
      },
    ];

    // Load available quizzes
    _availableQuizzes = [
      {
        'id': 'quiz_ewondo_basic',
        'title': 'Quiz Ewondo - Base',
        'description': 'Testez vos connaissances de base en Ewondo',
        'language': 'ewondo',
        'questionCount': 15,
        'timeLimit': 10,
        'difficulty': 'Débutant',
        'isCompleted': true,
        'bestScore': 87.5,
        'attempts': 3,
      },
      {
        'id': 'quiz_duala_family',
        'title': 'Quiz Famille Duala',
        'description': 'Vocabulaire familial en Duala',
        'language': 'duala',
        'questionCount': 12,
        'timeLimit': 8,
        'difficulty': 'Débutant',
        'isCompleted': true,
        'bestScore': 91.7,
        'attempts': 2,
      },
      {
        'id': 'quiz_mixed_advanced',
        'title': 'Quiz Mélangé Avancé',
        'description': 'Quiz difficile mélangeant plusieurs langues',
        'language': 'mixed',
        'questionCount': 25,
        'timeLimit': 20,
        'difficulty': 'Avancé',
        'isCompleted': false,
        'bestScore': 0.0,
        'attempts': 0,
      },
    ];
  }

  Future<void> _loadActivityData() async {
    // Load recent activities
    _recentActivities = [
      {
        'id': '1',
        'type': 'lesson_completed',
        'title': 'Leçon terminée',
        'description': 'Famille en Ewondo terminée avec 95% de réussite',
        'time': 'Il y a 2 heures',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'experience': 200,
      },
      {
        'id': '2',
        'type': 'game_played',
        'title': 'Nouveau record!',
        'description': 'Record battu au jeu Mémoire des Mots (92 points)',
        'time': 'Il y a 5 heures',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'experience': 150,
      },
      {
        'id': '3',
        'type': 'streak_maintained',
        'title': 'Série maintenue',
        'description': '12 jours consécutifs d\'apprentissage!',
        'time': 'Aujourd\'hui',
        'timestamp': DateTime.now(),
        'experience': 100,
      },
      {
        'id': '4',
        'type': 'achievement_earned',
        'title': 'Achievement débloqué',
        'description': 'Maître du Quiz - 10 quiz terminés',
        'time': 'Hier',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'experience': 300,
      },
    ];

    // Load achievements
    _achievements = [
      {
        'id': 'first_lesson',
        'title': 'Première Leçon',
        'description': 'Terminer votre première leçon',
        'type': 'first_lesson',
        'earnedAt': DateTime.now().subtract(const Duration(days: 30)),
        'experience': 100,
      },
      {
        'id': 'streak_week',
        'title': 'Série Hebdomadaire',
        'description': '7 jours consécutifs d\'apprentissage',
        'type': 'streak_master',
        'earnedAt': DateTime.now().subtract(const Duration(days: 5)),
        'experience': 250,
      },
      {
        'id': 'quiz_master',
        'title': 'Maître du Quiz',
        'description': 'Terminer 10 quiz avec succès',
        'type': 'quiz_champion',
        'earnedAt': DateTime.now().subtract(const Duration(days: 1)),
        'experience': 300,
      },
      {
        'id': 'game_enthusiast',
        'title': 'Passionné de Jeux',
        'description': 'Jouer 20 parties de jeu',
        'type': 'game_master',
        'earnedAt': DateTime.now().subtract(const Duration(days: 7)),
        'experience': 200,
      },
      {
        'id': 'language_explorer',
        'title': 'Explorateur Linguistique',
        'description': 'Commencer l\'apprentissage de 2 langues',
        'type': 'language_explorer',
        'earnedAt': DateTime.now().subtract(const Duration(days: 15)),
        'experience': 400,
      },
    ];

    // Load notifications
    _notifications = [
      {
        'id': '1',
        'title': 'Nouvelle leçon disponible!',
        'message': 'La leçon "Contes Ewondo" est maintenant disponible',
        'time': 'Il y a 1 heure',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'type': 'content',
        'isRead': false,
      },
      {
        'id': '2',
        'title': 'Maintenez votre série!',
        'message': 'Vous avez 12 jours de série. Continuez aujourd\'hui!',
        'time': 'Il y a 3 heures',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'type': 'reminder',
        'isRead': false,
      },
      {
        'id': '3',
        'title': 'Nouveau défi hebdomadaire',
        'message': 'Défi de la semaine: Terminer 5 leçons en Duala',
        'time': 'Hier',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'type': 'challenge',
        'isRead': true,
      },
    ];
  }

  Future<void> _loadSettings() async {
    _notificationsEnabled = true;
    _darkModeEnabled = false;
    _interfaceLanguage = 'Français';
  }

  /// Get progress for a specific language
  double getLanguageProgress(String languageCode) {
    return _languageProgress[languageCode] ?? 0.0;
  }

  /// Get experience for a specific language
  int getLanguageExperience(String languageCode) {
    return _languageExperience[languageCode] ?? 0;
  }

  /// Get lessons for a specific language
  List<Map<String, dynamic>> getLessonsByLanguage(String languageCode) {
    return _availableLessons
        .where((lesson) => lesson['language'] == languageCode)
        .toList();
  }

  /// Get games for a specific language
  List<Map<String, dynamic>> getGamesByLanguage(String languageCode) {
    return _availableGames
        .where((game) => game['language'] == languageCode || game['language'] == 'all')
        .toList();
  }

  /// Get quizzes for a specific language
  List<Map<String, dynamic>> getQuizzesByLanguage(String languageCode) {
    return _availableQuizzes
        .where((quiz) => quiz['language'] == languageCode || quiz['language'] == 'mixed')
        .toList();
  }

  /// Start learning a new language
  Future<bool> startLearningLanguage(String languageCode) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      if (!_currentLearningLanguages.contains(languageCode)) {
        _currentLearningLanguages.add(languageCode);
        _languageProgress[languageCode] = 0.0;
        _languageExperience[languageCode] = 0;

        // Add activity
        _recentActivities.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'language_started',
          'title': 'Nouvelle langue',
          'description': 'Apprentissage de ${SupportedLanguages.getDisplayName(languageCode)} commencé',
          'time': 'Maintenant',
          'timestamp': DateTime.now(),
          'experience': 50,
        });

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors du démarrage de l\'apprentissage: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Stop learning a language
  Future<bool> stopLearningLanguage(String languageCode) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _currentLearningLanguages.remove(languageCode);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'arrêt de l\'apprentissage: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete a lesson
  Future<bool> completeLesson(String lessonId, double score) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final lessonIndex = _availableLessons.indexWhere((lesson) => lesson['id'] == lessonId);
      if (lessonIndex != -1) {
        final lesson = _availableLessons[lessonIndex];
        lesson['isCompleted'] = true;
        lesson['progress'] = 100.0;

        final experience = ((lesson['experience'] ?? 0) as num).toInt();
        final languageCode = lesson['language'];

        // Update progress
        _completedLessons++;
        _totalExperience += experience;
        _languageExperience[languageCode] = (_languageExperience[languageCode] ?? 0) + experience;

        // Update language progress
        final currentProgress = _languageProgress[languageCode] ?? 0.0;
        _languageProgress[languageCode] = (currentProgress + 5.0).clamp(0.0, 100.0);

        // Add activity
        _recentActivities.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'lesson_completed',
          'title': 'Leçon terminée',
          'description': '${lesson['title']} terminée avec ${score.toStringAsFixed(0)}% de réussite',
          'time': 'Maintenant',
          'timestamp': DateTime.now(),
          'experience': experience,
        });

        // Update streak
        _updateStreak();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors de la completion de la leçon: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Play a game and update score
  Future<bool> playGame(String gameId, int score) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final gameIndex = _availableGames.indexWhere((game) => game['id'] == gameId);
      if (gameIndex != -1) {
        final game = _availableGames[gameIndex];
        final currentBest = game['bestScore'] ?? 0;

        game['timesPlayed'] = (game['timesPlayed'] ?? 0) + 1;

        if (score > currentBest) {
          game['bestScore'] = score;

          // Add activity for new record
          _recentActivities.insert(0, {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'type': 'game_played',
            'title': 'Nouveau record!',
            'description': 'Record battu au jeu ${game['title']} ($score points)',
            'time': 'Maintenant',
            'timestamp': DateTime.now(),
            'experience': 100,
          });

          _totalExperience += 100;
        }

        _gamesPlayed++;
        _updateStreak();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors du jeu: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Take a quiz and update score
  Future<bool> takeQuiz(String quizId, double score) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final quizIndex = _availableQuizzes.indexWhere((quiz) => quiz['id'] == quizId);
      if (quizIndex != -1) {
        final quiz = _availableQuizzes[quizIndex];
        final currentBest = quiz['bestScore']?.toDouble() ?? 0.0;

        quiz['attempts'] = (quiz['attempts'] ?? 0) + 1;
        quiz['isCompleted'] = true;

        if (score > currentBest) {
          quiz['bestScore'] = score;
        }

        // Calculate experience based on score
        final experience = (score * 2).round();
        _totalExperience += experience;

        // Add activity
        _recentActivities.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'type': 'quiz_taken',
          'title': 'Quiz terminé',
          'description': '${quiz['title']} terminé avec ${score.toStringAsFixed(0)}%',
          'time': 'Maintenant',
          'timestamp': DateTime.now(),
          'experience': experience,
        });

        _quizzesTaken++;
        _updateStreak();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Erreur lors du quiz: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update daily streak
  void _updateStreak() {
    // Simulate streak update logic
    final now = DateTime.now();
    final lastActivity = DateTime.now(); // Should come from stored data

    if (_isSameDay(now, lastActivity)) {
      // Same day, streak continues
    } else if (_isConsecutiveDay(now, lastActivity)) {
      // Next day, increment streak
      _currentStreak++;

      // Add streak activity
      _recentActivities.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'streak_maintained',
        'title': 'Série maintenue',
        'description': '$_currentStreak jours consécutifs d\'apprentissage!',
        'time': 'Maintenant',
        'timestamp': DateTime.now(),
        'experience': 50,
      });

      _totalExperience += 50;
    } else {
      // Streak broken, reset
      _currentStreak = 1;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isConsecutiveDay(DateTime current, DateTime previous) {
    final difference = current.difference(previous).inDays;
    return difference == 1;
  }

  /// Toggle notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Toggle dark mode
  void toggleDarkMode(bool enabled) {
    _darkModeEnabled = enabled;
    notifyListeners();
  }

  /// Change interface language
  void changeInterfaceLanguage(String language) {
    _interfaceLanguage = language == 'fr' ? 'Français' : 'English';
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (name != null) _studentName = name;
      if (email != null) _email = email;
      if (profilePicture != null) _profilePicture = profilePicture;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour du profil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mark notification as read
  void markNotificationAsRead(String notificationId) {
    final notificationIndex = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (notificationIndex != -1) {
      _notifications[notificationIndex]['isRead'] = true;
      notifyListeners();
    }
  }

  /// Get unread notifications count
  int get unreadNotificationsCount {
    return _notifications.where((n) => !(n['isRead'] ?? true)).length;
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadStudentDashboard();
  }

  /// Logout
  void logout() {
    // Clear all data
    _studentName = '';
    _email = '';
    _profilePicture = null;
    _currentLevel = 'Débutant';
    _totalExperience = 0;
    _overallProgress = 0.0;
    _currentStreak = 0;
    _completedLessons = 0;
    _gamesPlayed = 0;
    _quizzesTaken = 0;
    _currentLearningLanguages = [];
    _completedLanguages = [];
    _languageProgress = {};
    _languageExperience = {};
    _availableLessons = [];
    _availableGames = [];
    _availableQuizzes = [];
    _recentActivities = [];
    _achievements = [];
    _notifications = [];
    _errorMessage = null;

    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}