import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../domain/entities/onboarding_entity.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import '../../domain/usecases/get_onboarding_status_usecase.dart';

/// Onboarding view model
class OnboardingViewModel extends ChangeNotifier {
  final CompleteOnboardingUsecase completeOnboardingUsecase;
  final GetOnboardingStatusUsecase getOnboardingStatusUsecase;

  OnboardingViewModel({
    required this.completeOnboardingUsecase,
    required this.getOnboardingStatusUsecase,
  });

  // State
  bool _isLoading = false;
  String? _errorMessage;
  bool _isCompleted = false;
  int _currentStep = 0;
  String _selectedLanguage = 'ewondo'; // Default to Ewondo
  String _userName = '';
  String? _learningGoal;
  String? _experienceLevel;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _microphonePermissionGranted = false;
  bool _cameraPermissionGranted = false;
  bool _storagePermissionGranted = false;

  final List<String> learningGoals = [
    'Communiquer avec ma famille',
    'Préserver ma culture',
    'Voyager au Cameroun',
    'Comprendre les médias locaux',
    'Enrichir mes connaissances',
    'Autre'
  ];

  final List<String> experienceLevels = [
    'Débutant complet',
    'Quelques mots connus',
    'Niveau conversationnel',
    'Avancé'
  ];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isCompleted => _isCompleted;
  int get currentStep => _currentStep;
  String get selectedLanguage => _selectedLanguage;
  String get userName => _userName;
  String? get learningGoal => _learningGoal;
  String? get experienceLevel => _experienceLevel;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get microphonePermissionGranted => _microphonePermissionGranted;
  bool get cameraPermissionGranted => _cameraPermissionGranted;
  bool get storagePermissionGranted => _storagePermissionGranted;
  bool get canProceed => _canProceedFromCurrentStep();

  // Total steps in onboarding
  static const int totalSteps = 6;

  // Step titles
  List<String> get stepTitles => [
        'Bienvenue',
        'Choisissez votre langue',
        'Vos objectifs',
        'Votre niveau',
        'Préférences',
        'Prêt à commencer !'
      ];

  // Step descriptions
  List<String> get stepDescriptions => [
        'Découvrez Mayegue, votre compagnon d\'apprentissage des langues camerounaises.',
        'Sélectionnez la langue que vous souhaitez apprendre.',
        'Qu\'est-ce qui vous motive à apprendre cette langue ?',
        'Quel est votre niveau actuel dans cette langue ?',
        'Personnalisez votre expérience d\'apprentissage.',
        'Votre aventure linguistique commence maintenant !'
      ];

