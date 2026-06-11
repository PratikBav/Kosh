import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/route_constants.dart';
import '../../transactions/models/transaction_type.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _ActionPill(
            icon: Icons.remove_circle_outline,
            label: 'Expense',
            color: AppColors.danger,
            onTap: () => context.pushNamed(
              RouteConstants.addTransaction,
              extra: {'type': TransactionType.expense},
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionPill(
            icon: Icons.add_circle_outline,
            label: 'Income',
            color: AppColors.success,
            onTap: () => context.pushNamed(
              RouteConstants.addTransaction,
              extra: {'type': TransactionType.income},
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionPill(
            icon: Icons.flag_circle_outlined,
            label: 'Goal',
            color: AppColors.primary,
            onTap: () => context.pushNamed(RouteConstants.addGoal),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionPill(
            icon: Icons.savings_outlined,
            label: 'Contribute',
            color: AppColors.secondary,
            onTap: () {
              // Can open a goal picker bottom sheet or just navigate to goals list
              context.goNamed(RouteConstants.goals);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: 
                FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
