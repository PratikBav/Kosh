import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/cards/kosh_card.dart';

/// Top summary card showing aggregate goals data.
class GoalSummaryCard extends StatelessWidget {
  const GoalSummaryCard({
    super.key,
    required this.totalSaved,
    required this.totalTarget,
    required this.activeGoalsCount,
    required this.completedGoalsCount,
  });

  final double totalSaved;
  final double totalTarget;
  final int activeGoalsCount;
  final int completedGoalsCount;

  @override
  Widget build(BuildContext context) {
    final double overallPercentage = totalTarget > 0 
        ? (totalSaved / totalTarget) * 100 
        : 0.0;

    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Savings',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${overallPercentage.toStringAsFixed(1)}% Overall',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyUtils.format(totalSaved),
            style: AppTextStyles.amountLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Target: ${CurrencyUtils.format(totalTarget)}',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildStatBlock(
                title: 'Active Goals',
                value: activeGoalsCount.toString(),
                icon: Icons.track_changes_rounded,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.md),
              _buildStatBlock(
                title: 'Completed',
                value: completedGoalsCount.toString(),
                icon: Icons.workspace_premium_rounded,
                color: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.surfaceLight,
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBlock({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
