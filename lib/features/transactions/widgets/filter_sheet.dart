import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/kosh_button.dart';
import '../models/transaction_category.dart';
import '../models/transaction_type.dart';
import '../viewmodel/transaction_state.dart';
import '../viewmodel/transaction_viewmodel.dart';

/// Bottom sheet for filtering transactions.
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionViewModelProvider);
    final viewModel = ref.read(transactionViewModelProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filters', style: AppTextStyles.headline),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Date Range
            const Text('Date Range', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: DateRangeFilter.values.map((range) {
                final isSelected = state.selectedDateRange == range;
                return ChoiceChip(
                  label: Text(range.label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      viewModel.setDateRangeFilter(range);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Type
            const Text('Type', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: state.selectedTypeFilter == null,
                  onSelected: (s) {
                    if (s) viewModel.setTypeFilter(null);
                  },
                ),
                ...TransactionType.values.map((type) {
                  return ChoiceChip(
                    label: Text(type.label),
                    selected: state.selectedTypeFilter == type,
                    onSelected: (s) {
                      if (s) viewModel.setTypeFilter(type);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Category
            const Text('Category', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: state.selectedCategoryFilter == null,
                  onSelected: (s) {
                    if (s) viewModel.setCategoryFilter(null);
                  },
                ),
                ...TransactionCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: state.selectedCategoryFilter == cat,
                    onSelected: (s) {
                      if (s) viewModel.setCategoryFilter(cat);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: KoshButton(
                    label: 'Clear Filters',
                    variant: KoshButtonVariant.secondary,
                    onPressed: () {
                      viewModel.setTypeFilter(null);
                      viewModel.setCategoryFilter(null);
                      viewModel.setDateRangeFilter(DateRangeFilter.thisMonth);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: KoshButton(
                    label: 'Apply',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
