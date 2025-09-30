import 'package:flutter/material.dart';

/// Admin User Guide
class AdminGuideView extends StatelessWidget {
  const AdminGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide de l\'Administrateur'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guide Administrateur',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gérez l\'application Mayègue',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Dashboard Overview
            _buildSection(
              context,
              icon: Icons.dashboard,
              title: '1. Tableau de Bord',
              content: '''
Le tableau de bord administrateur vous permet de:
• Visualiser les statistiques générales de l'application
• Surveiller l'activité des utilisateurs
• Accéder rapidement aux fonctionnalités de gestion
• Voir les dernières inscriptions et activités
              ''',
            ),

            // Section: User Management
            _buildSection(
              context,
              icon: Icons.people,
              title: '2. Gestion des Utilisateurs',
              content: '''
Gérez tous les utilisateurs de la plateforme:
• Voir la liste de tous les utilisateurs (étudiants, enseignants)
• Activer ou désactiver des comptes utilisateurs
• Modifier les rôles et permissions
• Consulter l'historique des activités
• Gérer les abonnements et paiements
              ''',
            ),

            // Section: Content Management
            _buildSection(
              context,
              icon: Icons.content_paste,
              title: '3. Gestion du Contenu',
              content: '''
Contrôlez tout le contenu éducatif:
• Créer, modifier et supprimer des leçons
• Gérer le dictionnaire multilingue (Ewondo, Bafang, etc.)
• Ajouter des ressources audio et vidéo
• Modérer les contributions des enseignants
• Organiser les cours par niveaux et catégories
              ''',
            ),

            // Section: Analytics
            _buildSection(
              context,
              icon: Icons.analytics,
              title: '4. Statistiques et Rapports',
              content: '''
Analysez les performances de la plateforme:
• Nombre total d'utilisateurs actifs
• Taux de complétion des cours
• Langues les plus étudiées
• Revenus et abonnements
• Tendances d'utilisation mensuelle
• Exportation de rapports détaillés
              ''',
            ),

            // Section: System Settings
            _buildSection(
              context,
              icon: Icons.settings,
              title: '5. Configuration Système',
              content: '''
Configurez les paramètres de l'application:
• Gérer les langues disponibles
• Configurer les options de paiement
• Définir les tarifs d'abonnement
• Paramètres de notifications push
• Intégration Firebase et services tiers
• Sauvegarde et restauration des données
              ''',
            ),

            // Section: Teacher Management
            _buildSection(
              context,
              icon: Icons.school,
              title: '6. Gestion des Enseignants',
              content: '''
Supervisez les enseignants:
• Approuver les demandes de compte enseignant
• Attribuer des permissions spécifiques
• Évaluer la qualité du contenu créé
• Gérer les certifications des instructeurs
• Consulter les statistiques de chaque enseignant
              ''',
            ),

            // Section: Support & Moderation
            _buildSection(
              context,
              icon: Icons.support_agent,
              title: '7. Support et Modération',
              content: '''
Assurez un environnement sûr:
• Répondre aux tickets de support
• Modérer les commentaires et forums
• Gérer les signalements d'abus
• Bannir ou avertir les utilisateurs
• Consulter les logs du système
              ''',
            ),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils pour les Administrateurs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Effectuez des sauvegardes régulières de la base de données\n'
                    '• Surveillez les performances du système quotidiennement\n'
                    '• Répondez rapidement aux demandes de support\n'
                    '• Vérifiez la qualité du contenu avant publication\n'
                    '• Maintenez une communication claire avec les enseignants\n'
                    '• Utilisez les rapports pour améliorer l\'expérience utilisateur',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Support
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open support contact
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Support Technique'),
                      content: const Text(
                        'Pour toute assistance, contactez:\n\n'
                        'Email: admin@mayegue.com\n'
                        'Téléphone: +237 XXX XXX XXX',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.contact_support),
                label: const Text('Contacter le Support Technique'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content.trim(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
