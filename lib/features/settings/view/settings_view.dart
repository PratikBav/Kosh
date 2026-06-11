import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/route_constants.dart';
import '../../../shared/cards/kosh_card.dart';
import '../../analytics/viewmodel/analytics_viewmodel.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../gamification/viewmodel/gamification_viewmodel.dart';
import '../../goals/viewmodel/goals_viewmodel.dart';
import '../../security/viewmodel/security_viewmodel.dart';
import '../../transactions/viewmodel/transaction_viewmodel.dart';
import '../../vision_board/viewmodel/vision_board_viewmodel.dart';
import '../../../providers/database_providers.dart';
import '../viewmodel/theme_viewmodel.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeViewModelProvider);
    final securityState = ref.watch(securityViewModelProvider);
    final settings = securityState.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background.withValues(alpha: 0.8),
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              title: Text('Settings', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Card
                KoshCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pratik', style: AppTextStyles.title),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text('Kosh Pro Member', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // SECURITY STATUS
                const Text('SECURITY STATUS', style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.sm),
                _buildSettingsGroup([
                  _SettingItem(
                    icon: settings?.isAppLockEnabled == true ? Icons.lock_rounded : Icons.lock_open_rounded,
                    iconColor: settings?.isAppLockEnabled == true ? AppColors.success : AppColors.warning,
                    title: 'App Lock',
                    subtitle: settings?.isAppLockEnabled == true ? 'Protected with biometrics' : 'Not protected',
                    onTap: () => context.pushNamed(RouteConstants.securitySettings),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),

                // GENERAL
                const Text('GENERAL', style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.sm),
                _buildSettingsGroup([
                  _SettingItem(
                    icon: Icons.palette_rounded,
                    iconColor: AppColors.primary,
                    title: 'Appearance',
                    subtitle: 'Glassmorphic Dark Mode',
                    onTap: () => context.goNamed('appearance'),
                  ),
                  _SettingItem(
                    icon: Icons.shield_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Privacy Center',
                    subtitle: 'Local Data & Trust',
                    onTap: () => context.pushNamed(RouteConstants.privacy),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),

                // DATA & BACKUP
                const Text('DATA', style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.sm),
                _buildSettingsGroup([
                  _SettingItem(
                    icon: Icons.cloud_download_rounded,
                    iconColor: AppColors.info,
                    title: 'Backup & Restore',
                    subtitle: 'Export JSON, Import, CSV Reports',
                    onTap: () => context.pushNamed(RouteConstants.backup),
                  ),
                ]),
                const SizedBox(height: AppSpacing.xl),

                // DANGER ZONE
                const Text('DANGER ZONE', style: AppTextStyles.overline),
                const SizedBox(height: AppSpacing.sm),
                _buildSettingsGroup([
                  _SettingItem(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.danger,
                    title: 'Wipe All Data',
                    subtitle: 'Irreversible action',
                    isDestructive: true,
                    onTap: () => _showDeleteAllDataDialog(context, ref),
                  ),
                ]),
                const SizedBox(height: 160), // Ensure it clears the floating bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(color: AppColors.glassBorder),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
              const SizedBox(width: AppSpacing.sm),
              const Text('Wipe All Data?', style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
          content: const Text(
            'This will permanently delete all transactions, goals, and achievements. This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.2),
                foregroundColor: AppColors.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                final isar = ref.read(isarProvider);
                await isar.writeTxn(() async {
                  await isar.clear();
                });
                
                ref.invalidate(analyticsViewModelProvider);
                ref.invalidate(dashboardViewModelProvider);
                ref.invalidate(gamificationViewModelProvider);
                ref.invalidate(goalsViewModelProvider);
                ref.invalidate(securityViewModelProvider);
                ref.invalidate(transactionViewModelProvider);
                ref.invalidate(visionBoardViewModelProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('App data has been successfully reset.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  context.go(RouteConstants.dashboard);
                }
              },
              child: const Text('Delete Everything', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isDestructive
                        ? AppColors.danger.withValues(alpha: 0.1)
                        : item.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isDestructive ? AppColors.danger : item.iconColor,
                    size: 24,
                  ),
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.body.copyWith(
                    color: item.isDestructive ? AppColors.danger : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(item.subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 64),
                  child: Divider(height: 1, color: AppColors.surfaceBorder.withValues(alpha: 0.5)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool isDestructive;
  final VoidCallback? onTap;
}
