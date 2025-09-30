import 'package:flutter/material.dart';
import '../../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../features/authentication/domain/entities/user_entity.dart';

/// Base class for all dashboard ViewModels to reduce duplication
abstract class BaseDashboardViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;

  BaseDashboardViewModel(this.authViewModel) {
    authViewModel.addListener(_onAuthChanged);
  }

  /// Common properties across all dashboards
  UserEntity? get currentUser => authViewModel.currentUser;
  String get userRole => currentUser?.role ?? 'learner';
  bool get isAuthenticated => currentUser != null;
  String get displayName => currentUser?.displayName ?? 'Utilisateur';

  /// Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Common state management
  void _onAuthChanged() {
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Abstract methods to be implemented by specific dashboard ViewModels

  /// Get role-specific dashboard data
  Map<String, dynamic> getDashboardData();

  /// Get role-specific quick actions
  List<Map<String, dynamic>> getQuickActions();

  /// Get role-specific statistics
  List<Map<String, dynamic>> getStatistics();

  /// Get role-specific recent activity
  List<Map<String, dynamic>> getRecentActivity();

  /// Refresh dashboard data
  Future<void> refresh();

  /// Common dashboard actions
  void navigateToRoute(String route) {
    // Implementation would depend on navigation setup
    // This is a placeholder for navigation logic
  }

  /// Common utility methods
  String formatNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Color getStatColor(String type) {
    switch (type.toLowerCase()) {
      case 'users':
      case 'students':
      case 'learners':
        return Colors.blue;
      case 'lessons':
      case 'content':
        return Colors.green;
      case 'score':
      case 'revenue':
      case 'earnings':
        return Colors.orange;
      case 'progress':
      case 'retention':
      case 'success':
        return Colors.purple;
      case 'time':
      case 'duration':
        return Colors.indigo;
      case 'words':
      case 'vocabulary':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData getStatIcon(String type) {
    switch (type.toLowerCase()) {
      case 'users':
      case 'students':
      case 'learners':
        return Icons.people;
      case 'lessons':
      case 'content':
        return Icons.menu_book;
      case 'score':
      case 'points':
        return Icons.star;
      case 'revenue':
      case 'earnings':
        return Icons.attach_money;
      case 'progress':
      case 'retention':
        return Icons.trending_up;
      case 'time':
      case 'duration':
        return Icons.timer;
      case 'words':
      case 'vocabulary':
        return Icons.translate;
      case 'assessments':
      case 'evaluations':
        return Icons.assessment;
      case 'games':
        return Icons.videogame_asset;
      case 'ai':
      case 'artificial_intelligence':
        return Icons.smart_toy;
      default:
        return Icons.analytics;
    }
  }

  /// Common dashboard sections
  Widget buildStatCard(Map<String, dynamic> stat) {
    // This would return a common stat card widget
    // Implementation depends on UI framework
    throw UnimplementedError('Implement in specific dashboard view');
  }

  Widget buildQuickActionCard(Map<String, dynamic> action) {
    // This would return a common quick action card widget
    // Implementation depends on UI framework
    throw UnimplementedError('Implement in specific dashboard view');
  }

  Widget buildActivityItem(Map<String, dynamic> activity) {
    // This would return a common activity item widget
    // Implementation depends on UI framework
    throw UnimplementedError('Implement in specific dashboard view');
  }

  @override
  void dispose() {
    authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}

/// Mixin for dashboards that need real-time updates
mixin RealTimeUpdates on BaseDashboardViewModel {
  bool _realTimeEnabled = false;
  bool get realTimeEnabled => _realTimeEnabled;

  void enableRealTimeUpdates() {
    _realTimeEnabled = true;
    _startRealTimeUpdates();
  }

  void disableRealTimeUpdates() {
    _realTimeEnabled = false;
    _stopRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    // Implementation for starting real-time updates
    // Could use WebSocket, Firebase listeners, etc.
  }

  void _stopRealTimeUpdates() {
    // Implementation for stopping real-time updates
  }
}

/// Mixin for dashboards that need notification management
mixin NotificationManagement on BaseDashboardViewModel {
  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadNotificationCount =>
      _notifications.where((n) => !(n['isRead'] ?? false)).length;

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}