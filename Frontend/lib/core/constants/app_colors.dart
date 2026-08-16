import 'package:flutter/material.dart';

class AppColors {
  // Brand Primaries (Sky Blue & Deep Navy)
  static const Color primary = Color(0xFF0284C7); // sky-600
  static const Color primaryDark = Color(0xFF0369A1); // sky-700
  static const Color primaryLight = Color(0xFFE0F2FE); // sky-100
  static const Color primarySurface = Color(0xFFF0F9FF); // sky-50

  // Technician Portal Primary (Amber / Warm Gold)
  static const Color technicianPrimary = Color(0xFFD97706); // amber-600
  static const Color technicianDark = Color(0xFFB45309); // amber-700
  static const Color technicianLight = Color(0xFFFEF3C7); // amber-100
  static const Color technicianSurface = Color(0xFFFFFBEB); // amber-50

  // Functional & Semantic Colors
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color successLight = Color(0xFFD1FAE5); // emerald-100
  static const Color successDark = Color(0xFF047857); // emerald-700

  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFB45309); // amber-700

  static const Color error = Color(0xFFEF4444); // rose-500
  static const Color errorLight = Color(0xFFFFE4E6); // rose-100
  static const Color errorDark = Color(0xFFBE123C); // rose-700

  static const Color info = Color(0xFF0EA5E9); // sky-500

  // Neutrals & Slate Palette
  static const Color background = Color(0xFFF8FAFC); // slate-50
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF1F5F9); // slate-100

  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF475569); // slate-600
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color textLight = Color(0xFFCBD5E1); // slate-300

  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100
  static const Color divider = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF0C4A6E)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient techGradient = LinearGradient(
    colors: [Color(0xFFB45309), Color(0xFF78350F)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
