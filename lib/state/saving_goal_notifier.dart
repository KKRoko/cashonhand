import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../data/models/freezed/saving_goal.dart';
import '../services/saving_goal_service.dart';

class SavingGoalNotifier extends ChangeNotifier {
  final List<SavingGoal> _goals = [];
  final SavingGoalService _service;
  bool _isLoading = false;
  String? _error;

  SavingGoalNotifier(this._service);

  // Getters
  UnmodifiableListView<SavingGoal> get goals => UnmodifiableListView(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load goals from storage
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedGoals = await _service.getGoals();
      _goals.clear();
      _goals.addAll(loadedGoals);
    } catch (e) {
      _error = 'Failed to load saving goals: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new goal
  Future<void> addGoal(SavingGoal goal) async {
    _error = null;
    try {
      await _service.addGoal(goal);
      _goals.add(goal);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add goal: ${e.toString()}';
      notifyListeners();
    }
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
  Future<void> deleteGoal(String id) async {
    _error = null;
    try {
      await _service.deleteGoal(id as int);
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
}
