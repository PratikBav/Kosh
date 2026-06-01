import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount) {
    final format = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }
}
