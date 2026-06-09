import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../database/collections/transaction_collection.dart';
import '../../../../shared/widgets/kosh_button.dart';
import '../../../../shared/widgets/kosh_textfield.dart';
import '../models/transaction_category.dart';
import '../models/transaction_type.dart';
import '../viewmodel/transaction_viewmodel.dart';

/// Screen for adding or editing a transaction.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.transactionId});

  final int? transactionId;

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  TransactionCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool _isEditing = false;
  TransactionCollection? _existingTransaction;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _isEditing = true;
      _loadExistingTransaction();
    }
  }

  void _loadExistingTransaction() {
    // Find the transaction from the state
    final state = ref.read(transactionViewModelProvider);
    try {
      _existingTransaction = state.transactions.firstWhere((t) => t.id == widget.transactionId);
      
      _amountController.text = _existingTransaction!.amount.toString();
      _titleController.text = _existingTransaction!.title;
      _notesController.text = _existingTransaction!.notes ?? '';
      _selectedType = _existingTransaction!.type;
      _selectedCategory = _existingTransaction!.category;
      _selectedDate = _existingTransaction!.date;
    } catch (e) {
      // Transaction not found, fallback to add mode
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      // Reset category if it doesn't belong to the new type
      if (_selectedCategory != null) {
        final allowedCategories = TransactionCategory.getCategoriesForType(type);
        if (!allowedCategories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount must be greater than 0')),
        );
        return;
      }

      final transaction = TransactionCollection()
        ..title = _titleController.text.trim()
        ..amount = amount
        ..type = _selectedType
        ..category = _selectedCategory!
        ..date = _selectedDate
        ..notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim()
        ..updatedAt = DateTime.now();

      if (_isEditing && _existingTransaction != null) {
        transaction.id = _existingTransaction!.id;
        transaction.createdAt = _existingTransaction!.createdAt;
        ref.read(transactionViewModelProvider.notifier).updateTransaction(transaction);
      } else {
        transaction.createdAt = DateTime.now();
        ref.read(transactionViewModelProvider.notifier).addTransaction(transaction);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = TransactionCategory.getCategoriesForType(_selectedType);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Segmented Button
              Center(
                child: SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                      icon: Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<TransactionType> newSelection) {
                    _onTypeChanged(newSelection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return _selectedType == TransactionType.income
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.danger.withValues(alpha: 0.2);
                        }
                        return Colors.transparent;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return _selectedType == TransactionType.income
                              ? AppColors.success
                              : AppColors.danger;
                        }
                        return AppColors.textSecondary;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Amount
              KoshTextField(
                controller: _amountController,
                label: 'Amount (₹)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(11),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                prefixIcon: Icons.currency_rupee_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount > 99999999999) {
                    return 'Cannot exceed 99,999,999,999';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              KoshTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Lunch, Salary, Movie',
                prefixIcon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              DropdownButtonFormField<TransactionCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded, color: AppColors.textTertiary),
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(category.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (TransactionCategory? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Picker
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.textTertiary),
                  ),
                  child: Text(
                    dateFormat.format(_selectedDate),
                    style: AppTextStyles.body,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notes
              KoshTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Add any extra details here',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Save Button
              KoshButton(
                label: _isEditing ? 'Update Transaction' : 'Save Transaction',
                isExpanded: true,
                onPressed: _saveTransaction,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
