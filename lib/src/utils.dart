// utils.dart
import 'package:cash_on_hand/src/home/event_model.dart';


class Event {
  final String title;
  final double? amount;
  final bool isPositiveCashflow;
  final bool isNegativeCashflow;
  final CustomRecurrence? customRecurrence;

  Event({
    required this.title,
    this.amount,
    required this.isPositiveCashflow,
    required this.isNegativeCashflow,
    this.customRecurrence,
  });

  @override
  String toString() => title;
}