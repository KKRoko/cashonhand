import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/error/exception.dart';
import '../../utils/event_date_utils.dart';
import '../database/database.dart';
import '../models/enums/delete_option.dart';
import '../models/freezed/custom_recurrence.dart';
import '../models/freezed/event.dart';
import '../models/enums/repeat_option.dart';
import 'base_repository.dart';
import 'i_event_repository.dart';

@Injectable(as: IEventRepository)
class EventRepository extends BaseRepository<Event>
    implements IEventRepository {
  final Database _database;

  EventRepository(this._database);

@override
Future<Either<Failure, List<Event>>> getEvents(DateTime day) {
    return catchError(() async {
      // First, get all events
      final events = await _database.getAllEvents();
      List<Event> eventsForDay = [];
      
      for (var eventData in events) {
        final event = await _convertToEvent(eventData);
        
        // For non-recurring events, just check the exact date
        if (!event.isRecurring) {
          if (EventDateUtils.isSameDay(event.dateTime, day)) {
            eventsForDay.add(event);
          }
          continue;
        }

        // For recurring events, check if this day matches the pattern
        if (_doesEventOccurOnDay(event, day)) {
          eventsForDay.add(event.copyWith(dateTime: day));
        }
      }

      return eventsForDay;
    });
}

bool _doesEventOccurOnDay(Event event, DateTime targetDay) {
    if (!event.isRecurring) return EventDateUtils.isSameDay(event.dateTime, targetDay);

    DateTime currentDate = event.dateTime;
    while (!currentDate.isAfter(targetDay)) {
        if (EventDateUtils.isSameDay(currentDate, targetDay)) {
            return true;
        }
        currentDate = _getNextDate(currentDate, event.repeatOption, event.customRecurrence);
        
        // Prevent infinite loops
        if (currentDate.isAfter(DateTime(targetDay.year + 1, 1, 1))) {
            break;
        }
    }
    return false;
}


  @override
  Future<Either<Failure, List<Event>>> getEventsForRange(
      DateTime start, DateTime end) {
    return catchError(() async {
      final events = await (_database.select(_database.events)
            ..where((tbl) =>
                tbl.date.isBiggerOrEqualValue(start) &
                tbl.date.isSmallerOrEqualValue(end)))
          .get();

      return await _convertToEvents(events);
    });
  }

  @override
  Future<Either<Failure, List<Event>>> getAllEvents() {
    return catchError(() async {
      final events = await _database.getAllEvents();
      return await _convertToEvents(events);
    });
  }

  @override
  Future<Either<Failure, Event>> addEvent(DateTime day, Event event) {
    return catchError(() async {
      final eventCompanion = EventsCompanion.insert(
        title: event.title,
        categoryId: event.categoryId,
        amount: event.amount,
        date: day,
        repeatOption: event.repeatOption,
        isRecurring: Value(event.isRecurring),
        notes: Value(event.notes),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      final id = await _database.createEvent(eventCompanion);
      return event.copyWith(id: id);
    });
  }

  @override
  Future<Either<Failure, Event>> updateEvent(
      DateTime day, Event oldEvent, Event newEvent) {
    return catchError(() async {
      final eventData = EventTableData(
        id: oldEvent.id!,
        title: newEvent.title,
        categoryId: newEvent.categoryId,
        amount: newEvent.amount,
        date: day,
        repeatOption: newEvent.repeatOption,
        isRecurring: newEvent.isRecurring,
        notes: newEvent.notes,
        createdAt: oldEvent.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _database.updateEvent(eventData);
      if (success) {
        return newEvent;
      } else {
        throw DatabaseException('Failed to update event');
      }
    });
  }

  @override
Future<Either<Failure, bool>> deleteEvent(DateTime day, Event event, DeleteOption option) {
    return catchError(() async {
      if (event.id == null) {
        throw DatabaseException('Cannot delete event without id');
      }
    final deletedCount = await _database.deleteEventsWithOption(event.id!, option, day);
      return deletedCount > 0;
    });
  }

  @override
  Future<Either<Failure, bool>> hasEvents(DateTime day) {
    return catchError(() async {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final events = await (_database.select(_database.events)
            ..where((tbl) => tbl.date.equals(normalizedDay)))
          .get();
      return events.isNotEmpty;
    });
  }

  @override
  Future<Either<Failure, int>> getTotalEvents() {
    return catchError(() async {
      final count = await _database.events.count().getSingle();
      return count;
    });
  }

  @override
  Future<Either<Failure, List<Event>>> addRecurringEvent(
      DateTime startDay, Event event) {
    return catchError(() async {
      final events = await _generateRecurringEvents(startDay, event);
      return events;
    });
  }

  Future<List<Event>> _generateRecurringEvents(DateTime startDate, Event event) async {
    List<Event> events = [];
    DateTime currentDate = startDate;
    final endDate = DateTime(startDate.year, 12, 31); // Generate until year-end

    // For weekly recurring events, adjust the start date to first occurrence
    if (event.repeatOption == RepeatOption.weekly && event.customRecurrence != null) {
        currentDate = startDate; // We already adjusted this in the dialog
    }

    // Create first event
    final firstEventCompanion = EventsCompanion.insert(
      title: event.title,
      categoryId: event.categoryId,
      amount: event.amount,
      date: currentDate,
      repeatOption: event.repeatOption,
      isRecurring: Value(true),
      notes: Value(event.notes),
      customRecurrence: Value(event.customRecurrence!.toJson() as CustomRecurrence?),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final originalId = await _database.createEvent(firstEventCompanion);
    events.add(event.copyWith(id: originalId, dateTime: currentDate));

    // Generate remaining events in series
    while (currentDate.isBefore(endDate)) {
        currentDate = _getNextDate(currentDate, event.repeatOption, event.customRecurrence);
        
        if (currentDate.isAfter(endDate)) break;

        final eventCompanion = EventsCompanion.insert(
          title: event.title,
          categoryId: event.categoryId,
          amount: event.amount,
          date: currentDate,
          repeatOption: event.repeatOption,
          isRecurring: Value(true),
          notes: Value(event.notes),
          customRecurrence: Value(event.customRecurrence),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        final id = await _database.createEvent(eventCompanion);
        events.add(event.copyWith(
            id: id, 
            dateTime: currentDate, 
            originalEventId: originalId
        ));
    }

    return events;
}

DateTime _getNextDate(DateTime current, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
    if (customRecurrence == null) {
      // Handle basic recurrence without custom pattern
      switch (repeatOption) {
        case RepeatOption.daily:
          return current.add(const Duration(days: 1));
        case RepeatOption.weekly:
          return current.add(const Duration(days: 7));
        case RepeatOption.monthly:
          return _addMonths(current, 1);
        default:
          return current;
      }
    }

    // Handle custom recurrence patterns
    switch (customRecurrence.interval) {
    case RepeatOption.daily:
      return current.add(Duration(days: customRecurrence.frequency));
      
    case RepeatOption.weekly:
      if (!customRecurrence.hasSelectedDays) {
        return current.add(Duration(days: 7 * customRecurrence.frequency));
      }
      
      List<int> selectedDayIndices = customRecurrence.selectedDayIndices;
      if (selectedDayIndices.isEmpty) {
        return current.add(Duration(days: 7 * customRecurrence.frequency));
      }

      // Current weekday in 0-6 format
      int currentWeekdayIndex = current.weekday % 7;
      
      // Find next selected day
      int nextDayIndex = selectedDayIndices.firstWhere(
        (dayIndex) => dayIndex > currentWeekdayIndex,
        orElse: () => selectedDayIndices.first
      );
      
      // Calculate days until next occurrence
      DateTime nextDate;
      if (nextDayIndex > currentWeekdayIndex) {
        // Next day is later this week
        nextDate = current.add(Duration(days: nextDayIndex - currentWeekdayIndex));
      } else {
        // Next day is in the next frequency period
        nextDate = current.add(Duration(days: 7 - currentWeekdayIndex + nextDayIndex));
      }
      
      // Add additional weeks based on frequency
      if (nextDayIndex <= currentWeekdayIndex) {
        nextDate = nextDate.add(Duration(days: 7 * (customRecurrence.frequency - 1)));
      }
      
      return nextDate;
        
      case RepeatOption.monthly:
        DateTime baseDate = _addMonths(current, customRecurrence.frequency);
        
        if (customRecurrence.repeatAtEndOfMonth) {
          return DateTime(baseDate.year, baseDate.month + 1, 0); // Last day of month
        }
        
        if (customRecurrence.useLastDayOfMonth) {
          int lastDay = DateTime(baseDate.year, baseDate.month + 1, 0).day;
          return DateTime(baseDate.year, baseDate.month, lastDay);
        }
        
        if (customRecurrence.dayOfMonth != null) {
          int lastDay = DateTime(baseDate.year, baseDate.month + 1, 0).day;
          int targetDay = customRecurrence.dayOfMonth!;
          // Ensure we don't exceed the month's length
          targetDay = targetDay.clamp(1, lastDay);
          return DateTime(baseDate.year, baseDate.month, targetDay);
        }
        
        return baseDate;
        
      default:
        return current;
    }
}

// Helper function to properly handle month addition
DateTime _addMonths(DateTime date, int months) {
    var year = date.year + (date.month + months - 1) ~/ 12;
    var month = (date.month + months - 1) % 12 + 1;
    
    // Handle month length differences
    var lastDayOfMonth = DateTime(year, month + 1, 0).day;
    var day = date.day.clamp(1, lastDayOfMonth);
    
    return DateTime(year, month, day);
}


  @override
  Future<Either<Failure, List<Event>>> getEventSeries(int originalEventId) {
    return catchError(() async {
      final events = await _database.getEventsByOriginalId(originalEventId);
      return await _convertToEvents(events);
    });
  }

  @override
  Future<Either<Failure, bool>> deleteEventSeries(Event event) {
    return catchError(() async {
      if (event.originalEventId == null) {
        throw DatabaseException('Cannot delete series without originalEventId');
      }
      final deletedCount =
          await _database.deleteEventSeries(event.originalEventId!);
      return deletedCount > 0;
    });
  }
}

// Helper method to convert database events to domain events
Future<List<Event>> _convertToEvents(List<EventTableData> eventData) {
  return Future.wait(
    eventData.map((e) async {
      return Event(
        id: e.id,
        title: e.title,
        categoryId: e.categoryId,
        amount: e.amount,
        dateTime: e.date,
        repeatOption: e.repeatOption,
        isRecurring: e.isRecurring,
        notes: e.notes,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        isYearEndSummary: false, // Add this as well
      );
    }).toList(), // Add .toList() here
  );
}

  Future<Event> _convertToEvent(EventTableData e) async {
    return Event(
      id: e.id,
      title: e.title,
      categoryId: e.categoryId,
      amount: e.amount,
      dateTime: e.date,
      repeatOption: e.repeatOption,
      isRecurring: e.isRecurring,
      notes: e.notes,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      isYearEndSummary: false,
    );
  }