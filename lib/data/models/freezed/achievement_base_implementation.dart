import 'package:freezed_annotation/freezed_annotation.dart';


part 'achievement_base_implementation.freezed.dart';
part 'achievement_base_implementation.g.dart';

enum AchievementType {
  savingMilestone,
  streak,
  yearEndTarget,
  customGoal,
  // New allocation-focused achievements
  allocationConsistency,
  multiGoalSaver,
  roundUpMaster,
  smartAllocator,
  goalCompleter,
  savingsStreak,
  weeklyHabit,
  monthlyChampion,
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
    // Enhanced fields for gamification
    @Default('🏆') String emoji,
    @Default('gold') String badgeColor,
    @Default(100) int points,
    @Default(1) int tier, // 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
    @Default([]) List<String> celebrationMessages,
    String? shareText,
    Map<String, dynamic>? metadata,
  }) = _Achievement;

  const Achievement._();

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);

  /// Get tier name based on tier number
  String get tierName {
    switch (tier) {
      case 1: return 'Bronze';
      case 2: return 'Silver'; 
      case 3: return 'Gold';
      case 4: return 'Platinum';
      default: return 'Bronze';
    }
  }

  /// Get tier color based on tier
  String get tierColor {
    switch (tier) {
      case 1: return '#CD7F32'; // Bronze
      case 2: return '#C0C0C0'; // Silver
      case 3: return '#FFD700'; // Gold
      case 4: return '#E5E4E2'; // Platinum
      default: return '#CD7F32';
    }
  }

  /// Get default share text
  String get defaultShareText {
    return shareText ?? 
           'Just unlocked the "$title" achievement in my savings journey! 💪 $emoji';
  }

  /// Check if achievement is completed
  bool get isCompleted => progress >= 100.0 || isUnlocked;

  /// Get random celebration message
  String get celebrationMessage {
    if (celebrationMessages.isEmpty) {
      return 'Congratulations on unlocking $title!';
    }
    final index = DateTime.now().millisecondsSinceEpoch % celebrationMessages.length;
    return celebrationMessages[index];
  }
}



