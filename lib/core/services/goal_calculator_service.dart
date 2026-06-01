/// Service for performing goal-related calculations.
class GoalCalculatorService {
  GoalCalculatorService._();

  /// Calculates the completion percentage of a goal (0.0 to 100.0).
  static double getCompletionPercentage(double currentAmount, double targetAmount) {
    if (targetAmount <= 0) return 0.0;
    final percentage = (currentAmount / targetAmount) * 100;
    return percentage > 100.0 ? 100.0 : percentage;
  }

  /// Calculates the remaining amount needed to reach the target.
  static double getRemainingAmount(double currentAmount, double targetAmount) {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0.0 : remaining;
  }

  /// Calculates the number of days left until the deadline.
  /// Returns 0 if the deadline has passed.
  static int getDaysLeft(DateTime deadline) {
    final today = DateTime.now();
    // Normalize both dates to midnight to ensure accurate day calculation
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDeadline = DateTime(deadline.year, deadline.month, deadline.day);

    final diff = normalizedDeadline.difference(normalizedToday).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Calculates the amount required per month to reach the target by the deadline.
  static double getMonthlyRequirement(double currentAmount, double targetAmount, DateTime deadline) {
    final remaining = getRemainingAmount(currentAmount, targetAmount);
    if (remaining <= 0) return 0.0;

    final daysLeft = getDaysLeft(deadline);
    if (daysLeft <= 0) return remaining; // If deadline is passed/today, all of it is required now

    // Approximate months left (days / 30)
    final double monthsLeft = daysLeft / 30.0;
    
    // If less than a month is left, just return the remaining amount
    if (monthsLeft < 1.0) return remaining;

    return remaining / monthsLeft;
  }
}
