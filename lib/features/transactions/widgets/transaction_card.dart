import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../models/transaction_type.dart';

/// A single transaction row.
///
/// This is the one transaction presentation in the app — the dashboard feed
/// and the transactions list share it, so the same record never looks like two
/// different things.
///
/// The layout puts one fact in each place: what it was on the left, how much
/// on the right. The category is carried by the icon and the supporting line
/// rather than repeated in a separate chip.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionCollection transaction;
  final VoidCallback? onTap;

  static final DateFormat _dateFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome ? AppColors.success : AppColors.textPrimary;
    final categoryColor = transaction.category.color;
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
            padding: const EdgeInsets.all(AppSpacing.ms),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.category.icon,
                    color: categoryColor,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.title,
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.category.label}  ·  '
                        '${_dateFormat.format(transaction.date)}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  // Expenses carry the minus sign and stay neutral in colour;
                  // tinting every outgoing row red makes a normal month look
                  // like a wall of errors.
                  isIncome
                      ? CurrencyUtils.formatSigned(transaction.amount)
                      : '-${CurrencyUtils.format(transaction.amount)}',
                  style: AppTextStyles.amountSmall.copyWith(color: amountColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
