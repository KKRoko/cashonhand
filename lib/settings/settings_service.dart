import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../data/database/database.dart';
import '../state/category_notifier.dart';
import '../state/event_notifier.dart';

@injectable
class SettingsService {
  final Database _database;
  final EventNotifier _eventNotifier;
  final CategoryNotifier _categoryNotifier;

  SettingsService(
    this._database,
    this._eventNotifier,
    this._categoryNotifier,
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
      print("Starting database reset");
      
      // Step 1: Clear state first and prevent reloading
      print("Clearing state management");
      _eventNotifier.clearState();
      
      // Step 2: Delete all data in a transaction
      await _database.transaction(() async {
        print("Deleting all data...");
        
        await _database.delete(_database.events).go();
        await _database.delete(_database.categories).go();
        await _database.delete(_database.savingGoalsTable).go();
        await _database.delete(_database.achievements).go();
      });
      
      // Step 3: Run WAL checkpoint after transaction is complete
      print("Running WAL checkpoint...");
      await Future.delayed(Duration(milliseconds: 100)); // Give time for transaction to fully close
      await _database.customStatement('PRAGMA busy_timeout = 5000');
      await _database.customStatement('PRAGMA wal_checkpoint(RESTART)');
      
      // Step 4: Add default categories in a new transaction
      await _database.transaction(() async {
        print("Reinitializing default categories...");
        await _database.ensureDefaultCategories();
      });
      
      // Step 5: Final checkpoint after all operations
      print("Running final checkpoint...");
      await Future.delayed(Duration(milliseconds: 100));
      await _database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
      
      // Step 6: Verify database state
      final eventCount = await _database.events.count().getSingle();
      final categoryCount = await _database.getCategoryCount();
      print("Database state - Events: $eventCount, Categories: $categoryCount");

      // Step 7: Reload state
      print("Reloading state management");
      await _categoryNotifier.loadCategories();
      await _eventNotifier.loadInitialEvents();
      
      print("Reset complete");
    } catch (e, stackTrace) {
      print("Error during reset: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }
}
