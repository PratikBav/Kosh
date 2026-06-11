import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../gamification/viewmodel/gamification_viewmodel.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/dashboard_hero_header.dart';
import '../widgets/wealth_health_ring.dart';
import '../widgets/goal_spotlight_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/daily_motivation_card.dart';
import '../widgets/activity_feed.dart';
import '../widgets/streak_progress_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);
    final gamificationState = ref.watch(gamificationViewModelProvider);

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
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider.notifier).refreshDashboard(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Section 1: Hero Header
            SliverToBoxAdapter(
              child: DashboardHeroHeader(
                netSavings: summary.netSavings,
                monthlyChange: summary.monthlyIncome - summary.monthlyExpense,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Section 2: Wealth Health Ring
                  WealthHealthRing(score: summary.savingsRate)
                      .animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Section 3: Goal Spotlight
                  if (summary.topGoals.isNotEmpty) ...[
                    GoalSpotlightCard(goal: summary.topGoals.first)
                        .animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Section 4: Quick Actions
                  const QuickActionsRow()
                      .animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: AppSpacing.xl),

                  // Section 5: Streak & Progress
                  StreakProgressCard(gamificationState: gamificationState)
                      .animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSpacing.xl),

                  // Section 6: Daily Motivation
                  const DailyMotivationCard()
                      .animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: AppSpacing.xl),

                  // Section 7: Activity Feed
                  const Text('Activity', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  ActivityFeed(transactions: summary.recentTransactions)
                      .animate().fadeIn(delay: 600.ms),
                      
                  const SizedBox(height: 160), // Bottom padding for floating nav
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
