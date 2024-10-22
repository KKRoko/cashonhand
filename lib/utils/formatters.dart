// lib/utils/formatters.dart

import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(symbol: '\$');
final _dateFormatter = DateFormat('EEEE, MMMM d, y');

String formatCurrency(double amount) {
  return _currencyFormatter.format(amount);
}

String formatDate(DateTime date) {
  return _dateFormatter.format(date);
}
