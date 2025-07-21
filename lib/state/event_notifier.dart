import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import '../data/models/enums/delete_option.dart';
import '../data/models/enums/edit_option.dart';
import '../data/models/enums/repeat_option.dart';
import '../data/models/freezed/event.dart';
import '../services/event_service.dart';
import '../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../utils/event_date_utils.dart';

@injectable
class EventNotifier extends ChangeNotifier {
  final EventService eventService;  
  final Map<DateTime, List<Event>> _events = {};
  bool _isLoading = false;
  String? _error;
  bool _isAddingRecurringEvent = false;

  EventNotifier(this.eventService); 

  // Getters
  Map<DateTime, List<Event>> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddingRecurringEvent => _isAddingRecurringEvent;
  
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

  Future<DateTime?> addEvent(DateTime day, Event event) async {
    _setLoading(true);

    DateTime? firstEventDate;
    if (event.repeatOption == RepeatOption.today) {
      await _addSingleEvent(day, event);
      firstEventDate = day;
    } else {
      firstEventDate = await _addRecurringEvent(day, event);
    }

    _setLoading(false);
    return firstEventDate;
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

  Future<void> updateEventWithScope(DateTime day, Event oldEvent, Event newEvent, EditOption editOption) async {
    print('🔍 DEBUG: EventNotifier.updateEventWithScope called');
    print('🔍 DEBUG: Event - ID: ${oldEvent.id}, Title: "${oldEvent.title}", OriginalID: ${oldEvent.originalEventId}');
    print('🔍 DEBUG: Date: ${day.toIso8601String()}, EditOption: $editOption');
    
    _setLoading(true);

    final result = await eventService.updateEventWithScope(day, oldEvent, newEvent, editOption);
    result.fold(
      (failure) {
        print('❌ ERROR: EventNotifier - Scoped update failed: ${failure.message}');
        _setError(failure.message);
      },
      (updatedCount) {
        print('🔍 DEBUG: EventNotifier - Scoped update success: $updatedCount events updated');
        if (updatedCount > 0) {
          // For now, don't automatically clear cache to avoid recursion issues
          // User can manually refresh by navigating away and back
          print('🔍 DEBUG: EventNotifier - Update successful, cache preserved to avoid recursion');
        } else {
          print('⚠️ WARNING: EventNotifier - Scoped update returned 0 (no events updated)');
        }
      }
    );

    _setLoading(false);
    print('🔍 DEBUG: EventNotifier.updateEventWithScope completed');
  }

  Future<Either<Failure, Map<String, int>>> getEditImpactCounts(Event event, DateTime cutoffDate) async {
    return await eventService.getEditImpactCounts(event, cutoffDate);
  }

  Future<void> deleteEvent(DateTime day, Event event, DeleteOption deleteOption) async {
    print('🔍 DEBUG: EventNotifier.deleteEvent called');
    print('🔍 DEBUG: Event - ID: ${event.id}, Title: "${event.title}", OriginalID: ${event.originalEventId}');
    print('🔍 DEBUG: Date: ${day.toIso8601String()}, DeleteOption: $deleteOption');
    
    _setLoading(true);

    final result = await eventService.deleteEvent(day, event, deleteOption);
    result.fold(
      (failure) {
        print('❌ ERROR: EventNotifier - Delete failed: ${failure.message}');
        _setError(failure.message);
      },
      (success) {
        print('🔍 DEBUG: EventNotifier - Delete success: $success');
        if (success) {
          _handleEventDeletion(day, event, deleteOption);
          notifyListeners();
          print('🔍 DEBUG: EventNotifier - UI state updated');
        } else {
          print('⚠️ WARNING: EventNotifier - Delete returned false (no events deleted)');
        }
      }
    );

    _setLoading(false);
    print('🔍 DEBUG: EventNotifier.deleteEvent completed');
  }

  List<Event> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    // If events are not cached for this day, schedule loading after build
    if (!_events.containsKey(normalizedDay)) {
      print("UI requesting events for $normalizedDay: not cached, scheduling load...");
      // Use WidgetsBinding to defer the async operation until after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadEventsForDay(normalizedDay);
      });
      return []; // Return empty list for now, UI will refresh when loaded
    }
    
    final events = _events[normalizedDay] ?? [];
    print("UI requesting events for $normalizedDay: found ${events.length} events in cache");
    for (var event in events) {
        print("- Title: ${event.title}, Amount: ${event.amount}, ID: ${event.id}, OriginalID: ${event.originalEventId}");
    }
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

