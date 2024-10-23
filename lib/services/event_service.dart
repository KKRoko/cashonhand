import '../data/models/freezed/event.dart';
import '../data/models/enums/delete_option.dart';
import '../state/event_notifier.dart';

/// Service class for managing events
class EventService {
  final EventNotifier _eventNotifier;

  EventService(this._eventNotifier);

  /// Returns events for a specific day
  List<Event> getEventsForDay(DateTime day) {
    return _eventNotifier.getEventsForDay(day);
  }

  /// Adds a new event
  void addEvent(DateTime day, Event event) {
    _eventNotifier.addEvent(day, event);
  }

  /// Updates an existing event
  void editEvent(DateTime day, Event oldEvent, Event newEvent) {
    _eventNotifier.editEvent(day, oldEvent, newEvent);
  }

  /// Deletes an event based on the specified option
  void deleteEvent(DateTime day, Event event, DeleteOption deleteOption) {
    _eventNotifier.deleteEvent(day, event, deleteOption);
  }

  /// Returns events within a date range
  List<Event> getEventsForRange(DateTime start, DateTime end) {
    return _eventNotifier.getEventsForRange(start, end);
  }
}
