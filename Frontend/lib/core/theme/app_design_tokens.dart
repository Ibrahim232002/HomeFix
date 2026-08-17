import 'package:flutter/material.dart';

/// HomeFix visual language in one place.
///
/// Keep business logic out of this layer. Screen-level styling should consume
/// these tokens instead of introducing one-off values.
class AppDesignTokens {
  AppDesignTokens._();

  // Spacing scale — 4pt base.
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space7 = 28;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // Radius scale.
  static const double radiusXs = 8;
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusPill = 999;

  // Component heights / touch targets.
  static const double buttonHeight = 50;
  static const double buttonHeightCompact = 44;
  static const double fieldHeight = 52;
  static const double navHeight = 72;
  static const double minTouchTarget = 48;

  // Elevation values stay intentionally restrained for a modern marketplace UI.
  static const double elevationCard = 0;
  static const double elevationSheet = 8;
  static const double elevationDialog = 16;

  // Responsive content widths.
  static const double contentMaxWidth = 720;
  static const double wideContentMaxWidth = 1120;

  static const Duration fastMotion = Duration(milliseconds: 160);
  static const Duration standardMotion = Duration(milliseconds: 220);
  static const Duration emphasizedMotion = Duration(milliseconds: 320);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;

  static const TextTheme baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.18),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
    titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3),
    titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.35),
    titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.35),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.45),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, height: 1.2),
  );
}
