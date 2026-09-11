import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/services/pin_service.dart';
import '../viewmodel/security_viewmodel.dart';
import '../widgets/pin_pad.dart';

enum PinSetupMode {
  /// No PIN exists yet.
  create,

  /// Replace an existing PIN; the current one is required first.
  change,
}

/// Guided PIN creation. Pops `true` once a PIN has been stored.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key, required this.mode});

  final PinSetupMode mode;

  /// Pushes the flow on the root navigator so it covers the shell's nav bar.
  static Future<bool> show(BuildContext context, PinSetupMode mode) async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => PinSetupScreen(mode: mode)),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

enum _Step { verifyCurrent, choose, confirm }

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  late _Step _step =
      widget.mode == PinSetupMode.change ? _Step.verifyCurrent : _Step.choose;

  String _entry = '';
  String _currentPin = '';
  String _chosenPin = '';
  String? _message;
  bool _isBusy = false;

  ({String title, String subtitle}) get _copy {
    switch (_step) {
      case _Step.verifyCurrent:
        return (
          title: 'Enter current PIN',
          subtitle: 'Confirm it is you before choosing a new one',
        );
      case _Step.choose:
        return (
          title: widget.mode == PinSetupMode.change
              ? 'Choose a new PIN'
              : 'Choose a PIN',
          subtitle: '${PinService.minPinLength} to ${PinService.maxPinLength} '
              'digits. You will need this to open Kosh.',
        );
      case _Step.confirm:
        return (
          title: 'Re-enter your PIN',
          subtitle: 'Type it once more so it cannot be mistyped',
        );
    }
  }

  void _onDigit(String digit) {
    if (_entry.length >= PinService.maxPinLength) return;
    setState(() {
      _entry += digit;
      _message = null;
    });
  }

  void _onBackspace() {
    if (_entry.isEmpty) return;
    setState(() {
      _entry = _entry.substring(0, _entry.length - 1);
      _message = null;
    });
  }

  Future<void> _submit() async {
    if (_entry.length < PinService.minPinLength || _isBusy) return;

    switch (_step) {
      case _Step.verifyCurrent:
        await _verifyCurrent();
      case _Step.choose:
        _chooseNew();
      case _Step.confirm:
        await _confirmAndSave();
    }
  }

  Future<void> _verifyCurrent() async {
    setState(() => _isBusy = true);

    final outcome =
        await ref.read(securityViewModelProvider.notifier).submitPin(_entry);

    if (!mounted) return;

    if (!outcome.isAccepted) {
      setState(() {
        _isBusy = false;
        _entry = '';
        _message = outcome.message ?? 'That is not your current PIN.';
      });
      return;
    }

    setState(() {
      _isBusy = false;
      _currentPin = _entry;
      _entry = '';
      _step = _Step.choose;
    });
  }

  void _chooseNew() {
    final problem = PinService.validatePin(_entry);
    if (problem != null) {
      setState(() {
        _entry = '';
        _message = problem;
      });
      return;
    }

    setState(() {
      _chosenPin = _entry;
      _entry = '';
      _step = _Step.confirm;
    });
  }

  Future<void> _confirmAndSave() async {
    if (_entry != _chosenPin) {
      setState(() {
        _entry = '';
        _chosenPin = '';
        _step = _Step.choose;
        _message = 'Those PINs did not match. Start again.';
      });
      return;
    }

    setState(() => _isBusy = true);

    final notifier = ref.read(securityViewModelProvider.notifier);
    final error = widget.mode == PinSetupMode.change
        ? await notifier.changePin(currentPin: _currentPin, newPin: _chosenPin)
        : await notifier.setPin(_chosenPin);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isBusy = false;
        _entry = '';
        _chosenPin = '';
        _step = _Step.choose;
        _message = error;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final copy = _copy;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.mode == PinSetupMode.change ? 'Change PIN' : 'Set up PIN',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  copy.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    copy.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PinDots(filled: _entry.length, hasError: _message != null),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 40,
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
