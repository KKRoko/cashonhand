import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../data/database/database.dart';
import '../state/category_notifier.dart';
import '../state/event_notifier.dart';
import '../state/saving_goal_notifier.dart';
import '../state/achievement_state.dart';
import '../state/budget_notifier.dart';

@injectable
class SettingsService {
  final Database _database;
  final EventNotifier _eventNotifier;
  final CategoryNotifier _categoryNotifier;
  final SavingGoalNotifier _savingGoalNotifier;
  final AchievementNotifier _achievementNotifier;
  final BudgetNotifier _budgetNotifier;

  SettingsService(
    this._database,
    this._eventNotifier,
    this._categoryNotifier,
    this._savingGoalNotifier,
    this._achievementNotifier,
    this._budgetNotifier,
  );

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    return ThemeMode.system;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Theme persistence logic here
  }

  /// Resets all application data to initial state
  Future<void> resetAllData() async {
    try {
      // Clear state first and prevent reloading
      await _eventNotifier.clearState();
      _budgetNotifier.clearState();

      // Delete all data in a transaction
      await _database.transaction(() async {
        await _database.delete(_database.events).go();
        await _database.delete(_database.categories).go();
        await _database.delete(_database.savingGoalsTable).go();
        await _database.delete(_database.achievements).go();
        await _database.delete(_database.budgets).go();
        await _database.delete(_database.categoryBudgets).go();
        await _database.delete(_database.allocationTemplates).go();
      });

      // Run WAL checkpoint after transaction is complete
      await Future.delayed(const Duration(milliseconds: 100));
      await _database.customStatement('PRAGMA busy_timeout = 5000');
      await _database.customStatement('PRAGMA wal_checkpoint(RESTART)');

      // Add default categories in a new transaction
      await _database.transaction(() async {
        await _database.ensureDefaultCategories();
      });

      // Final checkpoint after all operations
      await Future.delayed(const Duration(milliseconds: 100));
      await _database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

      // Reload all state notifiers
      await _categoryNotifier.loadCategories();
      await _eventNotifier.loadInitialEvents();
      await _savingGoalNotifier.loadGoals();
      await _achievementNotifier.reload();
      await _budgetNotifier.loadActiveBudget(); // Will find no budget and clear state
    } catch (e, stackTrace) {
      print("Error during reset: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }
}
