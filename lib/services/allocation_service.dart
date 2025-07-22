import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../core/error/failures.dart';
import '../data/database/database.dart';
import '../data/models/freezed/goal_allocation.dart';
import '../data/models/freezed/allocation_rule.dart';
import '../data/models/freezed/event.dart';
import '../data/models/enums/allocation_type.dart';
import '../data/models/enums/trigger_type.dart';

@injectable
class AllocationService {
  final Database _database;
  
  AllocationService(this._database);
  
  /// Calculate allocations for a transaction based on active rules
  Future<Either<Failure, List<GoalAllocation>>> calculateAutoAllocations(Event event) async {
    try {
      final rules = await _database.getActiveAllocationRules();
      final allocations = <GoalAllocation>[];
      
      for (final rule in rules) {
        final ruleModel = _mapRuleToModel(rule);
        
        if (ruleModel.shouldTrigger(event.amount.abs(), event.categoryId, event.isPositiveCashflow)) {
          final allocationAmount = ruleModel.calculateAllocation(event.amount.abs());
          
          if (allocationAmount > 0) {
            final allocation = GoalAllocation(
              id: null,
              eventId: event.id ?? 0,
              goalId: rule.goalId,
              allocationAmount: allocationAmount,
              allocationType: AllocationType.auto,
              notes: 'Auto-allocated by rule: ${rule.ruleName}',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            allocations.add(allocation);
          }
        }
      }
      
      return Right(allocations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate auto allocations: ${e.toString()}'));
    }
  }
  
  /// Calculate round-up allocation for a transaction
  Either<Failure, GoalAllocation?> calculateRoundUpAllocation(Event event, int goalId) {
    try {
      if (!event.isPositiveCashflow) { // Only for expenses
        final roundUpAmount = event.amount.abs().ceilToDouble() - event.amount.abs();
        
        if (roundUpAmount > 0) {
          return Right(GoalAllocation(
            id: null,
            eventId: event.id ?? 0,
            goalId: goalId,
            allocationAmount: roundUpAmount,
            allocationType: AllocationType.roundUp,
            notes: 'Round-up savings',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(GeneralFailure('Failed to calculate round-up: ${e.toString()}'));
    }
  }
  
  /// Create manual allocation
  Either<Failure, GoalAllocation> createManualAllocation({
    required int eventId,
    required int goalId,
    required double amount,
    String? notes,
  }) {
    try {
      return Right(GoalAllocation(
        id: null,
        eventId: eventId,
        goalId: goalId,
        allocationAmount: amount,
        allocationType: AllocationType.manual,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(GeneralFailure('Failed to create manual allocation: ${e.toString()}'));
    }
  }
  
  /// Get suggested allocation amounts based on user patterns
  Future<Either<Failure, Map<int, double>>> getSuggestedAllocations(Event event) async {
    try {
      final suggestions = <int, double>{};
      
      // Get user's active goals
      final activeGoals = await _database.getActiveGoals();
      
      // Simple suggestion logic - can be enhanced with ML in the future
      if (event.isPositiveCashflow && event.amount > 100) {
        // Suggest 10% allocation for income over $100
        for (final goal in activeGoals) {
          suggestions[goal.id] = event.amount * 0.10;
        }
      }
      
      return Right(suggestions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get allocation suggestions: ${e.toString()}'));
    }
  }
  
  /// Validate allocation against business rules
  Either<Failure, bool> validateAllocation(GoalAllocation allocation, Event event) {
    try {
      // Check if allocation amount is valid
      if (allocation.allocationAmount <= 0) {
        return const Left(ValidationFailure('Allocation amount must be greater than zero'));
      }
      
      // Check if allocation amount doesn't exceed transaction amount for expenses
      if (!event.isPositiveCashflow && allocation.allocationAmount > event.amount.abs()) {
        return const Left(ValidationFailure('Allocation cannot exceed transaction amount'));
      }
      
      // For income, allow allocations up to 100% of the income
      if (event.isPositiveCashflow && allocation.allocationAmount > event.amount) {
        return const Left(ValidationFailure('Allocation cannot exceed income amount'));
      }
      
      return const Right(true);
    } catch (e) {
      return Left(ValidationFailure('Validation failed: ${e.toString()}'));
    }
  }
  
  /// Helper method to convert database rule to model
  AllocationRule _mapRuleToModel(AutoAllocationRuleTableData rule) {
    return AllocationRule(
      id: rule.id,
      goalId: rule.goalId,
      ruleName: rule.ruleName,
      triggerType: rule.triggerType,
      triggerCategoryId: rule.triggerCategoryId,
      allocationMethod: rule.allocationMethod,
      allocationValue: rule.allocationValue,
      minimumTriggerAmount: rule.minimumTriggerAmount,
      maximumAllocationAmount: rule.maximumAllocationAmount,
      isActive: rule.isActive,
      description: rule.description,
      createdAt: rule.createdAt,
      updatedAt: rule.updatedAt,
    );
  }
}