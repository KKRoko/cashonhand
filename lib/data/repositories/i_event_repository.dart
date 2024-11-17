import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../models/enums/delete_option.dart';
import '../models/freezed/event.dart';
import 'base_repository.dart';

abstract class IEventRepository extends BaseRepository<Event> {
  Future<Either<Failure, List<Event>>> getEvents(DateTime day);
  Future<Either<Failure, List<Event>>> getEventsForRange(
      DateTime start, DateTime end);
  Future<Either<Failure, List<Event>>> getAllEvents();
  Future<Either<Failure, Event>> addEvent(DateTime day, Event event);
  Future<Either<Failure, List<Event>>> addRecurringEvent(
      DateTime startDay, Event event); // New
  Future<Either<Failure, Event>> updateEvent(
      DateTime day, Event oldEvent, Event newEvent);
  Future<Either<Failure, bool>> deleteEvent(DateTime day, Event event, DeleteOption option);
  Future<Either<Failure, bool>> deleteEventSeries(Event event); // New
  Future<Either<Failure, bool>> hasEvents(DateTime day);
  Future<Either<Failure, int>> getTotalEvents();
  Future<Either<Failure, List<Event>>> getEventSeries(
      int originalEventId); // New
}
