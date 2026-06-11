import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../viewmodel/security_viewmodel.dart';
import '../../../shared/widgets/kosh_button.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    // Prompt biometric/device auth on start if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryUnlock();
    });
  }

  Future<void> _tryUnlock() async {
    final success = await ref.read(securityViewModelProvider.notifier).authenticateDevice('Unlock Kosh');
    if (success && mounted) {
      ref.read(securityViewModelProvider.notifier).unlockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Kosh is Locked',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Unlock to access your financial data.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: KoshButton(
                  label: 'Unlock',
                  onPressed: _tryUnlock,
                  isExpanded: true,
                  icon: Icons.fingerprint_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
