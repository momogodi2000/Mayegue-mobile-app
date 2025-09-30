/// Enumeration of user roles in the application
enum UserRole {
  visitor,
  learner,
  teacher,
  admin;

  /// Display name for the role
  String get displayName {
    switch (this) {
      case UserRole.visitor:
        return 'Visiteur';
      case UserRole.learner:
        return 'Apprenant';
      case UserRole.teacher:
        return 'Enseignant';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  /// Description of the role's capabilities
  String get description {
    switch (this) {
      case UserRole.visitor:
        return 'Accès limité aux contenus gratuits';
      case UserRole.learner:
        return 'Accès complet aux leçons et outils d\'apprentissage';
      case UserRole.teacher:
        return 'Création de contenu et gestion des apprenants';
      case UserRole.admin:
        return 'Administration complète de la plateforme';
    }
  }

  /// Check if this role has permission to perform an action
  bool hasPermission(Permission permission) {
    return _permissions[this]?.contains(permission) ?? false;
  }

  /// Get all permissions for this role
  Set<Permission> get permissions => _permissions[this] ?? {};

  /// Check if this role can access a specific feature
  bool canAccess(Feature feature) {
    return _featureAccess[this]?.contains(feature) ?? false;
  }

  /// Get default dashboard route for this role
  String get defaultDashboardRoute {
    switch (this) {
      case UserRole.visitor:
        return '/guest-dashboard';
      case UserRole.learner:
        return '/dashboard';
      case UserRole.teacher:
        return '/teacher-dashboard';
      case UserRole.admin:
        return '/admin-dashboard';
    }
  }

  /// Check if this role requires authentication
  bool get requiresAuthentication {
    return this != UserRole.visitor;
  }

  /// Check if this role requires subscription
  bool get requiresSubscription {
    return this == UserRole.learner || this == UserRole.teacher;
  }

  /// Get the navigation items for this role
  List<NavigationItem> get navigationItems {
    return _navigationItems[this] ?? [];
  }
}

/// Extension for converting strings to UserRole
extension UserRoleExtension on UserRole {
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'visitor':
        return UserRole.visitor;
      case 'learner':
      case 'student':
        return UserRole.learner;
      case 'teacher':
      case 'instructor':
        return UserRole.teacher;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      default:
        return UserRole.learner; // Default fallback
    }
  }

  String get value {
    return toString().split('.').last;
  }
}

/// Permissions that can be granted to roles
enum Permission {
  // Content permissions
  viewLessons,
  createLessons,
  editLessons,
  deleteLessons,

  // Dictionary permissions
  viewDictionary,
  addDictionaryEntries,
  editDictionaryEntries,
  deleteDictionaryEntries,
  reviewDictionaryEntries,

  // Assessment permissions
  takeAssessments,
  createAssessments,
  viewAssessmentResults,

  // Community permissions
  participateInCommunity,
  moderateCommunity,

  // AI permissions
  useAiAssistant,
  configureAiSettings,

  // Admin permissions
  manageUsers,
  viewAnalytics,
  systemConfiguration,
  contentModeration,

  // Games permissions
  playGames,
  createGames,

  // Payment permissions
  processPayments,
  viewPaymentHistory,
}

/// Features that can be accessed by roles
enum Feature {
  lessons,
  dictionary,
  games,
  community,
  assessments,
  aiAssistant,
  analytics,
  userManagement,
  contentCreation,
  paymentManagement,
}

/// Navigation item for role-based menus
class NavigationItem {
  final String title;
  final String route;
  final String icon;
  final List<NavigationItem>? children;

  NavigationItem({
    required this.title,
    required this.route,
    required this.icon,
    this.children,
  });
}

/// Permission mapping for each role
const Map<UserRole, Set<Permission>> _permissions = {
  UserRole.visitor: {
    Permission.viewLessons, // Limited access
    Permission.viewDictionary, // Read-only
  },

  UserRole.learner: {
    Permission.viewLessons,
    Permission.viewDictionary,
    Permission.takeAssessments,
    Permission.viewAssessmentResults,
    Permission.participateInCommunity,
    Permission.useAiAssistant,
    Permission.playGames,
    Permission.viewPaymentHistory,
  },

  UserRole.teacher: {
    // All learner permissions plus:
    Permission.viewLessons,
    Permission.createLessons,
    Permission.editLessons,
    Permission.viewDictionary,
    Permission.addDictionaryEntries,
    Permission.editDictionaryEntries,
    Permission.reviewDictionaryEntries,
    Permission.takeAssessments,
    Permission.createAssessments,
    Permission.viewAssessmentResults,
    Permission.participateInCommunity,
    Permission.moderateCommunity,
    Permission.useAiAssistant,
    Permission.configureAiSettings,
    Permission.playGames,
    Permission.createGames,
    Permission.viewPaymentHistory,
  },

  UserRole.admin: {
    // All permissions
    ...Permission.values,
  },
};

/// Feature access mapping for each role
const Map<UserRole, Set<Feature>> _featureAccess = {
  UserRole.visitor: {
    Feature.lessons, // Limited
    Feature.dictionary, // Read-only
  },

  UserRole.learner: {
    Feature.lessons,
    Feature.dictionary,
    Feature.games,
    Feature.community,
    Feature.assessments,
    Feature.aiAssistant,
  },

  UserRole.teacher: {
    Feature.lessons,
    Feature.dictionary,
    Feature.games,
    Feature.community,
    Feature.assessments,
    Feature.aiAssistant,
    Feature.analytics, // Limited
    Feature.contentCreation,
  },

  UserRole.admin: {
    // All features
    ...Feature.values,
  },
};

