import 'package:flutter/material.dart';

/// Every colour used in BiteBay lives here.
///
/// Keeping colours in one file means you can restyle the whole app by
/// editing this single file instead of hunting through every screen.
class AppColors {
  const AppColors._();

  // Brand
  static const Color brand = Color(0xFFFF5A1F);
  static const Color brandDark = Color(0xFFD8410C);
  static const Color brandSoft = Color(0xFFFFF1EA);

  // Accents
  static const Color amber = Color(0xFFFFB800);
  static const Color ratingGreen = Color(0xFF1BA672);
  static const Color veg = Color(0xFF16A34A);
  static const Color nonVeg = Color(0xFFDC2626);

  // Text
  static const Color textPrimary = Color(0xFF12141D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9AA1AC);

  // Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF6F7F9);
  static const Color surfaceSunken = Color(0xFFEFF1F4);
  static const Color divider = Color(0xFFE8EAEE);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  /// Gradient used behind promotional banners.
  static const List<Color> promoGradient = <Color>[
    Color(0xFFFF7A3D),
    Color(0xFFFF5A1F),
  ];
}
