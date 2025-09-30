import 'package:flutter/material.dart';

class SystemHealthWidget extends StatelessWidget {
  final String serverStatus;
  final String databaseStatus;
  final String cacheStatus;
  final double storageUsage;
  final VoidCallback onRefreshStatus;

  const SystemHealthWidget({
    super.key,
    required this.serverStatus,
    required this.databaseStatus,
    required this.cacheStatus,
    required this.storageUsage,
    required this.onRefreshStatus,
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
              'System Health',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthIndicator(
              'Database',
              'Healthy',
              Colors.green,
              0.98,
            ),
            const SizedBox(height: 12),
            _buildHealthIndicator(
              'API Services',
              'Healthy',
              Colors.green,
              0.96,
            ),
            const SizedBox(height: 12),
            _buildHealthIndicator(
              'File Storage',
              'Warning',
              Colors.orange,
              0.89,
            ),
            const SizedBox(height: 12),
            _buildHealthIndicator(
              'Payment Gateway',
              'Healthy',
              Colors.green,
              0.97,
            ),
            const SizedBox(height: 16),
            const Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildAlertItem(
              'High memory usage detected',
              '2 hours ago',
              Colors.orange,
            ),
            _buildAlertItem(
              'Backup completed successfully',
              '6 hours ago',
              Colors.green,
            ),
            _buildAlertItem(
              'SSL certificate renewed',
              '1 day ago',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Run system diagnostics
                    },
                    icon: const Icon(Icons.health_and_safety),
                    label: const Text('Run Diagnostics'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // View system logs
                    },
                    icon: const Icon(Icons.bug_report),
                    label: const Text('View Logs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(
    String service,
    String status,
    Color statusColor,
    double uptime,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            service,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1 * 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: uptime,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 2,
              ),
              const SizedBox(height: 4),
              Text(
                '${(uptime * 100).toInt()}% uptime',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(String message, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
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
