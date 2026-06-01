class MonthlySummary {
  MonthlySummary({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
  });

  final int year;
  final int month;
  final double income;
  final double expense;

  double get savings => income - expense;
  
  double get savingsRate {
    if (income <= 0) return 0;
    final rate = (savings / income) * 100;
    return rate < 0 ? 0 : rate;
  }
}
