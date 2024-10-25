import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../enums/repeat_option.dart';
import 'custom_recurrence.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  // Private constructor to force using factory constructors
  const Event._();

  const factory Event({
    required String id,
    required String title,
    double? amount,
    required bool isPositiveCashflow,
    required bool isNegativeCashflow,
    required RepeatOption repeatOption,
    CustomRecurrence? customRecurrence,
    required DateTime createdAt,
    @Default(true) bool isYearEndSummary,
    required DateTime dateTime,
  }) = _Event;

  // Named constructor for creating new events
  factory Event.create({
    required String title,
    double? amount,
    required bool isPositiveCashflow,
    required bool isNegativeCashflow,
    required RepeatOption repeatOption,
    CustomRecurrence? customRecurrence,
    required DateTime dateTime,
    bool isYearEndSummary = true,
  }) {
    return Event(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      isPositiveCashflow: isPositiveCashflow,
      isNegativeCashflow: isNegativeCashflow,
      repeatOption: repeatOption,
      customRecurrence: customRecurrence,
      createdAt: DateTime.now(),
      isYearEndSummary: isYearEndSummary,
      dateTime: dateTime,
    );
  }

  // Constructor for JSON serialization
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  // Computed properties
  double? get absoluteAmount => amount?.abs();



  bool get isFinancial => amount != null;

  bool get isRepeating => repeatOption != RepeatOption.today;

  String? get formattedAmount {
    if (amount == null) return null;
    final prefix = isPositiveCashflow ? '+' : '-';
    return '$prefix\$${absoluteAmount?.toStringAsFixed(2)}';
  }

  String get repeatDescription {

    return repeatOption.toString().split('.').last;
  }
}