import 'package:flutter_test/flutter_test.dart';
import 'package:cash_on_hand/services/recurrence_calculation_service.dart';
import 'package:cash_on_hand/data/models/enums/repeat_option.dart';
import 'package:cash_on_hand/data/models/freezed/custom_recurrence.dart';

void main() {
  group('Debug Recurring Events', () {
    test('should generate correct biweekly occurrences', () {
      final startDate = DateTime(2024, 7, 20); // July 20, 2024 (Saturday)
      final endDate = DateTime(2024, 8, 31); // End of August
      
      final customRecurrence = CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 2, // Biweekly
      );
      
      print('Start Date: ${startDate.toIso8601String()}');
      print('Biweekly with frequency 2:');
      
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        startDate,
        endDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      for (int i = 0; i < occurrences.length; i++) {
        print('Occurrence ${i + 1}: ${occurrences[i].toIso8601String().substring(0, 10)}');
      }
      
      // Should be: July 20, August 3, August 17, August 31
      expect(occurrences.length, 4);
      expect(occurrences[0], DateTime(2024, 7, 20));
      expect(occurrences[1], DateTime(2024, 8, 3));
      expect(occurrences[2], DateTime(2024, 8, 17));
      expect(occurrences[3], DateTime(2024, 8, 31));
    });

    test('should generate correct weekly occurrences with selected days', () {
      final startDate = DateTime(2024, 7, 20); // July 20, 2024 (Saturday)
      final endDate = DateTime(2024, 8, 10);
      
      // Let's say the user wants it to occur on Saturdays only
      final customRecurrence = CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 1,
        selectedDays: [false, false, false, false, false, false, true], // Saturday only
      );
      
      print('\nWeekly on Saturdays:');
      
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        startDate,
        endDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      for (int i = 0; i < occurrences.length; i++) {
        print('Occurrence ${i + 1}: ${occurrences[i].toIso8601String().substring(0, 10)} (${_getDayName(occurrences[i])})');
      }
      
      // Should be: July 20, July 27, August 3
      expect(occurrences.length, 3);
      expect(occurrences[0], DateTime(2024, 7, 20));
      expect(occurrences[1], DateTime(2024, 7, 27));
      expect(occurrences[2], DateTime(2024, 8, 3));
      
      // All should be Saturdays
      for (final occurrence in occurrences) {
        expect(occurrence.weekday, DateTime.saturday);
      }
    });
  });
}

String _getDayName(DateTime date) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[date.weekday - 1];
}