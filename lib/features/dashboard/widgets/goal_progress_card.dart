import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/goal_calculator_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../shared/cards/kosh_card.dart';
import '../../goals/widgets/goal_progress_ring.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({super.key, required this.goal, required this.onTap});

  final GoalCollection goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = GoalCalculatorService.getCompletionPercentage(goal.currentAmount, goal.targetAmount);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: KoshCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            GoalProgressRing(
              percentage: percentage,
              color: goal.category.color,
              size: 50,
              strokeWidth: 5,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyUtils.format(goal.currentAmount)} / ${CurrencyUtils.format(goal.targetAmount)}',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: goal.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${percentage.toInt()}%',
                style: AppTextStyles.caption.copyWith(
                  color: goal.category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
