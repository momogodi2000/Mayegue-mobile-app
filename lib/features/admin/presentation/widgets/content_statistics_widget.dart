import 'package:flutter/material.dart';
import '../viewmodels/admin_content_management_viewmodel.dart';

/// Widget for displaying content statistics in a grid layout
class ContentStatisticsWidget extends StatelessWidget {
  final ContentStatistics statistics;

  const ContentStatisticsWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          'Dictionary Entries',
          statistics.dictionaryEntries.toString(),
          Icons.book,
          Colors.blue,
        ),
        _buildStatCard(
          'Active Lessons',
          statistics.activeLessons.toString(),
          Icons.school,
          Colors.green,
        ),
        _buildStatCard(
          'Active Users',
          statistics.activeUsers.toString(),
          Icons.people,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Moderations',
          statistics.pendingModerations.toString(),
          Icons.pending,
          Colors.red,
        ),
        _buildStatCard(
          'Daily Active Users',
          statistics.dailyActiveUsers.toString(),
          Icons.today,
          Colors.purple,
        ),
        _buildStatCard(
          'Weekly Active Users',
          statistics.weeklyActiveUsers.toString(),
          Icons.calendar_view_week,
          Colors.teal,
        ),
        _buildStatCard(
          'Monthly Active Users',
          statistics.monthlyActiveUsers.toString(),
          Icons.calendar_month,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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
