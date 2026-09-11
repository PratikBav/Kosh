import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/finance_calculator_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/kosh_textfield.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../models/transaction_type.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../../settings/viewmodel/theme_viewmodel.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/transaction_card.dart';

/// Main screen for the transactions list.
class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  /// Clearance for the floating navigation bar and FAB.
  static const double _navBarClearance = 140;
  static const double _fabLift = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeViewModelProvider);
    final state = ref.watch(transactionViewModelProvider);
    final viewModel = ref.read(transactionViewModelProvider.notifier);
    final calculator = ref.watch(financeCalculatorServiceProvider);

    final summary = calculator.getMonthlySummary(state.transactions);
    final hasActiveFilters = state.selectedTypeFilter != null ||
        state.selectedCategoryFilter != null ||
        state.searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              backgroundColor: AppColors.primary,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: () => _openFilterSheet(context),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.loadTransactions,
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLight,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    KoshTextField(
                      hint: 'Search transactions',
                      prefixIcon: Icons.search_rounded,
                      onChanged: viewModel.searchTransactions,
                      suffixIcon: state.searchQuery.isNotEmpty
                          ? Icons.close_rounded
                          : null,
                      onSuffixTap: () => viewModel.searchTransactions(''),
                    ),
                    const SizedBox(height: AppSpacing.ms),
                    Row(
                      children: [
                        _TypeChip(
                          label: 'All',
                          isSelected: state.selectedTypeFilter == null,
                          onTap: () => viewModel.setTypeFilter(null),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _TypeChip(
                          label: 'Income',
                          isSelected: state.selectedTypeFilter ==
                              TransactionType.income,
                          onTap: () =>
                              viewModel.setTypeFilter(TransactionType.income),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _TypeChip(
                          label: 'Expense',
                          isSelected: state.selectedTypeFilter ==
                              TransactionType.expense,
                          onTap: () =>
                              viewModel.setTypeFilter(TransactionType.expense),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // The month summary is only meaningful over the unfiltered set.
            if (!hasActiveFilters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryStat(
                          label: 'Income',
                          amount: summary['income'] ?? 0,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SummaryStat(
                          label: 'Spent',
                          amount: summary['expense'] ?? 0,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SummaryStat(
                          label: 'Net',
                          amount: summary['net'] ?? 0,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

            if (state.isLoading && state.transactions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: LoadingIndicator(message: 'Loading transactions...'),
              )
            else if (state.filteredTransactions.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: hasActiveFilters
                      ? Icons.search_off_rounded
                      : Icons.swap_horiz_rounded,
                  title: hasActiveFilters
                      ? 'No matches found'
                      : 'No transactions yet',
                  description: hasActiveFilters
                      ? 'Try adjusting your filters or search.'
                      : 'Your income and expenses will appear here.',
                  actionLabel:
                      hasActiveFilters ? 'Clear filters' : 'Add transaction',
                  onAction: () {
                    if (hasActiveFilters) {
                      viewModel.setTypeFilter(null);
                      viewModel.setCategoryFilter(null);
                      viewModel.searchTransactions('');
                    } else {
                      context.pushNamed(RouteConstants.addTransaction);
                    }
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  _navBarClearance,
                ),
                sliver: SliverList.separated(
                  itemCount: state.filteredTransactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final transaction = state.filteredTransactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      onTap: () => context.pushNamed(
                        RouteConstants.transactionDetails,
                        pathParameters: {'id': transaction.id.toString()},
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: _fabLift),
        child: FloatingActionButton(
          heroTag: 'transactions_fab',
          tooltip: 'Add transaction',
          onPressed: () => context.pushNamed(RouteConstants.addTransaction),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterSheet(),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      labelStyle: AppTextStyles.captionBold.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
      ),
      shape: const StadiumBorder(),
    );
  }
}

/// One figure in the month summary row.
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              // Compact so a large figure cannot overflow a third of the row.
              CurrencyUtils.formatCompact(amount),
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
