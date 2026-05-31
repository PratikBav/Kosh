import 'package:flutter/material.dart';

/// Kosh futuristic dark color palette.
///
/// All colors are defined here as static constants so they can be
/// referenced from [AppTheme], widgets, and feature modules without
/// hard-coding hex values elsewhere.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Core Backgrounds ──────────────────────────────────────────────
  static const Color background = Color(0xFF0B0F1A);
  static const Color surface = Color(0xFF131A2A);
  static const Color surfaceLight = Color(0xFF1B2438);
  static const Color surfaceBorder = Color(0xFF1E2A40);

  // ── Accent Colors ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryLight = Color(0xFF9D8AFF);
  static const Color primaryDark = Color(0xFF5A3FE6);

  static const Color secondary = Color(0xFF00C2FF);
  static const Color secondaryLight = Color(0xFF4DD4FF);
  static const Color secondaryDark = Color(0xFF0099CC);

  // ── Semantic Colors ───────────────────────────────────────────────
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  // ── Text Colors ───────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAAB0C0);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4A5060);

  // ── Gradients ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
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

  // ── Glassmorphism ─────────────────────────────────────────────────
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.08);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.12);

  // ── Shimmer / Skeleton ────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFF1A2235);
  static const Color shimmerHighlight = Color(0xFF243045);

  // ── Bottom Nav ────────────────────────────────────────────────────
  static const Color navBarBackground = Color(0xFF0D1220);
  static const Color navBarActive = primary;
  static const Color navBarInactive = textTertiary;
}
