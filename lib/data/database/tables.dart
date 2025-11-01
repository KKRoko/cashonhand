import 'package:drift/drift.dart';
import 'type_converters.dart';

typedef JsonMap = Map<String, dynamic>;

@DataClassName('CategoryTableData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().map(const CategoryTypeConverter())();
  IntColumn get parentCategoryId => integer().nullable().references(Categories, #id)();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
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

@DataClassName('GoalAllocationTableData')
class GoalAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get eventId => integer().references(Events, #id, onDelete: KeyAction.cascade)();
  IntColumn get goalId => integer().references(SavingGoalsTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get allocationAmount => real()();
  TextColumn get allocationType => text().map(const AllocationTypeConverter())(); // manual, auto, round_up
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AutoAllocationRuleTableData')
class AutoAllocationRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(SavingGoalsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get ruleName => text().withLength(min: 1, max: 100)();
  TextColumn get triggerType => text().map(const TriggerTypeConverter())(); // income, expense, category
  IntColumn get triggerCategoryId => integer().references(Categories, #id).nullable()();
  TextColumn get allocationMethod => text().map(const AllocationMethodConverter())(); // percentage, fixed_amount, round_up
  RealColumn get allocationValue => real()(); // percentage (0.1 = 10%) or fixed amount
  RealColumn get minimumTriggerAmount => real().nullable()(); // minimum transaction amount to trigger
  RealColumn get maximumAllocationAmount => real().nullable()(); // cap on allocation amount
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BudgetTableData')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get month => integer()(); // 1-12
  IntColumn get year => integer()(); // e.g., 2025
  RealColumn get monthlyIncome => real()();
  IntColumn get cycleStartDay => integer().withDefault(const Constant(1))(); // 1-31
  RealColumn get needsPercentage => real().withDefault(const Constant(0.50))(); // 50%
  RealColumn get wantsPercentage => real().withDefault(const Constant(0.30))(); // 30%
  RealColumn get savingsPercentage => real().withDefault(const Constant(0.20))(); // 20%
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {month, year}, // Each month/year combination must be unique
  ];
}

@DataClassName('CategoryBudgetTableData')
class CategoryBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetId => integer().references(Budgets, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  RealColumn get allocatedAmount => real()(); // monthly dollar amount
  TextColumn get bucketType => text().map(const BucketTypeConverter())(); // needs, wants, savings
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('BudgetTemplateTableData')
class BudgetTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text()();
  RealColumn get needsPercentage => real().withDefault(const Constant(0.50))(); // 50%
  RealColumn get wantsPercentage => real().withDefault(const Constant(0.30))(); // 30%
  RealColumn get savingsPercentage => real().withDefault(const Constant(0.20))(); // 20%
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))(); // true for system presets
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

@DataClassName('YearEndGoalTableData')
class YearEndGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()(); // e.g., 2025
  RealColumn get needsPercentage => real()(); // annual percentage goal for needs bucket (0.0-1.0)
  RealColumn get wantsPercentage => real()(); // annual percentage goal for wants bucket (0.0-1.0)
  RealColumn get savingsPercentage => real()(); // annual percentage goal for savings bucket (0.0-1.0)
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {year}, // Each year must have only one goal
  ];
}

@DataClassName('AllocationTemplateTableData')
class AllocationTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  RealColumn get totalAmount => real()(); // Total allocation amount in this template
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('AllocationTemplateItemTableData')
class AllocationTemplateItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(AllocationTemplates, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  RealColumn get allocatedAmount => real()();
  TextColumn get bucketType => text().map(const BucketTypeConverter())(); // needs, wants, savings
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
