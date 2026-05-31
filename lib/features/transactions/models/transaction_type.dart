import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// The two types of transactions allowed in Kosh.
enum TransactionType {
  income,
  expense;

  /// Human-readable label.
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }

  /// Color associated with the transaction type.
  Color get color {
    switch (this) {
      case TransactionType.income:
        return AppColors.success;
      case TransactionType.expense:
        return AppColors.danger;
    }
  }
}
