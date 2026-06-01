import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/goal_calculator_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../shared/cards/kosh_card.dart';
import 'goal_progress_ring.dart';

/// Card displaying a brief overview of a single goal.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  final GoalCollection goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentage = GoalCalculatorService.getCompletionPercentage(
      goal.currentAmount,
      goal.targetAmount,
    );
    final daysLeft = GoalCalculatorService.getDaysLeft(goal.deadline);

    return KoshCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GoalProgressRing(
            percentage: percentage,
            color: goal.category.color,
            size: 50.0,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (goal.isCompleted)
                      Icon(Icons.check_circle, color: AppColors.success, size: 16)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: goal.priority.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: goal.priority.color.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          goal.priority.label,
                          style: AppTextStyles.caption.copyWith(
                            color: goal.priority.color,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${CurrencyUtils.format(goal.currentAmount)} / ${CurrencyUtils.format(goal.targetAmount)}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  goal.isCompleted 
                    ? 'Goal Reached! 🎉' 
                    : daysLeft > 0 
                        ? '$daysLeft Days Left' 
                        : 'Deadline Passed',
                  style: AppTextStyles.label.copyWith(
                    color: goal.isCompleted 
                        ? AppColors.success 
                        : (daysLeft > 0 ? AppColors.primary : AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
