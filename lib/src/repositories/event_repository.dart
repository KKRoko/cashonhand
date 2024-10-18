import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_on_hand/src/models/event_model.dart';
import 'dart:developer' as developer;

class EventRepository {
  final Map<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  static const String EVENTS_KEY = 'events';

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsJson = prefs.getString(EVENTS_KEY);
    if (eventsJson != null) {
      final Map<String, dynamic> eventsMap = json.decode(eventsJson);
      _events.clear();
      eventsMap.forEach((key, value) {
        final DateTime date = DateTime.parse(key);
        final List<Event> events = (value as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
        _events[date] = events;
      });
    }
  }

  Future<void> saveEvents() async {
      developer.log('Repository: Saving events', name: 'EventRepository');

    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> eventsMap = {};
    _events.forEach((key, value) {
      eventsMap[key.toIso8601String()] = value.map((e) => e.toJson()).toList();
    });
    await prefs.setString(EVENTS_KEY, json.encode(eventsMap));
      developer.log('Repository: Events saved', name: 'EventRepository');

  }

  Future<void> clearAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(EVENTS_KEY);
    _events.clear();
  }

  List<Event> getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void addEvent(DateTime day, Event event) {
    developer.log('Repository: Adding event ${event.title} on $day', name: 'EventRepository');

    if (_events[day] != null) {
      _events[day]!.add(event);
    } else {
      _events[day] = [event];
    }
      developer.log('Repository: Events for $day after adding: ${_events[day]}', name: 'EventRepository');

    saveEvents();
  }

  void updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    final events = _events[day];
    if (events != null) {
      final index = events.indexWhere((e) => e.id == oldEvent.id);
      if (index != -1) {
        events[index] = newEvent;
        saveEvents();
      }
    }
  }

  void deleteEvent(DateTime day, Event event) {
    _events[day]?.removeWhere((e) => e.id == event.id);
    if (_events[day]?.isEmpty ?? false) {
      _events.remove(day);
    }
    saveEvents();
  }

  void deleteAllEvents(Event event) {
    _events.forEach((date, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    _events.removeWhere((date, events) => events.isEmpty);
    saveEvents();
  }

  void deleteFutureEvents(DateTime day, Event event) {
    _events.forEach((date, events) {
      if (date.isAtSameMomentAs(day) || date.isAfter(day)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    _events.removeWhere((date, events) => events.isEmpty);
    saveEvents();
  }

  void deletePastEvents(DateTime day, Event event) {
    _events.forEach((date, events) {
      if (date.isAtSameMomentAs(day) || date.isBefore(day)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    _events.removeWhere((date, events) => events.isEmpty);
    saveEvents();
  }

  Map<DateTime, List<Event>> get allEvents => Map.unmodifiable(_events);

  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }
}

// These should be inside the class or in a separate utility file
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}