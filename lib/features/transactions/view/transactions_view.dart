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
import '../models/transaction_type.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../../settings/viewmodel/theme_viewmodel.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/transaction_card.dart';

/// Main screen for transactions list.
class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

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
            icon: const Icon(Icons.download_rounded),
            onPressed: () {
              // Future export feature
            },
          ),
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
                      decoration: BoxDecoration(
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
            // Search Bar & Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    KoshTextField(
                      hint: 'Search transactions...',
                      prefixIcon: Icons.search_rounded,
                      onChanged: (value) => viewModel.searchTransactions(value),
                      suffixIcon: state.searchQuery.isNotEmpty ? Icons.close_rounded : null,
                      onSuffixTap: () {
                        viewModel.searchTransactions('');
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildFilterChip('All', state.selectedTypeFilter == null, () => viewModel.setTypeFilter(null)),
                          const SizedBox(width: 8),
                          _buildFilterChip('Income', state.selectedTypeFilter == TransactionType.income, () => viewModel.setTypeFilter(TransactionType.income)),
                          const SizedBox(width: 8),
                          _buildFilterChip('Expense', state.selectedTypeFilter == TransactionType.expense, () => viewModel.setTypeFilter(TransactionType.expense)),
                          const SizedBox(width: 8),
                          ActionChip(
                            label: const Text('Categories'),
                            avatar: const Icon(Icons.category_rounded, size: 16),
                            backgroundColor: AppColors.surfaceLight,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Summary Cards
            if (state.searchQuery.isEmpty && !hasActiveFilters)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      _buildSummaryStatCard('Income', summary['income'] ?? 0, AppColors.success, Icons.arrow_downward_rounded),
                      const SizedBox(width: AppSpacing.md),
                      _buildSummaryStatCard('Expense', summary['expense'] ?? 0, AppColors.danger, Icons.arrow_upward_rounded),
                      const SizedBox(width: AppSpacing.md),
                      _buildSummaryStatCard('Net Savings', summary['net'] ?? 0, AppColors.primary, Icons.account_balance_wallet_rounded),
                    ],
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: TransactionCard(
                          transaction: transaction,
                          onTap: () {
                            context.pushNamed(
                              RouteConstants.transactionDetails,
                              pathParameters: {'id': transaction.id.toString()},
                            );
                          },
                        ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.05, end: 0),
                      );
                    },
                    childCount: state.filteredTransactions.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 160)), // FAB padding
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton(
          heroTag: 'transactions_fab',
          onPressed: () => context.pushNamed(RouteConstants.addTransaction),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.surfaceLight,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: isSelected ? BorderSide(color: AppColors.primary) : BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildSummaryStatCard(String title, double amount, Color color, IconData icon) {
    // We should ideally inject NumberFormat, but inline for now
    final formattedAmount = '₹${amount.toStringAsFixed(0)}';
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formattedAmount,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
