import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Glassmorphism-style card used throughout the Kosh app.
///
/// Features a frosted-glass background, subtle gradient border,
/// and optional glow effect. Designed for the dark futuristic theme.
///
/// ```dart
/// KoshCard(
///   child: Text('Balance'),
///   padding: EdgeInsets.all(AppSpacing.md),
/// )
/// ```
class KoshCard extends StatelessWidget {
  const KoshCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.showBorder = true,
    this.showGlow = false,
    this.glowColor,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Gradient? gradient;
  final bool showBorder;
  final bool showGlow;
  final Color? glowColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;
    final effectiveGlowColor = glowColor ?? AppColors.primary;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.cardGradient,
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? Border.all(
                    color: AppColors.glassBorder,
                    width: 1,
                  )
                : null,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: effectiveGlowColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: -4,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
