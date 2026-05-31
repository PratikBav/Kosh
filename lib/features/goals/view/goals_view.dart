import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/cards/kosh_card.dart';
import '../../../shared/widgets/empty_state.dart';

/// Goals placeholder screen.
///
/// Shows a summary card and empty state to validate architecture.
class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: KoshCard(
              showGlow: true,
              glowColor: AppColors.secondary,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.ms),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Goals',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text('0', style: AppTextStyles.amountMedium),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Saved',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹0.00',
                        style: AppTextStyles.amountMedium.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),

          // Empty state
          Expanded(
            child: EmptyState(
              icon: Icons.flag_outlined,
              title: 'No Goals Yet',
              description: 'Set financial goals and track your progress\ntowards achieving them.',
              actionLabel: 'Create Goal',
              onAction: () {},
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
