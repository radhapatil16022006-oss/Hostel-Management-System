import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Modern typography hierarchy for Hostel Management System.
class AppTextStyles {
  AppTextStyles._();

  static const List<String> _fontFallbacks = [
    'Inter',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'sans-serif',
  ];

  static TextStyle _fontStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
      color: color,
      fontFamilyFallback: _fontFallbacks,
    );
  }

  // Display & Headings
  static TextStyle displayLarge({Color? color}) => _fontStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => _fontStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.25,
        color: color,
      );

  static TextStyle titleLarge({Color? color}) => _fontStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => _fontStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => _fontStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Body Text
  static TextStyle bodyLarge({Color? color}) => _fontStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _fontStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => _fontStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  // Labels & Buttons
  static TextStyle labelLarge({Color? color}) => _fontStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => _fontStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => _fontStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: color,
      );

  // Stat Numbers
  static TextStyle statValue({Color? color}) => _fontStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? AppColors.primary,
      );
}
