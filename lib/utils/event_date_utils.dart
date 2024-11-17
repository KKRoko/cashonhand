import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/custom_recurrence.dart';

/// Utility class for calculating dates and recurrence patterns
class EventDateUtils {
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
    if (dateA == null || dateB == null) {
    print('isSameDay: one of the dates is null');
    return false;
    }
  bool result = dateA.year == dateB.year &&
         dateA.month == dateB.month &&
         dateA.day == dateB.day;
  print('isSameDay comparing: ${dateA.toIso8601String()} and ${dateB.toIso8601String()} = $result');
  return result;
  }

  /// Returns the next occurrence date based on repeat settings
  static DateTime getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    // If it's a custom recurrence, use that logic
    if (repeatOption == RepeatOption.custom && customRecurrence != null) {
      return _calculateCustomRecurrence(currentDay, customRecurrence);
    }

    // For standard repeat options, apply the frequency if available
    final frequency = customRecurrence?.frequency ?? 1;
    
    switch (repeatOption) {
      case RepeatOption.daily:
        return currentDay.add(Duration(days: frequency));
      case RepeatOption.weekly:
        return currentDay.add(Duration(days: 7 * frequency));
      case RepeatOption.monthly:
        return _calculateNextMonthlyDate(currentDay, customRecurrence);
      default:
        return currentDay.add(const Duration(days: 1));
    }
  }

  /// Calculates the next monthly date considering end-of-month settings
  static DateTime _calculateNextMonthlyDate(DateTime currentDate, CustomRecurrence? customRecurrence) {
    if (customRecurrence == null) {
      return DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
    }

    final frequency = customRecurrence.frequency;
    final nextMonth = currentDate.month + frequency;
    final nextYear = currentDate.year + (nextMonth - 1) ~/ 12;
    final adjustedMonth = ((nextMonth - 1) % 12) + 1;

    // Handle end of month cases
    if (customRecurrence.repeatAtEndOfMonth || customRecurrence.useLastDayOfMonth) {
      return DateTime(nextYear, adjustedMonth + 1, 0);
    }

    // For specific day of month
    if (customRecurrence.dayOfMonth != null) {
      final lastDayOfMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
      final targetDay = customRecurrence.dayOfMonth!;
      
      // If the target day exists in the month, use it
      if (targetDay <= lastDayOfMonth) {
        return DateTime(nextYear, adjustedMonth, targetDay);
      }
      
      // If the target day doesn't exist, use the last day of the month
      return DateTime(nextYear, adjustedMonth + 1, 0);
    }

    // Default case: maintain the same day of month if possible
    final lastDayOfTargetMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
    final targetDay = currentDate.day <= lastDayOfTargetMonth ? currentDate.day : lastDayOfTargetMonth;
    return DateTime(nextYear, adjustedMonth, targetDay);
  }

   static DateTime _calculateCustomRecurrence(DateTime currentDate, CustomRecurrence customRecurrence) {
    switch (customRecurrence.interval) {
      case RepeatOption.daily:
        return currentDate.add(Duration(days: customRecurrence.frequency));
    
      case RepeatOption.weekly:
        if (customRecurrence.hasSelectedDays) {
          List<int> selectedDayIndices = customRecurrence.selectedDayIndices;
          if (selectedDayIndices.isEmpty) {
            return currentDate.add(Duration(days: 7 * customRecurrence.frequency));
          }

          // If this is the first occurrence
          if (customRecurrence.originalDate != null && 
              isSameDay(currentDate, customRecurrence.originalDate)) {
              
            // Get current weekday in 0-6 format where 0 is Sunday
            int currentWeekdayIndex = currentDate.weekday % 7;
            
            // Find next selected day after current weekday
            int? nextDayIndex = selectedDayIndices.firstWhere(
              (dayIndex) => dayIndex > currentWeekdayIndex,
              orElse: () => selectedDayIndices.first
            );
            
            // Calculate days until next occurrence
            int daysUntilNext;
            if (nextDayIndex > currentWeekdayIndex) {
              daysUntilNext = nextDayIndex - currentWeekdayIndex;
            } else {
              daysUntilNext = 7 - currentWeekdayIndex + nextDayIndex;
            }
            
            return currentDate.add(Duration(days: daysUntilNext));
          }
          
          // For subsequent occurrences, add the frequency weeks
          return currentDate.add(Duration(days: 7 * customRecurrence.frequency));
        }
        return currentDate.add(Duration(days: 7 * customRecurrence.frequency));
    
      case RepeatOption.monthly:
        return _calculateNextMonthlyDate(currentDate, customRecurrence);

      default:
        return currentDate.add(Duration(days: customRecurrence.frequency));
    }
  }

  static int _sundayBasedToWeekday(int sundayBasedIndex) {
    // Convert from [0,1,2,3,4,5,6] to [7,1,2,3,4,5,6]
    return sundayBasedIndex == 0 ? 7 : sundayBasedIndex;
  }

  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime adjustDateForEndOfMonth(DateTime date, CustomRecurrence? customRecurrence) {
  if (customRecurrence?.repeatAtEndOfMonth == true) {
    return getEndOfMonth(date);
  }
  return date;
}
}
