import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../themes/colors.dart';

/// File Picker Widget - Reusable file selection component
class FilePickerWidget extends StatefulWidget {
  final List<PlatformFile>? initialFiles;
  final List<String>? allowedExtensions;
  final bool allowMultiple;
  final String? dialogTitle;
  final Function(List<PlatformFile>)? onFilesSelected;
  final Function(PlatformFile)? onFileRemoved;
  final double? maxFileSize; // in MB
  final int? maxFiles;

  const FilePickerWidget({
    super.key,
    this.initialFiles,
    this.allowedExtensions,
    this.allowMultiple = false,
    this.dialogTitle,
    this.onFilesSelected,
    this.onFileRemoved,
    this.maxFileSize,
    this.maxFiles,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedFiles = widget.initialFiles ?? [];
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: widget.allowMultiple,
        dialogTitle: widget.dialogTitle,
      );

      if (result != null) {
        List<PlatformFile> newFiles = result.files;

        // Check file size limits
        if (widget.maxFileSize != null) {
          newFiles = newFiles.where((file) {
            final fileSizeMB = file.size / (1024 * 1024);
            return fileSizeMB <= widget.maxFileSize!;
          }).toList();
        }

        // Check file count limits
        if (widget.maxFiles != null) {
          final totalFiles = _selectedFiles.length + newFiles.length;
          if (totalFiles > widget.maxFiles!) {
            newFiles = newFiles
                .take(widget.maxFiles! - _selectedFiles.length)
                .toList();
          }
        }

        setState(() {
          if (widget.allowMultiple) {
            _selectedFiles.addAll(newFiles);
          } else {
            _selectedFiles = newFiles;
          }
        });

        widget.onFilesSelected?.call(_selectedFiles);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      _showErrorSnackBar('Erreur lors de la sélection des fichiers');
    }
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
    widget.onFileRemoved?.call(file);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pick files button
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: Text(widget.allowMultiple
              ? 'Sélectionner des fichiers'
              : 'Sélectionner un fichier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
        ),

        // Selected files list
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Fichiers sélectionnés (${_selectedFiles.length})',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...(_selectedFiles.map((file) => _buildFileItem(file))),
        ],
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(file.extension),
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(file.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurface.withValues(alpha: 0.6 * 255),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeFile(file),
            icon: const Icon(Icons.close, color: AppColors.error),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Simple File Picker Button - Just a button to pick files
class FilePickerButton extends StatelessWidget {
  final String text;
  final List<String>? allowedExtensions;
  final bool allowMultiple;
  final Function(List<PlatformFile>)? onFilesSelected;
  final IconData? icon;

  const FilePickerButton({
    super.key,
    required this.text,
    this.allowedExtensions,
    this.allowMultiple = false,
    this.onFilesSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _pickFiles(context),
      icon: Icon(icon ?? Icons.attach_file),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        onFilesSelected?.call(result.files);
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      // Note: Using context after async operation - this is acceptable for error handling
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sélection des fichiers'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
