import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/cards/kosh_card.dart';

class FinancialOverviewCard extends StatelessWidget {
  const FinancialOverviewCard({
    super.key,
    required this.netSavings,
    required this.income,
    required this.expense,
  });

  final double netSavings;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Savings', style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
              Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyUtils.format(netSavings),
            style: AppTextStyles.amountLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _buildStatBlock(
                title: 'Income',
                amount: income,
                icon: Icons.arrow_upward_rounded,
                color: AppColors.success,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.surfaceBorder,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              _buildStatBlock(
                title: 'Expense',
                amount: expense,
                icon: Icons.arrow_downward_rounded,
                color: AppColors.danger,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatBlock({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.format(amount),
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
