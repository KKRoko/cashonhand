import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../data/models/enums/delete_option.dart';
import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/event.dart';
import '../services/event_service.dart';
import '../utils/event_date_utils.dart';

@injectable
class EventNotifier extends ChangeNotifier {
  final EventService eventService;  
  final Map<DateTime, List<Event>> _events = {};
  bool _isLoading = false;
  String? _error;

  EventNotifier(this.eventService); 

  // Getters
  Map<DateTime, List<Event>> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get currentYear {
    if (_events.isEmpty) return DateTime.now().year;
    return _events.keys.first.year;
  }

  // Public Methods
  Future<void> loadInitialEvents() async {
    final startDate = DateTime(DateTime.now().year, 1, 1);
    final endDate = DateTime(DateTime.now().year, 12, 31);
    await loadEventsForRange(startDate, endDate);
  }

  Future<void> loadEventsForDay(DateTime day) async {
    _setLoading(true);

    final result = await eventService.getEventsForDay(day);
    result.fold(
      (failure) => _setError(failure.message),
      (events) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        _events[normalizedDay] = events;
        notifyListeners();
      }
    );

    _setLoading(false);
  }

  Future<void> loadEventsForRange(DateTime start, DateTime end) async {
    _setLoading(true);

    final result = await eventService.getEventsForRange(start, end);
    result.fold(
      (failure) => _setError(failure.message),
      (events) {
        _groupEventsByDay(events);
        notifyListeners();
      }
    );

    _setLoading(false);
  }

  Future<void> addEvent(DateTime day, Event event) async {
    _setLoading(true);

    if (event.repeatOption == RepeatOption.today) {
      await _addSingleEvent(day, event);
    } else {
      await _addRecurringEvent(day, event);
    }

    _setLoading(false);
  }

  Future<void> updateEvent(DateTime day, Event oldEvent, Event newEvent) async {
    _setLoading(true);

    final result = await eventService.updateEvent(day, oldEvent, newEvent);
    result.fold(
      (failure) => _setError(failure.message),
      (updatedEvent) {
        _handleEventUpdate(oldEvent, updatedEvent, day);
        notifyListeners();
      }
    );

    _setLoading(false);
  }

Future<void> deleteEvent(DateTime day, Event event, DeleteOption deleteOption) async {
 _setLoading(true);

 final result = await eventService.deleteEvent(day, event, deleteOption);
 result.fold(
   (failure) => _setError(failure.message),
   (success) {
     if (success) {
       _handleEventDeletion(day, event, deleteOption); // This method already exists
       notifyListeners();
     }
   }
 );

 _setLoading(false);
}

