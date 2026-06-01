import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Predefined categories for goals.
enum GoalCategory {
  emergencyFund,
  travel,
  education,
  vehicle,
  gadgets,
  investment,
  business,
  home,
  personal,
  other;

  /// Human-readable label.
  String get label {
    switch (this) {
      case GoalCategory.emergencyFund: return 'Emergency Fund';
      case GoalCategory.travel: return 'Travel';
      case GoalCategory.education: return 'Education';
      case GoalCategory.vehicle: return 'Vehicle';
      case GoalCategory.gadgets: return 'Gadgets';
      case GoalCategory.investment: return 'Investment';
      case GoalCategory.business: return 'Business';
      case GoalCategory.home: return 'Home';
      case GoalCategory.personal: return 'Personal';
      case GoalCategory.other: return 'Other';
    }
  }

  /// Icon associated with the category.
  IconData get icon {
    switch (this) {
      case GoalCategory.emergencyFund: return Icons.health_and_safety_rounded;
      case GoalCategory.travel: return Icons.flight_takeoff_rounded;
      case GoalCategory.education: return Icons.school_rounded;
      case GoalCategory.vehicle: return Icons.directions_car_rounded;
      case GoalCategory.gadgets: return Icons.devices_rounded;
      case GoalCategory.investment: return Icons.trending_up_rounded;
      case GoalCategory.business: return Icons.storefront_rounded;
      case GoalCategory.home: return Icons.home_rounded;
      case GoalCategory.personal: return Icons.person_rounded;
      case GoalCategory.other: return Icons.star_rounded;
    }
  }

  /// The theme color mapped to this category.
  Color get color {
    switch (this) {
      case GoalCategory.emergencyFund: return Colors.redAccent;
      case GoalCategory.travel: return Colors.cyan;
      case GoalCategory.education: return Colors.indigo;
      case GoalCategory.vehicle: return Colors.blue;
      case GoalCategory.gadgets: return Colors.purple;
      case GoalCategory.investment: return AppColors.warning;
      case GoalCategory.business: return Colors.amber;
      case GoalCategory.home: return Colors.teal;
      case GoalCategory.personal: return Colors.pink;
      case GoalCategory.other: return AppColors.textSecondary;
    }
  }
}
