import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../viewmodel/security_viewmodel.dart';
import 'pin_prompt_screen.dart';
import 'pin_setup_screen.dart';

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
          SwitchListTile(
            title: const Text(
              'Enable App Lock',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              state.isPinSet
                  ? 'Require your PIN to open Kosh'
                  : 'Set a PIN to turn this on',
              style: const TextStyle(color: Colors.white70),
            ),
            value: settings.isAppLockEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (enable) => _toggleAppLock(context, ref, enable),
          ),
          if (settings.isAppLockEnabled) ...[
            const Divider(color: AppColors.surfaceBorder),
            ListTile(
              title: const Text(
                'Change PIN',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Replace your current PIN',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white54,
              ),
              onTap: () => _changePin(context),
            ),
            SwitchListTile(
              title: const Text(
                'Biometric Unlock',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                state.isBiometricAvailable
                    ? 'Use your fingerprint or face instead of typing the PIN'
                    : 'No biometrics are enrolled on this device',
                style: const TextStyle(color: Colors.white70),
              ),
              value: settings.isBiometricEnabled,
              activeTrackColor: AppColors.primary,
              onChanged: state.isBiometricAvailable
                  ? (enable) => _toggleBiometric(context, ref, enable)
                  : null,
            ),
            ListTile(
              title: const Text(
                'Auto-Lock Timeout',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                _autoLockLabel(settings.autoLockDuration),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white54,
              ),
              onTap: () =>
                  _showAutoLockDialog(context, ref, settings.autoLockDuration),
            ),
          ],
          const Divider(color: AppColors.surfaceBorder),
          SwitchListTile(
            title: const Text(
              'Block Screenshots',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Hide Kosh in the app switcher and stop screen recording',
              style: TextStyle(color: Colors.white70),
            ),
            value: settings.isScreenSecurityEnabled,
            activeTrackColor: AppColors.primary,
            onChanged: (enable) => ref
                .read(securityViewModelProvider.notifier)
                .setScreenSecurityEnabled(enable),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final notifier = ref.read(securityViewModelProvider.notifier);

    if (enable) {
      // A lock with no PIN cannot be opened, so set one first.
      if (!ref.read(securityViewModelProvider).isPinSet) {
        final created = await PinSetupScreen.show(context, PinSetupMode.create);
        if (!created) return;
      }
      await notifier.setAppLockEnabled(true);
      return;
    }

    if (!context.mounted) return;
    final pin = await PinPromptScreen.show(
      context,
      'Confirm your PIN to turn off app lock.',
    );
    if (pin == null) return;

    await notifier.setAppLockEnabled(false);

    if (!context.mounted) return;
    final removePin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove your PIN?'),
        content: const Text(
          'App lock is off. You can keep the PIN for next time, or remove it.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep PIN'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (removePin == true) await notifier.removePin(pin);
  }

  Future<void> _changePin(BuildContext context) async {
    final changed = await PinSetupScreen.show(context, PinSetupMode.change);
    if (changed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN updated')),
      );
    }
  }

  Future<void> _toggleBiometric(
    BuildContext context,
    WidgetRef ref,
    bool enable,
  ) async {
    final success = await ref
        .read(securityViewModelProvider.notifier)
        .setBiometricEnabled(enable);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed')),
      );
    }
  }

  String _autoLockLabel(int seconds) {
    return switch (seconds) {
      -1 => 'Immediately',
      0 => 'Never',
      30 => '30 Seconds',
      60 => '1 Minute',
      300 => '5 Minutes',
      _ => '$seconds Seconds',
    };
  }

  void _showAutoLockDialog(BuildContext context, WidgetRef ref, int current) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Auto-Lock Timeout',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const [
              ('Immediately', -1),
              ('30 Seconds', 30),
              ('1 Minute', 60),
              ('5 Minutes', 300),
              ('Never', 0),
            ])
              RadioListTile<int>(
                title: Text(
                  option.$1,
                  style: const TextStyle(color: Colors.white),
                ),
                value: option.$2,
                // ignore: deprecated_member_use
                groupValue: current,
                activeColor: AppColors.primary,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value == null) return;
                  ref
                      .read(securityViewModelProvider.notifier)
                      .setAutoLockDuration(value);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
