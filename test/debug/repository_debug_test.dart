import 'package:flutter_test/flutter_test.dart';
import 'package:cash_on_hand/data/repositories/event_repository.dart';
import 'package:cash_on_hand/data/models/freezed/event.dart';
import 'package:cash_on_hand/data/models/freezed/custom_recurrence.dart';
import 'package:cash_on_hand/data/models/enums/repeat_option.dart';

void main() {
  group('Repository Debug - Event Generation', () {
    test('should simulate biweekly event creation', () {
      final creationDate = DateTime(2024, 7, 20); // July 20
      
      final event = Event(
        title: 'Biweekly Event \$100',
        categoryId: 1,
        amount: 100.0,
        dateTime: creationDate,
        repeatOption: RepeatOption.weekly,
        isRecurring: true,
        customRecurrence: const CustomRecurrence(
          interval: RepeatOption.weekly,
          frequency: 2, // Biweekly
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );
      
      // Test the first occurrence calculation
      final testRepository = TestEventRepository();
      final firstOccurrence = testRepository.testCalculateFirstOccurrence(creationDate, event);
      
      print('Creation Date: ${creationDate.toIso8601String().substring(0, 10)}');
      print('First Occurrence: ${firstOccurrence.toIso8601String().substring(0, 10)}');
      
      // Should be the same for biweekly since no specific day is set
      expect(firstOccurrence, creationDate);
      
      // Now let's simulate what happens in generateRecurringEvents
      print('\nSimulating _generateRecurringEvents:');
      
      DateTime currentDate = firstOccurrence;
      final endDate = DateTime(2024, 8, 31);
      final events = <DateTime>[];
      
      // Add first event
      events.add(currentDate);
      print('Event 1 (original): ${currentDate.toIso8601String().substring(0, 10)}');
      
      // Generate remaining events
      int count = 1;
      while (currentDate.isBefore(endDate)) {
        currentDate = testRepository.getNextOccurrence(currentDate, event.repeatOption, event.customRecurrence);
        
        if (currentDate.isAfter(endDate)) break;
        
        count++;
        events.add(currentDate);
        print('Event $count: ${currentDate.toIso8601String().substring(0, 10)}');
      }
      
      print('\nTotal events generated: ${events.length}');
      
      // For biweekly from July 20 to August 31, should be:
      // July 20, August 3, August 17, August 31
      expect(events.length, 4);
      expect(events[0], DateTime(2024, 7, 20));
      expect(events[1], DateTime(2024, 8, 3));
      expect(events[2], DateTime(2024, 8, 17));
      expect(events[3], DateTime(2024, 8, 31));
    });
  });
}

// Test helper class
class TestEventRepository {
  DateTime testCalculateFirstOccurrence(DateTime startDate, Event event) {
    // For non-recurring or events without custom recurrence, use start date
    if (!event.isRecurring || event.customRecurrence == null) {
      return startDate;
    }

    final customRecurrence = event.customRecurrence!;
    
    switch (event.repeatOption) {
      case RepeatOption.monthly:
        // Handle monthly events with specific dayOfMonth
        if (customRecurrence.dayOfMonth != null) {
          final targetDay = customRecurrence.dayOfMonth!;
          final currentMonth = startDate.month;
          final currentYear = startDate.year;
          
          // Check if target day exists in current month
          final lastDayOfCurrentMonth = DateTime(currentYear, currentMonth + 1, 0).day;
          final clampedTargetDay = targetDay.clamp(1, lastDayOfCurrentMonth);
          
          // If target day hasn't passed this month, use it
          if (clampedTargetDay >= startDate.day) {
            return DateTime(currentYear, currentMonth, clampedTargetDay);
          }
          
          // Otherwise, move to next month
          final nextMonth = currentMonth + 1;
          final nextYear = currentYear + (nextMonth > 12 ? 1 : 0);
          final adjustedMonth = nextMonth > 12 ? 1 : nextMonth;
          final lastDayOfNextMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
          final clampedNextTargetDay = targetDay.clamp(1, lastDayOfNextMonth);
          
          return DateTime(nextYear, adjustedMonth, clampedNextTargetDay);
        }
        
        // Default: use start date for monthly
        return startDate;
        
      default:
        // For weekly and other types, use start date
        return startDate;
    }
  }
  
  DateTime getNextOccurrence(DateTime currentDate, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    final frequency = customRecurrence?.frequency ?? 1;

    switch (repeatOption) {
      case RepeatOption.weekly:
        return currentDate.add(Duration(days: 7 * frequency));
      case RepeatOption.monthly:
        // Basic month addition
        var nextMonth = currentDate.month + frequency;
        var nextYear = currentDate.year + (nextMonth - 1) ~/ 12;
        nextMonth = ((nextMonth - 1) % 12) + 1;
        return DateTime(nextYear, nextMonth, currentDate.day);
      default:
        return currentDate.add(Duration(days: frequency));
    }
  }
}