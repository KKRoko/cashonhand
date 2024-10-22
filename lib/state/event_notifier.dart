import 'package:flutter/foundation.dart';
import '../data/models/event_model.dart';
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
      _addSingleEvent(currentDay, event);
      currentDay = getNextRepeatDate(currentDay, event.repeatOption, event.customRecurrence);
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
    for (DateTime date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
      result.addAll(getEventsForDay(date));
    }
    return result;
  }

void loadEvents() {
  // Initialize empty map if no events exist
  _events = {};
  
  // Get all dates for current year
  final startDate = DateTime(DateTime.now().year, 1, 1);
  final endDate = DateTime(DateTime.now().year, 12, 31);
  
  // Load events for the entire year
  final events = _repository.getEventsForRange(startDate, endDate);
  
  // Organize events by date in the _events map
  for (DateTime date = startDate; 
       date.isBefore(endDate) || date.isAtSameMomentAs(endDate); 
       date = date.add(const Duration(days: 1))) {
    final eventsForDay = _repository.getEvents(date);
    if (eventsForDay.isNotEmpty) {
      _events[DateTime(date.year, date.month, date.day)] = eventsForDay;
    }
  }
  
  notifyListeners();
}
}
