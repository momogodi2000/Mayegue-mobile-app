import 'package:flutter/material.dart';
import '../themes/colors.dart';

/// SnackBar Utilities - Reusable SnackBar functions
class SnackBarUtils {
  /// Show success SnackBar
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      icon: Icons.check_circle_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show error SnackBar
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      icon: Icons.error_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show warning SnackBar
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      textColor: Colors.black,
      icon: Icons.warning_amber_outlined,
      duration: duration,
      action: action,
    );
  }

  /// Show info SnackBar
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      icon: Icons.info_outline,
      duration: duration,
      action: action,
    );
  }

  /// Show custom SnackBar
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: backgroundColor ?? AppColors.primary,
      textColor: textColor ?? AppColors.onPrimary,
      icon: icon,
      duration: duration,
      action: action,
    );
  }

  /// Internal method to show SnackBar
  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    required Duration duration,
    SnackBarAction? action,
  }) {
    // Remove any existing SnackBars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor,
              size: 20,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show loading SnackBar (persists until dismissed)
  static void showLoading(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Remove any existing SnackBars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ?? AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? AppColors.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      duration: const Duration(days: 1), // Long duration to keep it visible
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Hide any current SnackBar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }
}
