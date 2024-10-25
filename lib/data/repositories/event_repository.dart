import '../models/freezed/event.dart';
import '../../utils/date_utils.dart';

/// Repository responsible for managing event data storage and retrieval.
/// Implements the Singleton pattern to ensure a single source of truth for events.
class EventRepository {
  // Singleton implementation
  static final EventRepository _instance = EventRepository._internal();
  
  /// Factory constructor that returns the singleton instance
  factory EventRepository() {
    return _instance;
  }

  EventRepository._internal();

  // Private storage and constants
  final Map<DateTime, List<Event>> _events = {};
  static final DateTime _today = DateTime.now();
  static final DateTime _firstDay = DateTime(_today.year, _today.month - 3, _today.day);
  static final DateTime _lastDay = DateTime(_today.year, _today.month + 3, _today.day);

  /// Returns the first available date for event scheduling
  DateTime get firstDay => _firstDay;

  /// Returns the last available date for event scheduling
  DateTime get lastDay => _lastDay;

  /// Retrieves events for a specific day.
  /// 
  /// Returns an empty list if no events exist for the specified day.
  /// @param day The date to retrieve events for
  List<Event> getEvents(DateTime day) {
    return _events[day] ?? [];
  }

  /// Adds a new event to the specified day.
  /// 
  /// Creates a new event list for the day if none exists.
  /// @param day The date to add the event to
  /// @param event The event to be added
void addEvent(DateTime day, Event event) {
  print('Repository receiving day: $day'); // Add this line
  print('Repository receiving event datetime: ${event.dateTime}'); // Add this line
  
  // Normalize the date by removing the time component
  final normalizedDay = DateTime(day.year, day.month, day.day);
  print('Normalized day: $normalizedDay'); // Add this line
  
  if (_events[normalizedDay] != null) {
    _events[normalizedDay]!.add(event);
  } else {
    _events[normalizedDay] = [event];
  }
  _cleanupEmptyDays(normalizedDay);
}

  /// Updates an existing event on the specified day.
  /// 
  /// @param day The date of the event
  /// @param oldEvent The original event to be updated
  /// @param newEvent The new event data
  void updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    final events = _events[day];
    if (events != null) {
      final index = events.indexWhere((e) => e.id == oldEvent.id);
      if (index != -1) {
        events[index] = newEvent;
      }
    }
    _cleanupEmptyDays(day);
  }

  /// Deletes an event from the specified day.
  /// 
  /// @param day The date of the event
  /// @param event The event to be deleted
  void deleteEvent(DateTime day, Event event) {
    _events[day]?.removeWhere((e) => e.id == event.id);
    _cleanupEmptyDays(day);
  }

  /// Retrieves all events within a specified date range.
  /// 
  /// @param start The start date of the range
  /// @param end The end date of the range
  /// @returns List of events within the specified range
  List<Event> getEventsForRange(DateTime start, DateTime end) {
    return [
      for (final day in DateUtils.getDaysInRange(start, end)) 
        ...getEvents(day),
    ];
  }

    List<Event> getAllEvents() {
    return _events.values.expand((events) => events).toList();
  }

  /// Removes all events from storage.
  void clear() {
    _events.clear();
  }

  /// Removes days with no events from storage.
  /// 
  /// @param day The day to check and potentially remove
  void _cleanupEmptyDays(DateTime day) {
    if (_events[day]?.isEmpty ?? false) {
      _events.remove(day);
    }
  }

  /// Returns the total number of stored events.
  int get totalEvents => _events.values
      .fold(0, (sum, list) => sum + list.length);

  /// Checks if a specific day has any events.
  /// 
  /// @param day The date to check
  /// @returns true if the day has events, false otherwise
  bool hasEvents(DateTime day) {
    return _events.containsKey(day) && _events[day]!.isNotEmpty;
  }
}
