import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/database/database.dart';
import '../data/models/freezed/event.dart';
import '../data/models/freezed/goal_allocation.dart';
import '../data/models/enums/trigger_type.dart';
import '../data/models/enums/allocation_method.dart';
import '../data/models/enums/allocation_type.dart';
import '../data/models/enums/repeat_option.dart';
import '../data/repositories/saving_goal_repository.dart';

/// Result of rule evaluation
class RuleEvaluationResult {
  final AutoAllocationRuleTableData rule;
  final double allocationAmount;
  final String reason;
  final bool isApplicable;

  const RuleEvaluationResult({
    required this.rule,
    required this.allocationAmount,
    required this.reason,
    required this.isApplicable,
  });
}

/// Service responsible for executing auto-allocation rules on transactions
@injectable
class AutoAllocationRulesEngine {
  final Database _database;
  final ISavingGoalRepository _goalRepository;

  AutoAllocationRulesEngine(this._database, this._goalRepository);

  /// Evaluate all active rules for a given transaction and return applicable allocations
  Future<Either<Failure, List<GoalAllocation>>> evaluateRulesForTransaction(
    Event transaction,
  ) async {
    try {
      // Get all active rules
      final rules = await _database.getActiveAllocationRules();
      print('🔧 Rules Engine: Found ${rules.length} active rules to evaluate');

      final List<GoalAllocation> allocations = [];

      for (final rule in rules) {
        final evaluationResult = await _evaluateRule(rule, transaction);
        
        if (evaluationResult.isApplicable && evaluationResult.allocationAmount > 0) {
          print('🔧 Rules Engine: Rule "${rule.ruleName}" applicable - allocating \$${evaluationResult.allocationAmount.toStringAsFixed(2)}');
          
          // Get goal details
          final goalResult = await _goalRepository.getGoalById(rule.goalId);
          final goalTitle = goalResult.fold(
            (failure) => 'Unknown Goal',
            (goal) => goal?.title ?? 'Unknown Goal',
          );

          final allocation = GoalAllocation(
            id: null, // Will be set when saved to database
            eventId: transaction.id ?? 0, // Will be updated when event is saved
            goalId: rule.goalId,
            allocationAmount: evaluationResult.allocationAmount,
            allocationType: AllocationType.auto,
            goalTitle: goalTitle,
            notes: 'Auto-rule: ${rule.ruleName} - ${evaluationResult.reason}',
          );

          allocations.add(allocation);
        }
      }

      print('🔧 Rules Engine: Generated ${allocations.length} automatic allocations');
      return Right(allocations);
    } catch (e) {
      return Left(DatabaseFailure('Failed to evaluate allocation rules: $e'));
    }
  }

  /// Evaluate a single rule against a transaction
  Future<RuleEvaluationResult> _evaluateRule(
    AutoAllocationRuleTableData rule,
    Event transaction,
  ) async {
    // Check if rule trigger matches transaction
    if (!_doesTriggerMatch(rule, transaction)) {
      return RuleEvaluationResult(
        rule: rule,
        allocationAmount: 0.0,
        reason: 'Trigger condition not met',
        isApplicable: false,
      );
    }

    // Check minimum trigger amount
    if (rule.minimumTriggerAmount != null && 
        transaction.amount.abs() < rule.minimumTriggerAmount!) {
      return RuleEvaluationResult(
        rule: rule,
        allocationAmount: 0.0,
        reason: 'Transaction amount below minimum threshold',
        isApplicable: false,
      );
    }

    // Calculate allocation amount
    double allocationAmount;
    String reason;

    switch (rule.allocationMethod) {
      case AllocationMethod.percentage:
        allocationAmount = transaction.amount.abs() * rule.allocationValue;
        reason = '${(rule.allocationValue * 100).toStringAsFixed(1)}% of \$${transaction.amount.abs().toStringAsFixed(2)}';
        break;
        
      case AllocationMethod.fixedAmount:
        allocationAmount = rule.allocationValue;
        reason = 'Fixed amount of \$${rule.allocationValue.toStringAsFixed(2)}';
        break;
        
      case AllocationMethod.roundUp:
        // Calculate round-up amount
        final roundedUp = (transaction.amount.abs()).ceil().toDouble();
        allocationAmount = roundedUp - transaction.amount.abs();
        reason = 'Round-up from \$${transaction.amount.abs().toStringAsFixed(2)} to \$${roundedUp.toStringAsFixed(2)}';
        break;
    }

    // Apply maximum allocation limit if set
    if (rule.maximumAllocationAmount != null && 
        allocationAmount > rule.maximumAllocationAmount!) {
      allocationAmount = rule.maximumAllocationAmount!;
      reason += ' (capped at maximum)';
    }

    return RuleEvaluationResult(
      rule: rule,
      allocationAmount: allocationAmount,
      reason: reason,
      isApplicable: allocationAmount > 0,
    );
  }

