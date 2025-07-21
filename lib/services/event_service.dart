import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/event.dart';
import '../data/models/freezed/goal_allocation.dart';
import '../data/models/enums/delete_option.dart';
import '../data/models/enums/edit_option.dart';
import '../data/repositories/i_event_repository.dart';

@injectable
class EventService {
  final IEventRepository _repository;

  EventService(this._repository);

  /// Returns events for a specific day
  Future<Either<Failure, List<Event>>> getEventsForDay(DateTime day) {
    return _repository.getEvents(day);
  }

  /// Returns events within a date range
  Future<Either<Failure, List<Event>>> getEventsForRange(DateTime start, DateTime end) {
    return _repository.getEventsForRange(start, end);
  }

  /// Adds a new event
  Future<Either<Failure, Event>> addEvent(DateTime day, Event event) {
    print('🔍 DEBUG: EventService.addEvent called - Title: ${event.title}, Amount: \$${event.amount}, IsRecurring: ${event.isRecurring}');
    
    if (event.isRecurring) {
      print('🔍 DEBUG: Detected recurring event, calling addRecurringEvent...');
      // For recurring events, use addRecurringEvent and return the first event
      return _repository.addRecurringEvent(day, event).then((result) {
        return result.fold(
          (failure) {
            print('🔍 DEBUG: addRecurringEvent failed: ${failure.message}');
            return Left(failure);
          },
          (events) {
            print('🔍 DEBUG: addRecurringEvent succeeded, returned ${events.length} events');
            return events.isNotEmpty 
              ? Right(events.first) 
              : const Left(DatabaseFailure('No events generated'));
          },
        );
      });
    }
    
    print('🔍 DEBUG: Non-recurring event, calling regular addEvent...');
    return _repository.addEvent(day, event);
  }

  /// Adds a new event with goal allocations
  Future<Either<Failure, Event>> addEventWithAllocations(DateTime day, Event event, List<GoalAllocation> allocations) {
    print('🔍 DEBUG: EventService.addEventWithAllocations called - Title: ${event.title}, Allocations: ${allocations.length}');
    return _repository.addEventWithAllocations(day, event, allocations);
  }

  /// Updates an existing event
  Future<Either<Failure, Event>> updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    return _repository.updateEvent(day, oldEvent, newEvent);
  }

  /// Updates events with scope (for recurring events)
  Future<Either<Failure, int>> updateEventWithScope(
      DateTime day, Event oldEvent, Event newEvent, EditOption editOption) {
    print('🔍 DEBUG: EventService.updateEventWithScope called');
    print('🔍 DEBUG: Event - ID: ${oldEvent.id}, Title: "${oldEvent.title}", Date: ${day.toIso8601String()}');
    print('🔍 DEBUG: EditOption: $editOption');
    
    // Cast to EventRepository to access the new method
    final eventRepository = _repository as dynamic;
    return eventRepository.updateEventWithScope(day, oldEvent, newEvent, editOption);
  }

  /// Gets edit impact counts for preview
  Future<Either<Failure, Map<String, int>>> getEditImpactCounts(
      Event event, DateTime cutoffDate) {
    final eventRepository = _repository as dynamic;
    return eventRepository.getEditImpactCounts(event, cutoffDate);
  }

Future<Either<Failure, bool>> deleteEvent(DateTime day, Event event, DeleteOption deleteOption) {
  print('🔍 DEBUG: EventService.deleteEvent called');
  print('🔍 DEBUG: Event - ID: ${event.id}, Title: "${event.title}", Date: ${day.toIso8601String()}');
  print('🔍 DEBUG: DeleteOption: $deleteOption');
  
  return _repository.deleteEvent(day, event, deleteOption);
}


  /// Checks if there are any events for a given day
  Future<Either<Failure, bool>> hasEventsForDay(DateTime day) {
    return _repository.hasEvents(day);
  }

  /// Gets the total number of events
  Future<Either<Failure, int>> getTotalEvents() {
    return _repository.getTotalEvents();
  }
}
