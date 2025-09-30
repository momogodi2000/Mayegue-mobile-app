import 'package:flutter/material.dart';
import '../../domain/entities/gamification.dart';

/// Widget to display leaderboard
class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> leaderboard;
  final String? currentUserId;

  const LeaderboardWidget({
    super.key,
    required this.leaderboard,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Classement non disponible'),
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
                const Icon(Icons.leaderboard, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Classement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final isCurrentUser = entry.userId == currentUserId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrentUser
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200]!,
                      width: isCurrentUser ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getRankColor(entry.rank),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.rank}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Avatar placeholder
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          entry.userName.isNotEmpty
                              ? entry.userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.userName,
                              style: TextStyle(
                                fontWeight: isCurrentUser
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCurrentUser
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                              ),
                            ),
                            Text(
                              'Niveau ${entry.currentLevel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.totalPoints}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[300]!; // Bronze
      default:
        return Colors.blue; // Default
    }
  }
}
