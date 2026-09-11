import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/pin_service.dart';
import '../viewmodel/security_viewmodel.dart';
import '../widgets/pin_pad.dart';

/// Asks for the current PIN to authorise a sensitive settings change.
///
/// Pops the verified PIN, or `null` if the user backed out. Attempts go
/// through the same throttling as the lock screen, so this cannot be used as
/// an unthrottled oracle for guessing the PIN.
class PinPromptScreen extends ConsumerStatefulWidget {
  const PinPromptScreen({super.key, required this.reason});

  /// Shown under the title, e.g. 'Confirm to turn off app lock'.
  final String reason;

  static Future<String?> show(BuildContext context, String reason) {
    return Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(builder: (_) => PinPromptScreen(reason: reason)),
    );
  }

  @override
  ConsumerState<PinPromptScreen> createState() => _PinPromptScreenState();
}

class _PinPromptScreenState extends ConsumerState<PinPromptScreen> {
  String _entry = '';
  String? _message;
  bool _isBusy = false;

  Future<void> _submit() async {
    if (_entry.length < PinService.minPinLength || _isBusy) return;

    setState(() => _isBusy = true);

    final outcome =
        await ref.read(securityViewModelProvider.notifier).submitPin(_entry);

    if (!mounted) return;

    if (outcome.isAccepted) {
      Navigator.of(context).pop(_entry);
      return;
    }

    setState(() {
      _isBusy = false;
      _message = outcome.message ?? 'Incorrect PIN.';
      _entry = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirm PIN')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    widget.reason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PinDots(filled: _entry.length, hasError: _message != null),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 36,
                  child: _message == null
                      ? null
                      : Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 14,
                          ),
                        ),
                ),
                PinKeypad(
                  onDigit: (digit) {
                    if (_entry.length >= PinService.maxPinLength) return;
                    setState(() {
                      _entry += digit;
                      _message = null;
                    });
                  },
                  onBackspace: () {
                    if (_entry.isEmpty) return;
                    setState(() {
                      _entry = _entry.substring(0, _entry.length - 1);
                      _message = null;
                    });
                  },
                  onSubmit: _submit,
                  isEnabled: !_isBusy,
                  isSubmitEnabled: _entry.length >= PinService.minPinLength,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
