// lib/utils/migration_utils.dart
import 'package:dartz/dartz.dart';  // Add this for Either type
import '../data/models/enums/repeat_option.dart';
import '../data/repositories/event_repository.dart';
import '../data/models/freezed/event.dart';
import '../core/error/failures.dart';

class DataMigrationUtils {
  static Future<void> migrateExistingData(
    EventRepository oldRepo,
    EventRepository newRepo,
  ) async {
    // Get and handle the Either result
    final Either<Failure, List<Event>> result = await oldRepo.getAllEvents();
    
    // Extract the events using fold
    final List<Event> events = await result.fold(
      (failure) => <Event>[],  // Return empty list on failure
      (success) => success,    // Return the events on success
    );
    
    for (final event in events) {
      final newEvent = Event(
        id: event.id,
        title: event.title,
        amount: event.amount,
        categoryId: 1,  // You need to decide on a default category ID for migration
        repeatOption: event.repeatOption,
        customRecurrence: event.customRecurrence,
        dateTime: event.dateTime,
        createdAt: event.createdAt,
        updatedAt: DateTime.now(),  // Add current time for migration
        isRecurring: event.repeatOption != RepeatOption.today,  // Derive from repeatOption
        notes: null,  // Add if you have this data
        isYearEndSummary: event.isYearEndSummary,
      );
      
      // Await the add operation and handle the result
      await newRepo.addEvent(event.dateTime, newEvent).then(
        (result) => result.fold(
          (failure) => print('Failed to migrate event: ${event.id}'),  // Handle failure
          (success) => print('Successfully migrated event: ${event.id}'),  // Handle success
        ),
      );
    }
  }
}