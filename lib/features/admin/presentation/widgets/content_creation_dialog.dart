import 'package:flutter/material.dart';

/// Dialog for creating new content (dictionary entries, lessons, etc.)
class ContentCreationDialog extends StatefulWidget {
  const ContentCreationDialog({super.key});

  @override
  State<ContentCreationDialog> createState() => _ContentCreationDialogState();
}

class _ContentCreationDialogState extends State<ContentCreationDialog> {
  String _selectedContentType = 'dictionary';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Content'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select content type:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedContentType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(
                value: 'dictionary',
                child: Text('Dictionary Entry'),
              ),
              DropdownMenuItem(
                value: 'lesson',
                child: Text('Lesson'),
              ),
              DropdownMenuItem(
                value: 'game',
                child: Text('Game'),
              ),
              DropdownMenuItem(
                value: 'exercise',
                child: Text('Exercise'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedContentType = value;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'This will open the ${_getContentTypeName()} creation form.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createContent,
          child: const Text('Create'),
        ),
      ],
    );
  }

  String _getContentTypeName() {
    switch (_selectedContentType) {
      case 'dictionary':
        return 'Dictionary Entry';
      case 'lesson':
        return 'Lesson';
      case 'game':
        return 'Game';
      case 'exercise':
        return 'Exercise';
      default:
        return 'Content';
    }
  }

  void _createContent() {
    // TODO: Navigate to appropriate creation screen based on content type
    // For now, just show a snackbar
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getContentTypeName()} creation not yet implemented'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}
