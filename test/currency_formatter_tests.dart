import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cash_on_hand/utils/formatters.dart';

void main() {
  group('CurrencyInputFormatter Tests', () {
    late CurrencyInputFormatter formatter;

    setUp(() {
      formatter = CurrencyInputFormatter();
    });

    TextEditingValue _createTextEditingValue(String text, {int? selectionIndex}) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(
          offset: selectionIndex ?? text.length,
        ),
      );
    }

    test('should format basic currency input', () {
      final result = formatter.formatEditUpdate(
        _createTextEditingValue(''),
        _createTextEditingValue('12345'),
      );
      expect(result.text, '123.45');
    });

    test('should handle larger numbers', () {
      final result = formatter.formatEditUpdate(
        _createTextEditingValue(''),
        _createTextEditingValue('1234567'),
      );
      expect(result.text, '12,345.67');
    });

    test('should handle numbers over 5 digits', () {
      final result = formatter.formatEditUpdate(
        _createTextEditingValue(''),
        _createTextEditingValue('123456789'),
      );
      expect(result.text, '1,234,567.89');
    });
  });
}
