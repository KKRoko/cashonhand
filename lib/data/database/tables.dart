import 'package:drift/drift.dart';
import 'type_converters.dart';

typedef JsonMap = Map<String, dynamic>;

@DataClassName('CategoryTableData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().map(const CategoryTypeConverter())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('EventTableData')
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get originalEventId => integer().nullable()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get repeatOption => text().map(const RepeatOptionConverter())();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  TextColumn get customRecurrence => text().map(const CustomRecurrenceConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('SavingGoalTableData')
class SavingGoalsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get goalType => text().map(const GoalTypeConverter())();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deadlineDate => dateTime().nullable()();
  TextColumn get recurringPeriod => text().map(const RecurringPeriodConverter()).nullable()();
  RealColumn get recurringTargetAmount => real().nullable()();
  TextColumn get checkpoints => text().nullable()();
}

@DataClassName('AchievementTableData')
class Achievements extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text().map(const AchievementTypeConverter())();
  RealColumn get targetAmount => real()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
