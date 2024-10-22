import 'package:uuid/uuid.dart';

enum RepeatOption { today, daily, weekly, monthly, yearly, custom }

class Event {
  final String id;
  final String title;
  final double? amount;
  final bool isPositiveCashflow;
  final bool isNegativeCashflow;
  final RepeatOption repeatOption;
  final CustomRecurrence? customRecurrence;
  final DateTime createdAt;
  final bool isYearEndSummary;

  Event({
    String? id,
    required this.title,
    this.amount,
    required this.isPositiveCashflow,
    required this.isNegativeCashflow,
    required this.repeatOption,
    this.customRecurrence,
    DateTime? createdAt,
    this.isYearEndSummary = true,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Event copyWith({
    String? title,
    double? amount,
    bool? isPositiveCashflow,
    bool? isNegativeCashflow,
    RepeatOption? repeatOption,
    CustomRecurrence? customRecurrence,
    bool? isYearEndSummary,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isPositiveCashflow: isPositiveCashflow ?? this.isPositiveCashflow,
      isNegativeCashflow: isNegativeCashflow ?? this.isNegativeCashflow,
      repeatOption: repeatOption ?? this.repeatOption,
      customRecurrence: customRecurrence ?? this.customRecurrence,
      createdAt: createdAt,
      isYearEndSummary: isYearEndSummary ?? this.isYearEndSummary,
    );
  }

  @override
  String toString() => title;
}

class CustomRecurrence {
  final RepeatOption interval;
  final int frequency;
  final List<bool> selectedDays;
  final int? dayOfMonth;
  final int? weekOfMonth;
  final int? month;

  CustomRecurrence({
    required this.interval,
    required this.frequency,
    this.selectedDays = const [],
    this.dayOfMonth,
    this.weekOfMonth,
    this.month,
  });
}

enum DeleteOption {
  thisDay,
  allTime,
  futureOnly,
  pastOnly,
}