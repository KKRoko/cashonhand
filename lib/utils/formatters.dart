import 'package:intl/intl.dart';
import 'package:flutter/services.dart';


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
