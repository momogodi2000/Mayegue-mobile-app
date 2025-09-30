import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../themes/dimensions.dart';

/// App Container - Reusable container with common styling patterns
class AppContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final VoidCallback? onTap;
  final bool showBorder;
  final AppContainerType type;

  const AppContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.margin,
    this.elevation,
    this.boxShadow,
    this.gradient,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
    this.showBorder = true,
    this.type = AppContainerType.surface,
  });

  /// Card container - Elevated container with shadow
  const AppContainer.card({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.margin,
    this.gradient,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
  })  : elevation = AppDimensions.elevationXS,
        boxShadow = null,
        showBorder = false,
        type = AppContainerType.card;

  /// Outlined container - Container with border
  const AppContainer.outlined({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.margin,
    this.gradient,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
  })  : elevation = 0,
        boxShadow = null,
        showBorder = true,
        type = AppContainerType.outlined;

  /// Primary container - Container with primary color theme
  const AppContainer.primary({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
  })  : backgroundColor = AppColors.primary,
        borderColor = null,
        borderWidth = null,
        elevation = 0,
        boxShadow = null,
        gradient = null,
        showBorder = false,
        type = AppContainerType.primary;

  /// Surface container - Container with surface color theme
  const AppContainer.surface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.alignment,
    this.onTap,
  })  : backgroundColor = AppColors.surface,
        borderColor = AppColors.border,
        borderWidth = 1,
        elevation = 0,
        boxShadow = null,
        gradient = null,
        showBorder = true,
        type = AppContainerType.surface;

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = _getBackgroundColor();
    final effectiveBorderColor = _getBorderColor();
    final effectiveBorderRadius = borderRadius ?? AppDimensions.borderRadiusMObj;
    final effectivePadding = padding ?? AppDimensions.paddingM;

    Widget container = Container(
      width: width,
      height: height,
      alignment: alignment,
      margin: margin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBackgroundColor : null,
        gradient: gradient,
        borderRadius: effectiveBorderRadius,
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: borderWidth ?? 1,
              )
            : null,
        boxShadow: boxShadow ??
            (elevation != null && elevation! > 0
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1 * 255),
                      blurRadius: elevation! * 2,
                      offset: Offset(0, elevation!),
                    ),
                  ]
                : null),
      ),
      child: child,
    );

    if (onTap != null) {
      container = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: container,
      );
    }

    return container;
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    switch (type) {
      case AppContainerType.card:
      case AppContainerType.surface:
        return AppColors.surface;
      case AppContainerType.primary:
        return AppColors.primary;
      case AppContainerType.outlined:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (borderColor != null) return borderColor!;

    switch (type) {
      case AppContainerType.outlined:
      case AppContainerType.surface:
        return AppColors.border;
      case AppContainerType.card:
      case AppContainerType.primary:
        return Colors.transparent;
    }
  }
}

/// App Container Types
enum AppContainerType {
  surface,
  card,
  outlined,
  primary,
}

/// Info Container - Container for informational content
class InfoContainer extends StatelessWidget {
  final Widget child;
  final InfoContainerType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const InfoContainer({
    super.key,
    required this.child,
    this.type = InfoContainerType.info,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  const InfoContainer.success({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : type = InfoContainerType.success;

  const InfoContainer.warning({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : type = InfoContainerType.warning;

  const InfoContainer.error({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : type = InfoContainerType.error;

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: padding ?? AppDimensions.paddingM,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: borderRadius ?? AppDimensions.borderRadiusMObj,
        border: Border.all(color: colors.borderColor),
      ),
      child: child,
    );
  }

  _InfoContainerColors _getColors() {
    switch (type) {
      case InfoContainerType.success:
        return _InfoContainerColors(
          backgroundColor: AppColors.success.withValues(alpha: 0.1 * 255),
          borderColor: AppColors.success.withValues(alpha: 0.3 * 255),
        );
      case InfoContainerType.warning:
        return _InfoContainerColors(
          backgroundColor: AppColors.warning.withValues(alpha: 0.1 * 255),
          borderColor: AppColors.warning.withValues(alpha: 0.3 * 255),
        );
      case InfoContainerType.error:
        return _InfoContainerColors(
          backgroundColor: AppColors.error.withValues(alpha: 0.1 * 255),
          borderColor: AppColors.error.withValues(alpha: 0.3 * 255),
        );
      case InfoContainerType.info:
        return _InfoContainerColors(
          backgroundColor: AppColors.info.withValues(alpha: 0.1 * 255),
          borderColor: AppColors.info.withValues(alpha: 0.3 * 255),
        );
    }
  }
}

enum InfoContainerType {
  info,
  success,
  warning,
  error,
}

class _InfoContainerColors {
  final Color backgroundColor;
  final Color borderColor;

  const _InfoContainerColors({
    required this.backgroundColor,
    required this.borderColor,
  });
}
