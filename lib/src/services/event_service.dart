import 'package:cash_on_hand/src/models/event_model.dart';
import 'package:cash_on_hand/src/repositories/event_repository.dart';
import 'dart:developer' as developer;


class EventService {
  final EventRepository _repository;


  EventService(this._repository);


  Future<void> loadEvents() async {
    developer.log('Loading events', name: 'EventService');
    await _repository.loadEvents();
    developer.log('Events loaded', name: 'EventService');
  }

  Future<void> clearAllEvents() async {
    developer.log('Clearing all events', name: 'EventService');
    await _repository.clearAllEvents();
    developer.log('All events cleared', name: 'EventService');
  }



List<Event> getEventsForDay(DateTime day) {
    developer.log('Getting events for day: ${day.toString()}', name: 'EventService');
    var events = _repository.getEventsForDay(day);
    developer.log('Events for ${day.toString()}: $events', name: 'EventService');
    return events;
  }

 void addEvent(DateTime day, Event event) {
    developer.log('Adding event: ${event.title} on ${day.toString()}', name: 'EventService');
    _repository.addEvent(day, event);
    developer.log('Event added', name: 'EventService');
  }


  void updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    developer.log('Updating event: ${oldEvent.title} to ${newEvent.title} on ${day.toString()}', name: 'EventService');
    _repository.updateEvent(day, oldEvent, newEvent);
    developer.log('Event updated', name: 'EventService');
  }

  void deleteEvent(DateTime day, Event event) {
    developer.log('Deleting event: ${event.title} on ${day.toString()}', name: 'EventService');
    _repository.deleteEvent(day, event);
    developer.log('Event deleted', name: 'EventService');
  }

  void deleteAllEvents(Event event) {
    developer.log('Deleting all occurrences of event: ${event.title}', name: 'EventService');
    _repository.deleteAllEvents(event);
    developer.log('All occurrences deleted', name: 'EventService');
  }

  void deleteFutureEvents(DateTime day, Event event) {
    developer.log('Deleting future occurrences of event: ${event.title} from ${day.toString()}', name: 'EventService');
    _repository.deleteFutureEvents(day, event);
    developer.log('Future occurrences deleted', name: 'EventService');
  }

  void deletePastEvents(DateTime day, Event event) {
    developer.log('Deleting past occurrences of event: ${event.title} up to ${day.toString()}', name: 'EventService');
    _repository.deletePastEvents(day, event);
    developer.log('Past occurrences deleted', name: 'EventService');
  }


  Map<DateTime, List<Event>> get allEvents => _repository.allEvents;

  Map<String, Map<String, double>> calculateTotals(DateTime now) {

    Map<String, Map<String, double>> totals = {
      'day': {'positive': 0, 'negative': 0},
      'week': {'positive': 0, 'negative': 0},
      'month': {'positive': 0, 'negative': 0},
      'year': {'positive': 0, 'negative': 0},
    };

    final endOfWeek = _getEndOfWeek(now);
    final endOfMonth = _getEndOfMonth(now);
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);

    allEvents.forEach((date, events) {
      if (date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfYear.add(const Duration(days: 1)))) {
        for (var event in events) {
          final amount = event.amount ?? 0;

          if (!date.isAfter(endOfToday)) {
            _updateTotals(totals, 'day', amount, event.isPositiveCashflow);
          }

          if (!date.isAfter(endOfWeek)) {
            _updateTotals(totals, 'week', amount, event.isPositiveCashflow);
          }

          if (!date.isAfter(endOfMonth)) {
            _updateTotals(totals, 'month', amount, event.isPositiveCashflow);
          }

          _updateTotals(totals, 'year', amount, event.isPositiveCashflow);
        }
      }
    });

    return totals;
  }

  void _updateTotals(Map<String, Map<String, double>> totals, String period, double amount, bool isPositive) {
    if (isPositive) {
      totals[period]!['positive'] = (totals[period]!['positive'] ?? 0) + amount;
    } else {
      totals[period]!['negative'] = (totals[period]!['negative'] ?? 0) + amount;
    }
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
