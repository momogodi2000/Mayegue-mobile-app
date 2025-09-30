/// Application constants
class AppConstants {
  static const String appName = 'Mayegue';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.mayegue.com';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String lessonsCollection = 'lessons';
  static const String languagesCollection = 'languages';
  static const String assessmentsCollection = 'assessments';
  static const String communityCollection = 'community';

  // User Roles
  static const String roleVisitor = 'visitor';
  static const String roleLearner = 'learner';
  static const String roleTeacher = 'teacher';
  static const String roleAdmin = 'admin';

  // Languages
  static const String languageEwondo = 'ewondo';
  static const String languageBafang = 'bafang';
  static const String languagePidginEnglish = 'pidgin';
  static const String languageDuala = 'duala';
  static const String languageFulfulde = 'fulfulde';
  static const String languageFrench = 'fr';
  static const String languageEnglish = 'en';

  // Levels
  static const String levelBeginner = 'beginner';
  static const String levelIntermediate = 'intermediate';
  static const String levelAdvanced = 'advanced';

  // Payment
  static const double premiumMonthlyPrice = 2500.0; // FCFA
  static const double premiumAnnualPrice = 25000.0; // FCFA
  static const double teacherPrice = 15000.0; // FCFA
}
