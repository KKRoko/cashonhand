import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../database/database.dart';
import '../models/freezed/saving_goal.dart';

// Model for allocation history
class GoalAllocationHistory {
  final int allocationId;
  final int eventId;
  final int goalId;
  final double amount;
  final DateTime date;
  final String eventTitle;
  final String allocationType;
  
  GoalAllocationHistory({
    required this.allocationId,
    required this.eventId,
    required this.goalId,
    required this.amount,
    required this.date,
    required this.eventTitle,
    required this.allocationType,
  });
}

abstract class ISavingGoalRepository {
  Future<Either<Failure, List<SavingGoal>>> getAllGoals();
  Future<Either<Failure, SavingGoal?>> getGoalById(int id);
  Future<Either<Failure, int>> createGoal(SavingGoal goal);
  Future<Either<Failure, bool>> updateGoal(SavingGoal goal);
  Future<Either<Failure, int>> deleteGoal(int id);
  Future<Either<Failure, List<SavingGoal>>> getActiveGoals();
  Future<Either<Failure, List<SavingGoal>>> getOverdueGoals();
  Future<Either<Failure, double>> getGoalProgressFromAllocations(int goalId);
  Future<Either<Failure, List<GoalAllocationHistory>>> getGoalAllocationHistory(int goalId);
}

@Injectable(as: ISavingGoalRepository)
class SavingGoalRepository implements ISavingGoalRepository {
  final Database _db;

  SavingGoalRepository(this._db);

  // Convert database model to domain model
  SavingGoal _convertToModel(SavingGoalTableData data) {
    return SavingGoal(
      id: data.id,
      title: data.title,
      description: data.description,
      targetAmount: data.targetAmount,
      currentAmount: data.currentAmount,
      goalType: data.goalType,
      isCompleted: data.isCompleted,
      createdAt: data.createdAt,
      deadlineDate: data.deadlineDate,
      recurringPeriod: data.recurringPeriod,
      recurringTargetAmount: data.recurringTargetAmount,
      checkpoints: data.checkpoints != null 
          ? List<DateTime>.from(jsonDecode(data.checkpoints!).map((x) => DateTime.parse(x)))
          : null,
    );
  }

  // Convert domain model to database companion
  SavingGoalsTableCompanion _convertToCompanion(SavingGoal goal) {
    return SavingGoalsTableCompanion.insert(
      title: goal.title,
      description: goal.description,
      targetAmount: goal.targetAmount,
      currentAmount: Value(goal.currentAmount),
      goalType: goal.goalType,
      isCompleted: Value(goal.isCompleted),
      deadlineDate: Value(goal.deadlineDate),
      recurringPeriod: Value(goal.recurringPeriod),
      recurringTargetAmount: Value(goal.recurringTargetAmount),
      checkpoints: Value(goal.checkpoints != null 
          ? jsonEncode(goal.checkpoints!.map((date) => date.toIso8601String()).toList())
          : null),
    );
  }

  @override
  Future<Either<Failure, SavingGoal?>> getGoalById(int id) async {
    try {
      final goal = await _db.getSavingGoalById(id);
      return Right(goal != null ? _convertToModel(goal) : null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch saving goal: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createGoal(SavingGoal goal) async {
    try {
      final id = await _db.createSavingGoal(_convertToCompanion(goal));
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create saving goal: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateGoal(SavingGoal goal) async {
    try {
      final data = SavingGoalTableData(
        id: goal.id,
        title: goal.title,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        goalType: goal.goalType,
        isCompleted: goal.isCompleted,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
        deadlineDate: goal.deadlineDate,
        recurringPeriod: goal.recurringPeriod,
        recurringTargetAmount: goal.recurringTargetAmount,
        checkpoints: goal.checkpoints != null 
            ? jsonEncode(goal.checkpoints!.map((date) => date.toIso8601String()).toList())
            : null,
      );
     final result = await _db.updateSavingGoal(data);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update saving goal: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteGoal(int id) async {
    try {
      final result = await _db.deleteSavingGoal(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete saving goal: $e'));
    }
  }

   @override
  Future<Either<Failure, List<SavingGoal>>> getAllGoals() async {
    try {
      print("Debug Repository: getAllGoals called");
      final goals = await _db.getAllSavingGoals();
      print("Debug Repository: Database returned ${goals.length} goal records");
      final convertedGoals = goals.map(_convertToModel).toList();
      print("Debug Repository: Converted to ${convertedGoals.length} SavingGoal models");
      return Right(convertedGoals);
    } catch (e) {
      print("Debug Repository: getAllGoals failed - $e");
      return Left(DatabaseFailure('Failed to fetch saving goals: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SavingGoal>>> getActiveGoals() async {
    try {
      final goals = await _db.getActiveGoals();
      return Right(goals.map(_convertToModel).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch active goals: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SavingGoal>>> getOverdueGoals() async {
    try {
      final goals = await _db.getOverdueGoals();
      return Right(goals.map(_convertToModel).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch overdue goals: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getGoalProgressFromAllocations(int goalId) async {
    try {
      // Get all allocations for this goal
      final allocations = await _db.getAllocationsForGoal(goalId);
      
      // Calculate total from actual allocations
      final totalAllocated = allocations.fold(0.0, (sum, allocation) => sum + allocation.allocationAmount);
      
      print('Debug: Goal $goalId has ${allocations.length} allocations totaling \$${totalAllocated.toStringAsFixed(2)}');
      return Right(totalAllocated);
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate goal progress: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GoalAllocationHistory>>> getGoalAllocationHistory(int goalId) async {
    try {
      // Get allocations with event details
      final allocations = await _db.getAllocationsForGoal(goalId);
      final history = <GoalAllocationHistory>[];
      
      for (final allocation in allocations) {
        try {
          // Get the event details for each allocation
          final event = await _db.getEventById(allocation.eventId);
          
          history.add(GoalAllocationHistory(
            allocationId: allocation.id,
            eventId: allocation.eventId,
            goalId: goalId,
            amount: allocation.allocationAmount,
            date: event.date,
            eventTitle: event.title,
            allocationType: allocation.allocationType.toString(),
          ));
        } catch (e) {
          print('Warning: Could not load event ${allocation.eventId} for allocation ${allocation.id}: $e');
          // Add allocation without event details
          history.add(GoalAllocationHistory(
            allocationId: allocation.id,
            eventId: allocation.eventId,
            goalId: goalId,
            amount: allocation.allocationAmount,
            date: DateTime.now(), // Fallback date
            eventTitle: 'Unknown Event',
            allocationType: allocation.allocationType.toString(),
          ));
        }
      }
      
      // Sort by date, newest first
      history.sort((a, b) => b.date.compareTo(a.date));
      
      return Right(history);
    } catch (e) {
      return Left(DatabaseFailure('Failed to fetch allocation history: $e'));
    }
  }
}
