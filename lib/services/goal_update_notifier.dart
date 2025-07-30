import 'package:flutter/foundation.dart';
import '../core/di/injection.dart';
import 'achievement_service.dart';

/// Simple event notifier to broadcast when goals are updated
/// This allows different parts of the app to react to goal changes
class GoalUpdateNotifier extends ChangeNotifier {
  static final GoalUpdateNotifier _instance = GoalUpdateNotifier._internal();
  factory GoalUpdateNotifier() => _instance;
  GoalUpdateNotifier._internal();

  /// Notify all listeners that a goal's progress has been updated
  void notifyGoalUpdated(int goalId, double newAmount) {
    print("Debug: Broadcasting goal update - Goal $goalId updated to \$${newAmount.toStringAsFixed(2)}");
    notifyListeners();
    
    // Trigger achievement checking when goal is updated
    _checkAchievements();
  }

  /// Notify all listeners that multiple goals may have been updated
  void notifyGoalsUpdated() {
    print("Debug: Broadcasting general goal updates");
    notifyListeners();
    
    // Trigger achievement checking when goals are updated
    _checkAchievements();
  }
  
  /// Check achievements asynchronously without blocking UI
  void _checkAchievements() {
    try {
      print("🏆 GOAL UPDATE: Triggering achievement check...");
      final achievementService = getIt<AchievementService>();
      
      // Run achievement checking in the background with a small delay
      // to ensure goal data has been fully updated
      Future.delayed(const Duration(milliseconds: 500), () async {
        try {
          print("🏆 GOAL UPDATE: Running delayed achievement check to ensure fresh data...");
          await achievementService.checkAchievements();
        } catch (e) {
          print("❌ GOAL UPDATE: Achievement checking failed: $e");
        }
      });
    } catch (e) {
      print("❌ GOAL UPDATE: Failed to get achievement service: $e");
    }
  }
}