import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/currency_utils.dart';

/// Top of the dashboard: greeting, net worth, and this month at a glance.
///
/// The balance is the single focal point — everything else here is sized to
/// support it rather than compete with it.
class DashboardHeroHeader extends StatelessWidget {
  const DashboardHeroHeader({
    super.key,
    required this.netSavings,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  final double netSavings;
  final double monthlyIncome;
  final double monthlyExpense;

  double get _monthlyChange => monthlyIncome - monthlyExpense;

  /// Greeting for the current part of the day.
  ///
  /// Previously a hardcoded "Good Evening, Pratik" — wrong for most of the day,
  /// and wrong for anyone who is not Pratik.
  static String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = _monthlyChange >= 0;
    final changeColor = isPositive ? AppColors.success : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.md,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // A tint of the accent rather than a full-strength block, so the
            // balance stays the brightest thing on the screen.
            Color.alphaBlend(
              AppColors.primary.withValues(alpha: 0.22),
              AppColors.background,
            ),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _greeting(DateTime.now()),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _HeaderAction(
                icon: Icons.emoji_events_outlined,
                tooltip: 'Your progress',
                onTap: () =>
                    context.pushNamed(RouteConstants.profileProgress),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Net worth', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyUtils.format(netSavings),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: changeColor,
                size: AppSpacing.iconSm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                CurrencyUtils.formatSigned(_monthlyChange),
                style: AppTextStyles.bodyBold.copyWith(color: changeColor),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text('this month', style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MonthStat(
                  label: 'Income',
                  amount: monthlyIncome,
                  color: AppColors.success,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MonthStat(
                  label: 'Spent',
                  amount: monthlyExpense,
                  color: AppColors.danger,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: AppSpacing.iconMd,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// One half of the income/spend split beneath the balance.
class _MonthStat extends StatelessWidget {
  const _MonthStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.ms,
        vertical: AppSpacing.ms,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    CurrencyUtils.format(amount),
                    style: AppTextStyles.amountSmall,
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
