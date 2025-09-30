import 'package:flutter/material.dart';

class AnalyticsWidget extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final VoidCallback onExportReport;

  const AnalyticsWidget({
    super.key,
    required this.teacherData,
    required this.onExportReport,
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
              'Analytics & Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAnalyticsCard(
                  'Total Views',
                  '12,456',
                  '+15%',
                  Colors.blue,
                  Icons.visibility,
                ),
                const SizedBox(width: 12),
                _buildAnalyticsCard(
                  'Avg. Session',
                  '8m 32s',
                  '+5%',
                  Colors.green,
                  Icons.timer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Popular Languages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildLanguageProgress('Ewondo', 0.85, '85%'),
            const SizedBox(height: 8),
            _buildLanguageProgress('Bulu', 0.72, '72%'),
            const SizedBox(height: 8),
            _buildLanguageProgress('Fang', 0.68, '68%'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed analytics
              },
              child: const Text('View Detailed Analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    String change,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1 * 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
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
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 10,
                color: change.startsWith('+') ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageProgress(String language, double progress, String percentage) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            language,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            percentage,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}