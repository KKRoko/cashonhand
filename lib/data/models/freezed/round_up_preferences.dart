import 'package:freezed_annotation/freezed_annotation.dart';

part 'round_up_preferences.freezed.dart';
part 'round_up_preferences.g.dart';

enum RoundUpStrategy {
  nearestDollar,
  nearestFive,
  nearestTen,
  custom,
}

@freezed
class RoundUpPreferences with _$RoundUpPreferences {
  const factory RoundUpPreferences({
    @Default(false) bool isEnabled,
    @Default(RoundUpStrategy.nearestDollar) RoundUpStrategy strategy,
    double? customMultiplier,
    int? defaultGoalId,
    @Default(0.01) double minimumRoundUp,
    @Default(10.00) double maximumRoundUp,
    @Default([]) List<int> excludedCategoryIds,
    @Default(true) bool onlyOnExpenses,
    @Default(true) bool autoSelectGoal,
  }) = _RoundUpPreferences;

  factory RoundUpPreferences.fromJson(Map<String, dynamic> json) =>
      _$RoundUpPreferencesFromJson(json);
}