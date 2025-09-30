import 'package:hive/hive.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course.dart';
import '../models/course_model.dart';

/// Abstract data source for course operations
abstract class CourseDataSource {
  Future<List<CourseModel>> getCourses();
  Future<List<CourseModel>> getCoursesByLanguage(String language);
  Future<List<CourseModel>> getCoursesByLevel(String level);
  Future<CourseModel> getCourseById(String courseId);
  Future<List<CourseModel>> getEnrolledCourses(String userId);
  Future<bool> enrollInCourse(String userId, String courseId);
  Future<bool> unenrollFromCourse(String userId, String courseId);
  Future<bool> updateCourseProgress(String courseId, int completedLessons);
}

/// Local data source implementation using Hive
class CourseLocalDataSource implements CourseDataSource {
  static const String _coursesBoxName = 'courses';
  static const String _enrollmentsBoxName = 'course_enrollments';

  late Box<CourseModel> _coursesBox;
  late Box<List<String>> _enrollmentsBox;

  Future<void> initialize() async {
    _coursesBox = await Hive.openBox<CourseModel>(_coursesBoxName);
    _enrollmentsBox = await Hive.openBox<List<String>>(_enrollmentsBoxName);

    // Initialize with sample data if empty
    if (_coursesBox.isEmpty) {
      await _initializeSampleData();
    }
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();

    final sampleCourses = [
      CourseModel(
        id: 'ewondo-basics-1',
        title: 'Ewondo Basics - Part 1',
        description:
            'Learn the fundamentals of Ewondo language including basic greetings, numbers, and essential vocabulary.',
        languageCode: 'ewondo',
        thumbnailUrl: 'assets/images/courses/ewondo_basics.jpg',
        lessons: const [],
        estimatedDuration: 120,
        level: CourseLevel.beginner,
        status: CourseStatus.published,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        id: 'ewondo-conversation-1',
        title: 'Everyday Ewondo Conversations',
        description:
            'Master common conversation patterns and phrases used in daily Ewondo communication.',
        languageCode: 'ewondo',
        thumbnailUrl: 'assets/images/courses/ewondo_conversation.jpg',
        lessons: const [],
        estimatedDuration: 180,
        level: CourseLevel.intermediate,
        status: CourseStatus.published,
        createdAt: now,
        updatedAt: now,
      ),
      CourseModel(
        id: 'bafang-basics-1',
        title: 'Bafang Language Fundamentals',
        description:
            'Introduction to Bafang language with focus on pronunciation, basic grammar, and cultural context.',
        languageCode: 'bafang',
        thumbnailUrl: 'assets/images/courses/bafang_basics.jpg',
        lessons: const [],
        estimatedDuration: 150,
        level: CourseLevel.beginner,
        status: CourseStatus.published,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final course in sampleCourses) {
      await _coursesBox.put(course.id, course);
    }
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      return _coursesBox.values.toList();
    } catch (e) {
      throw CacheFailure('Failed to load courses: $e');
    }
  }

  @override
  Future<List<CourseModel>> getCoursesByLanguage(String language) async {
    try {
      return _coursesBox.values
          .where((course) => course.languageCode == language)
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to load courses by language: $e');
    }
  }

  @override
  Future<List<CourseModel>> getCoursesByLevel(String level) async {
    try {
      return _coursesBox.values
          .where((course) => course.level.name == level)
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to load courses by level: $e');
    }
  }

  @override
  Future<CourseModel> getCourseById(String courseId) async {
    try {
      final course = _coursesBox.get(courseId);
      if (course == null) {
        throw CacheFailure('Course not found: $courseId');
      }
      return course;
    } catch (e) {
      throw CacheFailure('Failed to load course: $e');
    }
  }

  @override
  Future<List<CourseModel>> getEnrolledCourses(String userId) async {
    try {
      final enrolledCourseIds = _enrollmentsBox.get(userId) ?? [];
      final enrolledCourses = <CourseModel>[];

      for (final courseId in enrolledCourseIds) {
        final course = _coursesBox.get(courseId);
        if (course != null) {
          enrolledCourses.add(course);
        }
      }

      return enrolledCourses;
    } catch (e) {
      throw CacheFailure('Failed to load enrolled courses: $e');
    }
  }

  @override
  Future<bool> enrollInCourse(String userId, String courseId) async {
    try {
      final enrolledCourseIds = _enrollmentsBox.get(userId) ?? [];
      if (!enrolledCourseIds.contains(courseId)) {
        enrolledCourseIds.add(courseId);
        await _enrollmentsBox.put(userId, enrolledCourseIds);
      }
      return true;
    } catch (e) {
      throw CacheFailure('Failed to enroll in course: $e');
    }
  }

  @override
  Future<bool> unenrollFromCourse(String userId, String courseId) async {
    try {
      final enrolledCourseIds = _enrollmentsBox.get(userId) ?? [];
      enrolledCourseIds.remove(courseId);
      await _enrollmentsBox.put(userId, enrolledCourseIds);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to unenroll from course: $e');
    }
  }

  @override
  Future<bool> updateCourseProgress(
      String courseId, int completedLessons) async {
    try {
      final course = _coursesBox.get(courseId);
      if (course == null) {
        throw CacheFailure('Course not found: $courseId');
      }

      final updatedCourse = CourseModel(
        id: course.id,
        title: course.title,
        description: course.description,
        languageCode: course.languageCode,
        thumbnailUrl: course.thumbnailUrl,
        lessons: course.lessons,
        estimatedDuration: course.estimatedDuration,
        level: course.level,
        status: course.status,
        createdAt: course.createdAt,
        updatedAt: DateTime.now(),
      );

      await _coursesBox.put(courseId, updatedCourse);
      return true;
    } catch (e) {
      throw CacheFailure('Failed to update course progress: $e');
    }
  }
}
