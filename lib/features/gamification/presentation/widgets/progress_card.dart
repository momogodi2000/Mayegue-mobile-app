import 'package:flutter/material.dart';
import '../../domain/entities/gamification.dart';

/// Widget to display user progress and level
class ProgressCard extends StatelessWidget {
  final UserProgress? userProgress;
  final double levelProgress;

  const ProgressCard({
    super.key,
    required this.userProgress,
    required this.levelProgress,
  });

  @override
  Widget build(BuildContext context) {
    if (userProgress == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.stars, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Niveau ${userProgress!.currentLevel}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Points badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${userProgress!.totalPoints} pts',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Coins
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${userProgress!.coins} Mayegue Coins',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression niveau',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${userProgress!.experiencePoints}/${userProgress!.pointsToNextLevel} XP',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: levelProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.school,
                  value: userProgress!.lessonsCompleted.toString(),
                  label: 'Leçons',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.book,
                  value: userProgress!.coursesCompleted.toString(),
                  label: 'Cours',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  value: userProgress!.streakDays.toString(),
                  label: 'Série',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
