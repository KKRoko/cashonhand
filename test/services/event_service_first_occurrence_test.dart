import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:cash_on_hand/services/event_service.dart';
import 'package:cash_on_hand/data/repositories/i_event_repository.dart';
import 'package:cash_on_hand/data/models/freezed/event.dart';
import 'package:cash_on_hand/data/models/freezed/custom_recurrence.dart';
import 'package:cash_on_hand/data/models/enums/repeat_option.dart';
import 'package:cash_on_hand/core/error/failures.dart';

// Generate mock classes
@GenerateMocks([IEventRepository])
import 'event_service_first_occurrence_test.mocks.dart';

void main() {
  group('EventService - First Occurrence Fix', () {
    late EventService eventService;
    late MockIEventRepository mockRepository;

    setUp(() {
      mockRepository = MockIEventRepository();
      eventService = EventService(mockRepository);
    });

    test('should call addRecurringEvent for recurring events', () async {
      // Arrange
      final creationDate = DateTime(2024, 7, 20); // July 20
      final firstOccurrence = DateTime(2024, 7, 24); // July 24 (correct first occurrence)
      
      final event = Event(
        title: 'Monthly Event',
        categoryId: 1,
        amount: 100.0,
        dateTime: creationDate,
        repeatOption: RepeatOption.monthly,
        isRecurring: true,
        customRecurrence: const CustomRecurrence(
          interval: RepeatOption.monthly,
          frequency: 1,
          dayOfMonth: 24,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );

      final generatedEvents = [
        event.copyWith(id: 1, dateTime: firstOccurrence),
        event.copyWith(id: 2, dateTime: DateTime(2024, 8, 24)),
        event.copyWith(id: 3, dateTime: DateTime(2024, 9, 24)),
      ];

      // Mock the addRecurringEvent call
      when(mockRepository.addRecurringEvent(creationDate, event))
          .thenAnswer((_) async => Right(generatedEvents));

      // Act
      final result = await eventService.addEvent(creationDate, event);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (returnedEvent) {
          expect(returnedEvent.dateTime, firstOccurrence); // Should be July 24, not July 20
          expect(returnedEvent.id, 1);
        },
      );

      // Verify that addRecurringEvent was called, not addEvent
      verify(mockRepository.addRecurringEvent(creationDate, event)).called(1);
      verifyNever(mockRepository.addEvent(any, any));
    });

    test('should call regular addEvent for non-recurring events', () async {
      // Arrange
      final creationDate = DateTime(2024, 7, 20);
      
      final event = Event(
        title: 'Single Event',
        categoryId: 1,
        amount: 100.0,
        dateTime: creationDate,
        repeatOption: RepeatOption.today,
        isRecurring: false,
        customRecurrence: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );

      final savedEvent = event.copyWith(id: 1);

      // Mock the addEvent call
      when(mockRepository.addEvent(creationDate, event))
          .thenAnswer((_) async => Right(savedEvent));

      // Act
      final result = await eventService.addEvent(creationDate, event);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (returnedEvent) {
          expect(returnedEvent.dateTime, creationDate); // Should use creation date for non-recurring
          expect(returnedEvent.id, 1);
        },
      );

      // Verify that addEvent was called, not addRecurringEvent
      verify(mockRepository.addEvent(creationDate, event)).called(1);
      verifyNever(mockRepository.addRecurringEvent(any, any));
    });

    test('should handle empty events list from addRecurringEvent', () async {
      // Arrange
      final creationDate = DateTime(2024, 7, 20);
      
      final event = Event(
        title: 'Monthly Event',
        categoryId: 1,
        amount: 100.0,
        dateTime: creationDate,
        repeatOption: RepeatOption.monthly,
        isRecurring: true,
        customRecurrence: const CustomRecurrence(
          interval: RepeatOption.monthly,
          frequency: 1,
          dayOfMonth: 24,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );

      // Mock addRecurringEvent to return empty list
      when(mockRepository.addRecurringEvent(creationDate, event))
          .thenAnswer((_) async => const Right([]));

      // Act
      final result = await eventService.addEvent(creationDate, event);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'No events generated');
        },
        (event) => fail('Should fail when no events generated'),
      );
    });
  });
}