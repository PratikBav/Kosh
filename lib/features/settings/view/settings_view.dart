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

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityState = ref.watch(securityViewModelProvider);
    final settings = securityState.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Security Dashboard Card ---
            KoshCard(
              showGlow: true,
              glowColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Security Status', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        settings?.isAppLockEnabled == true ? Icons.lock_rounded : Icons.lock_open_rounded,
                        color: settings?.isAppLockEnabled == true ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('App Lock: ${settings?.isAppLockEnabled == true ? 'Enabled' : 'Disabled'}', style: AppTextStyles.body),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // GENERAL
            const Text('GENERAL', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Dark mode',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.shield_outlined,
                title: 'Privacy Center',
                subtitle: 'Local Data & Trust',
                onTap: () => context.pushNamed(RouteConstants.privacy),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // SECURITY
            const Text('SECURITY', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.security_rounded,
                title: 'Security Settings',
                subtitle: 'Manage App Lock, Auto-Lock',
                onTap: () => context.pushNamed(RouteConstants.securitySettings),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // DATA & BACKUP
            const Text('DATA', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.cloud_download_outlined,
                title: 'Backup & Restore',
                subtitle: 'Export JSON, Import, CSV Reports',
                onTap: () => context.pushNamed(RouteConstants.backup),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // DANGER ZONE
            const Text('DANGER ZONE', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.delete_forever_rounded,
                title: 'Delete All Data',
                subtitle: 'Irreversible action',
                isDestructive: true,
                onTap: () => _showDeleteAllDataDialog(context, ref),
              ),
            ]),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete All Data?', style: TextStyle(color: Colors.white)),
          content: const Text('This will wipe all transactions, goals, and achievements permanently.', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App data has been reset.')));
                  context.go(RouteConstants.dashboard);
                }
              },
              child: const Text('WIPE DATA', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return KoshCard(
      padding: EdgeInsets.zero,
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
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: item.isDestructive
                        ? AppColors.danger.withValues(alpha: 0.12)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.isDestructive ? AppColors.danger : AppColors.textSecondary,
                    size: AppSpacing.iconMd,
                  ),
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.body.copyWith(
                    color: item.isDestructive ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(item.subtitle, style: AppTextStyles.caption),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              ),
              if (!isLast) const Divider(height: 1, indent: 60, color: AppColors.surfaceBorder),
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
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback? onTap;
}