List<Event> getEventsForDay(DateTime day) {
  final normalizedDay = DateTime(day.year, day.month, day.day);
  final events = _events[normalizedDay] ?? [];
  print("UI requesting events for $normalizedDay: found ${events.length} events");
  return events;
}

  List<Event> getEventsForDateRange(DateTime start, DateTime end) {
    List<Event> result = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (!current.isAfter(endDate)) {
      result.addAll(getEventsForDay(current));
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  void clearErrors() {
    _error = null;
    notifyListeners();
  }

  // Private Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _groupEventsByDay(List<Event> events) {
    _events.clear();
    for (final event in events) {
      final normalizedDay = DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
      _events[normalizedDay] = [...(_events[normalizedDay] ?? []), event];
    }
  }

  Future<void> _addSingleEvent(DateTime day, Event event) async {
    final result = await eventService.addEvent(day, event);
    result.fold(
      (failure) => _setError(failure.message),
      (newEvent) {
        final normalizedDay = DateTime(day.year, day.month, day.day);
        if (_events.containsKey(normalizedDay)) {
          _events[normalizedDay]!.add(newEvent);
        } else {
          _events[normalizedDay] = [newEvent];
        }
        notifyListeners();
      }
    );
  }

Future<void> _addRecurringEvent(DateTime startDay, Event event) async {
  // Initialize first occurrence
  DateTime firstOccurrence = startDay;
  final selectedWeekdays = event.customRecurrence?.selectedDays ?? [];

  if (event.repeatOption == RepeatOption.weekly && selectedWeekdays.any((day) => day)) {
    // Get the first selected weekday index (0 = Sunday, 6 = Saturday)
    // No need to add 1 since array index matches weekday for calculation
    int targetWeekday = selectedWeekdays.indexOf(true);
    
    // Convert Sunday-based index (0-6) to Monday-based (1-7) for calculation
    int dateTimeWeekday = targetWeekday == 0 ? 7 : targetWeekday;
    
    // Calculate days until next target weekday
    int daysUntilTarget = (dateTimeWeekday - startDay.weekday + 7) % 7;
    if (daysUntilTarget == 0) daysUntilTarget = 7;
    
    // Adjust to first occurrence
    firstOccurrence = startDay.add(Duration(days: daysUntilTarget));
  }

  DateTime currentDay = firstOccurrence;
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
    
    await _addSingleEvent(currentDay, updatedEvent);
    
    currentDay = EventDateUtils.getNextRepeatDate(
      currentDay, 
      event.repeatOption, 
      event.customRecurrence
    );
  }
}

  void _handleEventUpdate(Event oldEvent, Event updatedEvent, DateTime newDay) {
    final oldDay = DateTime(
      oldEvent.dateTime.year,
      oldEvent.dateTime.month,
      oldEvent.dateTime.day,
    );
    final normalizedNewDay = DateTime(newDay.year, newDay.month, newDay.day);

    // Remove from old day if different
    if (_events.containsKey(oldDay)) {
      _events[oldDay]!.removeWhere((e) => e.id == oldEvent.id);
      if (_events[oldDay]!.isEmpty) {
        _events.remove(oldDay);
      }
    }

    // Add to new day
    if (_events.containsKey(normalizedNewDay)) {
      _events[normalizedNewDay]!.add(updatedEvent);
    } else {
      _events[normalizedNewDay] = [updatedEvent];
    }
  }

  void _handleEventDeletion(DateTime day, Event event, DeleteOption deleteOption) {
    switch (deleteOption) {
      case DeleteOption.thisDay:
        _deleteSingleEventFromCache(day, event);
        break;
      case DeleteOption.allTime:
        _deleteAllEventOccurrencesFromCache(event);
        break;
      case DeleteOption.futureOnly:
        _deleteFutureEventsFromCache(day, event);
        break;
      case DeleteOption.pastOnly:
        _deletePastEventsFromCache(day, event);
        break;
    }
  }

  void _deleteSingleEventFromCache(DateTime day, Event event) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    if (_events.containsKey(normalizedDay)) {
      _events[normalizedDay]!.removeWhere((e) => e.id == event.id);
      if (_events[normalizedDay]!.isEmpty) {
        _events.remove(normalizedDay);
      }
    }
  }

  void _deleteAllEventOccurrencesFromCache(Event event) {
    _events.forEach((day, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    _events.removeWhere((day, events) => events.isEmpty);
  }

  void _deleteFutureEventsFromCache(DateTime fromDay, Event event) {
    _events.removeWhere((day, events) {
      if (day.isAfter(fromDay) || day.isAtSameMomentAs(fromDay)) {
        events.removeWhere((e) => e.id == event.id);
        return events.isEmpty;
      }
      return false;
    });
  }

  void _deletePastEventsFromCache(DateTime toDay, Event event) {
    _events.removeWhere((day, events) {
      if (day.isBefore(toDay)) {
        events.removeWhere((e) => e.id == event.id);
        return events.isEmpty;
      }
      return false;
    });
  }

  void debugPrintEvents() {
    _events.forEach((date, events) {
      // ignore: avoid_print
      print('Date: $date');
      for (var event in events) {
        // ignore: avoid_print
        print('  Event: ${event.title} (${event.id})');
      }
    });
  }

void clearState() {
  _events.clear();
  notifyListeners();
}
void debugState() {
  print("Current events in state: ${_events.length}");
  _events.forEach((date, events) {
    print("Date: $date, Events: ${events.length}");
    events.forEach((event) => print("  - ${event.title}"));
  });
}
}
