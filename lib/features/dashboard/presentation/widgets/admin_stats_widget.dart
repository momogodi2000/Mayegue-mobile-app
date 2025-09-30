import 'package:flutter/material.dart';

class AdminStatsWidget extends StatelessWidget {
  final int totalUsers;
  final int activeUsers;
  final int totalContent;
  final double revenue;
  final Map<String, dynamic> systemHealth;

  const AdminStatsWidget({
    super.key,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalContent,
    required this.revenue,
    required this.systemHealth,
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
              'System Overview',
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
                  'Total Users',
                  totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Active Users',
                  activeUsers.toString(),
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
                  'Total Content',
                  totalContent.toString(),
                  Icons.library_books,
                  Colors.amber,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  context,
                  'Monthly Revenue',
                  '\$${revenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildActivityItem('New user registration', '2 minutes ago'),
            _buildActivityItem('Payment processed', '5 minutes ago'),
            _buildActivityItem('Content updated', '12 minutes ago'),
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

  Widget _buildActivityItem(String activity, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
