import 'package:flutter/material.dart';

/// App color palette adhering to Material 3 and modern design guidelines.
class AppColors {
  AppColors._();

  // Primary Palette - Deep Royal Indigo / Blue
  static const Color primary = Color(0xFF1E3A8A); // Deep Indigo
  static const Color primaryLight = Color(0xFF3B82F6); // Vibrant Blue
  static const Color primaryDark = Color(0xFF172554); // Midnight Blue
  static const Color primaryContainer = Color(0xFFDBEAFE); // Soft Ice Blue
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // Secondary Palette - Modern Cyan / Teal
  static const Color secondary = Color(0xFF0D9488); // Deep Teal
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF115E59);

  // Semantic Status Colors
  // Success / Paid / Present / Approved
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  // Warning / Pending / Partially Paid / In Progress
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  // Danger / Error / Rejected / Absent / Inactive
  static const Color error = Color(0xFFEF4444); // Crimson Rose
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  // Info / Highlights
  static const Color info = Color(0xFF0284C7); // Sky Blue
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF075985);

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Neutrals
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF2563EB)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF111827)],
  );
}
