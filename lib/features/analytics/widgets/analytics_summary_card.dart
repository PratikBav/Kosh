import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({super.key, required this.summary});

  final Map<String, double> summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStat('Income', summary['income'] ?? 0, AppColors.success, Icons.arrow_downward_rounded)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStat('Expense', summary['expense'] ?? 0, AppColors.danger, Icons.arrow_upward_rounded)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStat('Savings', summary['savings'] ?? 0, AppColors.secondary, Icons.account_balance_wallet_rounded)),
      ],
    );
  }

  Widget _buildStat(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.label.copyWith(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            CurrencyUtils.format(amount),
            style: AppTextStyles.title.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
