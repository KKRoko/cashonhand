import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/custom_recurrence.dart';

class RecurrenceCalculationService {
  
  static DateTime getNextOccurrence(
    DateTime currentDate,
    RepeatOption repeatOption,
    CustomRecurrence? customRecurrence,
  ) {
    final frequency = customRecurrence?.frequency ?? 1;

    switch (repeatOption) {
      case RepeatOption.daily:
        return _calculateNextDaily(currentDate, frequency);
      case RepeatOption.weekly:
        return _calculateNextWeekly(currentDate, frequency, customRecurrence);
      case RepeatOption.monthly:
        return _calculateNextMonthly(currentDate, frequency, customRecurrence);
      default:
        return currentDate.add(const Duration(days: 1));
    }
  }

  static bool occursOnDate(
    DateTime eventStartDate,
    DateTime targetDate,
    RepeatOption repeatOption,
    CustomRecurrence? customRecurrence,
  ) {
    if (!_isRecurring(repeatOption)) {
      return isSameDay(eventStartDate, targetDate);
    }

    DateTime currentDate = eventStartDate;
    while (!currentDate.isAfter(targetDate)) {
      if (isSameDay(currentDate, targetDate)) {
        return true;
      }
      currentDate = getNextOccurrence(currentDate, repeatOption, customRecurrence);
      
      if (currentDate.isAfter(DateTime(targetDate.year + 1, 1, 1))) {
        break;
      }
    }
    return false;
  }

  static List<DateTime> generateOccurrences(
    DateTime startDate,
    DateTime endDate,
    RepeatOption repeatOption,
    CustomRecurrence? customRecurrence,
  ) {
    List<DateTime> occurrences = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      occurrences.add(currentDate);
      currentDate = getNextOccurrence(currentDate, repeatOption, customRecurrence);
      
      if (currentDate.isAfter(endDate)) break;
    }

    return occurrences;
  }

  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static bool isSameDay(DateTime? dateA, DateTime? dateB) {
    if (dateA == null || dateB == null) return false;
    return dateA.year == dateB.year &&
           dateA.month == dateB.month &&
           dateA.day == dateB.day;
  }

  static DateTime _calculateNextDaily(DateTime currentDate, int frequency) {
    return currentDate.add(Duration(days: frequency));
  }

  static DateTime _calculateNextWeekly(
    DateTime currentDate,
    int frequency,
    CustomRecurrence? customRecurrence,
  ) {
    if (customRecurrence?.hasSelectedDays == true) {
      return _calculateNextWeeklyWithSelectedDays(currentDate, customRecurrence!);
    }
    return currentDate.add(Duration(days: 7 * frequency));
  }

  static DateTime _calculateNextWeeklyWithSelectedDays(
    DateTime currentDate,
    CustomRecurrence customRecurrence,
  ) {
    List<int> selectedDayIndices = customRecurrence.selectedDayIndices;
    if (selectedDayIndices.isEmpty) {
      return currentDate.add(Duration(days: 7 * customRecurrence.frequency));
    }

    int currentWeekdayIndex = currentDate.weekday % 7;
    
    int? nextDayInCurrentWeek;
    for (int dayIndex in selectedDayIndices) {
      if (dayIndex > currentWeekdayIndex) {
        nextDayInCurrentWeek = dayIndex;
        break;
      }
    }
    
    DateTime nextDate;
    if (nextDayInCurrentWeek != null) {
      int daysToAdd = nextDayInCurrentWeek - currentWeekdayIndex;
      nextDate = currentDate.add(Duration(days: daysToAdd));
    } else {
      int firstDayNextCycle = selectedDayIndices.first;
      int daysToAdd = (7 - currentWeekdayIndex) + firstDayNextCycle;
      daysToAdd += 7 * (customRecurrence.frequency - 1);
      nextDate = currentDate.add(Duration(days: daysToAdd));
    }
    
    return nextDate;
  }

  static DateTime _calculateNextMonthly(
    DateTime currentDate,
    int frequency,
    CustomRecurrence? customRecurrence,
  ) {
    DateTime baseDate = _addMonths(currentDate, frequency);
    
    if (customRecurrence?.repeatAtEndOfMonth == true) {
      return DateTime(baseDate.year, baseDate.month + 1, 0);
    }
    
    if (customRecurrence?.useLastDayOfMonth == true) {
      int lastDay = DateTime(baseDate.year, baseDate.month + 1, 0).day;
      return DateTime(baseDate.year, baseDate.month, lastDay);
    }
    
    if (customRecurrence?.dayOfMonth != null) {
      int lastDay = DateTime(baseDate.year, baseDate.month + 1, 0).day;
      int targetDay = customRecurrence!.dayOfMonth!.clamp(1, lastDay);
      return DateTime(baseDate.year, baseDate.month, targetDay);
    }
    
    int lastDayOfTargetMonth = DateTime(baseDate.year, baseDate.month + 1, 0).day;
    int targetDay = currentDate.day.clamp(1, lastDayOfTargetMonth);
    return DateTime(baseDate.year, baseDate.month, targetDay);
  }

  static DateTime _addMonths(DateTime date, int months) {
    var year = date.year + (date.month + months - 1) ~/ 12;
    var month = (date.month + months - 1) % 12 + 1;
    
    var lastDayOfMonth = DateTime(year, month + 1, 0).day;
    var day = date.day.clamp(1, lastDayOfMonth);
    
    return DateTime(year, month, day);
  }

  static bool _isRecurring(RepeatOption repeatOption) {
    return repeatOption != RepeatOption.today;
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final dayCount = end.difference(start).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(start.year, start.month, start.day + index),
    );
  }

  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime adjustDateForEndOfMonth(DateTime date, CustomRecurrence? customRecurrence) {
    if (customRecurrence?.repeatAtEndOfMonth == true || 
        (customRecurrence?.useLastDayOfMonth == true && date.day >= 29)) {
      return DateTime(date.year, date.month + 1, 0);
    }
    return date;
  }
}