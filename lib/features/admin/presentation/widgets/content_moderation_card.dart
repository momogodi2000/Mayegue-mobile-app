import 'package:flutter/material.dart';
import '../viewmodels/admin_content_management_viewmodel.dart';

/// Card widget for displaying moderation items with approve/reject actions
class ContentModerationCard extends StatelessWidget {
  final ModerationItem moderation;
  final VoidCallback onApprove;
  final Function(String reason) onReject;

  const ContentModerationCard({
    super.key,
    required this.moderation,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildPriorityIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    moderation.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildTypeChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              moderation.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Submitted by: ${moderation.submittedBy}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const Spacer(),
                Text(
                  _formatDate(moderation.submittedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showRejectDialog(context),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label:
                      const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    Color color;
    switch (moderation.priority) {
      case ModerationPriority.low:
        color = Colors.green;
        break;
      case ModerationPriority.medium:
        color = Colors.orange;
        break;
      case ModerationPriority.high:
        color = Colors.red;
        break;
      case ModerationPriority.critical:
        color = Colors.purple;
        break;
    }

    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTypeChip() {
    String label;
    Color color;
    switch (moderation.type) {
      case ModerationItemType.dictionaryEntry:
        label = 'Dictionary';
        color = Colors.blue;
        break;
      case ModerationItemType.lesson:
        label = 'Lesson';
        color = Colors.green;
        break;
      case ModerationItemType.userContent:
        label = 'User Content';
        color = Colors.orange;
        break;
      case ModerationItemType.communityPost:
        label = 'Community';
        color = Colors.purple;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Content'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Please provide a reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onReject(controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
