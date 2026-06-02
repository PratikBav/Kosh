import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/cards/kosh_card.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Center')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const Icon(Icons.shield_outlined, size: 80, color: AppColors.success),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Your data never leaves this device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Kosh is a fully offline application. We do not use cloud servers, we do not track your financial habits, and your data is entirely under your control.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xl),
          KoshCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Data Stored Locally:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: AppSpacing.md),
                _buildDataRow(Icons.list_alt, 'Transactions'),
                const SizedBox(height: AppSpacing.sm),
                _buildDataRow(Icons.flag_outlined, 'Goals & Contributions'),
                const SizedBox(height: AppSpacing.sm),
                _buildDataRow(Icons.emoji_events_outlined, 'Achievements & Streaks'),
                const SizedBox(height: AppSpacing.sm),
                _buildDataRow(Icons.settings_outlined, 'Settings & Configuration'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
