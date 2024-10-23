import 'package:flutter/foundation.dart';
import '../data/models/enums/delete_option.dart';
import '../data/models/enums/repeat_option.dart';
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
    print("Adding recurring event: ${event.title} starting on $startDay");

    DateTime currentDay = startDay;
    final endOfYear = DateTime(startDay.year, 12, 31);
    print("End of year date: $endOfYear");

    // For custom recurrence (weekly events)
    if (event.repeatOption == RepeatOption.custom && 
        event.customRecurrence != null && 
        event.customRecurrence!.selectedDays.any((selected) => selected)) {
        
        int currentWeekday = currentDay.weekday;
        int targetWeekday = -1;
        
        // Find the first selected day
        for (int i = 0; i < 7; i++) {
            if (event.customRecurrence!.selectedDays[i]) {
                // Convert from Sunday-first index to DateTime.weekday
                // Sunday (0) -> 7
                // Monday (1) -> 1
                // Tuesday (2) -> 2
                // ...
                // Saturday (6) -> 6
                targetWeekday = i == 0 ? 7 : i;
                break;
            }
        }
        
        if (targetWeekday != -1) {
            // Calculate days until target weekday
            int daysToAdd = targetWeekday - currentWeekday;
            if (daysToAdd <= 0) daysToAdd += 7;
            currentDay = currentDay.add(Duration(days: daysToAdd));
        }
    }

    // Rest of the method remains the same...
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

        if (event.repeatOption == RepeatOption.custom && 
            event.customRecurrence != null) {
            currentDay = currentDay.add(
                Duration(days: 7 * event.customRecurrence!.frequency));
        } else {
            currentDay = DateUtils.getNextRepeatDate(
                currentDay, event.repeatOption, event.customRecurrence);
        }
    }

    print("Events after adding: ");
    _events.forEach((key, value) {
        print("Date: $key, Events: ${value.length}");
    });
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
    for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
      result.addAll(getEventsForDay(date));
    }
    return result;
  }

  void loadEvents() {
    _events = {};
    
    final startDate = DateTime(DateTime.now().year, 1, 1);
    final endDate = DateTime(DateTime.now().year, 12, 31);
    
    final events = _repository.getEventsForRange(startDate, endDate);
    
    for (final event in events) {
      final eventDate = DateTime(
        event.dateTime.year,
        event.dateTime.month, 
        event.dateTime.day
      );
      
      if (_events.containsKey(eventDate)) {
        _events[eventDate]!.add(event);
      } else {
        _events[eventDate] = [event];
      }
    }
    
    notifyListeners();
  }

  // Add this to EventNotifier class
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
    // Get the first event's year
    return _events.keys.first.year;
}
}