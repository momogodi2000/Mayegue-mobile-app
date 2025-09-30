import 'package:flutter/material.dart';
import '../../../../features/languages/domain/entities/language_entity.dart';
import '../../../../features/lessons/domain/entities/lesson_entity.dart';

/// ViewModel for Guest Dashboard
class GuestDashboardViewModel extends ChangeNotifier {
  List<LanguageEntity> _featuredLanguages = [];
  List<LessonEntity> _demoLessons = [];
  bool _isLoading = false;

  List<LanguageEntity> get featuredLanguages => _featuredLanguages;
  List<LessonEntity> get demoLessons => _demoLessons;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load featured languages
      _featuredLanguages = [
        LanguageEntity(
          id: 'ewondo',
          name: 'Ewondo',
          group: 'Beti-Pahuin',
          region: 'Central',
          type: 'Primary',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LanguageEntity(
          id: 'dualala',
          name: 'Duala',
          group: 'Coastal Bantu',
          region: 'Littoral',
          type: 'Commercial',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LanguageEntity(
          id: 'feefe',
          name: 'Fe\'efe\'e',
          group: 'Grassfields',
          region: 'West',
          type: 'Heritage',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Load demo lessons
      _demoLessons = [
        LessonEntity(
          id: 'demo-1',
          title: 'Greetings in Ewondo',
          description: 'Learn basic greetings',
          language: 'ewondo',
          difficulty: 'Beginner',
          duration: 10,
          category: 'Basics',
          objectives: const ['Learn basic greetings'],
          isPremium: false,
          order: 1,
          chapterId: 'chapter-1',
          exercises: const [],
          metadata: const {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        LessonEntity(
          id: 'demo-2',
          title: 'Numbers in Duala',
          description: 'Count from 1 to 10',
          language: 'dualala',
          difficulty: 'Beginner',
          duration: 15,
          category: 'Basics',
          objectives: const ['Learn numbers 1-10'],
          isPremium: false,
          order: 1,
          chapterId: 'chapter-1',
          exercises: const [],
          metadata: const {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLanguage(String languageId) {
    // Navigate to language selection
  }

  void startDemoLesson(String lessonId) {
    // Navigate to demo lesson
  }

  void navigateToSignUp() {
    // Navigate to sign up
  }
}
