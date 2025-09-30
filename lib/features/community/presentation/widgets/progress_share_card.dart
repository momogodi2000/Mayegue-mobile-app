import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget for displaying progress share items
class ProgressShareCard extends StatelessWidget {
  final Map<String, dynamic> progressData;
  final VoidCallback? onLikePressed;
  final VoidCallback? onCommentPressed;
  final bool showUserInfo;

  const ProgressShareCard({
    Key? key,
    required this.progressData,
    this.onLikePressed,
    this.onCommentPressed,
    this.showUserInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progressType =
        progressData['progressData']?['type'] as String? ?? 'achievement';
    final title =
        progressData['progressData']?['title'] as String? ?? 'Progress Update';
    final description =
        progressData['progressData']?['description'] as String? ?? '';
    final sharedAt = progressData['sharedAt'] as Timestamp?;
    final likes = progressData['likes'] as int? ?? 0;
    final comments = progressData['comments'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showUserInfo) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: progressData['userAvatar'] != null
                        ? NetworkImage(progressData['userAvatar'])
                        : null,
                    child: progressData['userAvatar'] == null
                        ? Text(
                            progressData['userName']?.toString().isNotEmpty ==
                                    true
                                ? progressData['userName']
                                    .toString()[0]
                                    .toUpperCase()
                                : '?',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          progressData['userName']?.toString() ??
                              'Unknown User',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTimestamp(sharedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Progress content
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProgressColor(progressType).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getProgressColor(progressType).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getProgressIcon(progressType),
                        color: _getProgressColor(progressType),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getProgressColor(progressType),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (progressData['progressData']?['details'] != null) ...[
                    const SizedBox(height: 8),
                    _buildProgressDetails(
                        progressData['progressData']['details']),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: onLikePressed,
                  icon: Icon(
                    Icons.favorite,
                    size: 16,
                    color: likes > 0 ? Colors.red : Colors.grey,
                  ),
                  label: Text('$likes'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: onCommentPressed,
                  icon: const Icon(Icons.comment, size: 16),
                  label: Text('$comments'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDetails(Map<String, dynamic> details) {
    final children = <Widget>[];

    details.forEach((key, value) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Text(
                '$key: ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Color _getProgressColor(String type) {
    switch (type) {
      case 'lesson_completed':
        return Colors.green;
      case 'quiz_passed':
        return Colors.blue;
      case 'streak_achieved':
        return Colors.orange;
      case 'level_up':
        return Colors.purple;
      case 'language_mastered':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }

  IconData _getProgressIcon(String type) {
    switch (type) {
      case 'lesson_completed':
        return Icons.check_circle;
      case 'quiz_passed':
        return Icons.quiz;
      case 'streak_achieved':
        return Icons.local_fire_department;
      case 'level_up':
        return Icons.trending_up;
      case 'language_mastered':
        return Icons.star;
      default:
        return Icons.celebration;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}
