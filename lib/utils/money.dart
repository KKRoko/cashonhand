import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// A utility class for handling financial calculations with precise decimal arithmetic
/// Prevents floating-point precision errors common with double arithmetic
class Money {
  final Decimal _amount;
  
  const Money._(this._amount);
  
  /// Create Money from a double (for migration compatibility)
  factory Money.fromDouble(double amount) {
    return Money._(Decimal.parse(amount.toStringAsFixed(2)));
  }
  
  /// Create Money from a Decimal
  factory Money.fromDecimal(Decimal amount) {
    return Money._(amount);
  }
  
  /// Create Money from a string
  factory Money.fromString(String amount) {
    return Money._(Decimal.parse(amount));
  }
  
  /// Create Money from cents (integer)
  factory Money.fromCents(int cents) {
    return Money._(Decimal.parse((cents / 100).toStringAsFixed(2)));
  }
  
  /// Zero money
  static final Money zero = Money._(Decimal.zero);
  
  /// Get the amount as Decimal
  Decimal get decimal => _amount;
  
  /// Get the amount as double (for compatibility with existing code)
  double get toDouble => _amount.toDouble();
  
  /// Get the amount as integer cents
  int get toCents => (_amount * Decimal.fromInt(100)).toBigInt().toInt();
  
  /// Format as currency string
  String formatCurrency({String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(_amount.toDouble());
  }
  
  /// Format as simple string with 2 decimal places
  String toStringFixed(int fractionDigits) {
    return _amount.toStringAsFixed(fractionDigits);
  }
  
  @override
  String toString() => _amount.toString();
  
  // Arithmetic operations
  Money operator +(Money other) => Money._(_amount + other._amount);
  Money operator -(Money other) => Money._(_amount - other._amount);
  Money operator *(num factor) => Money._(_amount * Decimal.parse(factor.toString()));
  Money operator -() => Money._(-_amount);
  
  /// Division that returns a double (for percentages, ratios, etc.)
  double divideBy(Money other) => (_amount / other._amount).toDouble();
  double divideByNumber(num divisor) => (_amount / Decimal.parse(divisor.toString())).toDouble();
  
  // Comparison operations
  bool operator >(Money other) => _amount > other._amount;
  bool operator <(Money other) => _amount < other._amount;
  bool operator >=(Money other) => _amount >= other._amount;
  bool operator <=(Money other) => _amount <= other._amount;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Money && _amount == other._amount;
  }
  
  @override
  int get hashCode => _amount.hashCode;
  
  /// Get absolute value
  Money abs() => Money._(_amount.abs());
  
  /// Clamp between min and max values
  Money clamp(Money min, Money max) {
    if (_amount < min._amount) return min;
    if (_amount > max._amount) return max;
    return this;
  }
  
  /// Check if the amount is positive
  bool get isPositive => _amount > Decimal.zero;
  
  /// Check if the amount is negative
  bool get isNegative => _amount < Decimal.zero;
  
  /// Check if the amount is zero
  bool get isZero => _amount == Decimal.zero;
}

/// Extension methods for converting between double and Money
extension DoubleToMoney on double {
  Money get money => Money.fromDouble(this);
}

extension IntToMoney on int {
  Money get cents => Money.fromCents(this);
}

extension StringToMoney on String {
  Money get money => Money.fromString(this);
}