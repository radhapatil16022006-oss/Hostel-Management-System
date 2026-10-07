import 'package:flutter/material.dart';

/// Spacing, radius, elevation, and layout breakpoint definitions.
class AppDimensions {
  AppDimensions._();

  // Spacing & Padding
  static const double space2xs = 2.0;
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2xl = 48.0;
  static const double space3xl = 64.0;

  // Edge Insets Convenience
  static const EdgeInsets paddingXs = EdgeInsets.all(spaceXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spaceSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spaceMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spaceLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spaceXl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: spaceMd,
    vertical: spaceMd,
  );

  static const EdgeInsets screenPaddingWide = EdgeInsets.symmetric(
    horizontal: spaceLg,
    vertical: spaceLg,
  );

  // Border Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // Card / Element Heights
  static const double buttonHeight = 52.0;
  static const double buttonHeightSm = 40.0;
  static const double inputHeight = 56.0;
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double avatarSizeSm = 36.0;
  static const double avatarSizeMd = 52.0;
  static const double avatarSizeLg = 80.0;
  static const double avatarSizeXl = 104.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1100.0;

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
