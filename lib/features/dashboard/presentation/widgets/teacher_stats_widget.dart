import 'package:flutter/material.dart';

class TeacherStatsWidget extends StatelessWidget {
  final int totalStudents;
  final int activeStudents;
  final int completedLessons;
  final double averageProgress;

  const TeacherStatsWidget({
    super.key,
    required this.totalStudents,
    required this.activeStudents,
    required this.completedLessons,
    required this.averageProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teaching Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Total Students',
                  totalStudents.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Active Students',
                  activeStudents.toString(),
                  Icons.online_prediction,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  context,
                  'Completed Lessons',
                  completedLessons.toString(),
                  Icons.check_circle,
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Avg Progress',
                  '${averageProgress.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
