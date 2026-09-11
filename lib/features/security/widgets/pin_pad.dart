import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

/// Row of dots showing how many digits have been entered, without revealing
/// the PIN's configured length.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.filled,
    this.slots = 6,
    this.hasError = false,
  });

  /// Number of digits entered so far.
  final int filled;

  /// How many dots to draw.
  final int slots;

  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final activeColor = hasError ? AppColors.danger : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slots, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          width: isFilled ? 14 : 12,
          height: isFilled ? 14 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? activeColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? activeColor : AppColors.textTertiary,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// Numeric keypad for PIN entry.
///
/// Deliberately not a text field: it keeps the system keyboard — and its
/// autofill, clipboard and prediction surfaces — away from the PIN.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
    this.isSubmitEnabled = false,
    this.isEnabled = true,
    this.onBiometric,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool isSubmitEnabled;
  final bool isEnabled;

  /// When provided, a fingerprint key replaces the empty bottom-left slot.
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final digit in row) _DigitKey(digit: digit, onTap: _tap),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActionKey(
              icon: onBiometric == null ? null : Icons.fingerprint_rounded,
              onTap: isEnabled ? onBiometric : null,
              tooltip: 'Unlock with biometrics',
            ),
            _DigitKey(digit: '0', onTap: _tap),
            _ActionKey(
              icon: Icons.backspace_outlined,
              onTap: isEnabled ? onBackspace : null,
              tooltip: 'Delete',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 240,
          height: 52,
          child: FilledButton(
            onPressed: isEnabled && isSubmitEnabled ? onSubmit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.surfaceLight,
              foregroundColor: Colors.white,
              disabledForegroundColor: AppColors.textDisabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _tap(String digit) {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
    onDigit(digit);
  }
}

class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onTap});

  final String digit;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onTap(digit),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Center(
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData? icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    // Keeps the grid aligned when there is no action for this slot.
    if (icon == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(width: 72, height: 72),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(
                icon,
                size: 26,
                color: onTap == null
                    ? AppColors.textDisabled
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
