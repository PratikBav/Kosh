import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/cards/kosh_card.dart';

class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({
    super.key,
    required this.savingsRate,
    required this.activeGoals,
    required this.completedGoals,
  });

  final double savingsRate;
  final int activeGoals;
  final int completedGoals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KoshCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Savings Rate', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${savingsRate.toInt()}%',
                      style: AppTextStyles.amountMedium.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: KoshCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goals', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$activeGoals Active',
                  style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
