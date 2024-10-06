// cash_flow_calculator.dart
import 'package:cash_on_hand/src/home/event_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CashFlowCalculator {
  static Future<double> calculateNetCashFlow(List<Event> events, DateTime startDate, DateTime endDate) async {
    double netCashFlow = 0;
    DateTime oneYearFromNow = DateTime.now().add(const Duration(days: 365));

    print('Calculating net cash flow from ${startDate.toString()} to ${endDate.toString()}');
    print('Total events to process: ${events.length}');

    for (var event in events) {
      print('Processing event: ${event.title}, Amount: ${event.amount}, RepeatOption: ${event.repeatOption}');

      if (event.createdAt.isAfter(endDate)) continue;

      double eventAmount = event.amount ?? 0;
      if (event.isNegativeCashflow) {
        eventAmount = -eventAmount;
      }

      if (event.repeatOption == RepeatOption.none) {
        if (event.createdAt.isAfter(startDate) || event.createdAt.isAtSameMomentAs(startDate)) {
          netCashFlow += eventAmount;
          print('Added one-time event: $eventAmount');
        }
      } else {
        DateTime currentDate = event.createdAt;
        while (currentDate.isBefore(endDate) && currentDate.isBefore(oneYearFromNow)) {
          if (currentDate.isAfter(startDate) || currentDate.isAtSameMomentAs(startDate)) {
            netCashFlow += eventAmount;
            print('Added recurring event on ${currentDate.toString()}: $eventAmount');
          }
          currentDate = _getNextRepeatDate(currentDate, event.repeatOption, event.customRecurrence);
        }
      }
            // Yield to the event loop periodically to prevent UI freezes
      if (events.indexOf(event) % 10 == 0) {
        await Future.delayed(Duration.zero);
      }    
    }

    print('Final net cash flow: $netCashFlow');
    return netCashFlow;
  }

   static DateTime _getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    if (repeatOption == RepeatOption.custom && customRecurrence != null) {
      switch (customRecurrence.interval) {
        case RepeatOption.daily:
          return currentDay.add(Duration(days: customRecurrence.frequency));
        case RepeatOption.weekly:
          if (customRecurrence.selectedDays.isNotEmpty) {
            int currentWeekday = currentDay.weekday % 7;
            int daysUntilNextOccurrence = 0;
            
            // Find the next occurrence
            for (int i = 0; i < 7; i++) {
              int nextWeekday = (currentWeekday + i) % 7;
              if (customRecurrence.selectedDays[nextWeekday]) {
                daysUntilNextOccurrence = i;
                break;
              }
            }
            
            // If found, return the next occurrence date
            if (daysUntilNextOccurrence > 0) {
              DateTime nextOccurrence = currentDay.add(Duration(days: daysUntilNextOccurrence));
              
              // If it's the first occurrence and it's within the same week, return it
              if (nextOccurrence.difference(currentDay).inDays < 7) {
                return nextOccurrence;
              }
              
              // Otherwise, adjust for frequency
              while (nextOccurrence.difference(currentDay).inDays < 7 * customRecurrence.frequency) {
                nextOccurrence = nextOccurrence.add(const Duration(days: 7));
              }
              
              return nextOccurrence;
            }
          }
          
          // If no specific days are selected or no valid occurrence found, jump by the frequency
          return currentDay.add(Duration(days: 7 * customRecurrence.frequency));
        case RepeatOption.monthly:
          int targetDay = customRecurrence.dayOfMonth ?? currentDay.day;
          DateTime nextMonth = DateTime(currentDay.year, currentDay.month + customRecurrence.frequency, 1);
          return DateTime(nextMonth.year, nextMonth.month, min(targetDay, DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month)));
        case RepeatOption.yearly:
          return DateTime(
            currentDay.year + customRecurrence.frequency,
            customRecurrence.month ?? currentDay.month,
            min(customRecurrence.dayOfMonth ?? currentDay.day, DateUtils.getDaysInMonth(currentDay.year + customRecurrence.frequency, customRecurrence.month ?? currentDay.month))
          );
        default:
          return currentDay;
      }
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
        return currentDay;
    }
  }
}