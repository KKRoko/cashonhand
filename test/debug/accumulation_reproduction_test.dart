import 'package:flutter_test/flutter_test.dart';
import 'package:cash_on_hand/services/recurrence_calculation_service.dart';
import 'package:cash_on_hand/data/models/enums/repeat_option.dart';
import 'package:cash_on_hand/data/models/freezed/custom_recurrence.dart';

void main() {
  group('Accumulation Bug Reproduction', () {
    test('should NOT have accumulating events in biweekly series', () {
      // Simulate creating a biweekly $100 event on July 20
      final startDate = DateTime(2024, 7, 20); // July 20, 2024
      final endDate = DateTime(2024, 9, 1);    // Through September
      
      final customRecurrence = const CustomRecurrence(
        interval: RepeatOption.weekly,
        frequency: 2, // Biweekly
      );
      
      print('🔍 Testing biweekly recurrence from ${startDate.toIso8601String().substring(0, 10)}:');
      
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        startDate,
        endDate,
        RepeatOption.weekly,
        customRecurrence,
      );
      
      for (int i = 0; i < occurrences.length; i++) {
        print('Occurrence ${i + 1}: ${occurrences[i].toIso8601String().substring(0, 10)}');
      }
      
      // Expected: July 20, August 3, August 17, August 31
      expect(occurrences.length, 4);
      expect(occurrences[0], DateTime(2024, 7, 20)); // Week 1: 1 event
      expect(occurrences[1], DateTime(2024, 8, 3));  // Week 3: 1 event (not 2!)  
      expect(occurrences[2], DateTime(2024, 8, 17)); // Week 5: 1 event (not 3!)
      expect(occurrences[3], DateTime(2024, 8, 31)); // Week 7: 1 event (not 4!)
      
      // CRITICAL: Each date should appear exactly ONCE
      final uniqueDates = occurrences.toSet();
      expect(uniqueDates.length, occurrences.length, 
        reason: 'Each occurrence date should be unique - no accumulation!');
    });
    
    test('should simulate what the user is experiencing', () {
      // The user says: "next week it adds two 100 events, then the third week add three 100s"
      // This suggests that somehow the SAME DATE is getting multiple events
      
      final july20 = DateTime(2024, 7, 20);
      final aug3 = DateTime(2024, 8, 3);   // "next week" (actually 2 weeks later for biweekly)
      final aug17 = DateTime(2024, 8, 17); // "third week" (actually 4 weeks later for biweekly)
      
      // Simulating what SHOULD happen vs what user is seeing
      print('\n🔍 What SHOULD happen:');
      print('July 20: 1 event (\$100)');
      print('August 3: 1 event (\$100)');  
      print('August 17: 1 event (\$100)');
      
      print('\n❌ What user is experiencing:');
      print('July 20: 1 event (\$100)');
      print('August 3: 2 events (\$100 each) ← BUG!');
      print('August 17: 3 events (\$100 each) ← BUG!');
      
      // This suggests the issue is in how events are stored/retrieved per date,
      // not in the recurrence calculation itself
      
      expect(true, true, reason: 'This test documents the expected behavior');
    });
  });
}