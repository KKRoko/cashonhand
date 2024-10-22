// lib/utils/date_utils.dart

import '../data/models/event_model.dart';

DateTime getEndOfWeek(DateTime date) {
  return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
}

DateTime getEndOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
}

DateTime getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
  if (repeatOption == RepeatOption.custom && customRecurrence != null) {
    // Implementation for custom recurrence
    // This would need to be expanded based on your specific requirements
    return currentDay.add(const Duration(days: 1));
  } else {
    switch (repeatOption) {
      case RepeatOption.daily:
        return currentDay.add(const Duration(days: 1));
      case RepeatOption.weekly:
        return currentDay.add(const Duration(days: 7));
      case RepeatOption.monthly:
        return DateTime(currentDay.year, currentDay.month + 1, currentDay.day);
      case RepeatOption.yearly:
        return DateTime(currentDay.year + 1, currentDay.month, currentDay.day);
      default:
        return currentDay.add(const Duration(days: 1));
    }
  }
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
