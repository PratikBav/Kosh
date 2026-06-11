import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/cards/kosh_card.dart';
import '../../settings/viewmodel/theme_viewmodel.dart';

/// Dashboard placeholder screen.
///
/// Validates the architecture by using the theme, KoshCard,
/// spacing, and text style systems. No business logic.
class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ──────────────────────────────────────────
            Text(
              'Good Evening',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Welcome to Kosh',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Balance Card ──────────────────────────────────────
            KoshCard(
              showGlow: true,
              glowColor: AppColors.primary,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BALANCE',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    '₹0.00',
                    style: AppTextStyles.amountLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildStatChip(
                        'Income',
                        '₹0.00',
                        AppColors.success,
                        Icons.arrow_upward_rounded,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      _buildStatChip(
                        'Expenses',
                        '₹0.00',
                        AppColors.danger,
                        Icons.arrow_downward_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: AppSpacing.lg),

            // ── Quick Actions ─────────────────────────────────────
            const Text('Quick Actions', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.ms),
            Row(
              children: [
                _buildQuickAction(Icons.add_rounded, 'Add\nExpense', AppColors.danger),
                const SizedBox(width: AppSpacing.ms),
                _buildQuickAction(Icons.savings_outlined, 'Add\nIncome', AppColors.success),
                const SizedBox(width: AppSpacing.ms),
                _buildQuickAction(Icons.flag_outlined, 'New\nGoal', AppColors.secondary),
                const SizedBox(width: AppSpacing.ms),
                _buildQuickAction(Icons.trending_up_rounded, 'Invest', AppColors.warning),
              ],
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),

            // ── Recent Transactions ───────────────────────────────
            const Text('Recent Transactions', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.ms),
            KoshCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'No transactions yet',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ms,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.captionBold.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Expanded(
      child: KoshCard(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.ms,
          horizontal: AppSpacing.sm,
        ),
        onTap: () {},
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
