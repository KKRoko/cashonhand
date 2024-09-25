// utils.dart

import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

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

  const Event({
    required this.title,
    this.amount,
    this.isPositiveCashflow = false,
    this.isNegativeCashflow = false,
    this.repeatOption = RepeatOption.none,
    this.customFrequency,
    this.selectedDays,
    this.customDay,
    this.customMonth,
    this.customRepeatOption,
  });

  @override
  String toString() => title;
}


enum RepeatOption { none, daily, weekly, monthly, yearly, custom }

final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = <DateTime, List<Event>>{};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);