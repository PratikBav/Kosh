import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/cards/kosh_card.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({super.key, required this.summary});

  final Map<String, double> summary;

  @override
  Widget build(BuildContext context) {
    return KoshCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Income', summary['income'] ?? 0, AppColors.success),
          _buildStat('Expense', summary['expense'] ?? 0, AppColors.danger),
          _buildStat('Savings', summary['savings'] ?? 0, AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildStat(String title, double amount, Color color) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(
          CurrencyUtils.format(amount),
          style: AppTextStyles.title.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