/// Navigation items for each role
final Map<UserRole, List<NavigationItem>> _navigationItems = {
  UserRole.visitor: [
    NavigationItem(
      title: 'Explorer',
      route: '/explore',
      icon: 'explore',
    ),
    NavigationItem(
      title: 'Connexion',
      route: '/login',
      icon: 'login',
    ),
  ],

  UserRole.learner: [
    NavigationItem(
      title: 'Tableau de bord',
      route: '/dashboard',
      icon: 'dashboard',
    ),
    NavigationItem(
      title: 'Leçons',
      route: '/lessons',
      icon: 'school',
    ),
    NavigationItem(
      title: 'Dictionnaire',
      route: '/dictionary',
      icon: 'book',
    ),
    NavigationItem(
      title: 'Jeux',
      route: '/games',
      icon: 'games',
    ),
    NavigationItem(
      title: 'Communauté',
      route: '/community',
      icon: 'people',
    ),
    NavigationItem(
      title: 'Assistant IA',
      route: '/ai',
      icon: 'smart_toy',
    ),
    NavigationItem(
      title: 'Profil',
      route: '/profile',
      icon: 'person',
    ),
  ],

  UserRole.teacher: [
    NavigationItem(
      title: 'Tableau de bord',
      route: '/teacher-dashboard',
      icon: 'dashboard',
    ),
    NavigationItem(
      title: 'Mes leçons',
      route: '/teacher/lessons',
      icon: 'school',
    ),
    NavigationItem(
      title: 'Dictionnaire',
      route: '/teacher/dictionary',
      icon: 'book',
      children: [
        NavigationItem(
          title: 'Consulter',
          route: '/dictionary',
          icon: 'search',
        ),
        NavigationItem(
          title: 'Réviser',
          route: '/teacher/dictionary/review',
          icon: 'rate_review',
        ),
        NavigationItem(
          title: 'Ajouter',
          route: '/teacher/dictionary/add',
          icon: 'add',
        ),
      ],
    ),
    NavigationItem(
      title: 'Évaluations',
      route: '/teacher/assessments',
      icon: 'quiz',
    ),
    NavigationItem(
      title: 'Mes élèves',
      route: '/teacher/students',
      icon: 'group',
    ),
    NavigationItem(
      title: 'Communauté',
      route: '/community',
      icon: 'people',
    ),
    NavigationItem(
      title: 'Statistiques',
      route: '/teacher/analytics',
      icon: 'analytics',
    ),
    NavigationItem(
      title: 'Profil',
      route: '/profile',
      icon: 'person',
    ),
  ],

  UserRole.admin: [
    NavigationItem(
      title: 'Administration',
      route: '/admin-dashboard',
      icon: 'admin_panel_settings',
    ),
    NavigationItem(
      title: 'Utilisateurs',
      route: '/admin/users',
      icon: 'people',
    ),
    NavigationItem(
      title: 'Contenu',
      route: '/admin/content',
      icon: 'content_copy',
      children: [
        NavigationItem(
          title: 'Leçons',
          route: '/admin/content/lessons',
          icon: 'school',
        ),
        NavigationItem(
          title: 'Dictionnaire',
          route: '/admin/content/dictionary',
          icon: 'book',
        ),
        NavigationItem(
          title: 'Jeux',
          route: '/admin/content/games',
          icon: 'games',
        ),
      ],
    ),
    NavigationItem(
      title: 'Modération',
      route: '/admin/moderation',
      icon: 'gavel',
    ),
    NavigationItem(
      title: 'Paiements',
      route: '/admin/payments',
      icon: 'payment',
    ),
    NavigationItem(
      title: 'Analytics',
      route: '/admin/analytics',
      icon: 'analytics',
    ),
    NavigationItem(
      title: 'Configuration',
      route: '/admin/settings',
      icon: 'settings',
    ),
  ],
};

/// Helper class for role-based access control
class RoleManager {
  /// Check if a user role has permission to perform an action
  static bool hasPermission(UserRole role, Permission permission) {
    return role.hasPermission(permission);
  }

  /// Check if a user role can access a specific feature
  static bool canAccess(UserRole role, Feature feature) {
    return role.canAccess(feature);
  }

  /// Get the appropriate dashboard route for a role
  static String getDashboardRoute(UserRole role) {
    return role.defaultDashboardRoute;
  }

  /// Get navigation items for a role
  static List<NavigationItem> getNavigationItems(UserRole role) {
    return role.navigationItems;
  }

  /// Check if a role is higher than another (for hierarchical permissions)
  static bool isRoleHigher(UserRole role1, UserRole role2) {
    const roleHierarchy = {
      UserRole.visitor: 0,
      UserRole.learner: 1,
      UserRole.teacher: 2,
      UserRole.admin: 3,
    };

    return (roleHierarchy[role1] ?? 0) > (roleHierarchy[role2] ?? 0);
  }

  /// Get all roles that have a specific permission
  static List<UserRole> getRolesWithPermission(Permission permission) {
    return UserRole.values.where((role) => role.hasPermission(permission)).toList();
  }

  /// Get all roles that can access a specific feature
  static List<UserRole> getRolesWithFeatureAccess(Feature feature) {
    return UserRole.values.where((role) => role.canAccess(feature)).toList();
  }
}