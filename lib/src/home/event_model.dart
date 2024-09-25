enum RepeatOption { none, daily, weekly, monthly, yearly, custom }

class Event {
  final String title;
  final double? amount;
  final bool isPositiveCashflow;
  final bool isNegativeCashflow;
  final RepeatOption repeatOption;
  final int? customFrequency;
  final List<bool>? selectedDays;
  final int? customDay;
  final int? customMonth;
  final RepeatOption? customRepeatOption;

  Event({
    required this.title,
    this.amount,
    required this.isPositiveCashflow,
    required this.isNegativeCashflow,
    required this.repeatOption,
    this.customFrequency,
    this.selectedDays,
    this.customDay,
    this.customMonth,
    this.customRepeatOption,
  });

  @override
  String toString() => title;
}
