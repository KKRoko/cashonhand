import 'package:cash_on_hand/src/services/event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cash_on_hand/src/models/event_model.dart';
import 'dart:developer' as developer;

class EventProvider extends ChangeNotifier {
  final EventService _eventService;
  Map<DateTime, List<Event>> _events = {};

  EventProvider(this._eventService) {
    _loadEvents();
  }

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;
  DateTime get focusedDay => _focusedDay;



Future<void> _loadEvents() async {
  try {
      await _eventService.loadEvents();
    _events = Map<DateTime, List<Event>>.from(_eventService.allEvents);
    notifyListeners();
  } catch (e) {
      developer.log('Error loading events: $e', name: 'EventProvider');
  }
}

  void focusDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  List<Event> getEventsForDay(DateTime day) {
   final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay] ?? [];
    developer.log('Getting events for day: $normalizedDay, Events: $events', name: 'EventProvider');
    return events;
  }

  void addEvent(DateTime day, Event event) {
        final normalizedDay = DateTime(day.year, day.month, day.day);

    developer.log('Adding event: ${event.title} on ${day.toString()}', name: 'EventProvider');
    developer.log('Repeat option: ${event.repeatOption}', name: 'EventProvider');
    developer.log('Current events for day: ${_events[day]}', name: 'EventProvider');

    
    _events.update(day, (events) => List<Event>.from(events)..add(event),
        ifAbsent: () => [event]);
    _eventService.addEvent(day, event);
    developer.log('Events for day after adding: ${_events[day]}', name: 'EventProvider');

    notifyListeners();

        developer.log('Events for day after adding: ${getEventsForDay(day)}', name: 'EventProvider');

  }

  void updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    final index = _events[day]?.indexOf(oldEvent) ?? -1;
    if (index != -1) {
      _events[day]![index] = newEvent;
      _eventService.updateEvent(day, oldEvent, newEvent);
      notifyListeners();
    }
  }

  void deleteEvent(DateTime day, Event event) {
    _events[day]?.remove(event);
    if (_events[day]?.isEmpty ?? false) {
      _events.remove(day);
    }
    _eventService.deleteEvent(day, event);
    notifyListeners();
  }

  void deleteAllEvents(Event event) {
    _events.forEach((day, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    _events.removeWhere((day, events) => events.isEmpty);
    _eventService.deleteAllEvents(event);
    notifyListeners();
  }

  void deleteFutureEvents(DateTime fromDay, Event event) {
    _events.forEach((day, events) {
      if (day.isAfter(fromDay) || day.isAtSameMomentAs(fromDay)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    _events.removeWhere((day, events) => events.isEmpty);
    _eventService.deleteFutureEvents(fromDay, event);
    notifyListeners();
  }

  void deletePastEvents(DateTime toDay, Event event) {
    _events.forEach((day, events) {
      if (day.isBefore(toDay) || day.isAtSameMomentAs(toDay)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    _events.removeWhere((day, events) => events.isEmpty);
    _eventService.deletePastEvents(toDay, event);
    notifyListeners();
  }

  void addRepeatingEvent(Event event, DateTime startDate, DateTime endDate) {
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      addEvent(currentDate, event);
      switch (event.repeatOption) {
        case RepeatOption.daily:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case RepeatOption.weekly:
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case RepeatOption.monthly:
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case RepeatOption.yearly:
          currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
          break;
        default:
          return; // If it's not a repeating event, just add it once and return
      }
    }
  }

  double getCashOnHandForDay(DateTime day) {
    double cashOnHand = 0;
    _events.forEach((eventDay, dayEvents) {
      if (eventDay.isBefore(day) || eventDay.isAtSameMomentAs(day)) {
        for (var event in dayEvents) {
          if (event.isPositiveCashflow) {
            cashOnHand += event.amount ?? 0;
          } else {
            cashOnHand -= event.amount ?? 0;
          }
        }
      }
    });
    return cashOnHand;
  }

Map<String, Map<String, double>> calculateTotals() {
    developer.log('Calculating totals', name: 'EventProvider');
    DateTime now = DateTime.now();
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

    _events.forEach((date, events) {
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

    developer.log('Calculated totals: $totals', name: 'EventProvider');
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

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
}