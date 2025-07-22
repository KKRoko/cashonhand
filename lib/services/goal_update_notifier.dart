import 'package:flutter/foundation.dart';

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
  }

  /// Notify all listeners that multiple goals may have been updated
  void notifyGoalsUpdated() {
    print("Debug: Broadcasting general goal updates");
    notifyListeners();
  }
}