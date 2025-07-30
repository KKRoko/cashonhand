import 'package:freezed_annotation/freezed_annotation.dart';

import '../enums/goal_type.dart';
import '../enums/recurring_period.dart';
import '../../utils/money.dart';

part 'saving_goal.freezed.dart';
part 'saving_goal.g.dart';

@freezed
class SavingGoal with _$SavingGoal {
  const factory SavingGoal({
    required int id,
    required String title,
    required String description,
    required double targetAmount,
    required double currentAmount,
    required GoalType goalType,
    required bool isCompleted,
    required DateTime createdAt,
    DateTime? deadlineDate,
    RecurringPeriod? recurringPeriod,
    double? recurringTargetAmount,
    List<DateTime>? checkpoints, 
  }) = _SavingGoal;

  const SavingGoal._();

  factory SavingGoal.fromJson(Map<String, dynamic> json) => 
      _$SavingGoalFromJson(json);

  double get progressPercentage => 
      (currentAmount / targetAmount * 100).clamp(0, 100);

  /// Precise progress percentage using Money arithmetic (recommended)
  double get progressPercentagePrecise {
    final current = Money.fromDouble(currentAmount);
    final target = Money.fromDouble(targetAmount);
    if (target.isZero) return 0.0;
    return (current.divideBy(target) * 100).clamp(0.0, 100.0);
  }

  /// Get current amount as Money for precise arithmetic
  Money get currentAmountMoney => Money.fromDouble(currentAmount);
  
  /// Get target amount as Money for precise arithmetic
  Money get targetAmountMoney => Money.fromDouble(targetAmount);
  
  /// Get remaining amount as Money with precise calculation
  Money get remainingAmountMoney => targetAmountMoney - currentAmountMoney;

  bool get isOverdue {
    if (deadlineDate == null) return false;
    return !isCompleted && DateTime.now().isAfter(deadlineDate!);
  }

  double getExpectedAmountForDate(DateTime date) {
    switch (goalType) {
      case GoalType.simple:
        return targetAmount;
        
      case GoalType.deadline:
        if (deadlineDate == null) return targetAmount;
        final totalDays = deadlineDate!.difference(createdAt).inDays;
        final elapsedDays = date.difference(createdAt).inDays;
        return (targetAmount / totalDays) * elapsedDays;
        
      case GoalType.recurring:
        if (recurringTargetAmount == null || recurringPeriod == null) {
          return targetAmount;
        }
        final periods = _calculatePeriodsBetween(createdAt, date);
        return recurringTargetAmount! * periods;
    }
  }

  int _calculatePeriodsBetween(DateTime start, DateTime end) {
    switch (recurringPeriod!) {
      case RecurringPeriod.weekly:
        return end.difference(start).inDays ~/ 7;
      case RecurringPeriod.monthly:
        return (end.year - start.year) * 12 + end.month - start.month;
    }
  }

  SavingGoal copyWithAmount(double newAmount) {
    return copyWith(
      currentAmount: newAmount,
      isCompleted: newAmount >= targetAmount,
    );
  }

  // Factory constructors for different goal types
  factory SavingGoal.simple({
    required String title,
    required String description,
    required double targetAmount,
  }) {
    return SavingGoal(
      id: 0,  // Will be replaced by DB auto-increment
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: 0,
      goalType: GoalType.simple,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  factory SavingGoal.withDeadline({
    required String title,
    required String description,
    required double targetAmount,
    required DateTime deadlineDate,
  }) {
    return SavingGoal(
      id: 0,  // Will be replaced by DB auto-increment
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: 0,
      goalType: GoalType.deadline,
      isCompleted: false,
      createdAt: DateTime.now(),
      deadlineDate: deadlineDate,
    );
  }

  factory SavingGoal.recurring({
    required String title,
    required String description,
    required double targetAmount,
    required RecurringPeriod period,
    required double recurringTarget,
  }) {
    return SavingGoal(
      id: 0,  // Will be replaced by DB auto-increment
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentAmount: 0,
      goalType: GoalType.recurring,
      isCompleted: false,
      createdAt: DateTime.now(),
      recurringPeriod: period,
      recurringTargetAmount: recurringTarget,
    );
  }
}