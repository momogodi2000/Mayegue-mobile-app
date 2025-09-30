import 'package:flutter/material.dart';

/// A reusable widget for displaying user guides in different dashboards
class UserGuideWidget extends StatelessWidget {
  final String role;
  final String title;
  final List<GuideSection> sections;

  const UserGuideWidget({
    super.key,
    required this.role,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getRoleIcon(role), color: _getRoleColor(role), size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getRoleColor(role),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showDetailedGuide(context),
                  tooltip: 'Guide détaillé',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sections.map((section) => _buildSection(context, section)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, GuideSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.icon, color: _getRoleColor(role), size: 20),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            section.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (section.steps.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...section.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getRoleColor(role),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'teacher':
        return Icons.school;
      case 'student':
      case 'learner':
        return Icons.person;
      default:
        return Icons.help;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.indigo;
      case 'student':
      case 'learner':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void _showDetailedGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Guide Utilisateur - $title'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ...sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            section.icon,
                            color: _getRoleColor(role),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            section.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (section.steps.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...section.steps.asMap().entries.map((entry) {
                          final index = entry.key;
                          final step = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(role),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    step,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

/// Data class for guide sections
class GuideSection {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  const GuideSection({
    required this.title,
    required this.description,
    required this.icon,
    this.steps = const [],
  });
}

/// Predefined guide sections for different roles
class UserGuideSections {
  static List<GuideSection> getAdminGuide() {
    return [
      const GuideSection(
        title: 'Gestion des Utilisateurs',
        description:
            'Administrez les comptes utilisateurs et leurs permissions.',
        icon: Icons.people,
        steps: [
          'Accédez à l\'onglet "Utilisateurs"',
          'Recherchez un utilisateur par nom ou email',
          'Cliquez sur un utilisateur pour voir ses détails',
          'Modifiez les permissions ou bannissez si nécessaire',
        ],
      ),
      const GuideSection(
        title: 'Modération du Contenu',
        description:
            'Contrôlez et validez le contenu créé par les utilisateurs.',
        icon: Icons.content_paste,
        steps: [
          'Vérifiez l\'onglet "Contenu" pour les éléments en attente',
          'Examinez le contenu signalé par les utilisateurs',
          'Approuvez ou rejetez le contenu selon les règles',
          'Communiquez avec les créateurs si nécessaire',
        ],
      ),
      const GuideSection(
        title: 'Surveillance du Système',
        description:
            'Surveillez la santé et les performances de la plateforme.',
        icon: Icons.monitor,
        steps: [
          'Consultez l\'onglet "Système" pour les métriques',
          'Vérifiez les alertes système',
          'Effectuez des sauvegardes régulières',
          'Planifiez la maintenance si nécessaire',
        ],
      ),
      const GuideSection(
        title: 'Gestion Financière',
        description: 'Surveillez les revenus et les paiements.',
        icon: Icons.account_balance,
        steps: [
          'Consultez l\'onglet "Finances" pour les revenus',
          'Vérifiez les transactions et abonnements',
          'Gérez les remboursements si nécessaire',
          'Exportez les rapports financiers',
        ],
      ),
    ];
  }

  static List<GuideSection> getTeacherGuide() {
    return [
      const GuideSection(
        title: 'Création de Contenu',
        description:
            'Créez des leçons, jeux et évaluations pour vos étudiants.',
        icon: Icons.add_circle,
        steps: [
          'Utilisez l\'onglet "Contenu" pour créer du nouveau matériel',
          'Choisissez le type de contenu (leçon, jeu, quiz)',
          'Sélectionnez la langue cible',
          'Ajoutez du texte, images et audio',
          'Publiez le contenu pour vos étudiants',
        ],
      ),
      const GuideSection(
        title: 'Suivi des Étudiants',
        description: 'Surveillez les progrès et performances de vos étudiants.',
        icon: Icons.track_changes,
        steps: [
          'Accédez à l\'onglet "Étudiants"',
          'Consultez les statistiques de progression',
          'Identifiez les étudiants en difficulté',
          'Envoyez des encouragements personnalisés',
        ],
      ),
      const GuideSection(
        title: 'Communication',
        description: 'Communiquez avec vos étudiants et collègues.',
        icon: Icons.message,
        steps: [
          'Utilisez la messagerie intégrée',
          'Envoyez des messages de groupe',
          'Planifiez des sessions de révision',
          'Partagez des ressources supplémentaires',
        ],
      ),
      const GuideSection(
        title: 'Analytiques Pédagogiques',
        description: 'Analysez l\'efficacité de votre enseignement.',
        icon: Icons.analytics,
        steps: [
          'Consultez l\'onglet "Analytiques"',
          'Analysez les taux de réussite',
          'Identifiez les sujets difficiles',
          'Adaptez votre approche pédagogique',
        ],
      ),
    ];
  }

  static List<GuideSection> getStudentGuide() {
    return [
      const GuideSection(
        title: 'Choisir une Langue',
        description:
            'Commencez votre apprentissage en sélectionnant une langue.',
        icon: Icons.language,
        steps: [
          'Accédez à l\'onglet "Langues"',
          'Explorez les langues disponibles',
          'Lisez les descriptions et informations culturelles',
          'Cliquez sur "Commencer" pour votre langue choisie',
        ],
      ),
      const GuideSection(
        title: 'Suivre des Leçons',
        description: 'Apprenez de manière structurée avec nos leçons.',
        icon: Icons.school,
        steps: [
          'Accédez à l\'onglet "Leçons"',
          'Choisissez une leçon adaptée à votre niveau',
          'Suivez les instructions étape par étape',
          'Pratiquez la prononciation avec l\'audio',
          'Passez au quiz pour valider vos acquis',
        ],
      ),
      const GuideSection(
        title: 'Jouer et Apprendre',
        description: 'Renforcez vos connaissances avec des jeux éducatifs.',
        icon: Icons.games,
        steps: [
          'Accédez à l\'onglet "Jeux"',
          'Sélectionnez un jeu selon votre niveau',
          'Jouez et gagnez des points',
          'Débloquez de nouveaux jeux en progressant',
        ],
      ),
      const GuideSection(
        title: 'Évaluer ses Progrès',
        description: 'Testez vos connaissances avec nos quiz.',
        icon: Icons.quiz,
        steps: [
          'Accédez à l\'onglet "Quiz"',
          'Choisissez un quiz adapté à votre niveau',
          'Répondez aux questions dans le temps imparti',
          'Consultez vos résultats et corrigez vos erreurs',
        ],
      ),
      const GuideSection(
        title: 'Maintenir sa Motivation',
        description: 'Gardez votre série d\'apprentissage active.',
        icon: Icons.local_fire_department,
        steps: [
          'Connectez-vous quotidiennement',
          'Complétez au moins une activité par jour',
          'Consultez votre progression dans le profil',
          'Participez aux défis communautaires',
        ],
      ),
    ];
  }
}
