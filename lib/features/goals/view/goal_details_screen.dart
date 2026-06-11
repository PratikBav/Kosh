import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/goal_calculator_service.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../viewmodel/goal_details_viewmodel.dart';
import '../widgets/contribution_tile.dart';
import '../widgets/goal_progress_ring.dart';

class GoalDetailsScreen extends ConsumerWidget {
  const GoalDetailsScreen({super.key, required this.goalId});

  final int goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalDetailsViewModelProvider(goalId));

    if (state.isLoading && state.goal == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (state.error != null || state.goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(state.error ?? 'Goal not found')),
      );
    }

    final goal = state.goal!;
    final percentage = GoalCalculatorService.getCompletionPercentage(
      goal.currentAmount,
      goal.targetAmount,
    );
    final remaining = GoalCalculatorService.getRemainingAmount(
      goal.currentAmount,
      goal.targetAmount,
    );
    final daysLeft = GoalCalculatorService.getDaysLeft(goal.deadline);
    final monthlyReq = GoalCalculatorService.getMonthlyRequirement(
      goal.currentAmount,
      goal.targetAmount,
      goal.deadline,
    );

    return Scaffold(
      floatingActionButton: goal.isCompleted
          ? null
          : FloatingActionButton.extended(
              heroTag: 'goal_details_fab_${goal.id}',
              backgroundColor: AppColors.primary,
              onPressed: () => context.goNamed(
                RouteConstants.addContribution,
                pathParameters: {'id': goal.id.toString()},
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Contribution', style: TextStyle(color: Colors.white)),
            ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [goal.category.color.withValues(alpha: 0.8), goal.category.color.withValues(alpha: 0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  // TODO: Implement Edit Goal
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    goal.title,
                    style: AppTextStyles.headline.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goal.category.color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      goal.category.label,
                      style: AppTextStyles.label.copyWith(color: goal.category.color),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GoalProgressRing(
                    percentage: percentage,
                    color: goal.category.color,
                    size: 160,
                    strokeWidth: 12,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    '${CurrencyUtils.format(goal.currentAmount)} / ${CurrencyUtils.format(goal.targetAmount)}',
                    style: AppTextStyles.amountLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (goal.description != null) ...[
                    Text(
                      goal.description!,
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  _buildStatsRow(remaining, daysLeft, monthlyReq),
                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Contribution History', style: AppTextStyles.title),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
          if (state.contributions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Text(
                    'No contributions yet.',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ContributionTile(
                    contribution: state.contributions[index],
                  ),
                  childCount: state.contributions.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double remaining, int daysLeft, double monthlyReq) {
    return Row(
      children: [
        _buildStatBlock('Remaining', CurrencyUtils.format(remaining)),
        _buildStatBlock('Days Left', daysLeft.toString()),
        _buildStatBlock('Monthly Req', CurrencyUtils.format(monthlyReq)),
      ],
    );
  }

  Widget _buildStatBlock(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
