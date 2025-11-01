import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/database/database.dart';
import '../data/models/freezed/event.dart';
import '../data/models/freezed/goal_allocation.dart';
import '../data/models/enums/repeat_option.dart';
import '../data/models/enums/allocation_type.dart';
import '../data/models/enums/category_type.dart';
import '../data/repositories/i_event_repository.dart';
import '../data/repositories/saving_goal_repository.dart';

/// Request for allocating surplus budget to savings goals
class SurplusAllocationRequest {
  final int budgetId;
  final int month;
  final int year;
  final Map<int, double> goalAllocations; // goalId -> amount
  final String notes;

  const SurplusAllocationRequest({
    required this.budgetId,
    required this.month,
    required this.year,
    required this.goalAllocations,
    this.notes = '',
  });
}

/// Result of surplus allocation
class SurplusAllocationResult {
  final int eventId;
  final List<int> allocationIds;
  final double totalAllocated;
  final Map<int, String> updatedGoals; // goalId -> goal title

  const SurplusAllocationResult({
    required this.eventId,
    required this.allocationIds,
    required this.totalAllocated,
    required this.updatedGoals,
  });
}

/// Service for allocating unspent budget surplus to savings goals
@injectable
class SurplusAllocationService {
  final Database _database;
  final IEventRepository _eventRepository;
  final ISavingGoalRepository _goalRepository;

  SurplusAllocationService(
    this._database,
    this._eventRepository,
    this._goalRepository,
  );

  /// Allocate surplus budget to savings goals
  /// Creates a virtual event to anchor the allocations and updates goal amounts
  Future<Either<Failure, SurplusAllocationResult>> allocateSurplus(
    SurplusAllocationRequest request,
  ) async {
    try {
      // Validate that we have allocations
      if (request.goalAllocations.isEmpty) {
        return Left(ValidationFailure('No allocations specified'));
      }

      // Calculate total allocation amount
      final totalAmount = request.goalAllocations.values.fold<double>(
        0.0,
        (sum, amount) => sum + amount,
      );

      if (totalAmount <= 0) {
        return Left(ValidationFailure('Total allocation must be greater than 0'));
      }

      print('💰 Surplus Allocation: Allocating \$${totalAmount.toStringAsFixed(2)} to ${request.goalAllocations.length} goals');

      // Check if surplus already allocated for this budget cycle
      final existingEvent = await _checkExistingSurplusEvent(request.budgetId, request.month, request.year);
      if (existingEvent != null) {
        return Left(ValidationFailure('Surplus already allocated for this budget cycle'));
      }

      // Create virtual event for surplus allocation
      final surplusEvent = Event(
        id: null,
        title: 'Budget Surplus Allocation - ${_getMonthName(request.month)} ${request.year}',
        categoryId: await _getBudgetSurplusCategoryId(),
        amount: -totalAmount, // Negative to represent outflow to savings
        dateTime: DateTime(request.year, request.month, DateTime.now().day),
        repeatOption: RepeatOption.today,
        isRecurring: false,
        notes: 'Budget ID: ${request.budgetId}\n${request.notes}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );

      // Create the event
      final eventDate = DateTime(request.year, request.month, DateTime.now().day);
      final eventResult = await _eventRepository.addEvent(eventDate, surplusEvent);

      final eventId = await eventResult.fold(
        (failure) => throw Exception('Failed to create surplus event: ${failure.message}'),
        (event) async => event.id!,
      );

      print('✅ Created virtual event with ID: $eventId');

      // Create goal allocations and update goal amounts
      final allocationIds = <int>[];
      final updatedGoals = <int, String>{};

      for (final entry in request.goalAllocations.entries) {
        final goalId = entry.key;
        final amount = entry.value;

        // Get goal details
        final goalResult = await _goalRepository.getGoalById(goalId);
        final goal = await goalResult.fold(
          (failure) => throw Exception('Failed to get goal $goalId: ${failure.message}'),
          (g) async => g,
        );

        if (goal == null) {
          throw Exception('Goal $goalId not found');
        }

        // Create goal allocation
        final allocation = GoalAllocation(
          id: null,
          eventId: eventId,
          goalId: goalId,
          allocationAmount: amount,
          allocationType: AllocationType.manual,
          notes: 'Surplus from ${_getMonthName(request.month)} ${request.year} budget',
          goalTitle: goal.title,
        );

        // Save allocation to database
        final companion = GoalAllocationsCompanion.insert(
          eventId: eventId,
          goalId: goalId,
          allocationAmount: amount,
          allocationType: allocation.allocationType,
          notes: drift.Value(allocation.notes),
        );

        final allocationId = await _database.into(_database.goalAllocations).insert(companion);

        allocationIds.add(allocationId);
        print('✅ Created allocation $allocationId: \$${amount.toStringAsFixed(2)} to "${goal.title}"');

        // Update goal's current amount
        final updatedGoal = goal.copyWithAmount(goal.currentAmount + amount);
        final updateResult = await _goalRepository.updateGoal(updatedGoal);

        await updateResult.fold(
          (failure) => throw Exception('Failed to update goal $goalId: ${failure.message}'),
          (success) async {
            updatedGoals[goalId] = goal.title;
            print('✅ Updated goal "${goal.title}": \$${goal.currentAmount.toStringAsFixed(2)} → \$${updatedGoal.currentAmount.toStringAsFixed(2)}');
          },
        );
      }

      print('💰 Surplus Allocation Complete: ${allocationIds.length} allocations created');

      return Right(SurplusAllocationResult(
        eventId: eventId,
        allocationIds: allocationIds,
        totalAllocated: totalAmount,
        updatedGoals: updatedGoals,
      ));
    } catch (e) {
      print('❌ Surplus allocation failed: $e');
      return Left(DatabaseFailure('Failed to allocate surplus: $e'));
    }
  }

  /// Check if surplus was already allocated for a budget cycle
  Future<Event?> _checkExistingSurplusEvent(int budgetId, int month, int year) async {
    try {
      final surplusCategoryId = await _getBudgetSurplusCategoryId();
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);

      // Use Drift's fluent API for type-safety
      final query = _database.select(_database.events)
        ..where((e) => e.categoryId.equals(surplusCategoryId))
        ..where((e) => e.date.isBiggerOrEqualValue(monthStart))
        ..where((e) => e.date.isSmallerOrEqualValue(monthEnd))
        ..where((e) => e.amount.isSmallerThanValue(0))
        ..where((e) => e.notes.like('%Budget ID: $budgetId%'))
        ..limit(1);

      final result = await query.getSingleOrNull();

      if (result == null) {
        return null;
      }

      // Map from the database-native EventTableData to your Event model
      return Event(
        id: result.id,
        title: result.title,
        categoryId: result.categoryId,
        amount: result.amount,
        dateTime: result.date,
        repeatOption: result.repeatOption,
        isRecurring: result.isRecurring,
        notes: result.notes,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
        // This field does not exist in the database table, so we default to false
        isYearEndSummary: false,
      );
    } catch (e) {
      print('❌ Error checking existing surplus event: $e');
      return null;
    }
  }

