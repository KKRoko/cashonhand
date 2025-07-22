import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/error/exception.dart';
import '../../utils/event_date_utils.dart';
import '../../services/recurrence_calculation_service.dart';
import '../../services/round_up_service.dart';
import '../../services/settings_service.dart';
import '../../services/auto_allocation_rules_engine.dart';
import '../database/database.dart';
import '../models/enums/delete_option.dart';
import '../models/enums/edit_option.dart';
import '../models/freezed/custom_recurrence.dart';
import '../models/freezed/event.dart';
import '../models/freezed/goal_allocation.dart';
import '../models/enums/repeat_option.dart';
import '../models/enums/allocation_type.dart';
import '../models/event_creation_result.dart';
import '../../services/goal_update_notifier.dart';
import 'base_repository.dart';
import 'i_event_repository.dart';

@Injectable(as: IEventRepository)
class EventRepository extends BaseRepository<Event>
    implements IEventRepository {
  final Database _database;
  final RoundUpService _roundUpService;
  final SettingsService _settingsService;
  final AutoAllocationRulesEngine _rulesEngine;

  EventRepository(
    this._database,
    this._roundUpService,
    this._settingsService,
    this._rulesEngine,
  );

@override
Future<Either<Failure, List<Event>>> getEvents(DateTime day) {
  return catchError(() async {
    print('🔍 DEBUG: getEvents called for day: ${day.toIso8601String().substring(0, 10)}');
    
    final events = await _database.getAllEvents();
    print('🔍 DEBUG: Found ${events.length} total events in database');
    
    List<Event> eventsForDay = [];
    
    // Simple approach: get events that match the date
    for (var eventData in events) {
      final event = await _convertToEvent(eventData);
      
      if (EventDateUtils.isSameDay(event.dateTime, day)) {
        eventsForDay.add(event);
        print('🔍 DEBUG: Added event for ${day.toIso8601String().substring(0, 10)}: ${event.title} (\$${event.amount}) - ID: ${event.id}, OriginalID: ${event.originalEventId}');
      }
    }

    print('🔍 DEBUG: Returning ${eventsForDay.length} events for ${day.toIso8601String().substring(0, 10)}');
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
        currentDate = RecurrenceCalculationService.getNextOccurrence(currentDate, event.repeatOption, event.customRecurrence);
        
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
    List<GoalAllocation> automaticAllocations = [];
    
    // 1. Check for auto-allocation rules
    print('🔧 EventRepository: Checking auto-allocation rules for transaction');
    final rulesResult = await _rulesEngine.evaluateRulesForTransaction(event);
    rulesResult.fold(
      (failure) => print('Warning: Failed to evaluate allocation rules: ${failure.message}'),
      (ruleAllocations) {
        automaticAllocations.addAll(ruleAllocations);
        print('🔧 EventRepository: Added ${ruleAllocations.length} rule-based allocations');
      },
    );
    
    // 2. Check if round-up is enabled and calculate automatic round-up
    final roundUpPrefs = _settingsService.roundUpPreferences;
    if (roundUpPrefs.isEnabled) {
      final roundUpCalc = _roundUpService.calculateRoundUp(
        event.amount,
        roundUpPrefs,
        categoryId: event.categoryId,
      );
      
      if (roundUpCalc.isApplicable && roundUpCalc.roundUpAmount > 0) {
        print('💰 EventRepository: Automatic round-up calculated: \$${roundUpCalc.roundUpAmount.toStringAsFixed(2)} for \$${event.amount.toStringAsFixed(2)}');
        
        // Create round-up allocation (we'll get the event ID from the creation process)
        final allocationResult = await _roundUpService.createRoundUpAllocation(
          0, // Temporary ID, will be updated below
          roundUpCalc,
          roundUpPrefs,
        );
        
        allocationResult.fold(
          (failure) => print('Warning: Failed to create round-up allocation: ${failure.message}'),
          (allocation) {
            if (allocation != null) {
              automaticAllocations.add(allocation);
              print('💰 EventRepository: Added round-up allocation');
            }
          },
        );
      }
    }
    
    // 3. If we have automatic allocations, use addEventWithAllocations
    if (automaticAllocations.isNotEmpty) {
      print('🎯 EventRepository: Creating event with ${automaticAllocations.length} automatic allocations');
      final result = await addEventWithAllocations(day, event, automaticAllocations);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (event) => event,
      );
    }
    
    // No round-up - proceed with normal event creation
    final eventCompanion = EventsCompanion.insert(
      title: event.title,
      categoryId: event.categoryId,
      amount: event.amount,
      date: event.dateTime,
      repeatOption: event.repeatOption,
      isRecurring: Value(event.isRecurring),
      notes: Value(event.notes),
      customRecurrence: Value(event.customRecurrence),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final createdEvent = await _database.createEvent(eventCompanion, generateRecurring: event.isRecurring);
    print('Created event - ID: ${createdEvent.id}, OriginalID: ${createdEvent.originalEventId}');
    
    if (createdEvent.originalEventId == null) {
      print('WARNING: originalEventId is still null after creation for event ID: ${createdEvent.id}');
    }
    
    // Convert database event back to domain event
    return event.copyWith(
      id: createdEvent.id,
      originalEventId: createdEvent.originalEventId,
      dateTime: createdEvent.date,
    );
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
        date: newEvent.dateTime,
        repeatOption: newEvent.repeatOption,
        isRecurring: newEvent.isRecurring,
        notes: newEvent.notes,
        customRecurrence: newEvent.customRecurrence,
        originalEventId: oldEvent.originalEventId,
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

  // New method for scoped event updates
  Future<Either<Failure, int>> updateEventWithScope(
      DateTime day, Event oldEvent, Event newEvent, EditOption editOption) {
    print('🔍 DEBUG: Repository.updateEventWithScope called');
    print('🔍 DEBUG: Event details - ID: ${oldEvent.id}, Title: "${oldEvent.title}", OriginalID: ${oldEvent.originalEventId}');
    print('🔍 DEBUG: Edit option: $editOption, Date: ${day.toIso8601String()}');
    
    return catchError(() async {
      if (oldEvent.id == null) {
        print('❌ ERROR: Repository - Cannot update event without id');
        throw DatabaseException('Cannot update event without id');
      }

      final eventData = EventTableData(
        id: newEvent.id ?? oldEvent.id!,
        title: newEvent.title,
        categoryId: newEvent.categoryId,
        amount: newEvent.amount,
        date: newEvent.dateTime,
        repeatOption: newEvent.repeatOption,
        isRecurring: newEvent.isRecurring,
        notes: newEvent.notes,
        customRecurrence: newEvent.customRecurrence,
        originalEventId: oldEvent.originalEventId,
        createdAt: oldEvent.createdAt,
        updatedAt: DateTime.now(),
      );
      
      print('🔍 DEBUG: Repository - Calling database.updateEventsWithOption with eventId: ${oldEvent.id}');
      final updatedCount = await _database.updateEventsWithOption(
        oldEvent.id!, 
        eventData, 
        editOption, 
        day
      );
      print('🔍 DEBUG: Repository - Database returned updatedCount: $updatedCount');

      return updatedCount;
    });
  }

  // Helper method to get edit impact counts
  Future<Either<Failure, Map<String, int>>> getEditImpactCounts(
      Event event, DateTime cutoffDate) {
    return catchError(() async {
      if (event.id == null) {
        throw DatabaseException('Cannot get impact counts for event without id');
      }
      
      return await _database.getEditImpactCounts(event.id!, cutoffDate);
    });
  }

  @override
Future<Either<Failure, bool>> deleteEvent(DateTime day, Event event, DeleteOption option) {
    print('🔍 DEBUG: Repository.deleteEvent called');
    print('🔍 DEBUG: Event details - ID: ${event.id}, Title: "${event.title}", OriginalID: ${event.originalEventId}');
    print('🔍 DEBUG: Delete option: $option, Date: ${day.toIso8601String()}');
    
    return catchError(() async {
      if (event.id == null) {
        print('❌ ERROR: Repository - Cannot delete event without id');
        throw DatabaseException('Cannot delete event without id');
      }
      
      print('🔍 DEBUG: Repository - Calling database.deleteEventsWithOption with eventId: ${event.id}');
      final deletedCount = await _database.deleteEventsWithOption(event.id!, option, day);
      print('🔍 DEBUG: Repository - Database returned deletedCount: $deletedCount');

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
      print('🔍 DEBUG: addRecurringEvent called for ${event.title} (\$${event.amount}) starting ${startDay.toIso8601String().substring(0, 10)}');
      
      final events = await _generateRecurringEvents(startDay, event);
      print('🔍 DEBUG: addRecurringEvent generated ${events.length} events');
      return events;
    });
  }

  Future<List<Event>> _generateRecurringEvents(DateTime startDate, Event event) async {
    print('🔍 DEBUG: _generateRecurringEvents called for: ${event.title}, startDate: ${startDate.toIso8601String()}');
    print('🔍 DEBUG: Event details - Amount: \$${event.amount}, RepeatOption: ${event.repeatOption}, CustomRecurrence: ${event.customRecurrence?.frequency}');
    
    List<Event> events = [];
    DateTime currentDate = _calculateFirstOccurrence(startDate, event);
    final endDate = DateTime(startDate.year, 12, 31); // Generate until year-end
    
    print('🔍 DEBUG: First occurrence calculated as: ${currentDate.toIso8601String()}');

    // Create first event
    final firstEventCompanion = EventsCompanion.insert(
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

    print('🔍 DEBUG: Creating first event in database...');
    final firstEvent = await _database.createEvent(firstEventCompanion, generateRecurring: false);
    final originalId = firstEvent.id;
    
    // The first event already has its originalEventId set correctly from createEvent
    
    events.add(event.copyWith(id: originalId, dateTime: currentDate, originalEventId: originalId));
    print('🔍 DEBUG: First event created with ID: $originalId, Date: ${currentDate.toIso8601String()}, OriginalEventId: $originalId');

    // Generate remaining events in series
    int eventCount = 1;
    while (currentDate.isBefore(endDate)) {
        currentDate = RecurrenceCalculationService.getNextOccurrence(currentDate, event.repeatOption, event.customRecurrence);
        
        if (currentDate.isAfter(endDate)) break;
        
        eventCount++;
        print('🔍 DEBUG: Creating event #$eventCount for date: ${currentDate.toIso8601String()}');

        final eventCompanion = EventsCompanion.insert(
          title: event.title,
          categoryId: event.categoryId,
          amount: event.amount,
          date: currentDate,
          repeatOption: event.repeatOption,
          isRecurring: Value(true),
          notes: Value(event.notes),
          customRecurrence: Value(event.customRecurrence),
          originalEventId: Value(originalId),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        final createdEvent = await _database.createEvent(eventCompanion, generateRecurring: false);
        events.add(event.copyWith(
            id: createdEvent.id, 
            dateTime: createdEvent.date, 
            originalEventId: createdEvent.originalEventId
        ));
        print('🔍 DEBUG: Event #$eventCount created with ID: ${createdEvent.id}');
    }

    print('🔍 DEBUG: Total events generated: ${events.length}');
    return events;
}

  DateTime _calculateFirstOccurrence(DateTime startDate, Event event) {
    // For non-recurring or events without custom recurrence, use start date
    if (!event.isRecurring || event.customRecurrence == null) {
      return startDate;
    }

    final customRecurrence = event.customRecurrence!;
    
    switch (event.repeatOption) {
      case RepeatOption.monthly:
        // Handle monthly events with specific dayOfMonth
        if (customRecurrence.dayOfMonth != null) {
          final targetDay = customRecurrence.dayOfMonth!;
          final currentMonth = startDate.month;
          final currentYear = startDate.year;
          
          // Check if target day exists in current month
          final lastDayOfCurrentMonth = DateTime(currentYear, currentMonth + 1, 0).day;
          final clampedTargetDay = targetDay.clamp(1, lastDayOfCurrentMonth);
          
          // If target day hasn't passed this month, use it
          if (clampedTargetDay >= startDate.day) {
            return DateTime(currentYear, currentMonth, clampedTargetDay);
          }
          
          // Otherwise, move to next month
          final nextMonth = currentMonth + 1;
          final nextYear = currentYear + (nextMonth > 12 ? 1 : 0);
          final adjustedMonth = nextMonth > 12 ? 1 : nextMonth;
          final lastDayOfNextMonth = DateTime(nextYear, adjustedMonth + 1, 0).day;
          final clampedNextTargetDay = targetDay.clamp(1, lastDayOfNextMonth);
          
          return DateTime(nextYear, adjustedMonth, clampedNextTargetDay);
        }
        
        // Handle end of month cases
        if (customRecurrence.repeatAtEndOfMonth || customRecurrence.useLastDayOfMonth) {
          final currentMonth = startDate.month;
          final currentYear = startDate.year;
          final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
          
          // If we haven't reached end of month yet, use it
          if (lastDayOfMonth.day >= startDate.day) {
            return DateTime(currentYear, currentMonth, lastDayOfMonth.day);
          }
          
          // Otherwise, move to next month's end
          return DateTime(currentYear, currentMonth + 1 + 1, 0);
        }
        
        // Default: use start date for monthly
        return startDate;
        
      case RepeatOption.weekly:
        // Handle weekly events with selected days
        if (customRecurrence.hasSelectedDays) {
          final selectedDayIndices = customRecurrence.selectedDayIndices;
          if (selectedDayIndices.isNotEmpty) {
            final currentWeekdayIndex = startDate.weekday % 7;
            
            // Check if today is a selected day
            if (selectedDayIndices.contains(currentWeekdayIndex)) {
              return startDate;
            }
            
            // Find next selected day this week
            for (int dayIndex in selectedDayIndices) {
              if (dayIndex > currentWeekdayIndex) {
                final daysToAdd = dayIndex - currentWeekdayIndex;
                return startDate.add(Duration(days: daysToAdd));
              }
            }
            
            // No selected day this week, go to first selected day next week
            final firstSelectedDay = selectedDayIndices.first;
            final daysToAdd = (7 - currentWeekdayIndex) + firstSelectedDay;
            return startDate.add(Duration(days: daysToAdd));
          }
        }
        
        // Default: use start date for weekly
        return startDate;
        
      default:
        // For daily and other types, use start date
        return startDate;
    }
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

  @override
  Future<Either<Failure, Event>> addEventWithAllocations(DateTime day, Event event, List<GoalAllocation> allocations) {
    return catchError(() async {
      // Start a database transaction to ensure atomicity
      final resultEvent = await _database.transaction(() async {
        // First create the event
        final eventCompanion = EventsCompanion.insert(
          title: event.title,
          categoryId: event.categoryId,
          amount: event.amount,
          date: event.dateTime,
          repeatOption: event.repeatOption,
          isRecurring: Value(event.isRecurring),
          notes: Value(event.notes),
          customRecurrence: Value(event.customRecurrence),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        final createdEvent = await _database.createEvent(eventCompanion, generateRecurring: event.isRecurring);
        print('Created event - ID: ${createdEvent.id}, OriginalID: ${createdEvent.originalEventId}');
        
        // Then create the allocations if any
        if (allocations.isNotEmpty) {
          for (final allocation in allocations) {
            final allocationCompanion = GoalAllocationsCompanion.insert(
              eventId: createdEvent.id,
              goalId: allocation.goalId,
              allocationAmount: allocation.allocationAmount,
              allocationType: allocation.allocationType,
              notes: Value(allocation.notes),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            );
            
            await _database.createGoalAllocation(allocationCompanion);
            print('Created allocation: ${allocation.goalTitle} - \$${allocation.allocationAmount}');
          }
        }
        
        // Convert database event back to domain event
        return event.copyWith(
          id: createdEvent.id,
          originalEventId: createdEvent.originalEventId,
          dateTime: createdEvent.date,
        );
      });
      
      // After transaction is complete, notify goal updates
      for (final allocation in allocations) {
        GoalUpdateNotifier().notifyGoalUpdated(allocation.goalId, allocation.allocationAmount);
      }
      
      return resultEvent;
    });
  }


  // Helper method to convert database events to domain events
  Future<List<Event>> _convertToEvents(List<EventTableData> eventData) {
    return Future.wait(
      eventData.map((e) async {
        return Event(
          id: e.id,
          originalEventId: e.originalEventId, 
          title: e.title,
          categoryId: e.categoryId,
          amount: e.amount,
          dateTime: e.date,
          repeatOption: e.repeatOption,
          isRecurring: e.isRecurring,
          notes: e.notes,
          customRecurrence: e.customRecurrence, 
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
      customRecurrence: e.customRecurrence, 
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      isYearEndSummary: false,
    );
  }
}