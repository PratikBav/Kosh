import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../database/collections/contribution_collection.dart';
import '../../../../shared/cards/kosh_card.dart';

/// Tile displaying a single contribution in the history list.
class ContributionTile extends StatelessWidget {
  const ContributionTile({super.key, required this.contribution});

  final ContributionCollection contribution;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: KoshCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contribution.note != null && contribution.note!.isNotEmpty
                        ? contribution.note!
                        : 'Contribution',
                    style: AppTextStyles.bodyBold,
                  ),
                  Text(
                    DateFormat.yMMMd().format(contribution.date),
                    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '+${CurrencyUtils.format(contribution.amount)}',
              style: AppTextStyles.title.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
