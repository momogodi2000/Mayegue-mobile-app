/// API endpoints configuration
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.mayegue.com';
  static const String campayBaseUrl = 'https://api.campay.net';
  static const String noupaiBaseUrl = 'https://api.noupai.com';

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User
  static const String getUser = '/users/me';
  static const String updateUser = '/users/me';
  static const String deleteUser = '/users/me';

  // Lessons
  static const String getLessons = '/lessons';
  static const String getLesson = '/lessons/{id}';
  static const String createLesson = '/lessons';
  static const String updateLesson = '/lessons/{id}';
  static const String deleteLesson = '/lessons/{id}';

  // Assessments
  static const String getAssessments = '/assessments';
  static const String submitAssessment = '/assessments/{id}/submit';
  static const String getResults = '/assessments/results';

  // Dictionary
  static const String searchDictionary = '/dictionary/search';
  static const String getWord = '/dictionary/{id}';

  // AI
  static const String aiChat = '/ai/chat';
  static const String aiPronunciation = '/ai/pronunciation';

  // Payments
  static const String processPayment = '/payments/process';
  static const String getPaymentHistory = '/payments/history';
  static const String campayWebhook = '/payments/campay/webhook';

  // Community
  static const String getForums = '/community/forums';
  static const String getForum = '/community/forums/{id}';
  static const String createDiscussion = '/community/discussions';
  static const String sendMessage = '/community/messages';

  // Analytics
  static const String getAnalytics = '/analytics/user';
  static const String getDashboard = '/analytics/dashboard';

  // Helper method to replace path parameters
  static String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
