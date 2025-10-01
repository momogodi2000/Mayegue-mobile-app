import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ViewModel for Admin Dashboard
class AdminDashboardViewModel extends ChangeNotifier {
  // Dependencies
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  // State
  bool _isLoading = false;
  String? _errorMessage;
  final String _adminName = 'Admin Principal';
  final String _adminRole = 'Super Admin';

  // Firestore subscriptions
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  StreamSubscription<QuerySnapshot>? _moderationQueueSubscription;

  // System Overview Data
  Map<String, dynamic> _systemHealth = {};
  Map<String, dynamic> _overviewStats = {};
  List<Map<String, dynamic>> _recentSystemActivities = [];
  Map<String, dynamic> _performanceMetrics = {};

  // User Management Data
  List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _userRoles = [];
  Map<String, int> _userStatistics = {};
  final List<Map<String, dynamic>> _recentUserActions = [];

  // Content Management Data
  List<Map<String, dynamic>> _content = [];
  Map<String, int> _contentStatistics = {};
  List<Map<String, dynamic>> _pendingContent = [];
  final List<Map<String, dynamic>> _reportedContent = [];

  // Financial Data
  Map<String, dynamic> _financialOverview = {};
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _subscriptions = [];
  Map<String, dynamic> _revenue = {};

  // System Management Data
  Map<String, dynamic> _systemConfig = {};
  List<Map<String, dynamic>> _systemLogs = [];
  Map<String, dynamic> _maintenanceSchedule = {};
  List<Map<String, dynamic>> _backups = [];

  // Reports Data
  List<Map<String, dynamic>> _availableReports = [];
  Map<String, dynamic> _reportAnalytics = {};

  // Constructor
  AdminDashboardViewModel([FirebaseAuth? auth, FirebaseFirestore? firestore]) {
    _auth = auth ?? FirebaseAuth.instance;
    _firestore = firestore ?? FirebaseFirestore.instance;
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  String get adminName => _adminName;
  String get adminRole => _adminRole;

  // System Overview Getters
  Map<String, dynamic> get systemHealth => _systemHealth;
  Map<String, dynamic> get overviewStats => _overviewStats;
  List<Map<String, dynamic>> get recentSystemActivities =>
      _recentSystemActivities;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;

  // User Management Getters
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get userRoles => _userRoles;
  Map<String, int> get userStatistics => _userStatistics;
  List<Map<String, dynamic>> get recentUserActions => _recentUserActions;

  // Content Management Getters
  List<Map<String, dynamic>> get content => _content;
  Map<String, int> get contentStatistics => _contentStatistics;
  List<Map<String, dynamic>> get pendingContent => _pendingContent;
  List<Map<String, dynamic>> get reportedContent => _reportedContent;

  // Financial Getters
  Map<String, dynamic> get financialOverview => _financialOverview;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get subscriptions => _subscriptions;
  Map<String, dynamic> get revenue => _revenue;

  // System Management Getters
  Map<String, dynamic> get systemConfig => _systemConfig;
  List<Map<String, dynamic>> get systemLogs => _systemLogs;
  Map<String, dynamic> get maintenanceSchedule => _maintenanceSchedule;
  List<Map<String, dynamic>> get backups => _backups;

  // Reports Getters
  List<Map<String, dynamic>> get availableReports => _availableReports;
  Map<String, dynamic> get reportAnalytics => _reportAnalytics;

  // Additional Getters for View
  int get alertsCount => _overviewStats['systemAlerts'] ?? 0;
  int get totalUsers => _overviewStats['totalUsers'] ?? 0;
  int get activeUsers => _overviewStats['activeUsers'] ?? 0;
  int get newUsersToday => _overviewStats['newUsersToday'] ?? 0;
  int get bannedUsersCount => _userStatistics['banned'] ?? 0;
  int get pendingModerationCount => _pendingContent.length;
  int get reportedContentCount => _reportedContent.length;
  int get totalContent => _overviewStats['totalContent'] ?? 0;
  int get approvedContent =>
      _content.where((c) => c['status'] == 'published').length;
  double get monthlyRevenue =>
      (_overviewStats['monthlyRevenue'] ?? 0).toDouble();
  double get yearlyRevenue => (_overviewStats['totalRevenue'] ?? 0).toDouble();
  int get totalLessons => _contentStatistics['lessonsCount'] ?? 0;
  int get totalGames => _contentStatistics['gamesCount'] ?? 0;
  int get totalTeachers => _userStatistics['teachers'] ?? 0;
  int get weeklyActiveUsers => (_overviewStats['activeUsers'] ?? 0) ~/ 7;
  double get retentionRate => 85.5; // Mock
  int get studentsCount => _userStatistics['students'] ?? 0;
  int get teachersCount => _userStatistics['teachers'] ?? 0;
  int get moderatorsCount => _userStatistics['moderators'] ?? 0;
  int get adminsCount => _userStatistics['admins'] ?? 0;
  List<Map<String, dynamic>> get recentAdminActivities =>
      _recentSystemActivities;

  // System Health Getters
  String get serverStatus => _systemHealth['server']?['status'] ?? 'unknown';
  String get databaseStatus =>
      _systemHealth['database']?['status'] ?? 'unknown';
  String get cacheStatus => 'healthy'; // Mock
  double get storageUsage {
    final used = _systemHealth['storage']?['used'] ?? '0%';
    final percentage = double.tryParse(used.replaceAll('%', '')) ?? 0.0;
    return percentage / 100.0; // Convert to decimal
  }

  // Calculate overall system health score (0.0 to 1.0)
  double get systemHealthScore {
    int healthyCount = 0;
    int totalCount = 0;

    // Check server status
    if (_systemHealth['server']?['status'] == 'healthy') healthyCount++;
    totalCount++;

    // Check database status
    if (_systemHealth['database']?['status'] == 'healthy') healthyCount++;
    totalCount++;

    // Check API status
    if (_systemHealth['api']?['status'] == 'healthy') healthyCount++;
    totalCount++;

    // Check storage status (warning is still acceptable)
    final storageStatus = _systemHealth['storage']?['status'];
    if (storageStatus == 'healthy' || storageStatus == 'warning') {
      healthyCount++;
    }
    totalCount++;

    return totalCount > 0 ? healthyCount / totalCount : 0.0;
  }

  /// Load admin dashboard data
  Future<void> loadAdminDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.delayed(const Duration(milliseconds: 2000));

      await _loadSystemOverview();
      await _loadUserManagementData();
      await _loadContentManagementData();
      await _loadFinancialData();
      await _loadSystemManagementData();
      await _loadReportsData();

      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement du tableau de bord admin: $e');
    }