  /// Check if a rule's trigger conditions match the transaction
  bool _doesTriggerMatch(AutoAllocationRuleTableData rule, Event transaction) {
    switch (rule.triggerType) {
      case TriggerType.anyTransaction:
        return true;
        
      case TriggerType.income:
        return transaction.amount > 0;
        
      case TriggerType.expense:
        return transaction.amount < 0;
        
      case TriggerType.category:
        return rule.triggerCategoryId != null && 
               transaction.categoryId == rule.triggerCategoryId;
    }
  }

  /// Preview what allocations would be created for a transaction without saving
  Future<Either<Failure, List<RuleEvaluationResult>>> previewRulesForTransaction(
    Event transaction,
  ) async {
    try {
      final rules = await _database.getActiveAllocationRules();
      final List<RuleEvaluationResult> results = [];

      for (final rule in rules) {
        final result = await _evaluateRule(rule, transaction);
        results.add(result);
      }

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure('Failed to preview allocation rules: $e'));
    }
  }

  /// Get rules that would be triggered by a specific category
  Future<Either<Failure, List<AutoAllocationRuleTableData>>> getRulesForCategory(
    int categoryId,
  ) async {
    try {
      final allRules = await _database.getActiveAllocationRules();
      final matchingRules = allRules.where((rule) {
        return rule.triggerType == TriggerType.category && 
               rule.triggerCategoryId == categoryId ||
               rule.triggerType == TriggerType.anyTransaction;
      }).toList();

      return Right(matchingRules);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get rules for category: $e'));
    }
  }

  /// Calculate total potential allocation for a transaction amount
  Future<Either<Failure, double>> calculateTotalPotentialAllocation(
    double transactionAmount,
    int? categoryId,
    {bool isIncome = false}
  ) async {
    try {
      // Create a mock transaction for evaluation
      final mockTransaction = Event(
        id: null,
        title: 'Mock Transaction',
        categoryId: categoryId ?? 1,
        amount: isIncome ? transactionAmount.abs() : -transactionAmount.abs(),
        dateTime: DateTime.now(),
        repeatOption: RepeatOption.today,
        isRecurring: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isYearEndSummary: false,
      );

      final allocationResult = await evaluateRulesForTransaction(mockTransaction);
      
      return allocationResult.fold(
        (failure) => Left(failure),
        (allocations) {
          final total = allocations.fold<double>(
            0.0, 
            (sum, allocation) => sum + allocation.allocationAmount,
          );
          return Right(total);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate potential allocation: $e'));
    }
  }

  /// Test a rule against various transaction scenarios
  Future<Either<Failure, Map<String, RuleEvaluationResult>>> testRule(
    AutoAllocationRuleTableData rule,
  ) async {
    try {
      final testScenarios = <String, Event>{
        'Small Expense (\$5)': Event(
          id: 1, title: 'Test', categoryId: rule.triggerCategoryId ?? 1,
          amount: -5.0, dateTime: DateTime.now(), repeatOption: RepeatOption.today, isRecurring: false,
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isYearEndSummary: false,
        ),
        'Medium Expense (\$50)': Event(
          id: 2, title: 'Test', categoryId: rule.triggerCategoryId ?? 1,
          amount: -50.0, dateTime: DateTime.now(), repeatOption: RepeatOption.today, isRecurring: false,
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isYearEndSummary: false,
        ),
        'Large Expense (\$500)': Event(
          id: 3, title: 'Test', categoryId: rule.triggerCategoryId ?? 1,
          amount: -500.0, dateTime: DateTime.now(), repeatOption: RepeatOption.today, isRecurring: false,
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isYearEndSummary: false,
        ),
        'Income (\$1000)': Event(
          id: 4, title: 'Test', categoryId: rule.triggerCategoryId ?? 1,
          amount: 1000.0, dateTime: DateTime.now(), repeatOption: RepeatOption.today, isRecurring: false,
          createdAt: DateTime.now(), updatedAt: DateTime.now(), isYearEndSummary: false,
        ),
      };

      final Map<String, RuleEvaluationResult> results = {};
      
      for (final entry in testScenarios.entries) {
        results[entry.key] = await _evaluateRule(rule, entry.value);
      }

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure('Failed to test rule: $e'));
    }
  }
}