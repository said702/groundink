import 'package:flutter/material.dart';

/// Central color palette for GroundInk.
///
/// Colors carry meaning aligned with the feedback concept:
/// - green  → correctly spelled word
/// - red    → spelling error (grounded in the handwriting)
/// - teal   → correction suggestions
/// - amber  → workflow accent
class AppColors {
  static const primary = Color(0xFF4355B9); // indigo – trust & focus
  static const primaryDark = Color(0xFF2B3A8F);
  static const accent = Color(0xFF0EA5A4); // teal – suggestions
  static const success = Color(0xFF16A34A); // correct words
  static const error = Color(0xFFDC2626); // spelling errors
  static const warning = Color(0xFFF59E0B); // low confidence / characters
  static const background = Color(0xFFF5F6FA);
  static const cardBorder = Color(0xFFE7E9F2);
}

/// Material 3 theme for the app (clean & academic style).
class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
