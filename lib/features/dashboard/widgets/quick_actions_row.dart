import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../transactions/models/transaction_type.dart';

/// The four things people open the app to do.
///
/// Laid out as an even row rather than a horizontal scroller — with only four
/// actions, scrolling hid a quarter of them behind a gesture for no reason.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.remove_rounded,
            label: 'Expense',
            color: AppColors.danger,
            onTap: () => context.pushNamed(
              RouteConstants.addTransaction,
              extra: {'type': TransactionType.expense},
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            icon: Icons.add_rounded,
            label: 'Income',
            color: AppColors.success,
            onTap: () => context.pushNamed(
              RouteConstants.addTransaction,
              extra: {'type': TransactionType.income},
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            icon: Icons.flag_outlined,
            label: 'Goal',
            color: AppColors.primary,
            onTap: () => context.pushNamed(RouteConstants.addGoal),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionTile(
            icon: Icons.savings_outlined,
            label: 'Save',
            color: AppColors.secondary,
            onTap: () => context.goNamed(RouteConstants.goals),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusLg);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.ms),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: AppSpacing.iconMd),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
