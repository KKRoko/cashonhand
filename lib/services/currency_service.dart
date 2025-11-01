import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/enums/currency.dart';

@singleton
class CurrencyService extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';

  Currency _selectedCurrency = Currency.usd;

  Currency get selectedCurrency => _selectedCurrency;

  /// Initialize currency service and load saved currency
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_currencyKey);

    if (savedCode != null) {
      final currency = Currency.fromCode(savedCode);
      if (currency != null) {
        _selectedCurrency = currency;
      }
    } else {
      // Set default currency based on device locale
      _selectedCurrency = _getDefaultCurrencyForDevice();
      // Save the default so it persists
      await _saveCurrency(_selectedCurrency);
    }
  }

  /// Update selected currency and persist it
  Future<void> updateCurrency(Currency currency) async {
    if (_selectedCurrency != currency) {
      _selectedCurrency = currency;
      await _saveCurrency(currency);
      notifyListeners(); // Notify all listeners of the change
    }
  }

  /// Get default currency based on device locale
  Currency _getDefaultCurrencyForDevice() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final localeString = '${locale.languageCode}_${locale.countryCode}';
      return Currency.getDefaultForLocale(localeString);
    } catch (e) {
      return Currency.usd; // Fallback to USD
    }
  }

  /// Save currency to shared preferences
  Future<void> _saveCurrency(Currency currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
  }

  /// Get currency symbol for display
  String get currencySymbol => _selectedCurrency.symbol;

  /// Get currency code for display
  String get currencyCode => _selectedCurrency.code;

  /// Get currency name for display
  String get currencyName => _selectedCurrency.name;

  /// Check if currency has been manually set by user
  Future<bool> get hasUserSelectedCurrency async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currencyKey);
  }
}
