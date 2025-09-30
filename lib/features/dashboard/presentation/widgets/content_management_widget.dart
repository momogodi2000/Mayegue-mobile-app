import 'package:flutter/material.dart';

class ContentManagementWidget extends StatelessWidget {
  final VoidCallback? onCreateLesson;
  final VoidCallback? onCreateGame;
  final VoidCallback? onManageVocabulary;
  final VoidCallback? onUploadMedia;

  const ContentManagementWidget({
    super.key,
    this.onCreateLesson,
    this.onCreateGame,
    this.onManageVocabulary,
    this.onUploadMedia,
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
              'Content Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContentItem(
              'Ewondo Lesson 1',
              'Published',
              Colors.green,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildContentItem(
              'Bulu Grammar Guide',
              'Draft',
              Colors.orange,
              Icons.edit,
            ),
            const SizedBox(height: 12),
            _buildContentItem(
              'Fang Vocabulary Quiz',
              'Under Review',
              Colors.blue,
              Icons.pending,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to create new content
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Content'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onManageVocabulary,
                    icon: const Icon(Icons.manage_search),
                    label: const Text('Manage'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentItem(
    String title,
    String status,
    Color statusColor,
    IconData statusIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Edit content
            },
            icon: const Icon(Icons.edit, size: 20),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
