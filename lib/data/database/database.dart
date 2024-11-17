import 'package:cash_on_hand/data/database/type_converters.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'dart:io';
import '../models/enums/delete_option.dart';
import '../models/enums/recurring_period.dart';
import '../models/enums/repeat_option.dart';
import '../models/enums/category_type.dart';
import '../models/freezed/achievement_base_implementation.dart';
import '../models/freezed/custom_recurrence.dart';
import '/utils/event_date_utils.dart';
import 'tables.dart';
import '../models/enums/goal_type.dart';

part 'database.g.dart';

enum UpdateType { single, allEvents, futureEvents, pastEvents }



@DriftDatabase(tables: [Categories, Events, SavingGoalsTable, Achievements])
@singleton
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
    );
  }

  Future<void> createRecurringEvent(EventsCompanion event) async {
    final id = await into(events).insert(event);
    final baseEvent = await getEventById(id);
    final instances = _generateYearInstances(baseEvent);
    await batch((batch) {
      batch.insertAll(events, instances);
    });
  }

  Future<void> updateRecurringEvents(
    EventTableData event,
    UpdateType type,
    DateTime? cutoffDate,
  ) async {
    final query = update(events);
    
    switch (type) {
      case UpdateType.single:
        await query
          ..where((e) => e.id.equalsNullable(event.id))
          ..write(event);
        break;
      case UpdateType.allEvents:
        await query
          ..where((e) => e.originalEventId.equalsNullable(event.originalEventId))
          ..write(event);
        break;
      case UpdateType.futureEvents:
        await query
          ..where((e) => 
            e.originalEventId.equalsNullable(event.originalEventId) &
            e.date.isBiggerOrEqualValue(cutoffDate!)
          )
          ..write(event);
        break;
      case UpdateType.pastEvents:
        await query
          ..where((e) => 
            e.originalEventId.equalsNullable(event.originalEventId) &
            e.date.isSmallerOrEqualValue(cutoffDate!)
          )
          ..write(event);
        break;
    }
  }

  List<EventsCompanion> _generateYearInstances(EventTableData source) {
    final instances = <EventsCompanion>[];
    final yearEnd = DateTime(DateTime.now().year, 12, 31);
    var currentDate = source.date;

    while (currentDate.isBefore(yearEnd)) {
      instances.add(EventsCompanion(
        originalEventId: Value(source.id),
        title: Value(source.title),
        categoryId: Value(source.categoryId),
        amount: Value(source.amount),
        date: Value(currentDate),
        repeatOption: Value(source.repeatOption),
        isRecurring: Value(source.isRecurring),
        notes: Value(source.notes),
        customRecurrence: Value(source.customRecurrence),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
      currentDate = EventDateUtils.getNextRepeatDate(
        currentDate, 
        source.repeatOption,
        source.customRecurrence
      );
    }
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
    print("Adding default categories");

    // Default income categories
    final defaultIncomeCategories = [
      CategoriesCompanion.insert(
        name: 'Salary',
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        name: 'Investment',
        type: CategoryType.income,
      ),
      CategoriesCompanion.insert(
        name: 'Freelance',
        type: CategoryType.income,
      ),
    ];

    // Default expense categories
    final defaultExpenseCategories = [
      CategoriesCompanion.insert(
        name: 'Food & Dining',
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        name: 'Transportation',
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        name: 'Housing',
        type: CategoryType.expense,
      ),
      CategoriesCompanion.insert(
        name: 'Healthcare',
        type: CategoryType.expense,
      ),
    ];

    try {
      // Insert income categories
      for (final category in defaultIncomeCategories) {
        await into(categories).insert(category);
      }

      // Insert expense categories
      for (final category in defaultExpenseCategories) {
        await into(categories).insert(category);
      }

      print("Default categories added successfully");
    } catch (e) {
      print("Error adding default categories: $e");
      rethrow;
    }
  }

  Future<CategoryTableData> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equalsNullable(id))).getSingle();

  Future<int> createCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> updateCategory(CategoryTableData category) =>
      update(categories).replace(category);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equalsNullable(id))).go();

  // Events CRUD operations
  Future<List<EventTableData>> getAllEvents() => select(events).get();

  Future<EventTableData> getEventById(int id) =>
      (select(events)..where((t) => t.id.equalsNullable(id))).getSingle();

  Future<int> createEvent(EventsCompanion event) => into(events).insert(event);

  Future<bool> updateEvent(EventTableData event) =>
      update(events).replace(event);

  Future<int> deleteEvent(int id) =>
      (delete(events)..where((t) => t.id.equalsNullable(id))).go();

  // SavingGoals CRUD operations
  Future<List<SavingGoalTableData>>
      getAllSavingGoals() => (select(savingGoalsTable)
            ..orderBy([
              (t) =>
                  OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
            ]))
          .get();

  Future<SavingGoalTableData?> getSavingGoalById(int id) =>
      (select(savingGoalsTable)..where((t) => t.id.equalsNullable(id)))
          .getSingleOrNull();

  Future<int> createSavingGoal(SavingGoalsTableCompanion goal) =>
      into(savingGoalsTable).insert(goal);

  Future<bool> updateSavingGoal(SavingGoalTableData goal) =>
      update(savingGoalsTable).replace(goal);

  Future<int> deleteSavingGoal(int id) =>
      (delete(savingGoalsTable)..where((t) => t.id.equalsNullable(id))).go();

  // Query methods with fixed DateTime comparisons
  Future<List<SavingGoalTableData>> getActiveGoals() =>
      (select(savingGoalsTable)
            ..where((t) => t.isCompleted.equalsNullable(false))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

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
  final query = delete(events);
  
  switch (option) {
    case DeleteOption.thisDay:
      return (query..where((e) => e.id.equalsNullable(eventId))).go();
      
    case DeleteOption.allTime:
      final event = await (select(events)..where((e) => e.id.equalsNullable(eventId))).getSingle();
      if (event.originalEventId != null) {
        return (query..where((e) => e.originalEventId.equalsNullable(event.originalEventId))).go();
      }
      return (query..where((e) => e.id.equalsNullable(eventId))).go();
      
    case DeleteOption.futureOnly:
      final event = await (select(events)..where((e) => e.id.equalsNullable(eventId))).getSingle();
      if (event.originalEventId != null) {
        return (query..where((e) => 
          e.originalEventId.equalsNullable(event.originalEventId) &
          e.date.isBiggerOrEqualValue(cutoffDate)
        )).go();
      }
      return (query..where((e) => e.id.equalsNullable(eventId))).go();
      
    case DeleteOption.pastOnly:
      final event = await (select(events)..where((e) => e.id.equalsNullable(eventId))).getSingle();
      if (event.originalEventId != null) {
        return (query..where((e) => 
          e.originalEventId.equalsNullable(event.originalEventId) &
          e.date.isSmallerOrEqualValue(cutoffDate)
        )).go();
      }
      return (query..where((e) => e.id.equalsNullable(eventId))).go();
  }
}

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