import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/cards/kosh_card.dart';

/// Displays the monthly summary: Total Income, Total Expense, Net Savings.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
  });

  final double totalIncome;
  final double totalExpense;
  final double netSavings;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      showGlow: true,
      glowColor: netSavings >= 0 ? AppColors.success : AppColors.danger,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn('Total Income', currencyFormat.format(totalIncome), AppColors.success),
              _buildStatColumn('Total Expense', currencyFormat.format(totalExpense), AppColors.danger),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: AppColors.surfaceBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Savings',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                currencyFormat.format(netSavings),
                style: AppTextStyles.title.copyWith(
                  color: netSavings >= 0 ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.amountMedium.copyWith(color: color),
        ),
      ],
    );
  }
}
