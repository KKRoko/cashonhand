import 'package:freezed_annotation/freezed_annotation.dart';
import 'round_up_preferences.dart';

part 'round_up_calculation.freezed.dart';
part 'round_up_calculation.g.dart';

@freezed
class RoundUpCalculation with _$RoundUpCalculation {
  const factory RoundUpCalculation({
    required double originalAmount,
    required double roundUpAmount,
    required double roundedTotal,
    required RoundUpStrategy strategyUsed,
    @Default(true) bool isApplicable,
    @Default('') String reason,
  }) = _RoundUpCalculation;

  factory RoundUpCalculation.fromJson(Map<String, dynamic> json) =>
      _$RoundUpCalculationFromJson(json);
}