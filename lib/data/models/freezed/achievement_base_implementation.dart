import 'package:freezed_annotation/freezed_annotation.dart';


part 'achievement_base_implementation.freezed.dart';
part 'achievement_base_implementation.g.dart';

enum AchievementType {
  savingMilestone,
  streak,
  yearEndTarget,
  customGoal
}

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required double targetAmount,
    @Default(false) bool isUnlocked,
    @Default(0.0) double progress,
    DateTime? unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}



