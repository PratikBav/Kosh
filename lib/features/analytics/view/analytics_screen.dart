import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../dashboard/widgets/section_header.dart';
import '../viewmodel/analytics_state.dart';
import '../viewmodel/analytics_viewmodel.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/pie_chart_card.dart';
import '../widgets/trend_chart_card.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: false,
        actions: [
          PopupMenuButton<TimeFilter>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (filter) => ref.read(analyticsViewModelProvider.notifier).setTimeFilter(filter),
            itemBuilder: (context) => TimeFilter.values.map((f) {
              return PopupMenuItem(
                value: f,
                child: Row(
                  children: [
                    if (state.selectedTimeFilter == f)
                      Icon(Icons.check, color: AppColors.primary, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(f.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: state.isLoading && state.expenseBreakdown.isEmpty
          ? const LoadingIndicator()
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: AppColors.danger)))
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Showing data for: ${state.selectedTimeFilter.label}',
                              style: AppTextStyles.label.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            AnalyticsSummaryCard(summary: state.overallSummary)
                                .animate().slideY(begin: 0.1).fadeIn(),

                            const SizedBox(height: AppSpacing.xl),
                            
                            const SectionHeader(title: 'Expense Breakdown'),
                            const SizedBox(height: AppSpacing.sm),
                            PieChartCard(
                              title: 'Where your money went',
                              data: state.expenseBreakdown,
                            ).animate().fadeIn(delay: 100.ms),

                            const SizedBox(height: AppSpacing.xl),

                            const SectionHeader(title: 'Monthly Expenses'),
                            const SizedBox(height: AppSpacing.sm),
                            TrendChartCard(
                              title: 'Spending over time',
                              data: state.monthlyTrends,
                              isSavingsRate: false,
                            ).animate().fadeIn(delay: 200.ms),

                            const SizedBox(height: AppSpacing.xl),

                            const SectionHeader(title: 'Savings Rate'),
                            const SizedBox(height: AppSpacing.sm),
                            TrendChartCard(
                              title: 'Savings vs Income',
                              data: state.monthlyTrends,
                              isSavingsRate: true,
                            ).animate().fadeIn(delay: 300.ms),

                            const SizedBox(height: AppSpacing.xl),

                            const SectionHeader(title: 'Income Sources'),
                            const SizedBox(height: AppSpacing.sm),
                            PieChartCard(
                              title: 'Where your money came from',
                              data: state.incomeSources,
                            ).animate().fadeIn(delay: 400.ms),

                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