void _groupEventsByDay(List<Event> events, {bool clearExisting = false}) {
  if (clearExisting) {
    _events.clear();
  }
  
  // Create a temporary map to handle duplicates
  final Map<DateTime, Map<String, Event>> tempEvents = {};
  
  for (final event in events) {
    final normalizedDay = DateTime(
      event.dateTime.year,
      event.dateTime.month,
      event.dateTime.day,
    );
    
    if (!tempEvents.containsKey(normalizedDay)) {
      tempEvents[normalizedDay] = {};
    }
    
    // Create a unique key for each event series
    final String eventKey = event.originalEventId != null 
      ? '${event.originalEventId}-${event.dateTime}'
      : '${event.id}-${event.dateTime}';
    
    // Prefer generated instances over original events
    if (!tempEvents[normalizedDay]!.containsKey(eventKey) ||
        event.originalEventId != null) {
      tempEvents[normalizedDay]![eventKey] = event;
    }
  }
  
  // Convert back to the original structure
  tempEvents.forEach((day, eventMap) {
    _events[day] = eventMap.values.toList();
  });
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

  Future<DateTime?> _addRecurringEvent(DateTime startDay, Event event) async {
  print('🔍 DEBUG: EventNotifier._addRecurringEvent called - Title: ${event.title}, Amount: \$${event.amount}');
  print('🔍 DEBUG: StartDay: ${startDay.toIso8601String()}, RepeatOption: ${event.repeatOption}');
  
  // Prevent multiple simultaneous recurring event additions
  if (_isAddingRecurringEvent) {
    print('🚫 DEBUG: Already adding a recurring event, ignoring duplicate call');
    return null;
  }
  
  _isAddingRecurringEvent = true;
  _setLoading(true);
  
  DateTime? firstEventDate;
  final result = await eventService.addEvent(startDay, event);
  result.fold(
    (failure) {
      print('🔍 DEBUG: _addRecurringEvent failed: ${failure.message}');
      _setError(failure.message);
      _isAddingRecurringEvent = false;
    },
    (event) async {
      print('🔍 DEBUG: _addRecurringEvent succeeded, triggering UI refresh...');
      // Clear the events cache so it gets reloaded with fresh data from database
      // This ensures all events (including new recurring ones) are displayed
      _events.clear();
      firstEventDate = event.dateTime;
      print('🔍 DEBUG: First event created on: ${firstEventDate!.toIso8601String()}');
      
      // Force a complete reload of the UI by notifying listeners
      // The improved getEventsForDay will now auto-load missing events
      notifyListeners();
    }
  );

  _setLoading(false);
  _isAddingRecurringEvent = false;
  print('🔍 DEBUG: _addRecurringEvent completed');
  return firstEventDate;
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
    notifyListeners();
  }

  void _handleEventDeletion(DateTime day, Event event, DeleteOption deleteOption) {
      print('EventNotifier: Handling deletion of event ${event.id} with option $deleteOption');
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    switch (deleteOption) {
      case DeleteOption.thisDay:
        if (_events.containsKey(normalizedDay)) {
          _events[normalizedDay]?.removeWhere((e) => e.id == event.id);
          if (_events[normalizedDay]?.isEmpty ?? false) {
            _events.remove(normalizedDay);
          }
        }
        break;
        
      case DeleteOption.allTime:
        // Remove from all days
      final eventCount = _events.values.expand((e) => e).length;
      print('EventNotifier: Total events before deletion: $eventCount');
        _events.removeWhere((date, events) {
          events.removeWhere((e) => e.id == event.id || e.originalEventId == event.originalEventId);
          return events.isEmpty;
        });
              final remainingCount = _events.values.expand((e) => e).length;
      print('EventNotifier: Events remaining after deletion: $remainingCount');
        break;
        
      case DeleteOption.futureOnly:
        // Remove from current day and future
        _events.removeWhere((date, events) {
          if (!date.isBefore(normalizedDay)) {
            events.removeWhere((e) => e.id == event.id || e.originalEventId == event.originalEventId);
            return events.isEmpty;
          }
          return false;
        });
        break;
        
      case DeleteOption.pastOnly:
        // Remove from past including current day
        _events.removeWhere((date, events) {
          if (!date.isAfter(normalizedDay)) {
            events.removeWhere((e) => e.id == event.id || e.originalEventId == event.originalEventId);
            return events.isEmpty;
          }
          return false;
        });
        break;
    }
    
    notifyListeners();
      print('EventNotifier: UI update triggered');

  }

  void debugPrintEvents() {
    _events.forEach((date, events) {
      print('Date: $date');
      for (var event in events) {
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
