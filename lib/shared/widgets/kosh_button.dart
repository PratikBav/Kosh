import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';

/// Button variant types for [KoshButton].
enum KoshButtonVariant {
  /// Filled gradient button (primary action).
  primary,

  /// Outlined button with accent border.
  secondary,

  /// Text-only button with no background or border.
  ghost,
}

/// Styled button component used throughout the Kosh app.
///
/// Supports three variants: [KoshButtonVariant.primary] (gradient fill),
/// [KoshButtonVariant.secondary] (outlined), and
/// [KoshButtonVariant.ghost] (text-only).
///
/// ```dart
/// KoshButton(
///   label: 'Add Transaction',
///   onPressed: () {},
///   variant: KoshButtonVariant.primary,
///   icon: Icons.add,
/// )
/// ```
class KoshButton extends StatelessWidget {
  const KoshButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KoshButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.isDisabled = false,
    this.height,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final KoshButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final bool isDisabled;
  final double? height;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;
    final opacity = isDisabled ? 0.5 : 1.0;

    Widget button;

    switch (variant) {
      case KoshButtonVariant.primary:
        button = _buildPrimaryButton(effectiveOnPressed);
      case KoshButtonVariant.secondary:
        button = _buildSecondaryButton(effectiveOnPressed);
      case KoshButtonVariant.ghost:
        button = _buildGhostButton(effectiveOnPressed);
    }

    return Opacity(
      opacity: opacity,
      child: isExpanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }

  Widget _buildPrimaryButton(VoidCallback? onPressed) {
    return Container(
      height: height ?? 48,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : AppColors.primaryGradient,
        color: isDisabled ? AppColors.surfaceLight : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: _buildContent(AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(VoidCallback? onPressed) {
    return SizedBox(
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: _buildContent(AppColors.primary),
      ),
    );
  }

  Widget _buildGhostButton(VoidCallback? onPressed) {
    return SizedBox(
      height: height ?? 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: _buildContent(AppColors.primary),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
        ),
      );
    }

    final textStyle = AppTextStyles.button.copyWith(
      color: color,
      fontSize: fontSize,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: textStyle),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Text(label, style: textStyle),
    );
  }
}
