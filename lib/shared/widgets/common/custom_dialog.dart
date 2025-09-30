import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// Custom Dialog - Reusable dialog component with theme integration
class CustomDialog extends StatelessWidget {
  final String title;
  final String? content;
  final List<Widget>? actions;
  final Widget? contentWidget;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? contentColor;
  final double? elevation;
  final ShapeBorder? shape;

  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.contentWidget,
    this.contentPadding,
    this.backgroundColor,
    this.titleColor,
    this.contentColor,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? AppColors.surface,
      elevation: elevation ?? 8,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: contentWidget ??
          (content != null
              ? Text(
                  content!,
                  style: TextStyle(
                    color: contentColor ?? AppColors.onSurface.withValues(alpha: 204),
                    fontSize: 16,
                  ),
                )
              : null),
      contentPadding: contentPadding ??
          const EdgeInsets.fromLTRB(24, 20, 24, 24),
      actions: actions,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// Show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    List<Widget>? actions,
    Widget? contentWidget,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        actions: actions,
        contentWidget: contentWidget,
      ),
    );
  }
}

/// Confirmation Dialog - Pre-configured dialog for confirmations
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    this.onCancel,
    this.confirmButtonColor,
    this.cancelButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: message,
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: cancelButtonColor ?? AppColors.onSurface.withValues(alpha: 178),
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmButtonColor,
    Color? cancelButtonColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
      ),
    );
  }
}

/// Success Dialog - Pre-configured dialog for success messages
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: title,
      content: message,
      actions: [
        ElevatedButton(
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  /// Show success dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
      ),
    );
  }
}
