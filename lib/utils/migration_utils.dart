// lib/utils/migration_utils.dart
import '../data/repositories/event_repository.dart';
import '../data/models/freezed/event.dart';  // Add this import

class DataMigrationUtils {
  static Future<void> migrateExistingData(
    EventRepository oldRepo,
    EventRepository newRepo,
  ) async {
    final allEvents = oldRepo.getAllEvents();
    
    for (final event in allEvents) {
      final newEvent = Event(
        id: event.id,
        title: event.title,
        amount: event.amount,
        isPositiveCashflow: event.isPositiveCashflow,
        isNegativeCashflow: event.isNegativeCashflow,
        repeatOption: event.repeatOption,
        customRecurrence: event.customRecurrence,
        createdAt: event.createdAt,
        isYearEndSummary: event.isYearEndSummary,
        dateTime: event.dateTime,
      );
      newRepo.addEvent(event.dateTime, newEvent);  // Note: Added dateTime parameter
    }
  }
}