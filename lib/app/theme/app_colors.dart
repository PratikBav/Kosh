import 'package:flutter/material.dart';

/// Kosh futuristic dark color palette.
///
/// Most background colors are static const, but Accent colors
/// can be dynamically changed.
class AppColors {
  AppColors._(); // prevent instantiation

  static const Color background = Color(0xFF0B0F1A);
  static const Color surface = Color(0xFF131A2A);
  static const Color surfaceLight = Color(0xFF1B2438);
  static const Color surfaceBorder = Color(0xFF1E2A40);

  static Color primary = const Color(0xFFA855F7); // Default: Vibrant Purple
  static Color primaryLight = const Color(0xFFC084FC);
  static Color primaryDark = const Color(0xFF7E22CE);

  static Color secondary = const Color(0xFF06B6D4); // Default: Vibrant Cyan
  static Color secondaryLight = const Color(0xFF22D3EE);
  static Color secondaryDark = const Color(0xFF0891B2);

  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAAB0C0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4A5060);

  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, Color(0xFF0E1422)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF1A2235),
      Color(0xFF131A2A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color glassBackground = Colors.white.withValues(alpha: 0.03);
  static Color glassBorder = Colors.white.withValues(alpha: 0.05);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.1);

  static const Color shimmerBase = Color(0xFF1A2235);
  static const Color shimmerHighlight = Color(0xFF243045);

  static const Color navBarBackground = Color(0xFF0D1220);
  static Color get navBarActive => primary;
  static const Color navBarInactive = textTertiary;

  static void setAccentColor(AppAccentColor accent) {
    switch (accent) {
      case AppAccentColor.purple:
        primary = const Color(0xFFA855F7);
        primaryLight = const Color(0xFFC084FC);
        primaryDark = const Color(0xFF7E22CE);
        secondary = const Color(0xFF06B6D4);
        secondaryLight = const Color(0xFF22D3EE);
        secondaryDark = const Color(0xFF0891B2);
        break;
      case AppAccentColor.emerald:
        primary = const Color(0xFF10B981);
        primaryLight = const Color(0xFF34D399);
        primaryDark = const Color(0xFF047857);
        secondary = const Color(0xFF3B82F6);
        secondaryLight = const Color(0xFF60A5FA);
        secondaryDark = const Color(0xFF1D4ED8);
        break;
      case AppAccentColor.rose:
        primary = const Color(0xFFF43F5E);
        primaryLight = const Color(0xFFFB7185);
        primaryDark = const Color(0xFFBE123C);
        secondary = const Color(0xFFF59E0B);
        secondaryLight = const Color(0xFFFBBF24);
        secondaryDark = const Color(0xFFB45309);
        break;
      case AppAccentColor.cyan:
        primary = const Color(0xFF06B6D4);
        primaryLight = const Color(0xFF22D3EE);
        primaryDark = const Color(0xFF0891B2);
        secondary = const Color(0xFF8B5CF6);
        secondaryLight = const Color(0xFFA78BFA);
        secondaryDark = const Color(0xFF5B21B6);
        break;
      case AppAccentColor.gold:
        primary = const Color(0xFFF59E0B);
        primaryLight = const Color(0xFFFBBF24);
        primaryDark = const Color(0xFFB45309);
        secondary = const Color(0xFF10B981);
        secondaryLight = const Color(0xFF34D399);
        secondaryDark = const Color(0xFF047857);
        break;
    }
  }

  static void setCustomAccentColor(Color customColor) {
    primary = customColor;
    
    final hsl = HSLColor.fromColor(customColor);
    
    primaryLight = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    primaryDark = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    
    // Create an analogous secondary color by shifting hue
    final secondaryHue = (hsl.hue + 45.0) % 360.0;
    final secondaryHsl = hsl.withHue(secondaryHue);
    
    secondary = secondaryHsl.toColor();
    secondaryLight = secondaryHsl.withLightness((secondaryHsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    secondaryDark = secondaryHsl.withLightness((secondaryHsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}

enum AppAccentColor {
  purple,
  emerald,
  rose,
  cyan,
  gold,
}
