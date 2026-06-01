import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/finance_calculator_service.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/kosh_textfield.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

/// Main screen for transactions list.
class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded),
                if (hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterSheet(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadTransactions(),
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLight,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: KoshTextField(
                  hint: 'Search by title or notes...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (value) => viewModel.searchTransactions(value),
                  suffixIcon: state.searchQuery.isNotEmpty ? Icons.close_rounded : null,
                  onSuffixTap: () {
                    viewModel.searchTransactions('');
                  },
                ),
              ),
            ),

            // Summary Card
            if (state.searchQuery.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: SummaryCard(
                    totalIncome: summary['income'] ?? 0,
                    totalExpense: summary['expense'] ?? 0,
                    netSavings: summary['net'] ?? 0,
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
                ),
              ),

            // Transactions List or Empty State
            if (state.isLoading && state.transactions.isEmpty)
              const SliverFillRemaining(
                child: LoadingIndicator(message: 'Loading transactions...'),
              )
            else if (state.filteredTransactions.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: hasActiveFilters ? Icons.search_off_rounded : Icons.swap_horiz_rounded,
                  title: hasActiveFilters ? 'No matches found' : 'No Transactions Yet',
                  description: hasActiveFilters
                      ? 'Try adjusting your filters or search query.'
                      : 'Your income and expenses will appear here.\nStart tracking your finances!',
                  actionLabel: hasActiveFilters ? 'Clear Filters' : 'Add Transaction',
                  onAction: () {
                    if (hasActiveFilters) {
                      viewModel.setTypeFilter(null);
                      viewModel.setCategoryFilter(null);
                      viewModel.searchTransactions('');
                    } else {
                      context.pushNamed(RouteConstants.addTransaction);
                    }
                  },
                ).animate().fadeIn(duration: 500.ms),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = state.filteredTransactions[index];
                      return TransactionCard(
                        transaction: transaction,
                        onTap: () {
                          context.pushNamed(
                            RouteConstants.transactionDetails,
                            pathParameters: {'id': transaction.id.toString()},
                          );
                        },
                      ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
                    },
                    childCount: state.filteredTransactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transactions_fab',
        onPressed: () => context.pushNamed(RouteConstants.addTransaction),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
