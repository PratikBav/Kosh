import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../database/collections/contribution_collection.dart';
import '../../../../shared/widgets/kosh_button.dart';
import '../../../../shared/widgets/kosh_textfield.dart';
import '../viewmodel/goal_details_viewmodel.dart';

class AddContributionScreen extends ConsumerStatefulWidget {
  const AddContributionScreen({super.key, required this.goalId});

  final int goalId;

  @override
  ConsumerState<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends ConsumerState<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveContribution() {
    if (!_formKey.currentState!.validate()) return;

    final contribution = ContributionCollection()
      ..goalId = widget.goalId
      ..amount = double.parse(_amountController.text)
      ..note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim()
      ..date = DateTime.now()
      ..createdAt = DateTime.now();

    ref.read(goalDetailsViewModelProvider(widget.goalId).notifier)
       .addContribution(contribution)
       .then((_) {
         if (mounted) context.pop();
       });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Contribution')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KoshTextField(
                controller: _amountController,
                label: 'Amount to add',
                hint: 'e.g. 5000',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  final amount = double.tryParse(val);
                  if (amount == null) return 'Invalid number';
                  if (amount > 99999999999) return 'Cannot exceed 99,999,999,999';
                  if (amount <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              KoshTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                hint: 'e.g. Salary savings',
                prefixIcon: Icons.notes_rounded,
              ),
              const Spacer(),
              KoshButton(
                label: 'Add to Goal',
                onPressed: _saveContribution,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
