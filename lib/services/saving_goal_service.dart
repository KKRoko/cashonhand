// saving_goal_service.dart
import 'package:dartz/dartz.dart';
import '../core/error/failures.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../data/models/freezed/saving_goal.dart';
import '../services/achievement_service.dart';

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
          await _achievementService.checkSavingGoalsAchievements();
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

  getGoals() {}

  addGoal(SavingGoal goal) {}
}
