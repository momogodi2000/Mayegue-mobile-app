import 'package:flutter/material.dart';

/// Teacher User Guide
class TeacherGuideView extends StatelessWidget {
  const TeacherGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide de l\'Enseignant'),
        backgroundColor: Colors.blue,
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
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.school, size: 48, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guide Enseignant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Créez et partagez vos cours',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: Getting Started
            _buildSection(
              context,
              icon: Icons.rocket_launch,
              title: '1. Démarrage Rapide',
              content: '''
Bienvenue dans Mayègue!
• Complétez votre profil enseignant
• Ajoutez votre spécialité linguistique (Ewondo, Bafang, etc.)
• Indiquez votre niveau d'expérience
• Téléchargez une photo de profil professionnelle
• Consultez le tableau de bord pour voir vos statistiques
              ''',
            ),

            // Section: Course Creation
            _buildSection(
              context,
              icon: Icons.create,
              title: '2. Création de Cours',
              content: '''
Créez des cours engageants:
• Utilisez l'éditeur de cours intégré
• Ajoutez des leçons structurées par modules
• Intégrez du contenu multimédia (audio, vidéo, images)
• Créez des exercices interactifs
• Définissez les objectifs d'apprentissage
• Ajoutez des ressources téléchargeables
              ''',
            ),

            // Section: Student Management
            _buildSection(
              context,
              icon: Icons.people_alt,
              title: '3. Gestion des Étudiants',
              content: '''
Suivez la progression de vos étudiants:
• Voir la liste de vos étudiants inscrits
• Consulter les statistiques de progression
• Identifier les étudiants en difficulté
• Envoyer des messages personnalisés
• Attribuer des notes et feedbacks
• Gérer les groupes d'apprentissage
              ''',
            ),

            // Section: Assessments
            _buildSection(
              context,
              icon: Icons.quiz,
              title: '4. Évaluations et Quiz',
              content: '''
Créez des évaluations pertinentes:
• Concevoir des quiz à choix multiples
• Créer des exercices de prononciation
• Évaluer la compréhension orale et écrite
• Définir des critères de notation
• Générer des certificats de réussite
• Analyser les résultats des étudiants
              ''',
            ),

            // Section: Dictionary Contribution
            _buildSection(
              context,
              icon: Icons.book,
              title: '5. Contribution au Dictionnaire',
              content: '''
Enrichissez le dictionnaire multilingue:
• Ajouter de nouveaux mots et expressions
• Fournir des traductions précises
• Enregistrer des prononciations audio
• Ajouter des exemples d'utilisation
• Indiquer les contextes culturels
• Soumettre pour validation par l'administrateur
              ''',
            ),

            // Section: Interactive Tools
            _buildSection(
              context,
              icon: Icons.gamepad,
              title: '6. Outils Pédagogiques',
              content: '''
Utilisez des outils innovants:
• Créer des jeux éducatifs
• Organiser des sessions en direct
• Utiliser le tableau blanc virtuel
• Partager des ressources communautaires
• Créer des défis et compétitions
• Utiliser l'IA pour suggestions pédagogiques
              ''',
            ),

            // Section: Analytics
            _buildSection(
              context,
              icon: Icons.analytics,
              title: '7. Statistiques et Rapports',
              content: '''
Analysez vos performances:
• Nombre d'étudiants actifs
• Taux de complétion des cours
• Évaluations moyennes de vos cours
• Temps moyen passé par leçon
• Revenu généré (si applicable)
• Téléchargez des rapports détaillés
              ''',
            ),

            // Section: Community
            _buildSection(
              context,
              icon: Icons.forum,
              title: '8. Communauté et Collaboration',
              content: '''
Engagez-vous avec la communauté:
• Participer aux forums d'enseignants
• Partager des meilleures pratiques
• Collaborer avec d'autres instructeurs
• Répondre aux questions des étudiants
• Organiser des événements culturels
• Contribuer au blog pédagogique
              ''',
            ),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils pour Enseignants',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Soyez patient et encourageant avec vos étudiants\n'
                    '• Utilisez des exemples concrets et culturellement pertinents\n'
                    '• Variez les formats de contenu pour maintenir l\'engagement\n'
                    '• Répondez rapidement aux questions des étudiants\n'
                    '• Mettez régulièrement à jour vos cours\n'
                    '• Célébrez les progrès de vos étudiants',
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
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Support Enseignants'),
                      content: const Text(
                        'Pour toute question ou assistance:\n\n'
                        'Email: teachers@mayegue.com\n'
                        'Forum: forum.mayegue.com/teachers',
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
                label: const Text('Contacter le Support'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
