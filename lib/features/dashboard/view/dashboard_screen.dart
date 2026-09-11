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
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/activity_feed.dart';
import '../widgets/daily_motivation_card.dart';
import '../widgets/dashboard_hero_header.dart';
import '../widgets/goal_spotlight_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/section_header.dart';
import '../widgets/streak_progress_card.dart';
import '../widgets/wealth_health_ring.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  /// Clearance for the floating navigation bar so the last card is not
  /// trapped behind it.
  static const double _navBarClearance = 120;

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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ),
        ),
      );
    }

    final summary = state.summary!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(dashboardViewModelProvider.notifier).refreshDashboard(),
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceLight,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHeroHeader(
                netSavings: summary.netSavings,
                monthlyIncome: summary.monthlyIncome,
                monthlyExpense: summary.monthlyExpense,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                _navBarClearance,
              ),
              sliver: SliverList.list(
                children: [
                  const QuickActionsRow(),
                  const SizedBox(height: AppSpacing.lg),

                  WealthHealthRing(score: summary.savingsRate),
                  const SizedBox(height: AppSpacing.lg),

                  if (summary.topGoals.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Goal in focus',
                      action: 'All goals',
                      onActionPressed: () =>
                          context.goNamed(RouteConstants.goals),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GoalSpotlightCard(goal: summary.topGoals.first),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  StreakProgressCard(gamificationState: gamificationState),
                  const SizedBox(height: AppSpacing.lg),

                  SectionHeader(
                    title: 'Recent activity',
                    action: 'See all',
                    onActionPressed: () =>
                        context.goNamed(RouteConstants.transactions),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ActivityFeed(transactions: summary.recentTransactions),
                  const SizedBox(height: AppSpacing.lg),

                  const DailyMotivationCard(),
                ],
              ),
            ),
          ],
        ),
      )
          // One short fade for the page rather than a staggered entrance per
          // section. The dashboard rebuilds whenever the database changes, and
          // per-section animations replayed in full on every one of those.
          .animate()
          .fadeIn(duration: 220.ms),
    );
  }
}