  // Initialize onboarding
  Future<void> initialize() async {
    _setLoading(true);
    _clearError();

    final result = await getOnboardingStatusUsecase(const NoParams());

    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
      },
      (isCompleted) {
        _isCompleted = isCompleted;
        _setLoading(false);
        notifyListeners();
      },
    );
  }

  // Navigate to next step
  void nextStep() {
    if (_currentStep < totalSteps - 1 && canProceed) {
      _currentStep++;
      _trackStepView();
      notifyListeners();
    }
  }

  // Navigate to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _trackStepView();
      notifyListeners();
    }
  }

  // Set current step
  void setCurrentStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      _trackStepView();
      notifyListeners();
    }
  }

  // Set selected language
  void setSelectedLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();

    AppMonitoring().logEvent('onboarding_language_selected', parameters: {
      'language': language,
      'language_name': SupportedLanguages.getDisplayName(language),
    });
  }

  // Set user name
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // Set learning goal
  void setLearningGoal(String goal) {
    _learningGoal = goal;
    notifyListeners();

    AppMonitoring().logEvent('onboarding_goal_selected', parameters: {
      'goal': goal,
    });
  }

  // Set experience level
  void setExperienceLevel(String level) {
    _experienceLevel = level;
    notifyListeners();

    AppMonitoring().logEvent('onboarding_experience_selected', parameters: {
      'experience_level': level,
    });
  }

  // Toggle notifications
  void toggleNotifications(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  // Toggle sound
  void toggleSound(bool enabled) {
    _soundEnabled = enabled;
    notifyListeners();
  }

  // Complete onboarding
  Future<bool> completeOnboarding() async {
    _setLoading(true);
    _clearError();

    try {
      // Save onboarding data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      await prefs.setString('selected_language', _selectedLanguage);
      await prefs.setString('learning_goal', _learningGoal ?? '');
      await prefs.setString('experience_level', _experienceLevel ?? '');
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setBool('sound_enabled', _soundEnabled);

      // Request notification permissions if enabled
      if (_notificationsEnabled) {
        await NotificationService().initialize();
      }

      final onboardingData = OnboardingEntity(
        selectedLanguage: _selectedLanguage,
        userName: _userName,
        notificationsEnabled: _notificationsEnabled,
        soundEnabled: _soundEnabled,
        completedAt: DateTime.now(),
      );

      final result = await completeOnboardingUsecase(onboardingData);

      return result.fold(
        (failure) {
          _setError(_mapFailureToMessage(failure));
          _setLoading(false);
          return false;
        },
        (_) {
          _isCompleted = true;
          _setLoading(false);

          // Track onboarding completion
          AppMonitoring().logEvent('onboarding_completed', parameters: {
            'selected_language': _selectedLanguage,
            'learning_goal': _learningGoal,
            'experience_level': _experienceLevel,
            'notifications_enabled': _notificationsEnabled,
            'sound_enabled': _soundEnabled,
          });

          // Set user properties
          AppMonitoring().setUserProperties(
            customProperties: {
              'primary_language': _selectedLanguage,
              'learning_goal': _learningGoal ?? '',
              'experience_level': _experienceLevel ?? '',
            },
          );

          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Erreur lors de la finalisation: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // Skip onboarding
  Future<bool> skipOnboarding() async {
    _setLoading(true);
    _clearError();

    final onboardingData = OnboardingEntity(
      selectedLanguage: 'ewondo', // Default
      userName: '',
      notificationsEnabled: true,
      soundEnabled: true,
      completedAt: DateTime.now(),
    );

    final result = await completeOnboardingUsecase(onboardingData);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (_) {
        _isCompleted = true;
        _setLoading(false);
        notifyListeners();
        return true;
      },
    );
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

  String _mapFailureToMessage(Failure failure) {
    if (failure is CacheFailure) {
      return 'Erreur de sauvegarde: ${failure.message}';
    } else {
      return 'Une erreur s\'est produite: ${failure.message}';
    }
  }

  // Permission methods
  Future<void> requestMicrophonePermission() async {
    // TODO: Implement permission request using PermissionService
    _microphonePermissionGranted = true; // Mock for now
    notifyListeners();
  }

  Future<void> requestCameraPermission() async {
    // TODO: Implement permission request
    _cameraPermissionGranted = true; // Mock for now
    notifyListeners();
  }

  Future<void> requestStoragePermission() async {
    // TODO: Implement permission request
    _storagePermissionGranted = true; // Mock for now
    notifyListeners();
  }

  // Check if current step can proceed
  bool _canProceedFromCurrentStep() {
    switch (_currentStep) {
      case 0: // Welcome
        return true;
      case 1: // Language selection
        return _selectedLanguage.isNotEmpty;
      case 2: // Learning goals
        return _learningGoal != null;
      case 3: // Experience level
        return _experienceLevel != null;
      case 4: // Preferences
        return true;
      case 5: // Completion
        return _canCompleteOnboarding();
      default:
        return false;
    }
  }

  bool _canCompleteOnboarding() {
    return _selectedLanguage.isNotEmpty &&
        _learningGoal != null &&
        _experienceLevel != null;
  }

  void _trackStepView() {
    AppMonitoring().logScreenView(
      'onboarding_step_$_currentStep',
      screenClass: 'OnboardingView',
    );
  }

  // Static helper methods
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  static Future<Map<String, dynamic>> getOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'selected_language': prefs.getString('selected_language'),
      'learning_goal': prefs.getString('learning_goal'),
      'experience_level': prefs.getString('experience_level'),
      'notifications_enabled': prefs.getBool('notifications_enabled') ?? true,
      'sound_enabled': prefs.getBool('sound_enabled') ?? true,
    };
  }
}
