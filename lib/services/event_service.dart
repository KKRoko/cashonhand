import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/event.dart';
import '../data/models/enums/delete_option.dart';
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
    return _repository.addEvent(day, event);
  }

  /// Updates an existing event
  Future<Either<Failure, Event>> updateEvent(DateTime day, Event oldEvent, Event newEvent) {
    return _repository.updateEvent(day, oldEvent, newEvent);
  }

Future<Either<Failure, bool>> deleteEvent(DateTime day, Event event, DeleteOption deleteOption) {
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
