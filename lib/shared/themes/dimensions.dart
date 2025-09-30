import 'package:flutter/material.dart';

/// App Dimensions - Unified spacing and sizing
class AppDimensions {
  // Spacing
  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 20.0;
  static const double spacingXL = 24.0;
  static const double spacingXXL = 32.0;
  static const double spacingXXXL = 48.0;

  // Padding
  static const EdgeInsets paddingXXS = EdgeInsets.all(spacingXXS);
  static const EdgeInsets paddingXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets paddingS = EdgeInsets.all(spacingS);
  static const EdgeInsets paddingM = EdgeInsets.all(spacingM);
  static const EdgeInsets paddingL = EdgeInsets.all(spacingL);
  static const EdgeInsets paddingXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets paddingXXL = EdgeInsets.all(spacingXXL);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: spacingXS);
  static const EdgeInsets paddingHorizontalS = EdgeInsets.symmetric(horizontal: spacingS);
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: spacingM);
  static const EdgeInsets paddingHorizontalL = EdgeInsets.symmetric(horizontal: spacingL);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: spacingXL);

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: spacingXS);
  static const EdgeInsets paddingVerticalS = EdgeInsets.symmetric(vertical: spacingS);
  static const EdgeInsets paddingVerticalM = EdgeInsets.symmetric(vertical: spacingM);
  static const EdgeInsets paddingVerticalL = EdgeInsets.symmetric(vertical: spacingL);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: spacingXL);

  // Margins
  static const EdgeInsets marginXXS = EdgeInsets.all(spacingXXS);
  static const EdgeInsets marginXS = EdgeInsets.all(spacingXS);
  static const EdgeInsets marginS = EdgeInsets.all(spacingS);
  static const EdgeInsets marginM = EdgeInsets.all(spacingM);
  static const EdgeInsets marginL = EdgeInsets.all(spacingL);
  static const EdgeInsets marginXL = EdgeInsets.all(spacingXL);
  static const EdgeInsets marginXXL = EdgeInsets.all(spacingXXL);

  // Default spacing (alias for spacingM)
  static const double spacing = spacingM;

  // Border radius
  static const double borderRadiusXS = 4.0;
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 20.0;
  static const double borderRadiusXXL = 24.0;

  // Default border radius (alias for borderRadiusM)
  static const double borderRadius = borderRadiusM;

  // Border radius objects
  static const BorderRadius borderRadiusXSObj = BorderRadius.all(Radius.circular(borderRadiusXS));
  static const BorderRadius borderRadiusSObj = BorderRadius.all(Radius.circular(borderRadiusS));
  static const BorderRadius borderRadiusMObj = BorderRadius.all(Radius.circular(borderRadiusM));
  static const BorderRadius borderRadiusLObj = BorderRadius.all(Radius.circular(borderRadiusL));
  static const BorderRadius borderRadiusXLObj = BorderRadius.all(Radius.circular(borderRadiusXL));
  static const BorderRadius borderRadiusXXLObj = BorderRadius.all(Radius.circular(borderRadiusXXL));

  // Icon sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 40.0;
  static const double iconSizeXXL = 48.0;

  // Button heights
  static const double buttonHeightS = 36.0;
  static const double buttonHeightM = 44.0;
  static const double buttonHeightL = 52.0;

  // Input field heights
  static const double inputHeight = 48.0;

  // Card elevation
  static const double elevationXS = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 6.0;
  static const double elevationXL = 8.0;

  // Screen breakpoints (for responsive design)
  static const double screenBreakpointS = 600.0;
  static const double screenBreakpointM = 900.0;
  static const double screenBreakpointL = 1200.0;

  // Animation durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // App bar height
  static const double appBarHeight = 56.0;

  // Bottom navigation height
  static const double bottomNavHeight = 80.0;

  // Drawer width
  static const double drawerWidth = 280.0;

  // Dialog width constraints
  static const double dialogMaxWidth = 400.0;
  static const double dialogMinWidth = 280.0;
}
