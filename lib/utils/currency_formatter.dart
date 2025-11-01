import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import 'package:intl/intl.dart';

/// Helper class for currency formatting that respects user's currency selection
class CurrencyFormatter {
  /// Format an amount as currency using the selected currency from context
  /// This will automatically rebuild when currency changes
  static String format(BuildContext context, double amount, {bool listen = true}) {
    final currencyService = Provider.of<CurrencyService>(context, listen: listen);
    final formatter = NumberFormat.currency(
      symbol: currencyService.currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Get just the currency symbol from context
  static String symbol(BuildContext context, {bool listen = true}) {
    final currencyService = Provider.of<CurrencyService>(context, listen: listen);
    return currencyService.currencySymbol;
  }
}

/// A Text widget that automatically formats and displays currency
/// Will rebuild when the currency changes
class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CurrencyText(
    this.amount, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(context, amount),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
