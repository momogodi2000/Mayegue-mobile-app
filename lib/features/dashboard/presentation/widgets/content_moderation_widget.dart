import 'package:flutter/material.dart';

class ContentModerationWidget extends StatelessWidget {
  final int pendingContent;
  final int reportedContent;
  final Function(String, String) onModerateContent;

  const ContentModerationWidget({
    super.key,
    required this.pendingContent,
    required this.reportedContent,
    required this.onModerateContent,
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
              'Content Moderation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildModerationStat(
                    'Pending Review', pendingContent.toString(), Colors.orange),
                const SizedBox(width: 12),
                _buildModerationStat(
                    'Reported', reportedContent.toString(), Colors.red),
                const SizedBox(width: 12),
                _buildModerationStat('Approved', '156', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Items Needing Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildReviewItem(
              'User-submitted Ewondo translation',
              'Potential inaccuracy in pronunciation guide',
              'High',
            ),
            const SizedBox(height: 8),
            _buildReviewItem(
              'Bulu lesson content',
              'Contains cultural sensitivity concerns',
              'Medium',
            ),
            const SizedBox(height: 8),
            _buildReviewItem(
              'Fang vocabulary quiz',
              'Question format needs standardization',
              'Low',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to moderation queue
              },
              child: const Text('Review All Pending Items'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModerationStat(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1 * 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(String title, String reason, String priority) {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1 * 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            reason,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Reject content
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Reject'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Approve content
                },
                child: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
