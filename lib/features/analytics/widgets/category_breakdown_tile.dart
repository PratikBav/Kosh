import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_utils.dart';
import '../models/category_summary.dart';

class CategoryBreakdownTile extends StatelessWidget {
  const CategoryBreakdownTile({super.key, required this.summary});

  final CategorySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: summary.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              summary.name,
              style: AppTextStyles.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            CurrencyUtils.format(summary.totalAmount),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
