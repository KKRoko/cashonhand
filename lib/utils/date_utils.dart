import '../data/models/enums/repeat_option.dart';

import '../data/models/freezed/custom_recurrence.dart';

/// Utility class for calculating dates and recurrence patterns
class DateUtils {
  /// Returns the last day of the week containing [date]
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  /// Returns the last day of the month containing [date]
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Returns a list of dates between [startDate] and [endDate], inclusive
static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final dayCount = end.difference(start).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(start.year, start.month, start.day + index),
    );
  }

    /// Returns a DateTime with the time portion zeroed out
  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Returns true if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    if (dateA == null || dateB == null) return false;
    return dateA.year == dateB.year &&
           dateA.month == dateB.month &&
           dateA.day == dateB.day;
  }


  /// Returns the next occurrence date based on repeat settings
  static DateTime getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    if (repeatOption == RepeatOption.custom && customRecurrence != null) {
      return _calculateCustomRecurrence(currentDay, customRecurrence);
    }

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

  /// Returns a list of recurrence dates for a year starting from [startDate]
  static List<DateTime> yearlyRecurrenceDates(DateTime startDate, CustomRecurrence customRecurrence) {
    final endOfYear = DateTime(startDate.year, 12, 31);
    final List<DateTime> dates = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endOfYear) || currentDate.isAtSameMomentAs(endOfYear)) {
      switch (customRecurrence.interval) {
        case RepeatOption.daily:
          dates.add(currentDate);
          currentDate = currentDate.add(Duration(days: customRecurrence.frequency));
          break;

        case RepeatOption.weekly:
          if (customRecurrence.selectedDays.any((selected) => selected)) {
            dates.addAll(_selectedWeekDays(currentDate, customRecurrence, startDate, endOfYear));
          } else {
            dates.add(currentDate);
          }
          currentDate = currentDate.add(Duration(days: 7 * customRecurrence.frequency));
          break;

        case RepeatOption.monthly:
          if (customRecurrence.dayOfMonth != null) {
            final targetDate = _monthlyTargetDate(currentDate, customRecurrence);
            if (!targetDate.isBefore(startDate) && !targetDate.isAfter(endOfYear)) {
              dates.add(targetDate);
            }
          } else if (customRecurrence.weekOfMonth != null) {
            final targetDate = _nthWeekdayOfMonth(
              currentDate.year,
              currentDate.month,
              currentDate.weekday,
              customRecurrence.weekOfMonth!,
            );
            if (!targetDate.isBefore(startDate) && !targetDate.isAfter(endOfYear)) {
              dates.add(targetDate);
            }
          }
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + customRecurrence.frequency,
            currentDate.day,
          );
          break;

        default:
          return dates;
      }
    }

    return dates;
  }

  /// Returns the next custom recurrence date
  static DateTime _calculateCustomRecurrence(DateTime currentDate, CustomRecurrence customRecurrence) {
    switch (customRecurrence.interval) {
      case RepeatOption.daily:
        return currentDate.add(Duration(days: customRecurrence.frequency));
      
      case RepeatOption.weekly:
        return _nextWeeklyDate(currentDate, customRecurrence);
      
      case RepeatOption.monthly:
        return _nextMonthlyDate(currentDate, customRecurrence);

      default:
        return currentDate.add(const Duration(days: 1));
    }
  }

static DateTime _nextWeeklyDate(DateTime currentDate, CustomRecurrence customRecurrence) {
    if (customRecurrence.selectedDays.any((selected) => selected)) {
        // Convert from Monday-based (1-7) to Sunday-based (0-6) for list index
        int currentWeekday = currentDate.weekday % 7;
        int daysUntilTarget = 0;
        
        // Find days until next selected day
        for (int i = 1; i <= 7; i++) {
            int checkDay = (currentWeekday + i - 1) % 7;
            if (customRecurrence.selectedDays[checkDay]) {
                daysUntilTarget = i;
                break;
            }
        }

        // Calculate total days to add including frequency
        int totalDays = daysUntilTarget;
        
        // If we're not finding the first occurrence, apply frequency
        if (daysUntilTarget == 0 || !_isFirstOccurrence(currentDate)) {
            totalDays = 7 * customRecurrence.frequency;
        }
        
        return currentDate.add(Duration(days: totalDays));
    }
    return currentDate.add(Duration(days: 7 * customRecurrence.frequency));
}

// Helper to determine if this is the first occurrence
static bool _isFirstOccurrence(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
}

  /// Returns the next monthly occurrence date
  static DateTime _nextMonthlyDate(DateTime currentDate, CustomRecurrence customRecurrence) {
    if (customRecurrence.dayOfMonth != null) {
      return DateTime(
        currentDate.year,
        currentDate.month + customRecurrence.frequency,
        customRecurrence.dayOfMonth!,
      );
    } else if (customRecurrence.weekOfMonth != null) {
      final nextMonth = DateTime(
        currentDate.year,
        currentDate.month + customRecurrence.frequency,
        1,
      );
      return _nthWeekdayOfMonth(
        nextMonth.year,
        nextMonth.month,
        currentDate.weekday,
        customRecurrence.weekOfMonth!,
      );
    }
    return DateTime(
      currentDate.year,
      currentDate.month + customRecurrence.frequency,
      currentDate.day,
    );
  }

  /// Returns selected weekdays within the current week
  static List<DateTime> _selectedWeekDays(
    DateTime currentDate,
    CustomRecurrence customRecurrence,
    DateTime startDate,
    DateTime endDate,
  ) {
    List<DateTime> dates = [];
    for (int i = 0; i < 7; i++) {
      if (customRecurrence.selectedDays[i]) {
        final dayDiff = i - currentDate.weekday + 1;
        final targetDate = currentDate.add(Duration(days: dayDiff));
        if (!targetDate.isBefore(startDate) && !targetDate.isAfter(endDate)) {
          dates.add(targetDate);
        }
      }
    }
    return dates;
  }

  /// Returns the target date for monthly recurrence
  static DateTime _monthlyTargetDate(DateTime currentDate, CustomRecurrence customRecurrence) {
    return DateTime(
      currentDate.year,
      currentDate.month,
      customRecurrence.dayOfMonth!,
    );
  }

  /// Returns the nth occurrence of a weekday in a month
  static DateTime _nthWeekdayOfMonth(int year, int month, int weekday, int n) {
    return n == 4
        ? _lastWeekdayOfMonth(year, month, weekday)
        : _specificWeekdayOfMonth(year, month, weekday, n);
  }

  /// Returns the specific weekday of the month
  static DateTime _specificWeekdayOfMonth(int year, int month, int weekday, int n) {
    final first = DateTime(year, month, 1);
    int dayOffset = weekday - first.weekday;
    if (dayOffset < 0) dayOffset += 7;
    
    return DateTime(year, month, 1 + dayOffset + (n * 7));
  }

  /// Returns the last occurrence of a weekday in a month
  static DateTime _lastWeekdayOfMonth(int year, int month, int weekday) {
    final lastDay = DateTime(year, month + 1, 0);
    int diff = weekday - lastDay.weekday;
    if (diff > 0) diff -= 7;
    return lastDay.add(Duration(days: diff));
  }
}
