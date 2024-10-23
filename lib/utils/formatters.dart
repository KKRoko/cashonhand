import 'package:intl/intl.dart';

/// Formatters for currency and dates
class FormatUtils {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(symbol: '\$');
  static final DateFormat _dateFormatter = DateFormat('EEEE, MMMM d, y');

  /// Formats a number as currency
  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  /// Formats a date in full format
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
}