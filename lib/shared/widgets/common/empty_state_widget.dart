import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// Empty State Widget - Reusable empty state display component
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? actionButton;
  final Color? iconColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox,
    this.actionButton,
    this.iconColor,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: iconColor ?? AppColors.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionButton != null) ...[
            const SizedBox(height: 32),
            actionButton!,
          ],
        ],
      ),
    );
  }
}

/// Empty State with Action - Pre-configured empty state with action button
class EmptyStateWithAction extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final String actionText;
  final VoidCallback onActionPressed;
  final Color? iconColor;
  final Color? actionButtonColor;

  const EmptyStateWithAction({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.add,
    required this.actionText,
    required this.onActionPressed,
    this.iconColor,
    this.actionButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor,
      actionButton: ElevatedButton.icon(
        onPressed: onActionPressed,
        icon: Icon(icon),
        label: Text(actionText),
        style: ElevatedButton.styleFrom(
          backgroundColor: actionButtonColor ?? AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
