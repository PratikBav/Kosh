import 'package:flutter/material.dart';
import '../../transactions/models/transaction_category.dart';

class CategorySummary {
  CategorySummary({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  final TransactionCategory category;
  final double totalAmount;
  final double percentage;

  Color get color => category.color;
  String get name => category.label;
}
