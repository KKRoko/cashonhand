// lib/data/repositories/event_repository.dart

import '../models/event_model.dart';

class EventRepository {
  // Singleton instance
  static final EventRepository _instance = EventRepository._internal();

  factory EventRepository() {
    return _instance;
  }

  EventRepository._internal();

  // Private events storage
  final Map<DateTime, List<Event>> _events = {};

  // CRUD Operations

  List<Event> getEvents(DateTime day) {
    return _events[day] ?? [];
  }

  void addEvent(DateTime day, Event event) {
    if (_events[day] != null) {
      _events[day]!.add(event);
    } else {
      _events[day] = [event];
    }
  }

  void updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    final events = _events[day];
    if (events != null) {
      final index = events.indexWhere((e) => e.id == oldEvent.id);
      if (index != -1) {
        events[index] = newEvent;
      }
    }
  }

  void deleteEvent(DateTime day, Event event) {
    _events[day]?.removeWhere((e) => e.id == event.id);
    if (_events[day]?.isEmpty ?? false) {
      _events.remove(day);
    }
  }

  // Additional utility methods

  List<Event> getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [
      for (final day in days) ...getEvents(day),
    ];
  }

  void clear() {
    _events.clear();
  }

  // Constants
  static final kToday = DateTime.now();
  static final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
  static final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
}

// Utility function
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}
