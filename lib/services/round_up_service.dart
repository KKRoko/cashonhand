import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/event.dart';
import '../data/models/freezed/saving_goal.dart';
import '../data/models/freezed/goal_allocation.dart';
import '../data/models/freezed/round_up_preferences.dart';
import '../data/models/freezed/round_up_calculation.dart';
import '../data/models/enums/allocation_type.dart';
import '../data/repositories/saving_goal_repository.dart';


@injectable
class RoundUpService {
  final ISavingGoalRepository _goalRepository;

  RoundUpService(this._goalRepository);

  /// Calculate round-up amount for a transaction
  RoundUpCalculation calculateRoundUp(
    double amount, 
    RoundUpPreferences preferences,
    {int? categoryId}
  ) {
    final absAmount = amount.abs();
    
    // Check if round-up is applicable
    if (!preferences.isEnabled) {
      return RoundUpCalculation(
        originalAmount: amount,
        roundUpAmount: 0.0,
        roundedTotal: absAmount,
        strategyUsed: preferences.strategy,
        isApplicable: false,
        reason: 'Round-up is disabled',
      );
    }

    // Check if this is an expense transaction (if onlyOnExpenses is enabled)
    if (preferences.onlyOnExpenses && amount >= 0) {
      return RoundUpCalculation(
        originalAmount: amount,
        roundUpAmount: 0.0,
        roundedTotal: absAmount,
        strategyUsed: preferences.strategy,
        isApplicable: false,
        reason: 'Round-up only applies to expenses',
      );
    }

    // Check excluded categories
    if (categoryId != null && preferences.excludedCategoryIds.contains(categoryId)) {
      return RoundUpCalculation(
        originalAmount: amount,
        roundUpAmount: 0.0,
        roundedTotal: absAmount,
        strategyUsed: preferences.strategy,
        isApplicable: false,
        reason: 'Category is excluded from round-up',
      );
    }

    // Calculate round-up based on strategy
    final roundUp = _calculateRoundUpByStrategy(absAmount, preferences);
    
    // Apply min/max limits
    final clampedRoundUp = roundUp.clamp(preferences.minimumRoundUp, preferences.maximumRoundUp);
    
    // Check if round-up meets minimum threshold
    if (clampedRoundUp < preferences.minimumRoundUp) {
      return RoundUpCalculation(
        originalAmount: amount,
        roundUpAmount: 0.0,
        roundedTotal: absAmount,
        strategyUsed: preferences.strategy,
        isApplicable: false,
        reason: 'Round-up amount below minimum threshold',
      );
    }

    return RoundUpCalculation(
      originalAmount: amount,
      roundUpAmount: clampedRoundUp,
      roundedTotal: absAmount + clampedRoundUp,
      strategyUsed: preferences.strategy,
      isApplicable: true,
      reason: 'Round-up calculated successfully',
    );
  }

  double _calculateRoundUpByStrategy(double amount, RoundUpPreferences preferences) {
    switch (preferences.strategy) {
      case RoundUpStrategy.nearestDollar:
        return _roundUpToNearest(amount, 1.0);
      case RoundUpStrategy.nearestFive:
        return _roundUpToNearest(amount, 5.0);
      case RoundUpStrategy.nearestTen:
        return _roundUpToNearest(amount, 10.0);
      case RoundUpStrategy.custom:
        if (preferences.customMultiplier != null && preferences.customMultiplier! > 0) {
          return _roundUpToNearest(amount, preferences.customMultiplier!);
        }
        return _roundUpToNearest(amount, 1.0); // Fallback to nearest dollar
    }
  }

  double _roundUpToNearest(double amount, double multiplier) {
    final remainder = amount % multiplier;
    if (remainder == 0) return 0.0; // Already rounded
    return multiplier - remainder;
  }

  /// Create goal allocation for round-up amount
  Future<Either<Failure, GoalAllocation?>> createRoundUpAllocation(
    int eventId,
    RoundUpCalculation calculation,
    RoundUpPreferences preferences,
  ) async {
    if (!calculation.isApplicable || calculation.roundUpAmount <= 0) {
      return const Right(null);
    }

    try {
      // Determine which goal to allocate to
      int? goalId = preferences.defaultGoalId;
      String goalTitle = 'Round-up Savings';

      if (preferences.autoSelectGoal && goalId == null) {
        // Auto-select the first active goal
        final goalsResult = await _goalRepository.getActiveGoals();
        goalsResult.fold(
          (failure) => goalId = null,
          (goals) {
            if (goals.isNotEmpty) {
              goalId = goals.first.id;
              goalTitle = goals.first.title;
            }
          },
        );
      } else if (goalId != null) {
        // Get the specific goal title
        final goalResult = await _goalRepository.getGoalById(goalId);
        goalResult.fold(
          (failure) => goalTitle = 'Unknown Goal',
          (goal) => goalTitle = goal?.title ?? 'Unknown Goal',
        );
      }

      if (goalId == null) {
        return const Left(DatabaseFailure('No goal available for round-up allocation'));
      }

      final allocation = GoalAllocation(
        id: null,
        eventId: eventId,
        goalId: goalId!,
        allocationAmount: calculation.roundUpAmount,
        allocationType: AllocationType.roundUp,
        goalTitle: goalTitle,
        notes: 'Auto round-up: ${calculation.strategyUsed.toString().split('.').last}',
      );

      return Right(allocation);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create round-up allocation: $e'));
    }
  }


  /// Simulate round-up for multiple transactions (for preview/analysis)
  List<RoundUpCalculation> simulateRoundUps(
    List<Event> transactions,
    RoundUpPreferences preferences,
  ) {
    return transactions.map((transaction) => 
      calculateRoundUp(
        transaction.amount,
        preferences,
        categoryId: transaction.categoryId,
      )
    ).toList();
  }
}

