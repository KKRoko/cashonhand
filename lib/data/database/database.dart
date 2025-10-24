import 'package:cash_on_hand/data/database/type_converters.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'dart:io';
import '../models/enums/delete_option.dart';
import '../models/enums/edit_option.dart';
import '../models/enums/recurring_period.dart';
import '../models/enums/repeat_option.dart';
import '../models/enums/category_type.dart';
import '../models/freezed/achievement_base_implementation.dart';
import '../models/freezed/custom_recurrence.dart';
import '../models/enums/allocation_type.dart';
import '../models/enums/trigger_type.dart';
import '../models/enums/allocation_method.dart';
import '../models/enums/bucket_type.dart';
import '/utils/event_date_utils.dart';
import '../../services/recurrence_calculation_service.dart';
import 'tables.dart';
import '../models/enums/goal_type.dart';

part 'database.g.dart';

enum UpdateType { single, allEvents, futureEvents, pastEvents }



@DriftDatabase(tables: [Categories, Events, SavingGoalsTable, Achievements, GoalAllocations, AutoAllocationRules, Budgets, CategoryBudgets])
@singleton
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _addDefaultCategories();

        await customStatement('''
          INSERT INTO categories (name, type) 
          VALUES 
            ('Salary', 'income'),
            ('Investment', 'income'),
            ('Freelance', 'income'),
            ('Food & Dining', 'expense'),
            ('Transportation', 'expense'),
            ('Housing', 'expense'),
            ('Healthcare', 'expense')
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from v1 to v2: Add allocation tables
          await m.createTable(goalAllocations);
          await m.createTable(autoAllocationRules);
          print('Database migrated to v2: Added goal allocation tables');
        }
        if (from < 3) {
          // Migration from v2 to v3: Add hierarchical categories
          await _addColumnIfNotExists('categories', 'parent_category_id', 'INTEGER REFERENCES categories(id)');
          await _addColumnIfNotExists('categories', 'icon', 'TEXT');
          await _addColumnIfNotExists('categories', 'sort_order', 'INTEGER DEFAULT 0');
          
          // Clear existing categories and add the new hierarchical structure
          await customStatement('DELETE FROM categories');
          await _addDefaultCategories();
          
          print('Database migrated to v3: Added hierarchical category support with new categories');
        }
        if (from < 4) {
          // Migration from v3 to v4: Ensure hierarchical categories are properly populated
          await customStatement('DELETE FROM categories');
          await _addDefaultCategories();

          print('Database migrated to v4: Refreshed hierarchical categories');
        }
        if (from < 5) {
          // Migration from v4 to v5: Add budget tables
          await m.createTable(budgets);
          await m.createTable(categoryBudgets);

          print('Database migrated to v5: Added budget tables');
        }
        if (from < 6) {
          // Migration from v5 to v6: Add isActive and isSystem fields to categories
          await _addColumnIfNotExists('categories', 'is_active', 'INTEGER NOT NULL DEFAULT 1');
          await _addColumnIfNotExists('categories', 'is_system', 'INTEGER NOT NULL DEFAULT 0');

          // Mark all existing categories as system categories
          await customStatement('UPDATE categories SET is_system = 1 WHERE is_system IS NULL OR is_system = 0');

          print('Database migrated to v6: Added isActive and isSystem fields to categories');
        }
        if (from < 7) {
          // Migration from v6 to v7: Add month and year fields to budgets
          await _addColumnIfNotExists('budgets', 'month', 'INTEGER');
          await _addColumnIfNotExists('budgets', 'year', 'INTEGER');

          // Set existing budgets to current month/year
          final now = DateTime.now();
          await customStatement(
            'UPDATE budgets SET month = ?, year = ? WHERE month IS NULL OR year IS NULL',
            [now.month, now.year],
          );

          print('Database migrated to v7: Added month and year fields to budgets');
        }
      },
    );
  }

  /// Helper method to safely add a column if it doesn't exist
  Future<void> _addColumnIfNotExists(String tableName, String columnName, String columnDefinition) async {
    try {
      // Try to check if column exists by querying the table info
      final result = await customSelect('PRAGMA table_info($tableName)').get();
      final columnExists = result.any((row) => row.data['name'] == columnName);
      
      if (!columnExists) {
        await customStatement('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
        print('Added column $columnName to table $tableName');
      } else {
        print('Column $columnName already exists in table $tableName, skipping');
      }
    } catch (e) {
      print('Error checking/adding column $columnName: $e');
      // Try to add the column anyway, in case the PRAGMA query failed
      try {
        await customStatement('ALTER TABLE $tableName ADD COLUMN $columnName $columnDefinition');
        print('Successfully added column $columnName to table $tableName on retry');
      } catch (retryError) {
        print('Failed to add column $columnName even on retry: $retryError');
        // If it's a duplicate column error, that's actually fine - the column exists
        if (!retryError.toString().contains('duplicate column name')) {
          rethrow;
        }
      }
    }
  }

  Future<void> updateRecurringEvents(
    EventTableData event,
    UpdateType type,
    DateTime? cutoffDate,
  ) async {
    final query = update(events);
    
    switch (type) {
      case UpdateType.single:
        await (query
          ..where((e) => e.id.equalsNullable(event.id)))
          .write(event);
        break;
      case UpdateType.allEvents:
        await (query
          ..where((e) => e.originalEventId.equalsNullable(event.originalEventId)))
          .write(event);
        break;
      case UpdateType.futureEvents:
        await (query
          ..where((e) => 
            e.originalEventId.equalsNullable(event.originalEventId) &
            e.date.isBiggerOrEqualValue(cutoffDate!)))
          .write(event);
        break;
      case UpdateType.pastEvents:
        await (query
          ..where((e) => 
            e.originalEventId.equalsNullable(event.originalEventId) &
            e.date.isSmallerOrEqualValue(cutoffDate!)))
          .write(event);
        break;
    }
  }

  Future<int> updateEventsWithOption(
    int eventId,
    EventTableData updatedEvent,
    EditOption editOption,
    DateTime cutoffDate,
  ) async {
    print('🔍 DEBUG: Database.updateEventsWithOption called with eventId: $eventId, option: $editOption');
    print('🔍 DEBUG: CutoffDate: ${cutoffDate.toIso8601String()}');

    // First, find the event to ensure it exists and get series info
    final event = await (select(events)..where((e) => e.id.equals(eventId))).getSingleOrNull();
    
    if (event == null) {
      print('⚠️ WARNING: Event with ID $eventId not found in database - cannot update');
      return 0;
    }

    final seriesId = event.originalEventId ?? event.id;
    print('🔍 DEBUG: Found event - ID: ${event.id}, OriginalID: ${event.originalEventId}, SeriesID: $seriesId');
    
    // Check if this is a recurring event that needs to be expanded into instances
    final allSeriesEvents = await (select(events)
      ..where((e) => 
        e.originalEventId.equals(seriesId) | 
        e.id.equals(seriesId)))
      .get();
    
    print('🔍 DEBUG: Found ${allSeriesEvents.length} events in series:');
    for (var evt in allSeriesEvents) {
      print('  - ID: ${evt.id}, Date: ${evt.date.toIso8601String()}, OriginalID: ${evt.originalEventId}');
    }

    // For recurring events with single records, implement smart scoped updates
    if (event.isRecurring && allSeriesEvents.length == 1 && editOption != EditOption.thisInstance) {
      return await _handleRecurringScopedUpdate(event, updatedEvent, editOption, cutoffDate);
    }

    final query = update(events);
    int updatedCount;

    // For scoped updates, we only update certain fields and preserve each event's original date
    final eventToWrite = EventsCompanion(
      title: Value(updatedEvent.title),
      categoryId: Value(updatedEvent.categoryId),
      amount: Value(updatedEvent.amount),
      // DO NOT update date - preserve each event's original date
      repeatOption: Value(updatedEvent.repeatOption),
      isRecurring: Value(updatedEvent.isRecurring),
      notes: Value(updatedEvent.notes),
      customRecurrence: Value(updatedEvent.customRecurrence),
      // DO NOT update originalEventId - preserve existing series structure
      // DO NOT update createdAt - preserve original creation time
      updatedAt: Value(DateTime.now()),
    );
    
    print('🔍 DEBUG: EventToWrite details:');
    print('  - Title: ${updatedEvent.title}');
    print('  - Amount: ${updatedEvent.amount}');
    print('  - Date: ${updatedEvent.date.toIso8601String()}');
    print('  - OriginalEventId will be preserved as: ${event.originalEventId}');

    switch (editOption) {
      case EditOption.thisInstance:
        print('🔍 DEBUG: Updating single event with ID: $eventId');
        updatedCount = await (query
          ..where((e) => e.id.equals(eventId)))
          .write(eventToWrite);
        break;

      case EditOption.allInstances:
        print('🔍 DEBUG: Updating entire series with seriesId: $seriesId');
        // Debug: show which events this will affect
        final allEventsToUpdate = await (select(events)
          ..where((e) => 
            e.originalEventId.equals(seriesId) | 
            e.id.equals(seriesId)))
          .get();
        print('🔍 DEBUG: AllInstances will update ${allEventsToUpdate.length} events:');
        for (var evt in allEventsToUpdate) {
          print('  - ID: ${evt.id}, Date: ${evt.date.toIso8601String()}');
        }
        
        updatedCount = await (query
          ..where((e) => 
            e.originalEventId.equals(seriesId) | 
            e.id.equals(seriesId)))
          .write(eventToWrite);
        break;

      case EditOption.futureInstances:
        print('🔍 DEBUG: Updating future events from series $seriesId starting from: ${cutoffDate.toIso8601String()}');
        // Debug: show which events this will affect
        final futureEventsToUpdate = await (select(events)
          ..where((e) => 
            (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
            e.date.isBiggerOrEqualValue(cutoffDate)))
          .get();
        print('🔍 DEBUG: FutureInstances will update ${futureEventsToUpdate.length} events:');
        for (var evt in futureEventsToUpdate) {
          print('  - ID: ${evt.id}, Date: ${evt.date.toIso8601String()}');
        }
        
        updatedCount = await (query
          ..where((e) => 
            (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
            e.date.isBiggerOrEqualValue(cutoffDate)))
          .write(eventToWrite);
        break;

      case EditOption.pastInstances:
        print('🔍 DEBUG: Updating past events from series $seriesId up to: ${cutoffDate.toIso8601String()}');
        // Debug: show which events this will affect
        final pastEventsToUpdate = await (select(events)
          ..where((e) => 
            (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
            e.date.isSmallerOrEqualValue(cutoffDate)))
          .get();
        print('🔍 DEBUG: PastInstances will update ${pastEventsToUpdate.length} events:');
        for (var evt in pastEventsToUpdate) {
          print('  - ID: ${evt.id}, Date: ${evt.date.toIso8601String()}');
        }
        
        updatedCount = await (query
          ..where((e) => 
            (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
            e.date.isSmallerOrEqualValue(cutoffDate)))
          .write(eventToWrite);
        break;
    }

    print('🔍 DEBUG: Update operation completed - $updatedCount events updated');
    return updatedCount;
  }

  // Handles scoped updates for recurring events without expanding all instances
  Future<int> _handleRecurringScopedUpdate(
    EventTableData originalEvent,
    EventTableData updatedEvent,
    EditOption editOption,
    DateTime cutoffDate,
  ) async {
    print('🔍 DEBUG: Handling scoped update for recurring event');
    
    switch (editOption) {
      case EditOption.allInstances:
        print('🔍 DEBUG: Updating entire recurring series');
        // Update the original event with new details
        final updateResult = await (update(events)
          ..where((e) => e.id.equals(originalEvent.id)))
          .write(EventsCompanion(
            title: Value(updatedEvent.title),
            categoryId: Value(updatedEvent.categoryId),
            amount: Value(updatedEvent.amount),
            repeatOption: Value(updatedEvent.repeatOption),
            isRecurring: Value(updatedEvent.isRecurring),
            notes: Value(updatedEvent.notes),
            customRecurrence: Value(updatedEvent.customRecurrence),
            updatedAt: Value(DateTime.now()),
          ));
        print('🔍 DEBUG: Updated recurring event, returning virtual count based on recurrence pattern');
        // Return a virtual count based on the recurrence pattern
        return _calculateVirtualUpdateCount(originalEvent, editOption, cutoffDate);
        
      case EditOption.futureInstances:
      case EditOption.pastInstances:
        print('🔍 DEBUG: Creating split events for partial scope update');
        // For future/past instances, we need to split the recurring event
        return await _splitRecurringEvent(originalEvent, updatedEvent, editOption, cutoffDate);
        
      case EditOption.thisInstance:
        // This should not reach here
        return 0;
    }
  }

  // Calculates how many virtual instances would be affected
  int _calculateVirtualUpdateCount(EventTableData event, EditOption editOption, DateTime cutoffDate) {
    // For simplicity, return a reasonable estimate
    switch (editOption) {
      case EditOption.allInstances:
        // Estimate based on recurrence pattern
        if (event.repeatOption == RepeatOption.daily) return 365; // ~1 year of daily events
        if (event.repeatOption == RepeatOption.weekly) return 52; // ~1 year of weekly events
        if (event.repeatOption == RepeatOption.monthly) return 12; // ~1 year of monthly events
        return 10; // Default estimate
      case EditOption.futureInstances:
        return 50; // Estimate of future instances
      case EditOption.pastInstances:
        return 10; // Estimate of past instances
      case EditOption.thisInstance:
        return 1;
    }
  }

  // Splits a recurring event when editing only past or future instances
  Future<int> _splitRecurringEvent(
    EventTableData originalEvent,
    EventTableData updatedEvent,
    EditOption editOption,
    DateTime cutoffDate,
  ) async {
    print('🔍 DEBUG: Splitting recurring event for scoped update');
    
    if (editOption == EditOption.futureInstances) {
      // Create a new event for future instances with updated details
      // and modify the original to end before cutoff date
      final futureEvent = EventsCompanion.insert(
        title: updatedEvent.title,
        categoryId: updatedEvent.categoryId,
        amount: updatedEvent.amount,
        date: cutoffDate,
        repeatOption: updatedEvent.repeatOption,
        isRecurring: Value(updatedEvent.isRecurring),
        notes: Value(updatedEvent.notes),
        customRecurrence: Value(updatedEvent.customRecurrence),
        originalEventId: Value(originalEvent.id),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      
      await into(events).insert(futureEvent);
      print('🔍 DEBUG: Created future event starting from cutoff date');
      return _calculateVirtualUpdateCount(originalEvent, editOption, cutoffDate);
    } else {
      // For past instances, we update the original up to cutoff date
      // and create a new event for future instances with original details
      await (update(events)
        ..where((e) => e.id.equals(originalEvent.id)))
        .write(EventsCompanion(
          title: Value(updatedEvent.title),
          categoryId: Value(updatedEvent.categoryId),
          amount: Value(updatedEvent.amount),
          notes: Value(updatedEvent.notes),
          updatedAt: Value(DateTime.now()),
        ));
      
      final futureEvent = EventsCompanion.insert(
        title: originalEvent.title,
        categoryId: originalEvent.categoryId,
        amount: originalEvent.amount,
        date: cutoffDate.add(const Duration(days: 1)),
        repeatOption: originalEvent.repeatOption,
        isRecurring: Value(originalEvent.isRecurring),
        notes: Value(originalEvent.notes),
        customRecurrence: Value(originalEvent.customRecurrence),
        originalEventId: Value(originalEvent.id),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      
      await into(events).insert(futureEvent);
      print('🔍 DEBUG: Updated past instances and created future event');
      return _calculateVirtualUpdateCount(originalEvent, editOption, cutoffDate);
    }
  }

  // Helper method to count events that would be affected by an edit operation
  Future<Map<String, int>> getEditImpactCounts(int eventId, DateTime cutoffDate) async {
    final event = await (select(events)..where((e) => e.id.equals(eventId))).getSingleOrNull();
    
    if (event == null) {
      return {'total': 0, 'future': 0, 'past': 0};
    }

    final seriesId = event.originalEventId ?? event.id;

    // Get all events in this series
    final allSeriesEvents = await (select(events)
      ..where((e) => 
        e.originalEventId.equals(seriesId) | 
        e.id.equals(seriesId)))
      .get();

    // If this is a recurring event with only one database record, calculate based on generated occurrences
    if (event.isRecurring && allSeriesEvents.length == 1) {
      final endDate = cutoffDate.add(const Duration(days: 730)); // Look ahead 2 years
      final occurrences = RecurrenceCalculationService.generateOccurrences(
        event.date,
        endDate,
        event.repeatOption,
        event.customRecurrence,
      );
      
      final futureOccurrences = occurrences.where((date) => !date.isBefore(cutoffDate)).length;
      final pastOccurrences = occurrences.where((date) => !date.isAfter(cutoffDate)).length;
      
      return {
        'total': occurrences.length,
        'future': futureOccurrences,
        'past': pastOccurrences,
      };
    }

    // For already expanded events, count actual database records
    final totalCount = allSeriesEvents.length;
    final futureCount = allSeriesEvents.where((e) => !e.date.isBefore(cutoffDate)).length;
    final pastCount = allSeriesEvents.where((e) => !e.date.isAfter(cutoffDate)).length;

    return {
      'total': totalCount,
      'future': futureCount,
      'past': pastCount,
    };
  }

List<EventsCompanion> _generateYearInstances(EventTableData source) {
  final instances = <EventsCompanion>[];
  final yearEnd = DateTime(DateTime.now().year, 12, 31);
  var currentDate = source.date;
  
  print('Generating instances for event: ${source.title}');
  print('Source event ID: ${source.id}, OriginalID: ${source.originalEventId}');
  print('Repeat option: ${source.repeatOption}');
  print('Custom recurrence: ${source.customRecurrence?.toJson()}');
  print('DEBUG - Frequency: ${source.customRecurrence?.frequency}');

  while (currentDate.isBefore(yearEnd)) {
    // Skip the first instance since it's already created
    if (currentDate != source.date) {
        instances.add(EventsCompanion(
          originalEventId: Value(source.id),
          title: Value(source.title),
          categoryId: Value(source.categoryId),
          amount: Value(source.amount),
          date: Value(currentDate),
          repeatOption: Value(source.repeatOption),
          isRecurring: const Value(true),
          notes: Value(source.notes),
          customRecurrence: Value(source.customRecurrence),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
      ));
    }

    // Get next date using the utility with the custom recurrence
    currentDate = EventDateUtils.getNextRepeatDate(
      currentDate,
      source.repeatOption,
      source.customRecurrence,
    );
  }

  print('Generated ${instances.length} instances');
  return instances;
}


  Future<void> ensureDefaultCategories() async {
    final categoryCount = await getCategoryCount();
    if (categoryCount == 0) {
      print("No categories found, adding defaults");
      await _addDefaultCategories();
    } else {
      print("Categories already exist: $categoryCount");
    }
  }

  // Categories CRUD operations
  Future<List<CategoryTableData>> getAllCategories() =>
      select(categories).get();
// Add this method to your Database class
  Future<int> getCategoryCount() async {
    try {
      print("Starting count query");
      final result =
          await customSelect('SELECT COUNT(*) as count FROM categories')
              .getSingle();
      print("Count query completed");
      return result.data['count'] as int;
    } catch (e, stackTrace) {
      print("Error in count query: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<List<CategoryTableData>> getCategories({CategoryType? type}) async {
    try {
      print("Starting category fetch in database");
      if (type == null) {
        print("Executing query for all categories");
        final result = await (select(categories)).get();
        print("Query completed, found ${result.length} categories");
        return result;
      }

      print("Executing query for category type: ${type.toString()}");
      final result = await (select(categories)
            ..where((cat) =>
                cat.type.equalsNullable(type.toString().split('.').last) |
                cat.type.equalsNullable(CategoryType.both.toString().split('.').last)))
          .get();
      print("Query completed, found ${result.length} categories");
      return result;
    } catch (e, stackTrace) {
      print("Database error in getCategories: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> _addDefaultCategories() async {
    print("Adding comprehensive hierarchical categories");

    try {
      // INCOME CATEGORIES
      final incomeId = await into(categories).insert(CategoriesCompanion.insert(
        name: 'Income',
        type: CategoryType.income,
        icon: const Value('💰'),
        sortOrder: const Value(1),
        isSystem: const Value(true),
      ));

      // Income subcategories
      final incomeSubcategories = [
        'Salary', 'Investment', 'Freelance', 'Side Business', 'Rental Income', 'Other Income'
      ];

      for (int i = 0; i < incomeSubcategories.length; i++) {
        await into(categories).insert(CategoriesCompanion.insert(
          name: incomeSubcategories[i],
          type: CategoryType.income,
          parentCategoryId: Value(incomeId),
          sortOrder: Value(i + 1),
          isSystem: const Value(true),
        ));
      }

      // MAIN EXPENSE CATEGORIES WITH SUBCATEGORIES
      await _addExpenseCategory('Living Expenses', '🏠', 1, [
        'Rent or mortgage', 'Internet', 'Cable', 'Water', 'Electricity',
        'Phone service', 'Groceries', 'Cleaning supplies', 'Personal care products',
        'Child care', 'Homeowner\'s or renter\'s insurance'
      ]);

      await _addExpenseCategory('Transportation', '🚗', 2, [
        'Car insurance', 'Car payment', 'Gas', 'Car repairs', 'Bus pass',
        'Uber/Lyft', 'Parking', 'Car maintenance', 'Registration & fees'
      ]);

      await _addExpenseCategory('Travel Expenses', '✈️', 3, [
        'Airfare', 'Transportation', 'Accommodations', 'Meals',
        'Activities', 'Travel insurance', 'Visas & documents'
      ]);

      await _addExpenseCategory('Gifts and Donations', '🎁', 4, [
        'Birthday gifts', 'Holidays', 'Weddings or anniversaries',
        'Charity donations', 'Religious donations', 'Tips'
      ]);

      await _addExpenseCategory('Pet Care', '🐕', 5, [
        'Pet insurance', 'Groomer fees', 'Veterinary care', 'Food',
        'Medications', 'Cleaning supplies', 'Toys & accessories'
      ]);

      await _addExpenseCategory('Financial Goals', '🎯', 6, [
        'Credit card payments', 'Student loan payments', 'Personal loan payments',
        'Payment plans on financed purchases', 'Emergency fund', 'Long-term savings', 'Investments'
      ]);

      await _addExpenseCategory('Entertainment', '🎬', 7, [
        'Restaurants', 'Movies', 'Concerts', 'Hobby expenses',
        'Streaming platforms', 'Magazine subscriptions', 'Gaming', 'Books'
      ]);

      await _addExpenseCategory('Clothes', '👔', 8, [
        'Work attire', 'Leisure attire', 'Children\'s clothing',
        'Dry cleaning fees', 'Laundromat fees', 'Shoes', 'Accessories'
      ]);

      await _addExpenseCategory('Health and Wellness', '⚕️', 9, [
        'Prescription medications', 'Health insurance and copays',
        'Dental insurance and copays', 'Eye insurance and copays',
        'Gym membership', 'Therapy', 'Supplements'
      ]);

      await _addExpenseCategory('Education', '📚', 10, [
        'Books', 'Tuition', 'Class fees', 'Online courses',
        'Certification fees', 'School supplies', 'Conferences'
      ]);

      print("Default categories added successfully");
    } catch (e) {
      print("Error adding default categories: $e");
      rethrow;
    }
  }

  Future<void> _addExpenseCategory(String categoryName, String icon, int sortOrder, List<String> subcategories) async {
    final categoryId = await into(categories).insert(CategoriesCompanion.insert(
      name: categoryName,
      type: CategoryType.expense,
      icon: Value(icon),
      sortOrder: Value(sortOrder),
      isSystem: const Value(true),
    ));

    for (int i = 0; i < subcategories.length; i++) {
      await into(categories).insert(CategoriesCompanion.insert(
        name: subcategories[i],
        type: CategoryType.expense,
        parentCategoryId: Value(categoryId),
        sortOrder: Value(i + 1),
        isSystem: const Value(true),
      ));
    }
  }

  Future<CategoryTableData?> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equalsNullable(id))).getSingleOrNull();

  Future<int> createCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoryTableData category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equalsNullable(id))).go();

  // Hierarchical category methods
  Future<List<CategoryTableData>> getMainCategories({CategoryType? type}) =>
      (select(categories)..where((t) => 
        t.parentCategoryId.isNull() & 
        (type != null ? t.type.equals(type.toString().split('.').last) : const Constant(true)))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Future<List<CategoryTableData>> getSubcategories(int parentId) =>
      (select(categories)..where((t) => t.parentCategoryId.equals(parentId))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Future<List<CategoryTableData>> getAllCategoriesHierarchical() =>
      (select(categories)..orderBy([
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.parentCategoryId),
      ])).get();

  // User category management
  Future<List<CategoryTableData>> getUserCategories() =>
      (select(categories)..where((t) => t.isSystem.equals(false))
      ..orderBy([(c) => OrderingTerm.asc(c.name)])).get();

  Future<List<CategoryTableData>> getSystemCategories() =>
      (select(categories)..where((t) => t.isSystem.equals(true))
      ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)])).get();

  Future<List<CategoryTableData>> getActiveCategories() =>
      (select(categories)..where((t) => t.isActive.equals(true))
      ..orderBy([
        (c) => OrderingTerm.asc(c.isSystem),  // User categories first (false < true)
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.name),
      ])).get();

  // Events CRUD operations
  Future<List<EventTableData>> getAllEvents() => select(events).get();

  Future<EventTableData?> getEventById(int id) =>
      (select(events)..where((t) => t.id.equals(id))).getSingleOrNull();

Future<EventTableData> createEvent(EventsCompanion event, {bool generateRecurring = false}) async {
   print('Creating event with customRecurrence: ${event.customRecurrence}');
   
   return await transaction(() async {
     // First, create the base event
     final id = await into(events).insert(event);
     print('Event created with ID: $id');

     // Only set originalEventId to itself if it wasn't already provided
     // (i.e., this is the first event in a series, not a recurring instance)
     if (event.originalEventId == const Value.absent()) {
       await (update(events)..where((t) => t.id.equals(id)))
        .write(EventsCompanion(originalEventId: Value(id)));
       print('Updated originalEventId for event $id');
     }
     
     // Get the final event with correct originalEventId
     final updatedEvent = await getEventById(id);
     if (updatedEvent != null) {
       print('Event after update - ID: ${updatedEvent.id}, OriginalID: ${updatedEvent.originalEventId}');
     } else {
       throw Exception('Failed to retrieve created event with ID: $id');
     }

     // Only generate recurring instances if explicitly requested
     if (event.isRecurring.value && generateRecurring) {
       // Modify the future instances generation to explicitly set originalEventId
       await _generateAndInsertFutureInstances(
         event.copyWith(
           originalEventId: Value(id),
           customRecurrence: event.customRecurrence
         ), 
         id
       );
     }
     
     return updatedEvent;
   });
}

Future<void> _generateAndInsertFutureInstances(EventsCompanion event, int originalId) async {
  print('Generating future instances with customRecurrence: ${event.customRecurrence}');
  
  final baseEvent = await getEventById(originalId);
  if (baseEvent == null) {
    print('Error: Base event with ID $originalId not found');
    return;
  }
  print('Base event retrieved with customRecurrence: ${baseEvent.customRecurrence?.toJson()}');
  
  final instances = _generateYearInstances(baseEvent)
    .where((instance) => instance.date.value != baseEvent.date); // Skip the first instance
  
  if (instances.isNotEmpty) {
    await batch((batch) {
      batch.insertAll(events, instances);
    });
  }
}
  Future<bool> updateEvent(EventTableData event) =>
      update(events).replace(event);

  Future<int> deleteEvent(int id) =>
      (delete(events)..where((t) => t.id.equalsNullable(id))).go();

  // SavingGoals CRUD operations
  Future<List<SavingGoalTableData>> getAllSavingGoals() async {
    print("Debug Database: getAllSavingGoals called");
    final goals = await (select(savingGoalsTable)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .get();
    print("Debug Database: getAllSavingGoals found ${goals.length} goals");
    return goals;
  }

  Future<SavingGoalTableData?> getSavingGoalById(int id) =>
      (select(savingGoalsTable)..where((t) => t.id.equalsNullable(id)))
          .getSingleOrNull();

  Future<int> createSavingGoal(SavingGoalsTableCompanion goal) async {
    print("Debug Database: Creating saving goal with title: ${goal.title.value}");
    final id = await into(savingGoalsTable).insert(goal);
    print("Debug Database: Goal created successfully with ID: $id");
    return id;
  }

  Future<bool> updateSavingGoal(SavingGoalTableData goal) =>
      update(savingGoalsTable).replace(goal);

  Future<int> deleteSavingGoal(int id) =>
      (delete(savingGoalsTable)..where((t) => t.id.equalsNullable(id))).go();

  // Query methods with fixed DateTime comparisons
  Future<List<SavingGoalTableData>> getActiveGoals() async {
    final goals = await (select(savingGoalsTable)
            ..where((t) => t.isCompleted.equals(false) | t.isCompleted.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();
    
    // Debug logging
    final allGoals = await select(savingGoalsTable).get();
    print("Debug Database: Total goals in database: ${allGoals.length}");
    for (final goal in allGoals) {
      print("Debug Database: Goal '${goal.title}' - isCompleted: ${goal.isCompleted}");
    }
    print("Debug Database: Active goals returned: ${goals.length}");
    
    return goals;
  }

  Future<List<SavingGoalTableData>> getOverdueGoals() =>
      (select(savingGoalsTable)
            ..where((t) =>
                t.deadlineDate.isNotNull() &
                t.deadlineDate.isSmallerThan(Constant(DateTime.now())) &
                t.isCompleted.equalsNullable(false)))
          .get();

  Future<List<AchievementTableData>> getAllAchievements() =>
      select(achievements).get();

  Future<AchievementTableData?> getAchievementById(String id) =>
      (select(achievements)..where((t) => t.id.equalsNullable(id))).getSingleOrNull();

  Future<void> createAchievement(AchievementsCompanion achievement) =>
      into(achievements).insert(achievement);

  Future<bool> updateAchievement(AchievementTableData achievement) =>
      update(achievements).replace(achievement);

  Future<int> deleteAchievement(String id) =>
      (delete(achievements)..where((t) => t.id.equalsNullable(id))).go();

  // New helper methods for recurring events
  Future<List<EventTableData>> getEventsByOriginalId(int originalId) =>
      (select(events)..where((e) => e.originalEventId.equalsNullable(originalId)))
          .get();

  Future<int> deleteEventSeries(int originalId) =>
      (delete(events)..where((e) => e.originalEventId.equalsNullable(originalId))).go();

Future<int> deleteEventsWithOption(int eventId, DeleteOption option, DateTime cutoffDate) async {
  print('🔍 DEBUG: Database.deleteEventsWithOption called with eventId: $eventId, option: $option');

  // First, try to find the event - use getSingleOrNull to avoid "No element" error
  final event = await (select(events)..where((e) => e.id.equals(eventId))).getSingleOrNull();
  
  if (event == null) {
    print('⚠️ WARNING: Event with ID $eventId not found in database - it may have already been deleted');
    return 0; // Return 0 deleted count if event doesn't exist
  }

  final seriesId = event.originalEventId ?? event.id;
  print('🔍 DEBUG: Found event - ID: ${event.id}, OriginalID: ${event.originalEventId}, SeriesID: $seriesId');

  final query = delete(events);
  int deletedCount;
  
  switch (option) {
    case DeleteOption.thisDay:
      print('🔍 DEBUG: Deleting single event with ID: $eventId');
      deletedCount = await (query..where((e) => e.id.equals(eventId))).go();
      break;
      
    case DeleteOption.allTime:
      print('🔍 DEBUG: Deleting entire series with seriesId: $seriesId');
      deletedCount = await (query..where((e) => 
        e.originalEventId.equals(seriesId) | 
        e.id.equals(seriesId)
      )).go();
      break;
      
    case DeleteOption.futureOnly:
      print('🔍 DEBUG: Deleting future events from series $seriesId starting from: ${cutoffDate.toIso8601String()}');
      deletedCount = await (query..where((e) => 
        (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
        e.date.isBiggerOrEqualValue(cutoffDate)
      )).go();
      break;
      
    case DeleteOption.pastOnly:
      print('🔍 DEBUG: Deleting past events from series $seriesId up to: ${cutoffDate.toIso8601String()}');
      deletedCount = await (query..where((e) => 
        (e.originalEventId.equals(seriesId) | e.id.equals(seriesId)) &
        e.date.isSmallerOrEqualValue(cutoffDate)
      )).go();
      break;
  }
  
  print('🔍 DEBUG: Delete operation completed - $deletedCount events deleted');
  return deletedCount;
}

// Goal Allocation CRUD operations
Future<List<GoalAllocationTableData>> getAllocationsForEvent(int eventId) =>
    (select(goalAllocations)..where((a) => a.eventId.equals(eventId))).get();

Future<List<GoalAllocationTableData>> getAllocationsForGoal(int goalId) =>
    (select(goalAllocations)..where((a) => a.goalId.equals(goalId))).get();

Future<int> createGoalAllocation(GoalAllocationsCompanion allocation) =>
    into(goalAllocations).insert(allocation);

Future<bool> updateGoalAllocation(GoalAllocationTableData allocation) =>
    update(goalAllocations).replace(allocation);

Future<int> deleteGoalAllocation(int allocationId) =>
    (delete(goalAllocations)..where((a) => a.id.equals(allocationId))).go();

// Auto Allocation Rules CRUD operations
Future<List<AutoAllocationRuleTableData>> getActiveAllocationRules() =>
    (select(autoAllocationRules)..where((r) => r.isActive.equals(true))).get();

Future<List<AutoAllocationRuleTableData>> getAllAllocationRules() =>
    select(autoAllocationRules).get();

Future<List<AutoAllocationRuleTableData>> getAllocationRulesForGoal(int goalId) =>
    (select(autoAllocationRules)..where((r) => r.goalId.equals(goalId))).get();

Future<int> createAllocationRule(AutoAllocationRulesCompanion rule) =>
    into(autoAllocationRules).insert(rule);

Future<bool> updateAllocationRule(AutoAllocationRuleTableData rule) =>
    update(autoAllocationRules).replace(rule);

Future<int> deleteAllocationRule(int ruleId) =>
    (delete(autoAllocationRules)..where((r) => r.id.equals(ruleId))).go();

// Helper method already exists above - removed duplicate

// Round-up specific methods
Future<List<GoalAllocationTableData>> getRoundUpAllocations({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final query = select(goalAllocations)
    ..where((a) => a.allocationType.equals(AllocationType.roundUp.toString()));
    
  if (startDate != null || endDate != null) {
    // Join with events table to filter by event date
    final joinQuery = select(goalAllocations)
      .join([
        innerJoin(events, events.id.equalsExp(goalAllocations.eventId)),
      ])
      ..where(goalAllocations.allocationType.equals(AllocationType.roundUp.toString()));
      
    if (startDate != null) {
      joinQuery.where(events.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      joinQuery.where(events.date.isSmallerOrEqualValue(endDate));
    }
    
    final results = await joinQuery.get();
    return results.map((row) => row.readTable(goalAllocations)).toList();
  }
  
  return await query.get();
}

// Analytics methods for achievements and advanced analytics
Future<List<GoalAllocationTableData>> getAllocationsInRange(DateTime start, DateTime end) =>
    (select(goalAllocations)
      ..where((a) => a.createdAt.isBetweenValues(start, end))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
    .get();

Future<List<GoalAllocationTableData>> getRoundUpAllocationsInRange(DateTime start, DateTime end) =>
    (select(goalAllocations)
      ..where((a) => 
        a.createdAt.isBetweenValues(start, end) &
        a.allocationType.equals(AllocationType.roundUp.toString().split('.').last))
      ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
    .get();

Future<Map<String, double>> getSpendingByCategory(DateTime start, DateTime end) async {
  final query = '''
    SELECT c.name, SUM(ABS(e.amount)) as total
    FROM events e
    JOIN categories c ON e.category_id = c.id
    WHERE e.date BETWEEN ? AND ?
      AND e.amount < 0
    GROUP BY c.name
    ORDER BY total DESC
  ''';
  
  final results = await customSelect(
    query,
    variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
  ).get();
  
  return Map.fromEntries(
    results.map((row) => MapEntry(
      row.data['name'] as String,
      row.data['total'] as double,
    )),
  );
}

// Budget CRUD operations
Future<BudgetTableData?> getActiveBudget() =>
    (select(budgets)..where((b) => b.isActive.equals(true))).getSingleOrNull();

Future<BudgetTableData?> getBudgetById(int id) =>
    (select(budgets)..where((b) => b.id.equals(id))).getSingleOrNull();

Future<BudgetTableData?> getBudgetByMonth(int month, int year) =>
    (select(budgets)..where((b) => b.month.equals(month) & b.year.equals(year))).getSingleOrNull();

Future<int> createBudget(BudgetsCompanion budget) =>
    into(budgets).insert(budget);

Future<bool> updateBudget(BudgetsCompanion budget) =>
    update(budgets).replace(budget);

Future<void> deactivateAllBudgets() async {
  await (update(budgets)
    ..where((b) => b.isActive.equals(true)))
    .write(const BudgetsCompanion(isActive: Value(false)));
}

// CategoryBudget CRUD operations
Future<List<Map<String, dynamic>>> getCategoryBudgets(int budgetId) async {
  final query = await customSelect(
    '''
    SELECT cb.*, c.name as category_name
    FROM category_budgets cb
    LEFT JOIN categories c ON cb.category_id = c.id
    WHERE cb.budget_id = ?
    ORDER BY c.name
    ''',
    variables: [Variable.withInt(budgetId)],
    readsFrom: {categoryBudgets, categories},
  ).get();

  return query.map((row) => row.data).toList();
}

Future<List<Map<String, dynamic>>> getCategoryBudgetsByBucket(int budgetId, BucketType bucketType) async {
  final bucketString = bucketType.toString().split('.').last;
  final query = await customSelect(
    '''
    SELECT cb.*, c.name as category_name
    FROM category_budgets cb
    LEFT JOIN categories c ON cb.category_id = c.id
    WHERE cb.budget_id = ? AND cb.bucket_type = ?
    ORDER BY c.name
    ''',
    variables: [Variable.withInt(budgetId), Variable.withString(bucketString)],
    readsFrom: {categoryBudgets, categories},
  ).get();

  return query.map((row) => row.data).toList();
}

Future<int> createCategoryBudget(CategoryBudgetsCompanion categoryBudget) =>
    into(categoryBudgets).insert(categoryBudget);

Future<bool> updateCategoryBudget(CategoryBudgetsCompanion categoryBudget) =>
    update(categoryBudgets).replace(categoryBudget);

Future<int> deleteCategoryBudget(int categoryBudgetId) =>
    (delete(categoryBudgets)..where((cb) => cb.id.equals(categoryBudgetId))).go();

// Clean up category budgets that reference income categories (migration/fix)
Future<int> deleteIncomeCategoryBudgets() async {
  // First, get all income category IDs
  final incomeCategories = await (select(categories)
    ..where((c) => c.type.equals('income'))
  ).get();

  final incomeCategoryIds = incomeCategories.map((c) => c.id).toList();

  if (incomeCategoryIds.isEmpty) {
    return 0;
  }

  // Delete category budgets that reference these income categories
  return await (delete(categoryBudgets)
    ..where((cb) => cb.categoryId.isIn(incomeCategoryIds))
  ).go();
}

// Budget spending analysis methods
Future<Map<int, double>> getActualSpendingByCategory(DateTime start, DateTime end) async {
  final query = '''
    SELECT category_id, SUM(ABS(amount)) as total
    FROM events
    WHERE date BETWEEN ? AND ?
      AND amount < 0
    GROUP BY category_id
  ''';

  final results = await customSelect(
    query,
    variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
  ).get();

  return Map.fromEntries(
    results.map((row) => MapEntry(
      row.data['category_id'] as int,
      row.data['total'] as double,
    )),
  );
}

Future<Map<String, double>> getActualSpendingByBucket(int budgetId, DateTime start, DateTime end) async {
  final query = '''
    SELECT cb.bucket_type, SUM(ABS(e.amount)) as total
    FROM events e
    JOIN category_budgets cb ON e.category_id = cb.category_id
    WHERE cb.budget_id = ?
      AND e.date BETWEEN ? AND ?
      AND e.amount < 0
    GROUP BY cb.bucket_type
  ''';

  final results = await customSelect(
    query,
    variables: [
      Variable.withInt(budgetId),
      Variable.withDateTime(start),
      Variable.withDateTime(end),
    ],
  ).get();

  return Map.fromEntries(
    results.map((row) => MapEntry(
      row.data['bucket_type'] as String,
      row.data['total'] as double,
    )),
  );
}

Future<Map<String, double>> getAllocationsByType(DateTime start, DateTime end) async {
  final query = '''
    SELECT allocation_type, SUM(amount) as total
    FROM goal_allocations
    WHERE created_at BETWEEN ? AND ?
    GROUP BY allocation_type
    ORDER BY total DESC
  ''';
  
  final results = await customSelect(
    query,
    variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
  ).get();
  
  return Map.fromEntries(
    results.map((row) => MapEntry(
      row.data['allocation_type'] as String,
      row.data['total'] as double,
    )),
  );
}

Future<List<Map<String, dynamic>>> getVelocityData(DateTime start, DateTime end) async {
  final query = '''
    SELECT 
      DATE(ga.created_at) as date,
      SUM(ga.amount) as daily_total,
      COUNT(ga.id) as allocation_count
    FROM goal_allocations ga
    WHERE ga.created_at BETWEEN ? AND ?
    GROUP BY DATE(ga.created_at)
    ORDER BY DATE(ga.created_at) ASC
  ''';
  
  final results = await customSelect(
    query,
    variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
  ).get();
  
  return results.map((row) => {
    'date': row.data['date'] as String,
    'daily_total': row.data['daily_total'] as double,
    'allocation_count': row.data['allocation_count'] as int,
  }).toList();
}

// Add missing method for events in date range
Future<List<EventTableData>> getEventsForRange(DateTime start, DateTime end) =>
  (select(events)..where((e) => e.date.isBetweenValues(start, end))).get();

static LazyDatabase _openConnection() {  return LazyDatabase(() async {
    try {
      print("Starting database connection");
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      print("Database path: ${file.path}");

      // Check if file exists
      if (!await file.exists()) {
        print("Creating new database file");
        await file.create(recursive: true);
      }

      print("Opening database connection");
      final db = NativeDatabase(file, setup: (db) {
        // Set pragmas for better performance
        db.execute('PRAGMA foreign_keys = ON');
        db.execute('PRAGMA journal_mode = WAL');
      });
      print("Database connection established");
      return db;
    } catch (e, stackTrace) {
      print("Error opening database: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  });
}
}