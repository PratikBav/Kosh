import 'package:intl/intl.dart';

/// Single source of truth for rendering money.
///
/// Every amount in the app goes through here so the same value never renders
/// two different ways. Formatters are built once and reused — `NumberFormat`
/// is comparatively expensive and was previously constructed inside `build`
/// methods and list item builders.
class CurrencyUtils {
  CurrencyUtils._();

  static const String symbol = '₹';

  /// Indian digit grouping (1,00,000 rather than 100,000).
  static const String _locale = 'en_IN';

  static final NumberFormat _whole = NumberFormat.currency(
    locale: _locale,
    symbol: symbol,
    decimalDigits: 0,
  );

  static final NumberFormat _precise = NumberFormat.currency(
    locale: _locale,
    symbol: symbol,
    decimalDigits: 2,
  );

  static final NumberFormat _compactDecimal = NumberFormat('#,##0.#', _locale);

  static const double _lakh = 100000;
  static const double _crore = 10000000;

  /// Whole-rupee amount, e.g. `₹1,24,500`.
  ///
  /// The default for lists, cards and summaries — paise add noise without
  /// adding meaning at a glance.
  static String format(double amount) => _whole.format(amount);

  /// Amount including paise, e.g. `₹1,24,500.75`.
  ///
  /// For detail screens, where the exact figure is the point.
  static String formatPrecise(double amount) => _precise.format(amount);

  /// Abbreviated amount for tight spaces, e.g. `₹1.2L`, `₹3.45Cr`.
  ///
  /// Uses Indian scale words, since the app formats in Indian grouping.
  /// Falls back to [format] below one lakh, where abbreviating would cost
  /// precision without saving space.
  static String formatCompact(double amount) {
    final magnitude = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (magnitude >= _crore) {
      return '$sign$symbol${_compactDecimal.format(magnitude / _crore)}Cr';
    }
    if (magnitude >= _lakh) {
      return '$sign$symbol${_compactDecimal.format(magnitude / _lakh)}L';
    }
    return format(amount);
  }

  /// Amount with an explicit sign, e.g. `+₹500` / `-₹500`.
  ///
  /// [forceSign] keeps a leading `+` on positive values, which reads as a
  /// deliberate gain rather than a bare number.
  static String formatSigned(double amount, {bool forceSign = true}) {
    final formatted = format(amount.abs());
    if (amount < 0) return '-$formatted';
    return forceSign ? '+$formatted' : formatted;
  }
}
