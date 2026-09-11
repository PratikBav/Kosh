import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/cards/kosh_card.dart';

/// Savings rate for the current month, shown as a progress ring.
class WealthHealthRing extends StatelessWidget {
  const WealthHealthRing({super.key, required this.score});

  /// Percentage of this month's income kept, 0-100.
  final double score;

  Color get _color {
    if (score <= 30) return AppColors.danger;
    if (score <= 60) return AppColors.warning;
    if (score <= 80) return AppColors.secondary;
    return AppColors.success;
  }

  String get _label {
    if (score <= 30) return 'Needs attention';
    if (score <= 60) return 'Fair';
    if (score <= 80) return 'Good';
    return 'Excellent';
  }

  /// Says what the number actually means, so the ring is not just a colour.
  String get _description {
    if (score <= 0) return 'No savings recorded this month yet';
    return 'You kept ${score.toStringAsFixed(0)}% of this month’s income';
  }

  @override
  Widget build(BuildContext context) {
    return KoshCard(
      child: Row(
        children: [
          SizedBox(
            height: 72,
            width: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Clamped so an out-of-range value cannot overdraw the arc.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: (score / 100).clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 7,
                    backgroundColor: AppColors.surfaceLight,
                    color: _color,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Text(
                    '${score.toStringAsFixed(0)}%',
                    style: AppTextStyles.titleSmall.copyWith(color: _color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Savings rate', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(_label, style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(_description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
