import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/repeat_option.dart';
import 'custom_recurrence.dart';
import 'package:intl/intl.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  // Private constructor to force using factory constructors
  const Event._();

  const factory Event({
    int? id,
    int? originalEventId,
    required String title,
    required int categoryId,
    required double amount,
    required DateTime dateTime,
    required RepeatOption repeatOption,
    required bool isRecurring,
    String? notes,
    CustomRecurrence? customRecurrence,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isYearEndSummary,
  }) = _Event;

  // Named constructor for creating new events
  factory Event.create({
    required String title,
    required int categoryId,
    required double amount,
    required DateTime dateTime,
    required RepeatOption repeatOption,
    bool isRecurring = false,
    String? notes,
    CustomRecurrence? customRecurrence,
  }) {
    final now = DateTime.now();
    return Event(
      title: title,
      categoryId: categoryId,
      amount: amount,
      dateTime: dateTime,
      repeatOption: repeatOption,
      isRecurring: isRecurring,
      notes: notes,
      customRecurrence: customRecurrence,
      createdAt: now,
      updatedAt: now,
      isYearEndSummary: false,
    );
  }

  // Constructor for JSON serialization
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  // Computed properties
  double get absoluteAmount => amount.abs();

  bool get isPositiveCashflow => amount > 0;

  bool get isNegativeCashflow => amount < 0;

  bool get isFinancial => amount != 0;

  bool get isRepeating => repeatOption != RepeatOption.today;

  String get formattedAmount {
    final prefix = isPositiveCashflow ? '+' : '-';
    final formatter = NumberFormat("#,##0.00", "en_US");
    return '$prefix\$${formatter.format(absoluteAmount)}';
  }

  String get repeatDescription {
    return repeatOption.toString().split('.').last;
  }

  // Add helper method for recurring events
  Event copyWithNewDate(DateTime newDate) {
    return copyWith(
      dateTime: newDate,
      updatedAt: DateTime.now(),
    );
  }
}
