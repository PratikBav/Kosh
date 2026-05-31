import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'transaction_type.dart';

/// Predefined categories for transactions.
enum TransactionCategory {
  // Expense Categories
  food,
  transport,
  shopping,
  bills,
  entertainment,
  healthcare,
  education,
  travel,
  // Income Categories
  salary,
  freelance,
  business,
  gift,
  // Shared
  investment,
  other;

  /// Returns the categories available for a given transaction type.
  static List<TransactionCategory> getCategoriesForType(TransactionType type) {
    if (type == TransactionType.income) {
      return [
        salary,
        freelance,
        business,
        investment,
        gift,
        other,
      ];
    } else {
      return [
        food,
        transport,
        shopping,
        bills,
        entertainment,
        healthcare,
        education,
        travel,
        investment,
        other,
      ];
    }
  }

  /// Human-readable label.
  String get label {
    switch (this) {
      case TransactionCategory.food: return 'Food';
      case TransactionCategory.transport: return 'Transport';
      case TransactionCategory.shopping: return 'Shopping';
      case TransactionCategory.bills: return 'Bills';
      case TransactionCategory.entertainment: return 'Entertainment';
      case TransactionCategory.healthcare: return 'Healthcare';
      case TransactionCategory.education: return 'Education';
      case TransactionCategory.travel: return 'Travel';
      case TransactionCategory.salary: return 'Salary';
      case TransactionCategory.freelance: return 'Freelance';
      case TransactionCategory.business: return 'Business';
      case TransactionCategory.gift: return 'Gift';
      case TransactionCategory.investment: return 'Investment';
      case TransactionCategory.other: return 'Other';
    }
  }

  /// Icon associated with the category.
  IconData get icon {
    switch (this) {
      case TransactionCategory.food: return Icons.restaurant_rounded;
      case TransactionCategory.transport: return Icons.directions_car_rounded;
      case TransactionCategory.shopping: return Icons.shopping_bag_rounded;
      case TransactionCategory.bills: return Icons.receipt_long_rounded;
      case TransactionCategory.entertainment: return Icons.movie_rounded;
      case TransactionCategory.healthcare: return Icons.local_hospital_rounded;
      case TransactionCategory.education: return Icons.school_rounded;
      case TransactionCategory.travel: return Icons.flight_takeoff_rounded;
      case TransactionCategory.salary: return Icons.account_balance_wallet_rounded;
      case TransactionCategory.freelance: return Icons.computer_rounded;
      case TransactionCategory.business: return Icons.storefront_rounded;
      case TransactionCategory.gift: return Icons.card_giftcard_rounded;
      case TransactionCategory.investment: return Icons.trending_up_rounded;
      case TransactionCategory.other: return Icons.category_rounded;
    }
  }

  /// The theme color mapped to this category.
  Color get color {
    switch (this) {
      case TransactionCategory.food: return Colors.orange;
      case TransactionCategory.transport: return Colors.blue;
      case TransactionCategory.shopping: return Colors.purple;
      case TransactionCategory.bills: return Colors.redAccent;
      case TransactionCategory.entertainment: return Colors.pink;
      case TransactionCategory.healthcare: return Colors.teal;
      case TransactionCategory.education: return Colors.indigo;
      case TransactionCategory.travel: return Colors.cyan;
      case TransactionCategory.salary: return AppColors.success;
      case TransactionCategory.freelance: return AppColors.primary;
      case TransactionCategory.business: return Colors.amber;
      case TransactionCategory.gift: return Colors.greenAccent;
      case TransactionCategory.investment: return AppColors.warning;
      case TransactionCategory.other: return AppColors.textSecondary;
    }
  }
}
