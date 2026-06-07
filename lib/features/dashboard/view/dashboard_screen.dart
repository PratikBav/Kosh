import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../gamification/viewmodel/gamification_viewmodel.dart';
import '../../gamification/widgets/gamification_banner.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../../vision_board/viewmodel/vision_board_viewmodel.dart';
import '../../vision_board/widgets/vision_banner.dart';
import '../../vision_board/widgets/vision_card.dart';
import '../widgets/financial_overview_card.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final visionState = ref.watch(visionBoardViewModelProvider);

    if (state.isLoading && state.summary == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (state.error != null && state.summary == null) {
      return Scaffold(
        body: Center(
          child: Text(state.error!, style: AppTextStyles.body.copyWith(color: AppColors.danger)),
        ),
      );
    }

    final summary = state.summary!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, Pratik'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => context.pushNamed(RouteConstants.addTransaction),
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refreshDashboard(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GamificationBanner(state: ref.watch(gamificationViewModelProvider)),
                    const SizedBox(height: AppSpacing.md),
                    
                    const VisionBanner().animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: AppSpacing.md),
                    FinancialOverviewCard(
                      netSavings: summary.netSavings,
                      income: summary.totalIncome,
                      expense: summary.totalExpense,
                    ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut).fadeIn(),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    QuickStatsCard(
                      savingsRate: summary.savingsRate,
                      activeGoals: summary.activeGoals,
                      completedGoals: summary.completedGoals,
                    ).animate().slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOut).fadeIn(),

                    const SizedBox(height: AppSpacing.xl),

                    if (visionState.pinnedItems.isNotEmpty) ...[
                      SectionHeader(
                        title: 'Dreams In Progress',
                        action: 'Vision Board',
                        onActionPressed: () => context.goNamed(RouteConstants.visionBoard),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 240, // Fixed height for horizontal scroll
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: visionState.pinnedItems.length,
                          separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 200, // Fixed width for each card
                              child: VisionCard(vision: visionState.pinnedItems[index]),
                            );
                          },
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: AppSpacing.xl),
                    ],

                    if (summary.topGoals.isEmpty) ...[
                      SectionHeader(title: 'Goals'),
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Create your first financial goal.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ] else ...[
                      SectionHeader(
                        title: 'Goals',
                        action: 'View All',
                        onActionPressed: () => context.goNamed(RouteConstants.goals),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...summary.topGoals.map((goal) => GoalProgressCard(
                        goal: goal,
                        onTap: () => context.goNamed(
                          RouteConstants.goalDetails,
                          pathParameters: {'id': goal.id.toString()},
                        ),
                      )).toList().animate(interval: 100.ms).fadeIn(duration: 400.ms),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    if (summary.recentTransactions.isEmpty) ...[
                      SectionHeader(title: 'Recent Transactions'),
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'Start tracking your finances.',
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ] else ...[
                      SectionHeader(
                        title: 'Recent Transactions',
                        action: 'View All',
                        onActionPressed: () => context.goNamed(RouteConstants.transactions),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RecentTransactionsCard(
                        transactions: summary.recentTransactions,
                      ).animate().fadeIn(duration: 500.ms),
                    ],

                    const SizedBox(height: 100), // FAB spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
