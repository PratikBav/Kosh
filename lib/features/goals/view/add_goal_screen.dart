import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../database/collections/goal_collection.dart';
import '../../../../shared/widgets/kosh_button.dart';
import '../../../../shared/widgets/kosh_textfield.dart';
import '../models/goal_category.dart';
import '../models/goal_priority.dart';
import '../viewmodel/goals_viewmodel.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  
  DateTime? _deadline;
  GoalCategory _selectedCategory = GoalCategory.emergencyFund;
  GoalPriority _selectedPriority = GoalPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _deadline = date);
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    final goal = GoalCollection()
      ..title = _titleController.text.trim()
      ..description = _descController.text.trim().isEmpty ? null : _descController.text.trim()
      ..targetAmount = double.parse(_amountController.text)
      ..currentAmount = 0.0
      ..deadline = _deadline!
      ..category = _selectedCategory
      ..priority = _selectedPriority
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..isCompleted = false;

    ref.read(goalsViewModelProvider.notifier).createGoal(goal).then((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KoshTextField(
                controller: _titleController,
                label: 'Goal Name',
                hint: 'e.g. MacBook Pro',
                prefixIcon: Icons.flag_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              KoshTextField(
                controller: _amountController,
                label: 'Target Amount',
                hint: 'e.g. 120000',
                prefixIcon: Icons.currency_rupee_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                tileColor: AppColors.surfaceLight,
                leading: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                title: Text(
                  _deadline == null ? 'Select Deadline' : DateFormat.yMMMd().format(_deadline!),
                  style: AppTextStyles.body,
                ),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<GoalCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: GoalCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Priority', style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.xs),
              SegmentedButton<GoalPriority>(
                segments: GoalPriority.values.map((p) => ButtonSegment(
                  value: p,
                  label: Text(p.label, style: const TextStyle(fontSize: 12)),
                )).toList(),
                selected: {_selectedPriority},
                onSelectionChanged: (set) => setState(() => _selectedPriority = set.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedPriority.color.withValues(alpha: 0.2);
                    }
                    return AppColors.surfaceLight;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              KoshTextField(
                controller: _descController,
                label: 'Description (Optional)',
                hint: 'Why are you saving for this?',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),
              KoshButton(
                label: 'Create Goal',
                onPressed: _saveGoal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
