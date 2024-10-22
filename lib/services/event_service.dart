import '../data/models/event_model.dart';
import '/../../state/event_notifier.dart';      // Add this for EventNotifier

class EventService {
  final EventNotifier _eventNotifier;

  EventService(this._eventNotifier);

  List<Event> getEventsForDay(DateTime day) {
    return _eventNotifier.getEventsForDay(day);
  }

  void addEvent(DateTime day, Event event) {
    _eventNotifier.addEvent(day, event);
  }

  void editEvent(DateTime day, Event oldEvent, Event newEvent) {
    _eventNotifier.editEvent(day, oldEvent, newEvent);
  }

  void deleteEvent(DateTime day, Event event, DeleteOption deleteOption) {
    _eventNotifier.deleteEvent(day, event, deleteOption);
  }

  List<Event> getEventsForRange(DateTime start, DateTime end) {
    return _eventNotifier.getEventsForRange(start, end);
  }
}

