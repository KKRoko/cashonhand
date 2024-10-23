import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';
import 'dart:io';
import '../models/enums/repeat_option.dart';
import 'tables.dart';
import '../models/enums/category_type.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Events])
class Database extends _$Database {
  Database() : super(_openConnection());

  @override
  int get schemaVersion => 1;

@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // No need for migration since the relationship is already defined in tables.dart
    },
  );
}

  // Categories CRUD operations
  Future<List<CategoryTableData>> getAllCategories() => select(categories).get();
  
  Future<CategoryTableData> getCategoryById(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> createCategory(CategoriesCompanion category) =>
      into(categories).insert(category);
  
  Future<bool> updateCategory(CategoryTableData category) =>
      update(categories).replace(category);
  
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  // Events CRUD operations
  Future<List<EventTableData>> getAllEvents() => select(events).get();
  
  Future<EventTableData> getEventById(int id) =>
      (select(events)..where((t) => t.id.equals(id))).getSingle();
  
  Future<int> createEvent(EventsCompanion event) =>
      into(events).insert(event);
  
  Future<bool> updateEvent(EventTableData event) =>
      update(events).replace(event);
  
  Future<int> deleteEvent(int id) =>
      (delete(events)..where((t) => t.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}