    _setLoading(false);
  }

  /// User Management Functions
  Future<bool> updateUserRole(String userId, String newRole) async {
    _setLoading(true);
    _clearError();
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      final idx = _users.indexWhere((u) => u['id'] == userId);
      if (idx != -1) {
        _users[idx] = {..._users[idx], 'role': newRole};
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur maj rôle: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setUserActive(String userId, bool isActive) async {
    _setLoading(true);
    _clearError();
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });

      final idx = _users.indexWhere((u) => u['id'] == userId);
      if (idx != -1) {
        _users[idx] = {
          ..._users[idx],
          'status': isActive ? 'active' : 'suspended',
        };
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur maj statut: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAdminAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'displayName': displayName,
        'role': 'admin',
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isSuperAdmin': false,
        'permissions': [
          'manage_users',
          'manage_content',
          'manage_teachers',
          'view_analytics',
        ],
      });
      await _loadUserManagementData();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur création admin: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createTeacherAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid == null) {
        throw Exception('Utilisateur non authentifié');
      }
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'displayName': displayName,
        'role': 'teacher',
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': currentUid,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isApproved': true,
        'permissions': [
          'create_content',
          'edit_own_content',
          'view_students',
          'grade_assignments',
        ],
      });
      await _loadUserManagementData();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur création enseignant: $e');
      return false;
    } finally {
      _setLoading(false);
    }
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

  // Private methods
  Future<void> _loadSystemOverview() async {
    _systemHealth = {
      'server': {
        'status': 'healthy',
        'uptime': '99.9%',
        'lastCheck': DateTime.now(),
      },
      'database': {
        'status': 'healthy',
        'connections': 45,
        'lastBackup': DateTime.now().subtract(const Duration(hours: 2)),
      },
      'api': {
        'status': 'healthy',
        'responseTime': '125ms',
        'requestsPerSecond': 342,
      },
      'storage': {'status': 'warning', 'used': '78%', 'totalSpace': '2TB'},
    };

    _overviewStats = {
      'totalUsers': 15847,
      'activeUsers': 12634,
      'newUsersToday': 156,
      'totalContent': 2847,
      'pendingReviews': 23,
      'totalRevenue': 485600,
      'monthlyRevenue': 45800,
      'systemAlerts': 3,
    };

    _performanceMetrics = {
      'cpuUsage': 67.5,
      'memoryUsage': 78.2,
      'diskUsage': 45.8,
      'networkTraffic': 2.4,
      'activeConnections': 1245,
      'averageResponseTime': 185,
    };

    _recentSystemActivities = [
      {
        'id': '1',
        'type': 'user_registration',
        'description': 'Nouveau utilisateur inscrit: marie.fotso@email.com',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'severity': 'info',
      },
      {
        'id': '2',
        'type': 'content_published',
        'description': 'Nouvelle leçon publiée: "Salutations Bamum"',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
        'severity': 'info',
      },
      {
        'id': '3',
        'type': 'system_alert',
        'description': 'Espace disque faible (78% utilisé)',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
        'severity': 'warning',
      },
      {
        'id': '4',
        'type': 'payment_processed',
        'description': 'Paiement CamPay traité: 15,000 XAF',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'severity': 'success',
      },
      {
        'id': '5',
        'type': 'backup_completed',
        'description': 'Sauvegarde automatique terminée',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'severity': 'success',
      },
    ];
  }

  Future<void> _loadUserManagementData() async {
    // Cancel any existing subscription
    await _usersSubscription?.cancel();

    // Subscribe to users collection
    _usersSubscription = _firestore
        .collection('users')
        .limit(1000)
        .snapshots()
        .listen((snapshot) {
          _users = snapshot.docs.map((d) {
            final data = d.data();
            return {
              'id': d.id,
              'uid': data['uid'] ?? d.id,
              'name': data['displayName'] ?? '',
              'email': data['email'] ?? '',
              'role': (data['role'] ?? 'learner').toString(),
              'status': (data['isActive'] == false) ? 'suspended' : 'active',
              'registrationDate': (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              'lastActivity': (data['lastLoginAt'] is Timestamp)
                  ? (data['lastLoginAt'] as Timestamp).toDate()
                  : null,
              'permissions': data['permissions'] ?? [],
            };
          }).toList();

          // Compute statistics
          final total = _users.length;
          final active = _users.where((u) => u['status'] == 'active').length;
          final students = _users
              .where((u) => (u['role'] == 'learner' || u['role'] == 'student'))
              .length;
          final teachers = _users.where((u) => (u['role'] == 'teacher')).length;
          final admins = _users.where((u) => (u['role'] == 'admin')).length;
          final banned = _users.where((u) => u['status'] == 'suspended').length;

          _userStatistics = {
            'totalUsers': total,
            'activeUsers': active,
            'studentsCount': students,
            'teachersCount': teachers,
            'adminsCount': admins,
            'moderatorsCount': 0,
            'banned': banned,
          };

          notifyListeners();
        });
  }

  Future<void> _loadContentManagementData() async {
    // Cancel any existing subscriptions
    await _moderationQueueSubscription?.cancel();

    // Subscribe to published content
    final contentSnap = await _firestore
        .collection('public_content')
        .doc('lessons')
        .collection('items')
        .limit(50)
        .get();
    _content = contentSnap.docs
        .map(
          (d) => {
            'id': d.id,
            'title': d.data()['title'] ?? '',
            'type': 'lesson',
            'language': d.data()['languageCode'] ?? '',
            'status': (d.data()['isPublic'] == true) ? 'published' : 'draft',
            'author': d.data()['addedBy'] ?? 'admin',
            'createdAt':
                DateTime.tryParse(d.data()['addedAt'] ?? '') ?? DateTime.now(),
          },
        )
        .toList();

    _contentStatistics = {
      'totalContent': 2847,
      'publishedContent': 2756,
      'draftContent': 67,
      'pendingReview': 23,
      'reportedContent': 1,
      'lessonsCount': 1456,
      'gamesCount': 789,
      'quizzesCount': 567,
      'mediaCount': 35,
    };

    // Subscribe to moderation queue
    _moderationQueueSubscription = _firestore
        .collection('moderation_queue')
        .where('status', isEqualTo: 'pending')
        .limit(50)
        .snapshots()
        .listen((snapshot) {
          _pendingContent = snapshot.docs.map((d) {
            final data = d.data();
            return {
              'id': d.id,
              'title': data['title'] ?? 'Pending content',
              'type': data['type'] ?? 'content',
              'author': data['submittedBy'] ?? 'unknown',
              'submittedAt': (data['submittedAt'] is Timestamp)
                  ? (data['submittedAt'] as Timestamp).toDate()
                  : DateTime.now(),
              'language': data['languageCode'] ?? '',
              'reviewRequired': true,
              'reason': data['reason'] ?? 'Pending review',
              'priority': data['priority'] ?? 'low',
            };
          }).toList();
          notifyListeners();
        });
  }

  Future<void> _loadFinancialData() async {
    _financialOverview = {
      'totalRevenue': 485600,
      'monthlyRevenue': 45800,
      'weeklyRevenue': 12450,
      'dailyRevenue': 1850,
      'activeSubscriptions': 8456,
      'pendingPayments': 156,
      'refunds': 23,
      'averageRevenuePerUser': 57.4,
    };

    _transactions = [
      {
        'id': 'txn_1',
        'userId': 'user_123',
        'userName': 'Jean Kamga',
        'amount': 15000,
        'currency': 'XAF',
        'type': 'subscription',
        'method': 'campay',
        'status': 'completed',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'description': 'Abonnement Premium mensuel',
      },
      {
        'id': 'txn_2',
        'userId': 'user_456',
        'userName': 'Marie Fotso',
        'amount': 5000,
        'currency': 'XAF',
        'type': 'course',
        'method': 'noupai',
        'status': 'completed',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'description': 'Cours Duala Avancé',
      },
      {
        'id': 'txn_3',
        'userId': 'user_789',
        'userName': 'Paul Mbarga',
        'amount': 25000,
        'currency': 'XAF',
        'type': 'subscription',
        'method': 'campay',
        'status': 'pending',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'description': 'Abonnement Professionnel',
      },
    ];

    _subscriptions = [
      {
        'id': 'sub_1',
        'userId': 'user_123',
        'userName': 'Jean Kamga',
        'plan': 'premium',
        'status': 'active',
        'startDate': DateTime.now().subtract(const Duration(days: 15)),
        'endDate': DateTime.now().add(const Duration(days: 15)),
        'amount': 15000,
        'renewals': 3,
      },
      {
        'id': 'sub_2',
        'userId': 'user_456',
        'userName': 'Marie Fotso',
        'plan': 'basic',
        'status': 'active',
        'startDate': DateTime.now().subtract(const Duration(days: 8)),
        'endDate': DateTime.now().add(const Duration(days: 22)),
        'amount': 8000,
        'renewals': 1,
      },
    ];

    _revenue = {
      'monthly': [
        {'month': 'Jan', 'amount': 425000},
        {'month': 'Fév', 'amount': 445000},
        {'month': 'Mar', 'amount': 467000},
        {'month': 'Avr', 'amount': 485600},
      ],
      'byPaymentMethod': {'campay': 65.4, 'noupai': 28.7, 'bank_transfer': 5.9},
      'bySubscriptionType': {
        'premium': 45.2,
        'basic': 32.1,
        'professional': 15.8,
        'enterprise': 6.9,
      },
    };
  }

  Future<void> _loadSystemManagementData() async {
    _systemConfig = {
      'appVersion': '1.2.3',
      'databaseVersion': '2.1.0',
      'apiVersion': '3.4.1',
      'maintenanceMode': false,
      'debugMode': false,
      'maxUsers': 50000,
      'currentUsers': 15847,
      'backupFrequency': 'daily',
      'logLevel': 'info',
    };

    _systemLogs = [
      {
        'id': 'log_1',
        'level': 'info',
        'message': 'User login: jean.kamga@email.com',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
        'source': 'auth_service',
      },
      {
        'id': 'log_2',
        'level': 'warning',
        'message': 'High CPU usage detected: 85%',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'source': 'system_monitor',
      },
      {
        'id': 'log_3',
        'level': 'error',
        'message': 'Payment processing failed for user_456',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'source': 'payment_service',
      },
    ];

    _maintenanceSchedule = {
      'nextMaintenance': DateTime.now().add(const Duration(days: 7)),
      'lastMaintenance': DateTime.now().subtract(const Duration(days: 23)),
      'scheduledTasks': [
        {
          'task': 'Database optimization',
          'scheduledFor': DateTime.now().add(const Duration(days: 2)),
          'estimatedDuration': '2 heures',
        },
        {
          'task': 'Server updates',
          'scheduledFor': DateTime.now().add(const Duration(days: 7)),
          'estimatedDuration': '4 heures',
        },
      ],
    };

    _backups = [
      {
        'id': 'backup_1',
        'type': 'full',
        'status': 'completed',
        'size': '2.4 GB',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'location': 'cloud_storage',
      },
      {
        'id': 'backup_2',
        'type': 'incremental',
        'status': 'completed',
        'size': '156 MB',
        'createdAt': DateTime.now().subtract(const Duration(hours: 26)),
        'location': 'local_storage',
      },
    ];
  }

  Future<void> _loadReportsData() async {
    _availableReports = [
      {
        'id': 'report_users',
        'name': 'Rapport Utilisateurs',
        'description': 'Analyse détaillée des utilisateurs actifs',
        'category': 'users',
        'lastGenerated': DateTime.now().subtract(const Duration(hours: 6)),
        'frequency': 'daily',
      },
      {
        'id': 'report_content',
        'name': 'Rapport Contenu',
        'description': 'Statistiques de contenu et engagement',
        'category': 'content',
        'lastGenerated': DateTime.now().subtract(const Duration(hours: 12)),
        'frequency': 'weekly',
      },
      {
        'id': 'report_financial',
        'name': 'Rapport Financier',
        'description': 'Revenus et transactions détaillés',
        'category': 'financial',
        'lastGenerated': DateTime.now().subtract(const Duration(days: 1)),
        'frequency': 'monthly',
      },
      {
        'id': 'report_performance',
        'name': 'Rapport Performance',
        'description': 'Métriques système et performance',
        'category': 'system',
        'lastGenerated': DateTime.now().subtract(const Duration(hours: 3)),
        'frequency': 'hourly',
      },
    ];

    _reportAnalytics = {
      'totalReportsGenerated': 1247,
      'mostRequestedReport': 'report_users',
      'averageGenerationTime': '45 seconds',
      'reportsGeneratedToday': 23,
      'scheduledReports': 12,
    };
  }

  // Missing methods for admin dashboard view
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await _loadUserManagementData();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _users = _users.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return name.contains(searchQuery) || email.contains(searchQuery);
      }).toList();
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterUsers(String filter) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (filter == 'all') {
        await _loadUserManagementData();
      } else {
        _users = _users.where((user) {
          final role = user['role']?.toString() ?? '';
          return role == filter;
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors du filtrage: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> performModeration(String contentId, String action) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the content in pending or reported lists
      final pendingIndex = _pendingContent.indexWhere(
        (content) => content['id'] == contentId,
      );
      final reportedIndex = _reportedContent.indexWhere(
        (content) => content['id'] == contentId,
      );

      Map<String, dynamic>? targetContent;
      if (pendingIndex != -1) {
        targetContent = _pendingContent[pendingIndex];
        _pendingContent.removeAt(pendingIndex);
      } else if (reportedIndex != -1) {
        targetContent = _reportedContent[reportedIndex];
        _reportedContent.removeAt(reportedIndex);
      }

      if (targetContent != null) {
        if (action == 'approve') {
          targetContent['status'] = 'published';
          targetContent['moderatedAt'] = DateTime.now();
          _content.add(targetContent);
        } else if (action == 'reject') {
          targetContent['status'] = 'rejected';
          targetContent['moderatedAt'] = DateTime.now();
        }

        // Update Firestore
        await _firestore.collection('content').doc(contentId).update({
          'status': targetContent['status'],
          'moderatedAt': targetContent['moderatedAt'],
          'moderatedBy': _adminName,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la modération: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshSystemStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadSystemOverview();
      await _loadSystemManagementData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getContentCountForLanguage(String languageCode) {
    return _content.where((content) {
      final contentLanguage = content['language']?.toString() ?? '';
      return contentLanguage == languageCode;
    }).length;
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    _moderationQueueSubscription?.cancel();
    super.dispose();
  }
}
