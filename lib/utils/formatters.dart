import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'money.dart';
import '../core/di/injection.dart';
import '../services/currency_service.dart';


/// Formatters for currency and dates
class FormatUtils {
  static final DateFormat _dateFormatter = DateFormat('EEE, MMMM d, y');

  /// Get the current currency symbol from CurrencyService
  static String get currencySymbol {
    try {
      final currencyService = getIt<CurrencyService>();
      return currencyService.currencySymbol;
    } catch (e) {
      return '\$'; // Fallback to USD if service not available
    }
  }

  /// Formats a number as currency (legacy - use formatMoney instead)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: currencySymbol);
    return formatter.format(amount);
  }

  /// Formats Money as currency with precise arithmetic
  static String formatMoney(Money amount) {
    return amount.formatCurrency(symbol: currencySymbol);
  }

  /// Formats a date in full format
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0.00', 'en_US');
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If deleting or empty, return as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit input length to 7 digits (excluding cents)
    if (newText.length > 9) {
      return oldValue;
    }

    try {
      // Treat the last two digits as cents
      String dollars = newText.length > 2 ? newText.substring(0, newText.length - 2) : "0";
      String cents = newText.length > 2 ? newText.substring(newText.length - 2) : newText.padLeft(2, '0');
      
      // Parse the dollars and cents separately
      double value = double.parse('$dollars.$cents');

      // Format the number
      String formatted = _formatter.format(value);
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      return oldValue;
    }
  }

  static double? parse(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
  }
}