  /// Get or create the "Budget Surplus" category
  Future<int> _getBudgetSurplusCategoryId() async {
    // Check if category exists using Drift's ORM
    final existing = await (_database.select(_database.categories)
      ..where((c) => c.name.equals('Budget Surplus')))
      .getSingleOrNull();

    if (existing != null) {
      return existing.id;
    }

    // Create using Drift's ORM - this handles datetime formatting correctly
    // and keeps it consistent with how other categories are stored
    final categoryId = await _database.into(_database.categories).insert(
      CategoriesCompanion.insert(
        name: 'Budget Surplus',
        type: CategoryType.expense,
        isSystem: const drift.Value(true),
        isActive: const drift.Value(true),
      ),
    );

    print('✅ Created "Budget Surplus" category with ID: $categoryId');
    return categoryId;
  }

  /// Get allocations for a specific budget cycle
  Future<Either<Failure, List<GoalAllocation>>> getSurplusAllocationsForBudget(
    int budgetId,
    int month,
    int year,
  ) async {
    try {
      final event = await _checkExistingSurplusEvent(budgetId, month, year);

      if (event == null || event.id == null) {
        return const Right([]);
      }

      // Use Drift's fluent API with a join
      final query = _database.select(_database.goalAllocations).join([
        drift.innerJoin(
          _database.savingGoalsTable,
          _database.savingGoalsTable.id.equalsExp(_database.goalAllocations.goalId),
        )
      ])
        ..where(_database.goalAllocations.eventId.equals(event.id!))
        ..orderBy([drift.OrderingTerm.desc(_database.goalAllocations.createdAt)]);

      final results = await query.get();

      // Map the type-safe results
      final allocations = results.map((row) {
        final ga = row.readTable(_database.goalAllocations);
        final sg = row.readTable(_database.savingGoalsTable);

        return GoalAllocation(
          id: ga.id,
          eventId: ga.eventId,
          goalId: ga.goalId,
          allocationAmount: ga.allocationAmount,
          allocationType: ga.allocationType, // Use the real type from the DB
          notes: ga.notes,
          createdAt: ga.createdAt, // This is now a correct DateTime
          updatedAt: ga.updatedAt, // This is now a correct DateTime
          goalTitle: sg.title,
        );
      }).toList();

      return Right(allocations);
    } catch (e) {
      print('❌ Error getting surplus allocations: $e');
      return Left(DatabaseFailure('Failed to get surplus allocations: $e'));
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
