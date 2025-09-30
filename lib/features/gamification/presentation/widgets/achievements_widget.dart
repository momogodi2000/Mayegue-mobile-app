import 'package:flutter/material.dart';
import '../../domain/entities/gamification.dart';

/// Widget to display user achievements
class AchievementsWidget extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsWidget({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Aucun succès débloqué pour le moment'),
          ),
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
            Row(
              children: [
                Icon(Icons.emoji_events, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Succès (${achievements.where((a) => a.isUnlocked).length}/${achievements.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementItem(context, achievement);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(BuildContext context, Achievement achievement) {
    return Container(
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              _getAchievementIcon(achievement.iconName),
              size: 32,
              color: achievement.isUnlocked
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Points reward
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+${achievement.pointsReward}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'local_library':
        return Icons.local_library;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'stars':
        return Icons.stars;
      case 'workspace_premium':
        return Icons.workspace_premium;
      default:
        return Icons.star;
    }
  }
}
