import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../viewmodel/security_viewmodel.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityViewModelProvider);
    final settings = state.settings;

    if (state.isLoading || settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // App Lock Toggle
          SwitchListTile(
            title: const Text('Enable App Lock', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Require authentication to open the app', style: TextStyle(color: Colors.white70)),
            value: settings.isAppLockEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (val) async {
              final success = await ref.read(securityViewModelProvider.notifier).toggleAppLock(val);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(val ? 'Failed to enable App Lock' : 'Failed to disable App Lock')),
                );
              }
            },
          ),
          
          if (settings.isAppLockEnabled) ...[
            const Divider(color: AppColors.surfaceBorder),
            
            // Auto-lock Configuration
            ListTile(
              title: const Text('Auto-Lock Timeout', style: TextStyle(color: Colors.white)),
              subtitle: Text(_getAutoLockLabel(settings.autoLockDuration), style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              onTap: () => _showAutoLockDialog(context, ref, settings.autoLockDuration),
            ),
          ]
        ],
      ),
    );
  }

  String _getAutoLockLabel(int seconds) {
    if (seconds == -1) return 'Immediately';
    if (seconds == 0) return 'Never';
    if (seconds == 30) return '30 Seconds';
    if (seconds == 60) return '1 Minute';
    if (seconds == 300) return '5 Minutes';
    return '$seconds Seconds';
  }

  void _showAutoLockDialog(BuildContext context, WidgetRef ref, int current) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Auto-Lock Timeout', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRadio(context, ref, 'Immediately', -1, current),
              _buildRadio(context, ref, '30 Seconds', 30, current),
              _buildRadio(context, ref, '1 Minute', 60, current),
              _buildRadio(context, ref, '5 Minutes', 300, current),
              _buildRadio(context, ref, 'Never', 0, current),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadio(BuildContext context, WidgetRef ref, String label, int value, int current) {
    return RadioListTile<int>(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      // ignore: deprecated_member_use
      groupValue: current,
      activeColor: AppColors.primary,
      // ignore: deprecated_member_use
      onChanged: (val) {
        if (val != null) {
          ref.read(securityViewModelProvider.notifier).setAutoLockDuration(val);
          Navigator.pop(context);
        }
      },
    );
  }


}
