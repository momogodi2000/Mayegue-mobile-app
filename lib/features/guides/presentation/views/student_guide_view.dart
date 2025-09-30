import 'package:flutter/material.dart';

/// Student/Apprentice User Guide
class StudentGuideView extends StatelessWidget {
  const StudentGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide de l\'Apprenant'),
        backgroundColor: Colors.green,
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
                  colors: [Colors.green.shade700, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.school_outlined, size: 48, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guide Apprenant',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Apprenez les langues camerounaises',
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
              icon: Icons.start,
              title: '1. Premiers Pas',
              content: '''
Bienvenue sur Mayègue!
• Créez votre profil d'apprenant
• Choisissez votre langue maternelle
• Sélectionnez la langue que vous souhaitez apprendre
• Définissez vos objectifs d'apprentissage
• Explorez le tableau de bord
• Complétez le test de niveau (optionnel)
              ''',
            ),

            // Section: Courses
            _buildSection(
              context,
              icon: Icons.book_outlined,
              title: '2. Parcourir les Cours',
              content: '''
Découvrez nos cours:
• Explorez les cours par langue (Ewondo, Bafang, etc.)
• Filtrez par niveau (débutant, intermédiaire, avancé)
• Consultez les descriptions et objectifs
• Regardez les aperçus vidéo
• Vérifiez les avis des autres apprenants
• Inscrivez-vous aux cours qui vous intéressent
              ''',
            ),

            // Section: Learning
            _buildSection(
              context,
              icon: Icons.play_circle_outline,
              title: '3. Apprendre',
              content: '''
Suivez vos cours efficacement:
• Regardez les vidéos de leçons
• Écoutez les prononciations natives
• Complétez les exercices interactifs
• Pratiquez avec les jeux éducatifs
• Répétez les mots et phrases
• Notez les points importants
• Suivez votre progression
              ''',
            ),

            // Section: Dictionary
            _buildSection(
              context,
              icon: Icons.menu_book,
              title: '4. Utiliser le Dictionnaire',
              content: '''
Explorez le dictionnaire multilingue:
• Recherchez des mots en français, anglais, Ewondo, Bafang
• Écoutez les prononciations audio
• Consultez les exemples d'utilisation
• Découvrez les expressions idiomatiques
• Sauvegardez vos mots favoris
• Créez des listes de vocabulaire personnalisées
              ''',
            ),

            // Section: Practice
            _buildSection(
              context,
              icon: Icons.fitness_center,
              title: '5. S\'Entraîner',
              content: '''
Pratiquez régulièrement:
• Participez aux quiz quotidiens
• Jouez aux jeux de vocabulaire
• Utilisez les flashcards
• Pratiquez la prononciation
• Complétez les défis hebdomadaires
• Gagnez des badges et récompenses
              ''',
            ),

            // Section: Progress
            _buildSection(
              context,
              icon: Icons.trending_up,
              title: '6. Suivre vos Progrès',
              content: '''
Visualisez votre évolution:
• Consultez votre tableau de bord
• Voir les statistiques d'apprentissage
• Suivre les cours complétés
• Examiner vos scores de quiz
• Comparer avec vos objectifs
• Célébrer vos accomplissements
              ''',
            ),

            // Section: Community
            _buildSection(
              context,
              icon: Icons.groups,
              title: '7. Rejoindre la Communauté',
              content: '''
Connectez-vous avec d'autres apprenants:
• Participez aux forums de discussion
• Posez des questions aux enseignants
• Partagez vos expériences
• Rejoignez des groupes d'étude
• Participez aux événements culturels
• Pratiquez avec des partenaires linguistiques
              ''',
            ),

            // Section: Achievements
            _buildSection(
              context,
              icon: Icons.emoji_events,
              title: '8. Récompenses et Certifications',
              content: '''
Obtenez des reconnaissances:
• Débloquez des badges d'accomplissement
• Grimpez dans le classement
• Gagnez des points d'expérience (XP)
• Obtenez des certificats de complétion
• Participez aux compétitions
• Devenez ambassadeur de la langue
              ''',
            ),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Conseils pour Réussir',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Pratiquez au moins 15 minutes par jour\n'
                    '• Soyez régulier dans votre apprentissage\n'
                    '• N\'ayez pas peur de faire des erreurs\n'
                    '• Pratiquez la prononciation à voix haute\n'
                    '• Immergez-vous dans la culture camerounaise\n'
                    '• Fixez-vous des objectifs réalistes\n'
                    '• Amusez-vous pendant l\'apprentissage!',
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
                      title: const Text('Support Apprenants'),
                      content: const Text(
                        'Besoin d\'aide?\n\n'
                        'Email: support@mayegue.com\n'
                        'FAQ: faq.mayegue.com\n'
                        'Chat en direct: disponible 24/7',
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
                icon: const Icon(Icons.help_outline),
                label: const Text('Obtenir de l\'Aide'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
