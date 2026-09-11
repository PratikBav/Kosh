import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// The standard surface container used throughout Kosh.
///
/// A flat, bordered panel rather than a frosted one: the app background is
/// opaque, so a backdrop blur had nothing to sample and only cost a GPU pass
/// per card while softening the edges it was meant to define.
///
/// ```dart
/// KoshCard(
///   onTap: _openDetails,
///   child: Text('Balance'),
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
    this.color,
    this.showBorder = true,
    this.borderColor,
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

  /// Overrides the flat [color] when a card needs emphasis.
  final Gradient? gradient;

  final Color? color;
  final bool showBorder;
  final Color? borderColor;
  final bool showGlow;
  final Color? glowColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? AppSpacing.radiusXl);
    final effectiveGlow = glowColor ?? AppColors.primary;

    Widget card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.surfaceBorder)
            : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: effectiveGlow.withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: -6,
                ),
              ]
            : null,
      ),
      child: Material(
        // Transparent Material lets the ink ripple paint over the decoration
        // above without a second opaque layer hiding the border.
        type: MaterialType.transparency,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
