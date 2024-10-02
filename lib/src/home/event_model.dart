import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';

enum RepeatOption { none, daily, weekly, monthly, yearly, custom }

class Event {
  final String title;
  final double? amount;
  final bool isPositiveCashflow;
  final bool isNegativeCashflow;
  final RepeatOption repeatOption;
  final CustomRecurrence? customRecurrence;

  Event({
    required this.title,
    this.amount,
    required this.isPositiveCashflow,
    required this.isNegativeCashflow,
    required this.repeatOption,
    this.customRecurrence,
  });

  @override
  String toString() => title;
}

class CustomRecurrence {
  final RepeatOption interval;
  final int frequency;
  final List<bool> selectedDays;
  final int? dayOfMonth;
  final int? month;

  CustomRecurrence({
    required this.interval,
    required this.frequency,
    this.selectedDays = const [],
    this.dayOfMonth,
    this.month,
  });
}

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

// Add any other necessary constants or utilities
