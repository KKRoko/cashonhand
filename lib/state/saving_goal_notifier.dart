import 'package:flutter/widgets.dart';
import 'dart:collection';
import '../data/models/freezed/saving_goal.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../services/saving_goal_service.dart';
import '../services/goal_update_notifier.dart';

class SavingGoalNotifier extends ChangeNotifier {
  final List<SavingGoal> _goals = [];
  final SavingGoalService _service;
  bool _isLoading = false;
  String? _error;

  SavingGoalNotifier(this._service) {
    // Listen for goal updates from transactions
    _setupGoalUpdateListener();
  }

  void _setupGoalUpdateListener() {
    GoalUpdateNotifier().addListener(_handleGoalUpdate);
  }

  void _handleGoalUpdate() {
    print('Debug Notifier: Received goal update notification - refreshing goals');
    // Use postFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadGoals();
    });
  }

  @override
  void dispose() {
    GoalUpdateNotifier().removeListener(_handleGoalUpdate);
    super.dispose();
  }

  // Getters
  UnmodifiableListView<SavingGoal> get goals => UnmodifiableListView(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load goals from storage with real-time progress
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Debug Notifier: Loading goals with real-time progress');
      final result = await _service.getGoalsWithRealTimeProgress();
      result.fold(
        (failure) {
          _error = 'Failed to load saving goals: ${failure.message}';
          print('Debug Notifier: Failed to load goals - ${failure.message}');
        },
        (loadedGoals) {
          _goals.clear();
          _goals.addAll(loadedGoals);
          print('Debug Notifier: Loaded ${loadedGoals.length} goals with real-time progress');
          for (final goal in loadedGoals) {
            print('  - ${goal.title}: \$${goal.currentAmount.toStringAsFixed(2)}/\$${goal.targetAmount.toStringAsFixed(2)} (${(goal.progressPercentage * 100).toInt()}%)');
          }
        },
      );
    } catch (e) {
      _error = 'Failed to load saving goals: ${e.toString()}';
      print('Debug Notifier: Exception during goal loading - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new goal
  Future<void> addGoal(SavingGoal goal) async {
    _error = null;
    print("Debug Notifier: addGoal called for: ${goal.title}");
    
    final result = await _service.addGoal(goal);
    result.fold(
      (failure) {
        _error = 'Failed to add goal: ${failure.message}';
        print("Debug Notifier: addGoal failed - ${failure.message}");
        notifyListeners();
      },
      (id) {
        print("Debug Notifier: addGoal succeeded with ID: $id");
        final goalWithId = goal.copyWith(id: id);
        _goals.add(goalWithId);
        notifyListeners();
      }
    );
  }

  // Update existing goal
  Future<void> updateGoal(SavingGoal updatedGoal) async {
    _error = null;
    try {
      await _service.updateGoal(updatedGoal);
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal: ${e.toString()}';
      notifyListeners();
    }
  }

  // Delete goal
  Future<void> deleteGoal(int id) async {  // Changed from String to int
    _error = null;
  try {
      await _service.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete goal: ${e.toString()}';
      notifyListeners();
    }
  }

  // Update goal progress
  Future<void> updateGoalProgress(String id, double amount) async {
    _error = null;
    try {
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        final goal = _goals[index];
        final updatedGoal = goal.copyWith(
          currentAmount: goal.currentAmount + amount,
        );
        await _service.updateGoal(updatedGoal);
        _goals[index] = updatedGoal;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal progress: ${e.toString()}';
      notifyListeners();
    }
  }

  // Get total saved across all goals
  double getTotalSaved() {
    return _goals.fold(0, (sum, goal) => sum + goal.currentAmount);
  }

  // Get total targets
  double getTotalTargets() {
    return _goals.fold(0, (sum, goal) => sum + goal.targetAmount);
  }

  // Get average progress percentage
  double getAverageProgress() {
    if (_goals.isEmpty) return 0;
    final total = _goals.fold(0.0, (sum, goal) => 
      sum + (goal.currentAmount / goal.targetAmount)
    );
    return total / _goals.length;
  }

  // Get monthly savings rate based on recent history
  double getMonthlyRate() {
    // Implement based on your tracking logic
    // This could use event history or a separate savings tracking system
    return _goals.fold(0.0, (sum, goal) => 
      sum + (goal.currentAmount / 
        (DateTime.now().difference(goal.createdAt).inDays / 30))
    );
  }
DateTime getProjectedCompletion() {
    if (_goals.isEmpty) return DateTime.now();
    
    final monthlyRate = getMonthlyRate();
    // Guard against zero or negative rates
    if (monthlyRate <= 0) return DateTime.now().add(const Duration(days: 365));

    final remainingTotal = getTotalTargets() - getTotalSaved();
    // Guard against zero remaining total
    if (remainingTotal <= 0) return DateTime.now();

    final monthsNeeded = remainingTotal / monthlyRate;
    // Guard against infinite or NaN results
    if (monthsNeeded.isInfinite || monthsNeeded.isNaN) {
      return DateTime.now().add(const Duration(days: 365));
    }
    
    // Ensure the days calculation doesn't exceed maximum integer value
    final days = (monthsNeeded * 30).clamp(0, 365 * 10).round();
    return DateTime.now().add(Duration(days: days));
  }

  // Get historical savings rate
  double getHistoricalRate() {
    if (_goals.isEmpty) return 0;
    
    final oldestGoal = _goals.reduce((a, b) => 
      a.createdAt.isBefore(b.createdAt) ? a : b
    );
    
    final monthsSinceStart = DateTime.now()
        .difference(oldestGoal.createdAt)
        .inDays / 30;
        
    return getTotalSaved() / monthsSinceStart;
  }

  // Force refresh goals with real-time progress
  Future<void> refreshGoalsWithRealTimeProgress() async {
    print('Debug Notifier: Manual refresh requested');
    await loadGoals();
  }

  // Get allocation history for a specific goal
  Future<List<GoalAllocationHistory>> getGoalAllocationHistory(int goalId) async {
    final result = await _service.getGoalAllocationHistory(goalId);
    return result.fold(
      (failure) {
        print('Debug Notifier: Failed to load allocation history - ${failure.message}');
        return [];
      },
      (history) {
        print('Debug Notifier: Loaded ${history.length} allocation history entries for goal $goalId');
        return history;
      },
    );
  }

  // Sync a specific goal's progress with its allocations
  Future<void> syncGoalProgress(int goalId) async {
    final result = await _service.syncGoalProgressWithAllocations(goalId);
    result.fold(
      (failure) {
        print('Debug Notifier: Failed to sync goal progress - ${failure.message}');
        _error = 'Failed to sync goal progress: ${failure.message}';
      },
      (success) {
        print('Debug Notifier: Successfully synced goal $goalId progress');
        // Refresh goals to show updated progress
        loadGoals();
      },
    );
  }
}
