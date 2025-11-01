// saving_goal_service.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../data/models/freezed/saving_goal.dart';
import '../services/achievement_service.dart';

@injectable
class SavingGoalService {
  final ISavingGoalRepository _repository;
  final AchievementService _achievementService;

  SavingGoalService(this._repository, this._achievementService);

  Future<Either<Failure, List<SavingGoal>>> getAllGoals() => _repository.getAllGoals();

  Future<Either<Failure, SavingGoal?>> getGoalById(int id) => _repository.getGoalById(id);

  Future<Either<Failure, int>> createGoal(SavingGoal goal) async {
    final result = await _repository.createGoal(goal);
    
    result.fold(
      (failure) => null,
      (id) => _achievementService.checkSavingGoalsAchievements(),
    );

    return result;
  }

  Future<Either<Failure, bool>> updateProgress(int id, double newAmount) async {
    final goalResult = await _repository.getGoalById(id);
    
    return goalResult.fold(
      (failure) => Left(failure),
      (goal) async {
        if (goal == null) return const Left(DatabaseFailure('Goal not found'));
        
        final updatedGoal = goal.copyWithAmount(newAmount);
        final wasCompleted = goal.isCompleted;
        final isNowCompleted = updatedGoal.isCompleted;
        
        final result = await _repository.updateGoal(updatedGoal);
        
        // Check achievements if goal was just completed
        if (!wasCompleted && isNowCompleted) {
          print('🏆 ACHIEVEMENT: Goal "${updatedGoal.title}" just completed! Triggering achievement check...');
          await _achievementService.checkSavingGoalsAchievements();
        } else {
          print('🔍 ACHIEVEMENT DEBUG: Goal "${updatedGoal.title}" - wasCompleted: $wasCompleted, isNowCompleted: $isNowCompleted');
        }
        
        return result;
      }
    );
  }

  Future<Either<Failure, bool>> updateGoal(SavingGoal goal) =>
      _repository.updateGoal(goal);

  Future<Either<Failure, int>> deleteGoal(int id) =>
      _repository.deleteGoal(id);

  Future<Either<Failure, List<SavingGoal>>> getActiveGoals() =>
      _repository.getActiveGoals();

  Future<Either<Failure, List<SavingGoal>>> getOverdueGoals() =>
      _repository.getOverdueGoals();
      
  Future<Either<Failure, Map<String, dynamic>>> getGoalStatistics() async {
    final goalsResult = await getAllGoals();
    
    return goalsResult.fold(
      (failure) => Left(failure),
      (goals) {
        final totalGoals = goals.length;
        final completedGoals = goals.where((g) => g.isCompleted).length;
        final totalSaved = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
        final averageProgress = goals.isEmpty ? 0.0 :
            goals.fold(0.0, (sum, goal) => sum + goal.progressPercentage) / totalGoals;
            
        return Right({
          'totalGoals': totalGoals,
          'completedGoals': completedGoals,
          'completionRate': totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0,
          'totalSaved': totalSaved,
          'averageProgress': averageProgress,
        });
      }
    );
  }

  Future<List<SavingGoal>> getGoals() async {
    print("Debug Service: getGoals called");
    final result = await getAllGoals();
    return result.fold(
      (failure) {
        print("Debug Service: getGoals failed - ${failure.message}");
        throw Exception(failure.message);
      },
      (goals) {
        print("Debug Service: getGoals succeeded - ${goals.length} goals found");
        return goals;
      }
    );
  }

  Future<Either<Failure, int>> addGoal(SavingGoal goal) async {
    print("Debug Service: addGoal called with title: ${goal.title}");
    return await createGoal(goal);
  }

  // Enhanced progress tracking methods
  Future<Either<Failure, SavingGoal>> getGoalWithRealTimeProgress(int goalId) async {
    final goalResult = await _repository.getGoalById(goalId);
    
    return goalResult.fold(
      (failure) => Left(failure),
      (goal) async {
        if (goal == null) return const Left(DatabaseFailure('Goal not found'));
        
        // Get real-time progress from allocations
        final progressResult = await _repository.getGoalProgressFromAllocations(goalId);
        
        return progressResult.fold(
          (failure) => Right(goal), // Return original goal if allocation calculation fails
          (allocationTotal) {
            // Calculate total progress: initial amount + allocations
            final totalProgress = goal.currentAmount + allocationTotal;
            final updatedGoal = goal.copyWith(currentAmount: totalProgress);
            print('Debug Service: Goal ${goal.title} progress: initial \$${goal.currentAmount.toStringAsFixed(2)} + allocations \$${allocationTotal.toStringAsFixed(2)} = \$${totalProgress.toStringAsFixed(2)}');
            return Right(updatedGoal);
          }
        );
      }
    );
  }

  Future<Either<Failure, List<SavingGoal>>> getGoalsWithRealTimeProgress() async {
    final goalsResult = await getAllGoals();
    
    return goalsResult.fold(
      (failure) => Left(failure),
      (goals) async {
        final updatedGoals = <SavingGoal>[];
        
        for (final goal in goals) {
          final realTimeResult = await getGoalWithRealTimeProgress(goal.id);
          realTimeResult.fold(
            (failure) => updatedGoals.add(goal), // Add original goal if update fails
            (updatedGoal) => updatedGoals.add(updatedGoal),
          );
        }
        
        return Right(updatedGoals);
      }
    );
  }

  Future<Either<Failure, List<GoalAllocationHistory>>> getGoalAllocationHistory(int goalId) {
    return _repository.getGoalAllocationHistory(goalId);
  }

  // Sync goal progress with allocations - useful for maintenance/sync operations
  Future<Either<Failure, bool>> syncGoalProgressWithAllocations(int goalId) async {
    // Get the goal with real-time progress calculation
    final goalWithProgressResult = await getGoalWithRealTimeProgress(goalId);
    
    return goalWithProgressResult.fold(
      (failure) => Left(failure),
      (goalWithProgress) async {
        // Get the original goal to compare
        final originalGoalResult = await _repository.getGoalById(goalId);
        
        return originalGoalResult.fold(
          (failure) => Left(failure),
          (originalGoal) async {
            if (originalGoal == null) return const Left(DatabaseFailure('Goal not found'));
            
            // Only update if the calculated progress is different from stored progress
            if (goalWithProgress.currentAmount != originalGoal.currentAmount) {
              print('Debug Service: Syncing goal $goalId - Original: \$${originalGoal.currentAmount.toStringAsFixed(2)}, Calculated: \$${goalWithProgress.currentAmount.toStringAsFixed(2)}');
              
              // Update goal with the calculated total progress
              final syncedGoal = originalGoal.copyWith(
                currentAmount: goalWithProgress.currentAmount,
              );
              
              return await _repository.updateGoal(syncedGoal);
            } else {
              print('Debug Service: Goal $goalId already in sync - no update needed');
              return const Right(true);
            }
          }
        );
      }
    );
  }
}
