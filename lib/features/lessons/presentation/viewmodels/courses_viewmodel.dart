import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/course_usecases.dart';

/// ViewModel for courses management
class CoursesViewModel extends ChangeNotifier {
  final GetCoursesUsecase getCoursesUsecase;
  final GetCoursesByLanguageUsecase getCoursesByLanguageUsecase;
  final GetCoursesByLevelUsecase getCoursesByLevelUsecase;
  final GetEnrolledCoursesUsecase getEnrolledCoursesUsecase;
  final EnrollInCourseUsecase enrollInCourseUsecase;
  final UnenrollFromCourseUsecase unenrollFromCourseUsecase;

  CoursesViewModel({
    required this.getCoursesUsecase,
    required this.getCoursesByLanguageUsecase,
    required this.getCoursesByLevelUsecase,
    required this.getEnrolledCoursesUsecase,
    required this.enrollInCourseUsecase,
    required this.unenrollFromCourseUsecase,
  });

  // State
  List<Course> _courses = [];
  List<Course> _enrolledCourses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedLanguage;
  String? _selectedLevel;

  // Getters
  List<Course> get courses => _courses;
  List<Course> get enrolledCourses => _enrolledCourses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedLevel => _selectedLevel;

  // Computed getters
  List<Course> get filteredCourses {
    List<Course> filtered = _courses;

    if (_selectedLanguage != null) {
      filtered = filtered
          .where((course) => course.languageCode == _selectedLanguage)
          .toList();
    }

    if (_selectedLevel != null) {
      filtered = filtered
          .where((course) => course.level.name == _selectedLevel)
          .toList();
    }

    return filtered;
  }

  List<String> get availableLanguages {
    return _courses.map((course) => course.languageCode).toSet().toList();
  }

  List<String> get availableLevels {
    return _courses.map((course) => course.level.name).toSet().toList();
  }

  /// Load all courses
  Future<void> loadCourses() async {
    _setLoading(true);
    _clearError();

    final result = await getCoursesUsecase();

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (courses) {
        _courses = courses;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Load enrolled courses for a user
  Future<void> loadEnrolledCourses(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getEnrolledCoursesUsecase(userId);

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (courses) {
        _enrolledCourses = courses;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Filter courses by language
  void setLanguageFilter(String? language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  /// Filter courses by level
  void setLevelFilter(String? level) {
    _selectedLevel = level;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedLanguage = null;
    _selectedLevel = null;
    notifyListeners();
  }

  /// Enroll in a course
  Future<bool> enrollInCourse(String userId, String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await enrollInCourseUsecase(userId, courseId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (success) {
        // Reload enrolled courses
        loadEnrolledCourses(userId);
        _setLoading(false);
        return true;
      },
    );
  }

  /// Unenroll from a course
  Future<bool> unenrollFromCourse(String userId, String courseId) async {
    _setLoading(true);
    _clearError();

    final result = await unenrollFromCourseUsecase(userId, courseId);

    return result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
        _setLoading(false);
        return false;
      },
      (success) {
        // Reload enrolled courses
        loadEnrolledCourses(userId);
        _setLoading(false);
        return true;
      },
    );
  }

  /// Check if user is enrolled in a course
  bool isEnrolled(String courseId) {
    return _enrolledCourses.any((course) => course.id == courseId);
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
      return 'Erreur de cache: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Erreur réseau: ${failure.message}';
    } else {
      return 'Une erreur s\'est produite: ${failure.message}';
    }
  }
}
