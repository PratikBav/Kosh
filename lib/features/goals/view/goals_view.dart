import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../viewmodel/goals_viewmodel.dart';
import '../widgets/goal_card.dart';
import '../widgets/goal_summary_card.dart';

class GoalsView extends ConsumerWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'goals_fab',
        onPressed: () => context.pushNamed(RouteConstants.addGoal),
        child: const Icon(Icons.add_rounded),
      ),
      body: state.isLoading && state.goals.isEmpty
          ? const LoadingIndicator()
          : state.error != null
              ? Center(child: Text(state.error!, style: AppTextStyles.body.copyWith(color: AppColors.danger)))
              : _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, state) {
    if (state.goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_rounded, size: 80, color: AppColors.primary.withValues(alpha: 0.1)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No goals set yet.',
              style: AppTextStyles.displaySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start building your future today by creating your first financial goal.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GoalSummaryCard(
              totalSaved: state.totalSavedAmount,
              totalTarget: state.totalTargetAmount,
              activeGoalsCount: state.activeGoalsCount,
              completedGoalsCount: state.completedGoalsCount,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final goal = state.goals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GoalCard(
                    goal: goal,
                    onTap: () => context.goNamed(
                      RouteConstants.goalDetails,
                      pathParameters: {'id': goal.id.toString()},
                    ),
                  ),
                );
              },
              childCount: state.goals.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
      ],
    );
  }
}
