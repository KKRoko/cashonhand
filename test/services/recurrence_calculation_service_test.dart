import 'package:flutter_test/flutter_test.dart';
import 'package:cash_on_hand/services/recurrence_calculation_service.dart';
import 'package:cash_on_hand/data/models/enums/repeat_option.dart';
import 'package:cash_on_hand/data/models/freezed/custom_recurrence.dart';

void main() {
  group('RecurrenceCalculationService - Daily', () {
    test('should calculate next daily occurrence with frequency 1', () {
      final startDate = DateTime(2024, 1, 1);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.daily,
        const CustomRecurrence(interval: RepeatOption.daily, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 1, 2));
    });

    test('should calculate next daily occurrence with frequency 3', () {
      final startDate = DateTime(2024, 1, 1);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.daily,
        const CustomRecurrence(interval: RepeatOption.daily, frequency: 3),
      );
      
      expect(nextDate, DateTime(2024, 1, 4));
    });
  });

  group('RecurrenceCalculationService - Weekly', () {
    test('should calculate next weekly occurrence with frequency 1', () {
      final startDate = DateTime(2024, 1, 1); // Monday
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.weekly,
        const CustomRecurrence(interval: RepeatOption.weekly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 1, 8));
    });

    test('should calculate next weekly occurrence with frequency 2', () {
      final startDate = DateTime(2024, 1, 1); // Monday
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.weekly,
        const CustomRecurrence(interval: RepeatOption.weekly, frequency: 2),
      );
      
      expect(nextDate, DateTime(2024, 1, 15));
    });

    test('should handle weekly with selected days - next day in same week', () {
      final startDate = DateTime(2024, 1, 1); // Monday (weekday % 7 = 1)
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 1,
        selectedDays: [false, true, false, true, false, false, false], // Monday and Wednesday
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 1, 3)); // Wednesday
    });

    test('should handle weekly with selected days - next week cycle', () {
      final startDate = DateTime(2024, 1, 3); // Wednesday (weekday % 7 = 3)
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 1,
        selectedDays: [false, true, false, false, false, false, false], // Only Monday
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 1, 8)); // Next Monday
    });
  });

  group('RecurrenceCalculationService - Monthly', () {
    test('should calculate next monthly occurrence with frequency 1', () {
      final startDate = DateTime(2024, 1, 15);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        const CustomRecurrence(interval: RepeatOption.monthly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 2, 15));
    });

    test('should handle end of month edge case', () {
      final startDate = DateTime(2024, 1, 31);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        const CustomRecurrence(interval: RepeatOption.monthly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 2, 29)); // February 2024 has 29 days
    });

    test('should handle repeatAtEndOfMonth flag', () {
      final startDate = DateTime(2024, 1, 15);
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.monthly,
        frequency: 1,
        repeatAtEndOfMonth: true,
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 2, 29)); // Last day of February 2024
    });

    test('should handle useLastDayOfMonth flag', () {
      final startDate = DateTime(2024, 1, 15);
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.monthly,
        frequency: 1,
        useLastDayOfMonth: true,
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 2, 29)); // Last day of February 2024
    });

    test('should handle specific dayOfMonth', () {
      final startDate = DateTime(2024, 1, 15);
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.monthly,
        frequency: 1,
        dayOfMonth: 5,
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 2, 5));
    });

    test('should handle dayOfMonth exceeding month length', () {
      final startDate = DateTime(2024, 1, 15);
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.monthly,
        frequency: 1,
        dayOfMonth: 31, // February doesn't have 31 days
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 2, 29)); // Clamped to last day of February
    });
  });

  group('RecurrenceCalculationService - occursOnDate', () {
    test('should return true for non-recurring event on same date', () {
      final eventDate = DateTime(2024, 1, 15);
      final targetDate = DateTime(2024, 1, 15);
      
      final occurs = RecurrenceCalculationService.occursOnDate(
        eventDate,
        targetDate,
        RepeatOption.today,
        null,
      );
      
      expect(occurs, true);
    });

    test('should return false for non-recurring event on different date', () {
      final eventDate = DateTime(2024, 1, 15);
      final targetDate = DateTime(2024, 1, 16);
      
      final occurs = RecurrenceCalculationService.occursOnDate(
        eventDate,
        targetDate,
        RepeatOption.today,
        null,
      );
      
      expect(occurs, false);
    });

    test('should return true for daily recurring event', () {
      final eventDate = DateTime(2024, 1, 1);
      final targetDate = DateTime(2024, 1, 5);
      
      final occurs = RecurrenceCalculationService.occursOnDate(
        eventDate,
        targetDate,
        RepeatOption.daily,
        const CustomRecurrence(interval: RepeatOption.daily, frequency: 1),
      );
      
      expect(occurs, true);
    });

    test('should return false for daily recurring event with frequency 2 on odd days', () {
      final eventDate = DateTime(2024, 1, 1);
      final targetDate = DateTime(2024, 1, 4); // 3 days later, not divisible by 2
      
      final occurs = RecurrenceCalculationService.occursOnDate(
        eventDate,
        targetDate,
        RepeatOption.daily,
        const CustomRecurrence(interval: RepeatOption.daily, frequency: 2),
      );
      
      expect(occurs, false);
    });
  });

  group('RecurrenceCalculationService - generateOccurrences', () {
    test('should generate daily occurrences correctly', () {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 5);
      
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        startDate,
        endDate,
        RepeatOption.daily,
        const CustomRecurrence(interval: RepeatOption.daily, frequency: 1),
      );
      
      expect(occurrences.length, 5);
      expect(occurrences[0], DateTime(2024, 1, 1));
      expect(occurrences[4], DateTime(2024, 1, 5));
    });

    test('should generate weekly occurrences correctly', () {
      final startDate = DateTime(2024, 1, 1); // Monday
      final endDate = DateTime(2024, 1, 29); // 4 weeks later
      
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        startDate,
        endDate,
        RepeatOption.weekly,
        const CustomRecurrence(interval: RepeatOption.weekly, frequency: 1),
      );
      
      expect(occurrences.length, 5); // 5 Mondays in range
      expect(occurrences[1], DateTime(2024, 1, 8));
      expect(occurrences[2], DateTime(2024, 1, 15));
    });
  });

  group('RecurrenceCalculationService - Utility Methods', () {
    test('isSameDay should return true for same dates', () {
      final date1 = DateTime(2024, 1, 15, 10, 30);
      final date2 = DateTime(2024, 1, 15, 20, 45);
      
      expect(RecurrenceCalculationService.isSameDay(date1, date2), true);
    });

    test('isSameDay should return false for different dates', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);
      
      expect(RecurrenceCalculationService.isSameDay(date1, date2), false);
    });

    test('normalizeDate should remove time component', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final normalized = RecurrenceCalculationService.normalizeDate(date);
      
      expect(normalized, DateTime.utc(2024, 1, 15));
    });

    test('getDaysInRange should return correct number of days', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 5);
      
      final days = RecurrenceCalculationService.getDaysInRange(start, end);
      
      expect(days.length, 5);
      expect(days.first, DateTime.utc(2024, 1, 1));
      expect(days.last, DateTime.utc(2024, 1, 5));
    });

    test('getEndOfMonth should return last day of month', () {
      final date = DateTime(2024, 2, 15); // February 2024
      final endOfMonth = RecurrenceCalculationService.getEndOfMonth(date);
      
      expect(endOfMonth, DateTime(2024, 2, 29)); // 2024 is leap year
    });

    test('getDaysInMonth should return correct count', () {
      final daysInFeb2024 = RecurrenceCalculationService.getDaysInMonth(2024, 2);
      final daysInFeb2023 = RecurrenceCalculationService.getDaysInMonth(2023, 2);
      
      expect(daysInFeb2024, 29); // Leap year
      expect(daysInFeb2023, 28); // Non-leap year
    });
  });

  group('RecurrenceCalculationService - Edge Cases', () {
    test('should handle leap year February correctly', () {
      final startDate = DateTime(2024, 1, 29);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        const CustomRecurrence(interval: RepeatOption.monthly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 2, 29)); // 2024 is leap year
    });

    test('should handle non-leap year February correctly', () {
      final startDate = DateTime(2023, 1, 29);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        const CustomRecurrence(interval: RepeatOption.monthly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2023, 2, 28)); // 2023 is not leap year
    });

    test('should handle year boundary crossing', () {
      final startDate = DateTime(2023, 12, 15);
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.monthly,
        const CustomRecurrence(interval: RepeatOption.monthly, frequency: 1),
      );
      
      expect(nextDate, DateTime(2024, 1, 15));
    });

    test('should handle empty selected days list', () {
      final startDate = DateTime(2024, 1, 1);
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 1,
        selectedDays: [], // Empty list
      );
      
      final nextDate = RecurrenceCalculationService.getNextOccurrence(
        startDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      expect(nextDate, DateTime(2024, 1, 8)); // Falls back to weekly
    });
  });
}