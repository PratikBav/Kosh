import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Priority levels for goals.
enum GoalPriority {
  low,
  medium,
  high,
  critical;

  /// Human-readable label.
  String get label {
    switch (this) {
      case GoalPriority.low: return 'Low';
      case GoalPriority.medium: return 'Medium';
      case GoalPriority.high: return 'High';
      case GoalPriority.critical: return 'Critical';
    }
  }

  /// The theme color mapped to this priority.
  Color get color {
    switch (this) {
      case GoalPriority.low: return AppColors.success;
      case GoalPriority.medium: return Colors.blue;
      case GoalPriority.high: return Colors.orange;
      case GoalPriority.critical: return AppColors.danger;
    }
  }
}
