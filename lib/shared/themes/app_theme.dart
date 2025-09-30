import 'package:flutter/material.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'dimensions.dart';

/// App Theme - Unified theme configuration
class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    // Colors
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.surface,

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryLight,
      error: AppColors.error,
      errorContainer: AppColors.errorLight,
      surface: AppColors.surface,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurface,
      onError: AppColors.onError,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      headlineLarge: AppTextStyles.headline4,
      headlineMedium: AppTextStyles.headline5,
      headlineSmall: AppTextStyles.headline6,
      titleLarge: AppTextStyles.bodyText1,
      titleMedium: AppTextStyles.bodyText2,
      titleSmall: AppTextStyles.caption,
      bodyLarge: AppTextStyles.bodyText1,
      bodyMedium: AppTextStyles.bodyText2,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.bodyText2,
      labelSmall: AppTextStyles.overline,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: AppDimensions.elevationS,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.surfaceTint,
      titleTextStyle: AppTextStyles.headline6,
      toolbarHeight: AppDimensions.appBarHeight,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedIconTheme: IconThemeData(size: AppDimensions.iconSizeM),
      unselectedIconTheme: IconThemeData(size: AppDimensions.iconSizeM),
      elevation: AppDimensions.elevationM,
      type: BottomNavigationBarType.fixed,
    ),

    // Card theme
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      shadowColor: AppColors.shadow,
      elevation: AppDimensions.elevationXS,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevationXS,
        shadowColor: AppColors.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingM,
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: AppDimensions.elevationM,
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: AppColors.onSurface,
      size: AppDimensions.iconSizeM,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // List tile theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5 * 255);
        }
        return AppColors.border;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surface;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.border),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondary;
      }),
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.border,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2 * 255),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    ),

    // Chip theme
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.border,
      labelStyle: AppTextStyles.bodyText2,
      secondaryLabelStyle: AppTextStyles.bodyText2,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusL)),
      ),
    ),

    // Tab bar theme
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),

    // Dialog theme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusL)),
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusL),
        ),
      ),
    ),

    // Snack bar theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.onSurface,
      contentTextStyle: AppTextStyles.bodyText2,
      actionTextColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Tooltip theme
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.onSurface,
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusS)),
      ),
      textStyle: AppTextStyles.caption,
    ),

    // Popup menu theme
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surface,
      elevation: AppDimensions.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Drawer theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surface,
      elevation: AppDimensions.elevationM,
    ),

    // Navigation bar theme
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary,
      labelTextStyle: WidgetStatePropertyAll(AppTextStyles.caption),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    // Colors
    primaryColor: AppColors.primary,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    canvasColor: AppColors.surfaceDark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariantDark,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryVariantDark,
      error: AppColors.errorDark,
      errorContainer: AppColors.errorLight,
      surface: AppColors.surfaceDark,
      onPrimary: AppColors.onPrimary,
      onSecondary: AppColors.onSecondary,
      onSurface: AppColors.onSurfaceDark,
      onError: AppColors.onError,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      shadow: AppColors.shadowDark,
      scrim: AppColors.scrimDark,
      inverseSurface: AppColors.inverseSurfaceDark,
      onInverseSurface: AppColors.onInverseSurfaceDark,
      inversePrimary: AppColors.inversePrimaryDark,
      surfaceTint: AppColors.surfaceTintDark,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      headlineLarge: AppTextStyles.headline4,
      headlineMedium: AppTextStyles.headline5,
      headlineSmall: AppTextStyles.headline6,
      titleLarge: AppTextStyles.bodyText1,
      titleMedium: AppTextStyles.bodyText2,
      titleSmall: AppTextStyles.caption,
      bodyLarge: AppTextStyles.bodyText1,
      bodyMedium: AppTextStyles.bodyText2,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.bodyText2,
      labelSmall: AppTextStyles.overline,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      elevation: AppDimensions.elevationS,
      shadowColor: AppColors.shadowDark,
      surfaceTintColor: AppColors.surfaceTintDark,
      titleTextStyle: AppTextStyles.headline6,
      toolbarHeight: AppDimensions.appBarHeight,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryDark,
      selectedIconTheme: IconThemeData(size: AppDimensions.iconSizeM),
      unselectedIconTheme: IconThemeData(size: AppDimensions.iconSizeM),
      elevation: AppDimensions.elevationM,
      type: BottomNavigationBarType.fixed,
    ),

    // Card theme
    cardTheme: const CardThemeData(
      color: AppColors.surfaceDark,
      shadowColor: AppColors.shadowDark,
      elevation: AppDimensions.elevationXS,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevationXS,
        shadowColor: AppColors.shadowDark,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingL,
          vertical: AppDimensions.spacingM,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.outlineDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.outlineDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.errorDark),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
        borderSide: BorderSide(color: AppColors.errorDark, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingM,
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: AppDimensions.elevationM,
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: AppColors.onSurfaceDark,
      size: AppDimensions.iconSizeM,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: AppColors.outlineDark,
      thickness: 1,
      space: 1,
    ),

    // List tile theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5 * 255);
        }
        return AppColors.outlineDark;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.surfaceDark;
      }),
      checkColor: WidgetStateProperty.all(AppColors.onPrimary),
      side: const BorderSide(color: AppColors.outlineDark),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondaryDark;
      }),
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.outlineDark,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2 * 255),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.outlineDark,
      circularTrackColor: AppColors.outlineDark,
    ),

    // Chip theme
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.surfaceVariantDark,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.outlineDark,
      labelStyle: AppTextStyles.bodyText2,
      secondaryLabelStyle: AppTextStyles.bodyText2,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusL)),
      ),
    ),

    // Tab bar theme
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondaryDark,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),

    // Dialog theme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusL)),
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppDimensions.elevationL,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.borderRadiusL),
        ),
      ),
    ),

    // Snack bar theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.onSurfaceDark,
      contentTextStyle: AppTextStyles.bodyText2,
      actionTextColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Tooltip theme
    tooltipTheme: const TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.onSurfaceDark,
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusS)),
      ),
      textStyle: AppTextStyles.caption,
    ),

    // Popup menu theme
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surfaceDark,
      elevation: AppDimensions.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(AppDimensions.borderRadiusM)),
      ),
    ),

    // Drawer theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppDimensions.elevationM,
    ),

    // Navigation bar theme
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      indicatorColor: AppColors.primary,
      labelTextStyle: WidgetStatePropertyAll(AppTextStyles.caption),
    ),
  );
}
