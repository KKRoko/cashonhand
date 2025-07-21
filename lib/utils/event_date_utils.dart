import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/custom_recurrence.dart';
import '../services/recurrence_calculation_service.dart';

/// Utility class for calculating dates and recurrence patterns
class EventDateUtils {
  /// Returns the last day of the week containing [date]
  static DateTime getEndOfWeek(DateTime date) {
    return RecurrenceCalculationService.getEndOfWeek(date);
  }

  /// Returns the last day of the month containing [date]
  static DateTime getEndOfMonth(DateTime date) {
    return RecurrenceCalculationService.getEndOfMonth(date);
  }

  /// Returns a list of dates between [startDate] and [endDate], inclusive
  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    return RecurrenceCalculationService.getDaysInRange(start, end);
  }

  /// Returns a DateTime with the time portion zeroed out
  static DateTime normalizeDate(DateTime date) {
    return RecurrenceCalculationService.normalizeDate(date);
  }

  /// Returns true if two dates are the same day (ignoring time)
  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    return RecurrenceCalculationService.isSameDay(dateA, dateB);
  }

  static DateTime getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    return RecurrenceCalculationService.getNextOccurrence(currentDay, repeatOption, customRecurrence);
  }


  static int getDaysInMonth(int year, int month) {
    return RecurrenceCalculationService.getDaysInMonth(year, month);
  }

  static DateTime adjustDateForEndOfMonth(DateTime date, CustomRecurrence? customRecurrence) {
    return RecurrenceCalculationService.adjustDateForEndOfMonth(date, customRecurrence);
  }
}