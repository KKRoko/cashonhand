import 'package:flutter/foundation.dart';
import '../data/models/enums/delete_option.dart';
import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/custom_recurrence.dart';
import '../data/models/freezed/event.dart';
import '../data/repositories/event_repository.dart';
import '../utils/date_utils.dart';

class EventNotifier extends ChangeNotifier {
  final EventRepository _repository = EventRepository();
  Map<DateTime, List<Event>> _events = {};

  Map<DateTime, List<Event>> get events => _events;

  List<Event> getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void addEvent(DateTime day, Event event) {
    if (event.repeatOption == RepeatOption.today) {
      _addSingleEvent(day, event);
    } else {
      _addRecurringEvent(day, event);
    }
    notifyListeners();
  }

  void _addSingleEvent(DateTime day, Event event) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_events.containsKey(normalizedDay)) {
      _events[normalizedDay]!.add(event);
    } else {
      _events[normalizedDay] = [event];
    }
  }

  void _addRecurringEvent(DateTime startDay, Event event) {
    DateTime currentDay = startDay;
    final endOfYear = DateTime(startDay.year, 12, 31);

    while (!currentDay.isAfter(endOfYear)) {
        final updatedEvent = event.copyWith(
            dateTime: DateTime(
                currentDay.year,
                currentDay.month,
                currentDay.day,
                event.dateTime.hour,
                event.dateTime.minute,
                event.dateTime.second,
                event.dateTime.millisecond,
                event.dateTime.microsecond
            )
        );
        _addSingleEvent(currentDay, updatedEvent);

        // Handle different recurrence types
        if (event.repeatOption == RepeatOption.custom && 
            event.customRecurrence != null) {
            
            switch (event.customRecurrence!.interval) {
                case RepeatOption.monthly:
                    currentDay = _getNextMonthlyDate(
                        currentDay, 
                        event.customRecurrence!
                    );
                    break;
                    
                case RepeatOption.weekly:
                    currentDay = _getNextWeeklyDate(
                        currentDay, 
                        event.customRecurrence!
                    );
                    break;
                    
                default:
                    currentDay = DateUtils.getNextRepeatDate(
                        currentDay, 
                        event.repeatOption, 
                        event.customRecurrence
                    );
            }
        } else {
            currentDay = DateUtils.getNextRepeatDate(
                currentDay, 
                event.repeatOption, 
                event.customRecurrence
            );
        }
    }
  }

  DateTime _getNextWeeklyDate(DateTime currentDay, CustomRecurrence recurrence) {
    if (recurrence.selectedDays.any((selected) => selected)) {
      int currentWeekday = currentDay.weekday;
      int? nextWeekday;
      
      // Find the next selected day after current weekday
      for (int i = 0; i < 7; i++) {
        int checkDay = (currentWeekday + i) % 7;
        // Convert to Sunday = 0 format for checking selectedDays
        int selectedDaysIndex = checkDay == 7 ? 0 : checkDay;
        
        if (recurrence.selectedDays[selectedDaysIndex]) {
          if (i > 0) { // Found a day later this week
            nextWeekday = checkDay == 0 ? 7 : checkDay;
            break;
          }
        }
      }
      
      // If no later day found this week, move to next week and find first selected day
      if (nextWeekday == null) {
        for (int i = 0; i < 7; i++) {
          if (recurrence.selectedDays[i]) {
            nextWeekday = i == 0 ? 7 : i;
            currentDay = currentDay.add(Duration(days: 7 * (recurrence.frequency - 1)));
            break;
          }
        }
      }
      
      if (nextWeekday != null) {
        int daysToAdd = nextWeekday - currentWeekday;
        if (daysToAdd <= 0) daysToAdd += 7;
        return currentDay.add(Duration(days: daysToAdd));
      }
    }
    
    // Default weekly increment if no days selected
    return currentDay.add(Duration(days: 7 * recurrence.frequency));
  }

  DateTime _getNextMonthlyDate(DateTime currentDay, CustomRecurrence recurrence) {
    if (recurrence.dayOfMonth != null) {
        return _getNextMonthlyByDayOfMonth(
            currentDay, 
            recurrence.dayOfMonth!, 
            recurrence.frequency
        );
    } else if (recurrence.weekOfMonth != null) {
        return _getNextMonthlyByWeekOfMonth(
            currentDay, 
            recurrence.weekOfMonth!, 
            recurrence.frequency
        );
    }
    
    // Default monthly recurrence
    return DateTime(
        currentDay.year,
        currentDay.month + recurrence.frequency,
        currentDay.day,
    );
  }

  DateTime _getNextMonthlyByDayOfMonth(
      DateTime currentDay, 
      int dayOfMonth, 
      int frequency
  ) {
      // Calculate the next month
      int nextMonth = currentDay.month + frequency;
      int yearOffset = (nextMonth - 1) ~/ 12;
      nextMonth = ((nextMonth - 1) % 12) + 1;
      
      // Create the next date
      DateTime nextDate = DateTime(
          currentDay.year + yearOffset,
          nextMonth,
          1  // Start with first day of month
      );
      
      // Adjust to the target day of month, handling month length
      int actualDay = dayOfMonth;
      if (dayOfMonth > DateUtils.getDaysInMonth(nextDate.year, nextDate.month)) {
          actualDay = DateUtils.getDaysInMonth(nextDate.year, nextDate.month);
      }
      
      return DateTime(nextDate.year, nextDate.month, actualDay);
  }

  DateTime _getNextMonthlyByWeekOfMonth(
      DateTime currentDay, 
      int weekOfMonth, 
      int frequency
  ) {
      // Calculate the next month
      int nextMonth = currentDay.month + frequency;
      int yearOffset = (nextMonth - 1) ~/ 12;
      nextMonth = ((nextMonth - 1) % 12) + 1;
      
      DateTime nextDate = DateTime(
          currentDay.year + yearOffset,
          nextMonth,
          1  // Start with first day of month
      );
      
      if (weekOfMonth > 0) {
          // Positive week number (1st to 5th week)
          int targetDay = (weekOfMonth - 1) * 7 + 1;
          if (targetDay > DateUtils.getDaysInMonth(nextDate.year, nextDate.month)) {
              targetDay = DateUtils.getDaysInMonth(nextDate.year, nextDate.month);
          }
          return DateTime(nextDate.year, nextDate.month, targetDay);
      } else {
          // Negative week number (last week = -1)
          int daysInMonth = DateUtils.getDaysInMonth(nextDate.year, nextDate.month);
          int targetDay = daysInMonth + (weekOfMonth * 7) + 1;
          if (targetDay < 1) targetDay = 1;
          return DateTime(nextDate.year, nextDate.month, targetDay);
      }
  }

  void editEvent(DateTime day, Event oldEvent, Event newEvent) {
    deleteEvent(day, oldEvent, DeleteOption.allTime);
    addEvent(day, newEvent);
  }

  void deleteEvent(DateTime day, Event event, DeleteOption deleteOption) {
    switch (deleteOption) {
      case DeleteOption.thisDay:
        _deleteSingleEvent(day, event);
        break;
      case DeleteOption.allTime:
        _deleteRecurringEvent(event);
        break;
      case DeleteOption.futureOnly:
        _deleteFutureEvents(day, event);
        break;
      case DeleteOption.pastOnly:
        _deletePastEvents(day, event);
        break;
    }
    notifyListeners();
  }

  void _deleteSingleEvent(DateTime day, Event event) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    _events[normalizedDay]?.removeWhere((e) => e.id == event.id);
    if (_events[normalizedDay]?.isEmpty ?? false) {
      _events.remove(normalizedDay);
    }
  }

  void _deleteRecurringEvent(Event event) {
    _events.forEach((day, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    _events.removeWhere((day, events) => events.isEmpty);
  }

  void _deleteFutureEvents(DateTime fromDay, Event event) {
    _events.removeWhere((day, events) {
      if (day.isAfter(fromDay) || day.isAtSameMomentAs(fromDay)) {
        events.removeWhere((e) => e.id == event.id);
        return events.isEmpty;
      }
      return false;
    });
  }

  void _deletePastEvents(DateTime toDay, Event event) {
    _events.removeWhere((day, events) {
      if (day.isBefore(toDay)) {
        events.removeWhere((e) => e.id == event.id);
        return events.isEmpty;
      }
      return false;
    });
  }

  List<Event> getEventsForRange(DateTime start, DateTime end) {
    List<Event> result = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (!current.isAfter(endDate)) {
      result.addAll(getEventsForDay(current));
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  void loadEvents() {
    _events = {};
    
    final startDate = DateTime(DateTime.now().year, 1, 1);
    final endDate = DateTime(DateTime.now().year, 12, 31);
    
    final events = _repository.getEventsForRange(startDate, endDate);
    
    for (final event in events) {
      if (event.repeatOption == RepeatOption.today) {
        _addSingleEvent(event.dateTime, event);
      } else {
        _addRecurringEvent(event.dateTime, event);
      }
    }
    
    notifyListeners();
  }

  void debugPrintEvents() {
    print('Current events in notifier:');
    _events.forEach((date, events) {
      print('Date: $date');
      for (var event in events) {
        print('  Event: ${event.title}, Amount: ${event.amount}, Date: ${event.dateTime}');
      }
    });
  }

  int get currentYear {
    if (_events.isEmpty) return DateTime.now().year;
    return _events.keys.first.year;
  }
}
