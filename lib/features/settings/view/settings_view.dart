import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/cards/kosh_card.dart';

/// Settings placeholder screen.
///
/// Shows setting category cards to validate the design system.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            KoshCard(
              showGlow: true,
              glowColor: AppColors.primary,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Kosh User', style: AppTextStyles.title),
                      Text(
                        'Manage your profile',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: AppSpacing.lg),

            // General
            const Text('GENERAL', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                subtitle: 'Dark mode',
              ),
              _SettingItem(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency',
                subtitle: 'INR (₹)',
              ),
              _SettingItem(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English',
              ),
            ]).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),

            // Security
            const Text('SECURITY', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Lock',
                subtitle: 'Disabled',
              ),
              _SettingItem(
                icon: Icons.lock_outline_rounded,
                title: 'App PIN',
                subtitle: 'Not set',
              ),
            ]).animate().fadeIn(duration: 500.ms, delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),

            // Notifications
            const Text('NOTIFICATIONS', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.notifications_outlined,
                title: 'Reminders',
                subtitle: 'Enabled',
              ),
              _SettingItem(
                icon: Icons.schedule_rounded,
                title: 'Reminder Time',
                subtitle: '9:00 PM',
              ),
            ]).animate().fadeIn(duration: 500.ms, delay: 300.ms),
            const SizedBox(height: AppSpacing.lg),

            // Data
            const Text('DATA', style: AppTextStyles.overline),
            const SizedBox(height: AppSpacing.sm),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                subtitle: 'CSV, PDF',
              ),
              _SettingItem(
                icon: Icons.delete_outline_rounded,
                title: 'Clear All Data',
                subtitle: 'Irreversible',
                isDestructive: true,
              ),
            ]).animate().fadeIn(duration: 500.ms, delay: 400.ms),
            const SizedBox(height: AppSpacing.lg),

            // About
            Center(
              child: Text(
                'Kosh v1.0.0',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
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
                    color: item.isDestructive
                        ? AppColors.danger
                        : AppColors.textSecondary,
                    size: AppSpacing.iconMd,
                  ),
                ),
                title: Text(
                  item.title,
                  style: AppTextStyles.body.copyWith(
                    color: item.isDestructive
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  item.subtitle,
                  style: AppTextStyles.caption,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 60,
                  color: AppColors.surfaceBorder,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Internal data class for a settings item.
class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
}
