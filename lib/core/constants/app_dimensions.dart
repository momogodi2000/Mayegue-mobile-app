/// App dimension constants
class AppDimensions {
  AppDimensions._();

  // Padding and margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeHeading = 24.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;

  // App bar dimensions
  static const double appBarHeight = 56.0;

  // Card dimensions
  static const double cardElevation = 4.0;
  static const double cardElevationPressed = 8.0;

  // List item dimensions
  static const double listItemHeight = 72.0;
  static const double listItemHeightSmall = 56.0;

  // Divider dimensions
  static const double dividerHeight = 1.0;
  static const double dividerIndent = 16.0;

  // Progress indicator dimensions
  static const double progressIndicatorSize = 24.0;
  static const double progressIndicatorSizeLarge = 32.0;
  static const double progressIndicatorStrokeWidth = 4.0;

  // Avatar dimensions
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 56.0;
  static const double avatarSizeExtraLarge = 72.0;

  // Spacing
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  static const double spacingHuge = 48.0;

  // Layout dimensions
  static const double maxWidthMobile = 480.0;
  static const double maxWidthTablet = 768.0;
  static const double maxWidthDesktop = 1200.0;

  // Form field dimensions
  static const double inputFieldHeight = 56.0;
  static const double inputFieldHeightSmall = 40.0;
  static const double inputFieldBorderWidth = 1.0;

  // Bottom sheet dimensions
  static const double bottomSheetBorderRadius = 16.0;
  static const double bottomSheetMaxHeight = 600.0;

  // Dialog dimensions
  static const double dialogBorderRadius = 12.0;
  static const double dialogMaxWidth = 320.0;

  // Snackbar dimensions
  static const double snackbarBorderRadius = 8.0;
  static const double snackbarMargin = 16.0;

  // Tab dimensions
  static const double tabHeight = 48.0;
  static const double tabIndicatorHeight = 2.0;

  // Slider dimensions
  static const double sliderHeight = 40.0;
  static const double sliderThumbRadius = 12.0;
  static const double sliderTrackHeight = 4.0;

  // Carousel dimensions
  static const double carouselHeight = 200.0;
  static const double carouselItemSpacing = 8.0;

  // Grid dimensions
  static const double gridSpacing = 8.0;
  static const double gridCrossAxisSpacing = 8.0;
  static const double gridMainAxisSpacing = 8.0;
  static const double gridChildAspectRatio = 1.0;

  // Animation durations (in milliseconds)
  static const int animationDurationShort = 200;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;
  static const int animationDurationExtraLong = 800;

  // Z-index values for elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationExtra = 12.0;

  // Breakpoints for responsive design
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // Safe area dimensions
  static const double safeAreaTop = 24.0;
  static const double safeAreaBottom = 24.0;
  static const double safeAreaLeft = 16.0;
  static const double safeAreaRight = 16.0;

  // Legacy aliases for backward compatibility
  static double get spacing => spacingMedium;
  static double get borderRadius => borderRadiusMedium;
}