import 'package:flutter/material.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../../authentication/domain/entities/user_entity.dart';

class DashboardViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  DashboardViewModel(this._authViewModel) {
    _authViewModel.addListener(_onAuthChanged);
  }

  UserEntity? get currentUser => _authViewModel.currentUser;
  String get userRole => currentUser?.role ?? 'learner';

  void _onAuthChanged() {
    notifyListeners();
  }

  // Dashboard data based on role
  Map<String, dynamic> getDashboardData() {
    // Check if user is guest (not authenticated)
    if (currentUser == null) {
      return _getGuestDashboardData();
    }

    switch (userRole) {
      case 'admin':
        return _getAdminDashboardData();
      case 'teacher':
      case 'instructor':
        return _getTeacherDashboardData();
      case 'learner':
      case 'student':
      default:
        return _getLearnerDashboardData();
    }
  }

  Map<String, dynamic> _getGuestDashboardData() {
    return {
      'title': 'Exploration Mayegue',
      'welcomeMessage': 'Bienvenue, Visiteur !',
      'subtitle': 'Découvrez les langues traditionnelles camerounaises en mode invité',
      'stats': [
        {'label': 'Langues disponibles', 'value': '6', 'icon': Icons.language, 'color': Colors.green},
        {'label': 'Leçons découvertes', 'value': '3', 'icon': Icons.menu_book, 'color': Colors.blue},
        {'label': 'Mots explorés', 'value': '25', 'icon': Icons.translate, 'color': Colors.orange},
        {'label': 'Temps passé', 'value': '15m', 'icon': Icons.timer, 'color': Colors.purple},
      ],
      'quickActions': [
        {'icon': Icons.explore, 'label': 'Explorer', 'route': '/guest-explore'},
        {'icon': Icons.translate, 'label': 'Dictionnaire', 'route': '/dictionary'},
        {'icon': Icons.menu_book, 'label': 'Leçons démo', 'route': '/demo-lessons'},
        {'icon': Icons.videogame_asset, 'label': 'Mini-jeux', 'route': '/guest-games'},
        {'icon': Icons.info, 'label': 'À propos', 'route': '/about'},
        {'icon': Icons.login, 'label': 'S\'inscrire', 'route': '/register'},
      ],
      'recentActivity': [
        {'icon': Icons.visibility, 'title': 'Mode invité activé', 'subtitle': 'Bienvenue ! Explorez nos fonctionnalités', 'color': Colors.green},
        {'icon': Icons.explore, 'title': 'Découvrez l\'Ewondo', 'subtitle': 'Commencez par les salutations', 'color': Colors.blue},
        {'icon': Icons.info, 'title': 'Fonctionnalités limitées', 'subtitle': 'Inscrivez-vous pour plus d\'options', 'color': Colors.orange},
        {'icon': Icons.star, 'title': 'Préservation culturelle', 'subtitle': 'Rejoignez notre mission', 'color': Colors.purple},
      ],
      'isGuest': true,
    };
  }

  Map<String, dynamic> _getLearnerDashboardData() {
    return {
      'title': 'Tableau de bord Apprenant',
      'welcomeMessage': 'Bienvenue ${currentUser?.displayName ?? 'Apprenant'} !',
      'subtitle': 'Continuez votre apprentissage des langues camerounaises',
      'stats': [
        {'label': 'Leçons complétées', 'value': '12', 'icon': Icons.menu_book, 'color': Colors.green},
        {'label': 'Mots appris', 'value': '245', 'icon': Icons.translate, 'color': Colors.blue},
        {'label': 'Score total', 'value': '1,850', 'icon': Icons.star, 'color': Colors.orange},
        {'label': 'Temps d\'étude', 'value': '24h', 'icon': Icons.timer, 'color': Colors.purple},
      ],
      'quickActions': [
        {'icon': Icons.menu_book, 'label': 'Leçons', 'route': '/lessons'},
        {'icon': Icons.translate, 'label': 'Dictionnaire', 'route': '/dictionary'},
        {'icon': Icons.videogame_asset, 'label': 'Jeux', 'route': '/games'},
        {'icon': Icons.forum, 'label': 'Communauté', 'route': '/community'},
        {'icon': Icons.smart_toy, 'label': 'IA Assistant', 'route': '/ai-assistant'},
        {'icon': Icons.assessment, 'label': 'Évaluations', 'route': '/assessments'},
      ],
      'recentActivity': [
        {'icon': Icons.menu_book, 'title': 'Leçon Ewondo 3 terminée', 'subtitle': 'Aujourd\'hui à 10:15', 'color': Colors.green},
        {'icon': Icons.videogame_asset, 'title': 'Jeu de vocabulaire joué', 'subtitle': 'Hier à 18:30', 'color': Colors.purple},
        {'icon': Icons.translate, 'title': '5 nouveaux mots favoris', 'subtitle': 'Hier à 14:05', 'color': Colors.orange},
        {'icon': Icons.emoji_events, 'title': 'Badge "Persévérant" débloqué', 'subtitle': 'Il y a 2 jours', 'color': Colors.yellow},
      ],
    };
  }

  Map<String, dynamic> _getTeacherDashboardData() {
    return {
      'title': 'Tableau de bord Enseignant',
      'welcomeMessage': 'Bienvenue ${currentUser?.displayName ?? 'Enseignant'} !',
      'subtitle': 'Gérez vos cours et suivez vos étudiants',
      'stats': [
        {'label': 'Étudiants actifs', 'value': '47', 'icon': Icons.people, 'color': Colors.blue},
        {'label': 'Leçons créées', 'value': '23', 'icon': Icons.menu_book, 'color': Colors.green},
        {'label': 'Évaluations', 'value': '156', 'icon': Icons.assessment, 'color': Colors.orange},
        {'label': 'Taux réussite', 'value': '87%', 'icon': Icons.trending_up, 'color': Colors.purple},
      ],
      'quickActions': [
        {'icon': Icons.add, 'label': 'Créer leçon', 'route': '/create-lesson'},
        {'icon': Icons.assessment, 'label': 'Évaluations', 'route': '/teacher-assessments'},
        {'icon': Icons.people, 'label': 'Étudiants', 'route': '/students'},
        {'icon': Icons.analytics, 'label': 'Statistiques', 'route': '/analytics'},
        {'icon': Icons.forum, 'label': 'Forum', 'route': '/teacher-forum'},
        {'icon': Icons.settings, 'label': 'Paramètres', 'route': '/settings'},
      ],
      'recentActivity': [
        {'icon': Icons.people, 'title': 'Marie a terminé leçon 5', 'subtitle': 'Il y a 30 min', 'color': Colors.green},
        {'icon': Icons.assessment, 'title': 'Nouvelle évaluation créée', 'subtitle': 'Aujourd\'hui à 09:15', 'color': Colors.blue},
        {'icon': Icons.message, 'title': 'Question de Jean', 'subtitle': 'Hier à 16:45', 'color': Colors.orange},
        {'icon': Icons.star, 'title': 'Note moyenne classe: 8.5/10', 'subtitle': 'Hier à 12:00', 'color': Colors.yellow},
      ],
    };
  }

  Map<String, dynamic> _getAdminDashboardData() {
    return {
      'title': 'Panneau d\'administration',
      'welcomeMessage': 'Bienvenue ${currentUser?.displayName ?? 'Administrateur'} !',
      'subtitle': 'Gérez la plateforme Mayegue',
      'stats': [
        {'label': 'Utilisateurs totaux', 'value': '1,247', 'icon': Icons.people, 'color': Colors.blue},
        {'label': 'Revenus mensuels', 'value': '2.4M FCFA', 'icon': Icons.euro, 'color': Colors.green},
        {'label': 'Contenu actif', 'value': '342', 'icon': Icons.library_books, 'color': Colors.orange},
        {'label': 'Taux rétention', 'value': '78%', 'icon': Icons.trending_up, 'color': Colors.purple},
      ],
      'quickActions': [
        {'icon': Icons.people, 'label': 'Gestion users', 'route': '/admin-users'},
        {'icon': Icons.library_books, 'label': 'Contenu', 'route': '/admin-content'},
        {'icon': Icons.analytics, 'label': 'Analytics', 'route': '/admin-analytics'},
        {'icon': Icons.payment, 'label': 'Paiements', 'route': '/admin-payments'},
        {'icon': Icons.report, 'label': 'Rapports', 'route': '/admin-reports'},
        {'icon': Icons.settings, 'label': 'Configuration', 'route': '/admin-settings'},
      ],
      'recentActivity': [
        {'icon': Icons.people, 'title': '150 nouveaux utilisateurs', 'subtitle': 'Cette semaine', 'color': Colors.green},
        {'icon': Icons.payment, 'title': 'Revenus: +15% ce mois', 'subtitle': 'Aujourd\'hui à 08:00', 'color': Colors.blue},
        {'icon': Icons.report, 'title': 'Rapport mensuel généré', 'subtitle': 'Hier à 23:00', 'color': Colors.orange},
        {'icon': Icons.warning, 'title': 'Maintenance serveur programmée', 'subtitle': 'Dans 2 jours', 'color': Colors.red},
      ],
    };
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthChanged);
    super.dispose();
  }
}
