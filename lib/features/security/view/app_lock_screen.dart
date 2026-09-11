import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/pin_service.dart';
import '../viewmodel/security_viewmodel.dart';
import '../widgets/pin_pad.dart';

/// Full-screen lock shown over the app until the user authenticates.
///
/// The PIN is the primary path — it works on every device. Biometrics appear
/// as a shortcut only when the hardware exists and the user opted in.
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  String _pin = '';
  String? _message;
  bool _isVerifying = false;
  Duration? _lockoutRemaining;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    // Offer biometrics straight away so the common case is a single tap.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometrics());
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _tryBiometrics() async {
    if (!ref.read(securityViewModelProvider).canUseBiometricUnlock) return;
    if (_lockoutRemaining != null) return;

    await ref.read(securityViewModelProvider.notifier).unlockWithBiometrics();
  }

  void _onDigit(String digit) {
    if (_pin.length >= PinService.maxPinLength) return;
    setState(() {
      _pin += digit;
      _message = null;
    });
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _message = null;
    });
  }

  Future<void> _submit() async {
    if (_pin.length < PinService.minPinLength || _isVerifying) return;

    setState(() => _isVerifying = true);

    final outcome =
        await ref.read(securityViewModelProvider.notifier).submitPin(_pin);

    if (!mounted) return;

    if (outcome.isAccepted) {
      // The view model clears isLocked, which unmounts this screen.
      setState(() => _isVerifying = false);
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isVerifying = false;
      _pin = '';
      _message = outcome.message;
    });

    if (outcome.lockoutRemaining != null) {
      _startLockoutCountdown(outcome.lockoutRemaining!);
    }
  }

  /// Ticks the lockout down so the screen stays truthful about when entry
  /// reopens, rather than showing a figure frozen at the moment of failure.
  ///
  /// Counts against a wall-clock deadline rather than accumulating ticks, so a
  /// backgrounded or throttled timer cannot stretch the lockout.
  void _startLockoutCountdown(Duration initial) {
    _lockoutTimer?.cancel();

    final deadline = DateTime.now().add(initial);
    setState(() => _lockoutRemaining = initial);

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        timer.cancel();
        setState(() {
          _lockoutRemaining = null;
          _message = null;
        });
      } else {
        setState(() => _lockoutRemaining = remaining);
      }
    });
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityViewModelProvider);
    final isLockedOut = _lockoutRemaining != null;

    return PopScope(
      // The lock is the whole point; back must not dismiss it.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Kosh is locked',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isLockedOut
                        ? 'Try again in ${_formatRemaining(_lockoutRemaining!)}'
                        : 'Enter your PIN to continue',
                    style: TextStyle(
                      fontSize: 15,
                      color: isLockedOut
                          ? AppColors.danger
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PinDots(
                    filled: _pin.length,
                    hasError: _message != null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 36,
                    child: _message == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Text(
                              _message!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 14,
                              ),
                            ),
                          ),
                  ),
                  PinKeypad(
                    onDigit: _onDigit,
                    onBackspace: _onBackspace,
                    onSubmit: _submit,
                    isEnabled: !isLockedOut && !_isVerifying,
                    isSubmitEnabled: _pin.length >= PinService.minPinLength,
                    onBiometric:
                        state.canUseBiometricUnlock ? _tryBiometrics : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
