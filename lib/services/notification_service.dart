import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import '../data/models/freezed/financial_suggestion.dart';
import '../data/models/freezed/saving_goal.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/category_budget.dart';
import '../data/models/enums/bucket_type.dart';
import '../data/repositories/saving_goal_repository.dart';
import 'financial_suggestions_engine.dart';
import 'budget_analytics_service.dart';

/// Types of notifications
enum NotificationType {
  goalAlert,
  savingsOpportunity,
  budgetWarning,
  goalMilestone,
  unusualActivity,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// A notification to be displayed to the user
class AppNotification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;

  const AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
    this.actionRoute,
    this.actionData,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionData,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionData: actionData ?? this.actionData,
    );
  }

  /// Check if notification is still active
  bool get isActive {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.goalAlert:
        return 'flag';
      case NotificationType.savingsOpportunity:
        return 'savings';
      case NotificationType.budgetWarning:
        return 'warning';
      case NotificationType.goalMilestone:
        return 'celebration';
      case NotificationType.unusualActivity:
        return 'notification_important';
    }
  }

  /// Get color for notification priority
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return 'grey';
      case NotificationPriority.normal:
        return 'blue';
      case NotificationPriority.high:
        return 'orange';
      case NotificationPriority.urgent:
        return 'red';
    }
  }
}

/// Service for managing app notifications and alerts
@injectable
class NotificationService {
  final ISavingGoalRepository _goalRepository;
  final FinancialSuggestionsEngine _suggestionsEngine;
  final BudgetAnalyticsService _analyticsService;

  // In-memory storage for notifications (could be replaced with local storage)
  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _notificationsController =
      StreamController<List<AppNotification>>.broadcast();

  NotificationService(
    this._goalRepository,
    this._suggestionsEngine,
    this._analyticsService,
  );

  /// Stream of all active notifications
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead && n.isActive).length;

  /// Check for and generate goal-related alerts
  Future<void> checkGoalAlerts() async {
    print('🔔 Notification Service: Checking goal alerts...');
    
    try {
      final goalsResult = await _goalRepository.getAllGoals();
      
      await goalsResult.fold(
        (failure) async => print('Error loading goals: ${failure.message}'),
        (goals) async {
          for (final goal in goals) {
            await _checkIndividualGoalAlerts(goal);
                    }
        },
      );

      _notifyListeners();
    } catch (e) {
      print('Error checking goal alerts: $e');
    }
  }

  /// Check alerts for a specific goal
  Future<void> _checkIndividualGoalAlerts(SavingGoal goal) async {
    final now = DateTime.now();
    final daysRemaining = goal.deadlineDate?.difference(now).inDays;
    final progress = goal.currentAmount / goal.targetAmount;
    
    // Goal deadline approaching (7 days warning)
    if (daysRemaining != null && daysRemaining <= 7 && daysRemaining > 0 && progress < 0.9) {
      final notificationId = 'goal_deadline_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalAlert,
          priority: NotificationPriority.high,
          title: '⏰ Goal Deadline Approaching',
          body: 'Your "${goal.title}" goal is due in $daysRemaining days. You\'re ${(progress * 100).toStringAsFixed(0)}% complete.',
          data: {'goalId': goal.id},
          createdAt: now,
          expiresAt: goal.deadlineDate,
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal overdue
    if (daysRemaining != null && daysRemaining < 0 && progress < 1.0) {
      final notificationId = 'goal_overdue_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalAlert,
          priority: NotificationPriority.urgent,
          title: '🚨 Goal Overdue',
          body: 'Your "${goal.title}" goal is ${daysRemaining.abs()} days overdue. Consider updating the target date.',
          data: {'goalId': goal.id},
          createdAt: now,
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal milestone celebrations
    if (progress >= 0.25 && progress < 0.3) {
      final notificationId = 'goal_milestone_25_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 25% Progress!',
          body: 'Great job! You\'re 25% of the way to your "${goal.title}" goal.',
          data: {'goalId': goal.id, 'milestone': 0.25},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    if (progress >= 0.5 && progress < 0.55) {
      final notificationId = 'goal_milestone_50_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 Halfway There!',
          body: 'Amazing! You\'re 50% of the way to your "${goal.title}" goal.',
          data: {'goalId': goal.id, 'milestone': 0.5},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    if (progress >= 0.75 && progress < 0.8) {
      final notificationId = 'goal_milestone_75_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 Almost There!',
          body: 'You\'re 75% complete on your "${goal.title}" goal. The finish line is in sight!',
          data: {'goalId': goal.id, 'milestone': 0.75},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal completed
    if (progress >= 1.0) {
      final notificationId = 'goal_completed_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.high,
          title: '🎉 Goal Completed!',
          body: 'Congratulations! You\'ve reached your "${goal.title}" goal of \$${goal.targetAmount.toStringAsFixed(2)}!',
          data: {'goalId': goal.id, 'milestone': 1.0},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 30)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }
  }

  /// Check for and generate budget threshold alerts
  void checkBudgetThresholdAlerts({
    required Budget budget,
    required Map<BucketType, double> bucketSpending,
    required Map<int, double> categorySpending,
    required Map<BucketType, List<CategoryBudget>> categoryBudgets,
    double? actualIncome,
  }) {
    print('🔔 Notification Service: Checking budget threshold alerts...');

    try {
      final now = DateTime.now();

      // Check bucket-level thresholds
      _checkBucketThresholds(
        budget: budget,
        bucketSpending: bucketSpending,
        now: now,
      );

      // Check category-level thresholds
      _checkCategoryThresholds(
        budget: budget,
        categorySpending: categorySpending,
        categoryBudgets: categoryBudgets,
        now: now,
      );

      // Check overall budget threshold
      _checkOverallBudgetThreshold(
        budget: budget,
        bucketSpending: bucketSpending,
        now: now,
      );

      // Check income variance
      if (actualIncome != null) {
        _checkIncomeVariance(
          budget: budget,
          actualIncome: actualIncome,
          now: now,
        );
      }

      _notifyListeners();
    } catch (e) {
      print('Error checking budget threshold alerts: $e');
    }
  }

  /// Check bucket-level spending thresholds
  void _checkBucketThresholds({
    required Budget budget,
    required Map<BucketType, double> bucketSpending,
    required DateTime now,
  }) {
    for (final bucket in BucketType.values) {
      final budgeted = _getBudgetAmountForBucket(budget, bucket);
      final spent = bucketSpending[bucket] ?? 0.0;

      if (budgeted <= 0) continue;

      final percentage = (spent / budgeted) * 100;
      final bucketLabel = _getBucketLabel(bucket);

      // 100% threshold - urgent
      if (percentage >= 100 && percentage < 105) {
        final notificationId = 'budget_bucket_100_${budget.id}_${bucket.name}';
        if (!_hasNotification(notificationId)) {
          _addNotification(AppNotification(
            id: notificationId,
            type: NotificationType.budgetWarning,
            priority: NotificationPriority.urgent,
            title: '🚨 $bucketLabel Budget Exceeded',
            body: 'You\'ve spent \$${spent.toStringAsFixed(2)} of your \$${budgeted.toStringAsFixed(2)} $bucketLabel budget (${percentage.toStringAsFixed(0)}%).',
            data: {
              'budgetId': budget.id,
              'bucket': bucket.name,
              'budgeted': budgeted,
              'spent': spent,
              'percentage': percentage,
            },
            createdAt: now,
            expiresAt: _getBudgetCycleEnd(budget),
            actionRoute: '/budget',
            actionData: {'highlightBucket': bucket.name},
          ));
        }
      }
      // 90% threshold - high
      else if (percentage >= 90 && percentage < 95) {
        final notificationId = 'budget_bucket_90_${budget.id}_${bucket.name}';
        if (!_hasNotification(notificationId)) {
          final remaining = budgeted - spent;
          _addNotification(AppNotification(
            id: notificationId,
            type: NotificationType.budgetWarning,
            priority: NotificationPriority.high,
            title: '⚠️ $bucketLabel Budget Almost Used',
            body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $bucketLabel budget. Only \$${remaining.toStringAsFixed(2)} remaining.',
            data: {
              'budgetId': budget.id,
              'bucket': bucket.name,
              'budgeted': budgeted,
              'spent': spent,
              'percentage': percentage,
            },
            createdAt: now,
            expiresAt: _getBudgetCycleEnd(budget),
            actionRoute: '/budget',
            actionData: {'highlightBucket': bucket.name},
          ));
        }
      }
      // 80% threshold - normal
      else if (percentage >= 80 && percentage < 85) {
        final notificationId = 'budget_bucket_80_${budget.id}_${bucket.name}';
        if (!_hasNotification(notificationId)) {
          final remaining = budgeted - spent;
          _addNotification(AppNotification(
            id: notificationId,
            type: NotificationType.budgetWarning,
            priority: NotificationPriority.normal,
            title: '💡 $bucketLabel Budget Update',
            body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your $bucketLabel budget. \$${remaining.toStringAsFixed(2)} remaining.',
            data: {
              'budgetId': budget.id,
              'bucket': bucket.name,
              'budgeted': budgeted,
              'spent': spent,
              'percentage': percentage,
            },
            createdAt: now,
            expiresAt: _getBudgetCycleEnd(budget),
            actionRoute: '/budget',
            actionData: {'highlightBucket': bucket.name},
          ));
        }
      }
    }
  }

  /// Check category-level spending thresholds
  void _checkCategoryThresholds({
    required Budget budget,
    required Map<int, double> categorySpending,
    required Map<BucketType, List<CategoryBudget>> categoryBudgets,
    required DateTime now,
  }) {
    for (final bucket in BucketType.values) {
      final categories = categoryBudgets[bucket] ?? [];

      for (final categoryBudget in categories) {
        final budgeted = categoryBudget.allocatedAmount;
        final spent = categorySpending[categoryBudget.id] ?? 0.0;

        if (budgeted <= 0) continue;

        final percentage = (spent / budgeted) * 100;
        final categoryName = categoryBudget.categoryName ?? 'Unknown';

        // Only alert at 100% for categories (to avoid notification overload)
        if (percentage >= 100 && percentage < 105) {
          final notificationId = 'budget_category_100_${categoryBudget.id}';
          if (!_hasNotification(notificationId)) {
            _addNotification(AppNotification(
              id: notificationId,
              type: NotificationType.budgetWarning,
              priority: NotificationPriority.high,
              title: '⚠️ Category Budget Exceeded',
              body: '$categoryName has exceeded its budget. Spent \$${spent.toStringAsFixed(2)} of \$${budgeted.toStringAsFixed(2)}.',
              data: {
                'budgetId': budget.id,
                'categoryBudgetId': categoryBudget.id,
                'categoryName': categoryName,
                'bucket': bucket.name,
                'budgeted': budgeted,
                'spent': spent,
                'percentage': percentage,
              },
              createdAt: now,
              expiresAt: _getBudgetCycleEnd(budget),
              actionRoute: '/budget/category/${categoryBudget.id}',
            ));
          }
        }
      }
    }
  }

  /// Check overall budget threshold
  void _checkOverallBudgetThreshold({
    required Budget budget,
    required Map<BucketType, double> bucketSpending,
    required DateTime now,
  }) {
    final totalBudgeted = budget.needsAmount + budget.wantsAmount + budget.savingsAmount;
    final totalSpent = bucketSpending.values.fold<double>(0.0, (sum, v) => sum + v);

    if (totalBudgeted <= 0) return;

    final percentage = (totalSpent / totalBudgeted) * 100;

    // 100% threshold - urgent
    if (percentage >= 100 && percentage < 105) {
      final notificationId = 'budget_overall_100_${budget.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.budgetWarning,
          priority: NotificationPriority.urgent,
          title: '🚨 Monthly Budget Exceeded',
          body: 'You\'ve exceeded your total monthly budget. Spent \$${totalSpent.toStringAsFixed(2)} of \$${totalBudgeted.toStringAsFixed(2)}.',
          data: {
            'budgetId': budget.id,
            'totalBudgeted': totalBudgeted,
            'totalSpent': totalSpent,
            'percentage': percentage,
          },
          createdAt: now,
          expiresAt: _getBudgetCycleEnd(budget),
          actionRoute: '/budget',
        ));
      }
    }
    // 90% threshold - high
    else if (percentage >= 90 && percentage < 95) {
      final notificationId = 'budget_overall_90_${budget.id}';
      if (!_hasNotification(notificationId)) {
        final remaining = totalBudgeted - totalSpent;
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.budgetWarning,
          priority: NotificationPriority.high,
          title: '⚠️ Monthly Budget Almost Used',
          body: 'You\'ve used ${percentage.toStringAsFixed(0)}% of your total budget. Only \$${remaining.toStringAsFixed(2)} remaining.',
          data: {
            'budgetId': budget.id,
            'totalBudgeted': totalBudgeted,
            'totalSpent': totalSpent,
            'percentage': percentage,
          },
          createdAt: now,
          expiresAt: _getBudgetCycleEnd(budget),
          actionRoute: '/budget',
        ));
      }
    }
  }

  /// Check income variance
  void _checkIncomeVariance({
    required Budget budget,
    required double actualIncome,
    required DateTime now,
  }) {
    final budgetedIncome = budget.monthlyIncome;
    final variance = actualIncome - budgetedIncome;

    if (budgetedIncome <= 0) return;

    // Only check if we're past mid-month (day 15 or later)
    if (now.day < 15) return;

    // Calculate percentage shortfall
    final percentageShortfall = (variance.abs() / budgetedIncome) * 100;

    // Only alert if income is significantly below budget (15% or more)
    if (variance < 0 && percentageShortfall >= 15) {
      final notificationId = 'income_variance_${budget.id}_${now.month}_${now.year}';

      if (!_hasNotification(notificationId)) {
        final priority = percentageShortfall >= 25
            ? NotificationPriority.high
            : NotificationPriority.normal;

        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.budgetWarning,
          priority: priority,
          title: '⚠️ Income Below Budget',
          body: 'Your actual income (\$${actualIncome.toStringAsFixed(0)}) is ${percentageShortfall.toStringAsFixed(0)}% below your budgeted income (\$${budgetedIncome.toStringAsFixed(0)}). Consider reviewing your spending to stay on track.',
          data: {
            'budgetId': budget.id,
            'budgetedIncome': budgetedIncome,
            'actualIncome': actualIncome,
            'variance': variance,
            'percentageShortfall': percentageShortfall,
          },
          createdAt: now,
          expiresAt: _getBudgetCycleEnd(budget),
          actionRoute: '/budget',
        ));
      }
    }
  }

  /// Get budget amount for a specific bucket
  double _getBudgetAmountForBucket(Budget budget, BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return budget.needsAmount;
      case BucketType.wants:
        return budget.wantsAmount;
      case BucketType.savings:
        return budget.savingsAmount;
    }
  }

  /// Get bucket label
  String _getBucketLabel(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  /// Get budget cycle end date
  DateTime _getBudgetCycleEnd(Budget budget) {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, budget.cycleStartDay);
  }

  /// Generate end-of-cycle budget summary notification
  void generateBudgetCycleSummary({
    required Budget budget,
    required Map<BucketType, double> bucketSpending,
    required Map<int, double> categorySpending,
    required Map<BucketType, List<CategoryBudget>> categoryBudgets,
  }) {
    print('🔔 Notification Service: Generating budget cycle summary...');

    try {
      final now = DateTime.now();
      final notificationId = 'budget_summary_${budget.id}';

      // Don't create duplicate summaries
      if (_hasNotification(notificationId)) return;

      final totalBudgeted = budget.needsAmount + budget.wantsAmount + budget.savingsAmount;
      final totalSpent = bucketSpending.values.fold<double>(0.0, (sum, v) => sum + v);
      final difference = totalBudgeted - totalSpent;
      final isUnderBudget = totalSpent <= totalBudgeted;
      final percentage = totalBudgeted > 0 ? (totalSpent / totalBudgeted) * 100 : 0.0;

      // Calculate bucket performance
      final bucketPerformance = <BucketType, String>{};
      for (final bucket in BucketType.values) {
        final budgeted = _getBudgetAmountForBucket(budget, bucket);
        final spent = bucketSpending[bucket] ?? 0.0;
        if (budgeted > 0) {
          final bucketPercentage = (spent / budgeted) * 100;
          if (bucketPercentage > 100) {
            bucketPerformance[bucket] = 'over by \$${(spent - budgeted).toStringAsFixed(0)}';
          } else {
            bucketPerformance[bucket] = 'saved \$${(budgeted - spent).toStringAsFixed(0)}';
          }
        }
      }

      // Find top performing categories (most under budget)
      final categoryPerformances = <String, double>{};
      for (final bucket in BucketType.values) {
        final categories = categoryBudgets[bucket] ?? [];
        for (final categoryBudget in categories) {
          final budgeted = categoryBudget.allocatedAmount;
          final spent = categorySpending[categoryBudget.id] ?? 0.0;
          if (budgeted > 0) {
            final surplus = budgeted - spent;
            if (surplus > 0) {
              categoryPerformances[categoryBudget.categoryName ?? 'Unknown'] = surplus;
            }
          }
        }
      }

      // Get top 2 performing categories
      final topCategories = categoryPerformances.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topPerformers = topCategories.take(2).toList();

      // Build summary body
      final bodyParts = <String>[];

      if (isUnderBudget) {
        bodyParts.add('Great job! You stayed \$${difference.abs().toStringAsFixed(2)} under budget (${percentage.toStringAsFixed(0)}% used).');
      } else {
        bodyParts.add('You went \$${difference.abs().toStringAsFixed(2)} over budget (${percentage.toStringAsFixed(0)}% used).');
      }

      bodyParts.add('');
      bodyParts.add('Bucket Performance:');
      for (final entry in bucketPerformance.entries) {
        bodyParts.add('• ${_getBucketLabel(entry.key)}: ${entry.value}');
      }

      if (topPerformers.isNotEmpty) {
        bodyParts.add('');
        bodyParts.add('Top Savers:');
        for (final performer in topPerformers) {
          bodyParts.add('• ${performer.key}: +\$${performer.value.toStringAsFixed(0)}');
        }
      }

      _addNotification(AppNotification(
        id: notificationId,
        type: isUnderBudget ? NotificationType.goalMilestone : NotificationType.budgetWarning,
        priority: NotificationPriority.normal,
        title: isUnderBudget ? '🎉 Budget Cycle Complete!' : '📊 Budget Cycle Summary',
        body: bodyParts.join('\n'),
        data: {
          'budgetId': budget.id,
          'totalBudgeted': totalBudgeted,
          'totalSpent': totalSpent,
          'difference': difference,
          'isUnderBudget': isUnderBudget,
          'percentage': percentage,
        },
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
        actionRoute: '/budget/summary',
        actionData: {
          'budgetId': budget.id,
          'month': now.month,
          'year': now.year,
        },
      ));

      _notifyListeners();
    } catch (e) {
      print('Error generating budget cycle summary: $e');
    }
  }

  /// Generate pattern-based budget suggestions using analytics
  Future<void> generatePatternBasedSuggestions({
    AnalyticsTimeRange timeRange = AnalyticsTimeRange.threeMonths,
  }) async {
    print('🔔 Notification Service: Generating pattern-based suggestions...');

    try {
      final now = DateTime.now();

      // Get overspending patterns from analytics
      final patternsResult = await _analyticsService.getOverspendingPatterns(timeRange);

      await patternsResult.fold(
        (failure) async {
          print('Error getting overspending patterns: ${failure.message}');
        },
        (patterns) async {
          // Generate suggestions for consistent overspending patterns
          for (final pattern in patterns) {
            if (pattern.isConsistentPattern) {
              final notificationId = 'budget_pattern_${pattern.categoryBudgetId}_${timeRange.name}';

              // Don't create duplicate pattern notifications
              if (_hasNotification(notificationId)) continue;

              // Build suggestion body
              final bodyParts = <String>[];
              bodyParts.add('${pattern.categoryName} has been over budget in ${pattern.monthsOverspent} of the last ${pattern.totalMonths} months (${pattern.overspendingFrequency.toStringAsFixed(0)}%).');
              bodyParts.add('');
              bodyParts.add('Average overspend: \$${pattern.averageOverspendAmount.toStringAsFixed(2)}');
              bodyParts.add('');
              bodyParts.add('Consider:');
              bodyParts.add('• Increasing the budget for this category');
              bodyParts.add('• Reviewing transactions to identify savings opportunities');
              bodyParts.add('• Setting spending alerts for this category');

              _addNotification(AppNotification(
                id: notificationId,
                type: NotificationType.savingsOpportunity,
                priority: NotificationPriority.normal,
                title: '💡 Budget Adjustment Suggestion',
                body: bodyParts.join('\n'),
                data: {
                  'categoryBudgetId': pattern.categoryBudgetId,
                  'categoryName': pattern.categoryName,
                  'bucket': pattern.bucket.name,
                  'monthsOverspent': pattern.monthsOverspent,
                  'totalMonths': pattern.totalMonths,
                  'frequency': pattern.overspendingFrequency,
                  'averageOverspend': pattern.averageOverspendAmount,
                  'timeRange': timeRange.name,
                },
                createdAt: now,
                expiresAt: now.add(const Duration(days: 14)),
                actionRoute: '/budget/analytics',
              ));
            }
          }

          // Get spending trends for underspending insights
          final trendsResult = await _analyticsService.getCategoryTrends(timeRange);

          await trendsResult.fold(
            (failure) async {
              print('Error getting category trends: ${failure.message}');
            },
            (trends) async {
              // Find categories consistently under budget
              for (final trend in trends) {
                if (trend.monthlySpending.length < 2) continue;

                // Calculate if consistently underspent
                final budgetedValues = trend.monthlySpending.values.toList();
                final avgSpending = trend.averageMonthlySpending;

                // If spending is less than 70% on average, suggest reallocation
                if (avgSpending > 0) {
                  // We don't have budgeted amounts in the trend, but we can suggest
                  // based on very low spending compared to other categories
                  final isLowSpending = budgetedValues.every((v) => v < 50);

                  if (isLowSpending && avgSpending < 20) {
                    final notificationId = 'budget_underutilized_${trend.categoryBudgetId}_${timeRange.name}';

                    if (!_hasNotification(notificationId)) {
                      _addNotification(AppNotification(
                        id: notificationId,
                        type: NotificationType.savingsOpportunity,
                        priority: NotificationPriority.low,
                        title: '💡 Potential Budget Reallocation',
                        body: '${trend.categoryName} has consistently low spending (\$${avgSpending.toStringAsFixed(2)}/month average). Consider reallocating funds to categories you use more.',
                        data: {
                          'categoryBudgetId': trend.categoryBudgetId,
                          'categoryName': trend.categoryName,
                          'bucket': trend.bucket.name,
                          'averageSpending': avgSpending,
                          'timeRange': timeRange.name,
                        },
                        createdAt: now,
                        expiresAt: now.add(const Duration(days: 14)),
                        actionRoute: '/budget',
                      ));
                    }
                  }
                }
              }
            },
          );

          _notifyListeners();
        },
      );
    } catch (e) {
      print('Error generating pattern-based suggestions: $e');
    }
  }

  /// Convert financial suggestions to notifications
  Future<void> processFinancialSuggestions() async {
    print('🔔 Notification Service: Processing financial suggestions...');

    try {
      final suggestionsResult = await _suggestionsEngine.generateAllSuggestions();

      suggestionsResult.fold(
        (failure) => print('Error generating suggestions: ${failure.message}'),
        (suggestions) {
          for (final suggestion in suggestions) {
            _convertSuggestionToNotification(suggestion);
          }
          _notifyListeners();
        },
      );
    } catch (e) {
      print('Error processing financial suggestions: $e');
    }
  }

  /// Convert a financial suggestion to a notification
  void _convertSuggestionToNotification(FinancialSuggestion suggestion) {
    final notificationId = 'suggestion_${suggestion.id}';
    
    // Don't create duplicate notifications
    if (_hasNotification(notificationId)) return;

    final notificationType = _getNotificationTypeFromSuggestion(suggestion.type);
    final priority = _getNotificationPriority(suggestion.priority);

    _addNotification(AppNotification(
      id: notificationId,
      type: notificationType,
      priority: priority,
      title: suggestion.title,
      body: suggestion.description,
      data: {
        'suggestionId': suggestion.id,
        'suggestionType': suggestion.type.toString(),
        'potentialSavings': suggestion.potentialSavings,
        'relatedGoalId': suggestion.relatedGoalId,
        'relatedCategoryId': suggestion.relatedCategoryId,
      },
      createdAt: suggestion.createdAt,
      expiresAt: suggestion.expiresAt,
      actionRoute: suggestion.actionRoute,
      actionData: suggestion.actionData,
    ));
  }

  /// Get notification type from suggestion type
  NotificationType _getNotificationTypeFromSuggestion(SuggestionType suggestionType) {
    switch (suggestionType) {
      case SuggestionType.savingsOpportunity:
      case SuggestionType.roundUpOptimization:
      case SuggestionType.allocationImprovement:
        return NotificationType.savingsOpportunity;
      case SuggestionType.budgetWarning:
        return NotificationType.budgetWarning;
      case SuggestionType.goalRecommendation:
        return NotificationType.goalAlert;
      case SuggestionType.goalMilestone:
        return NotificationType.goalMilestone;
      case SuggestionType.unusualActivity:
        return NotificationType.unusualActivity;
      default:
        return NotificationType.savingsOpportunity;
    }
  }

  /// Get notification priority from suggestion priority
  NotificationPriority _getNotificationPriority(SuggestionPriority suggestionPriority) {
    switch (suggestionPriority) {
      case SuggestionPriority.low:
        return NotificationPriority.low;
      case SuggestionPriority.medium:
        return NotificationPriority.normal;
      case SuggestionPriority.high:
        return NotificationPriority.high;
      case SuggestionPriority.urgent:
        return NotificationPriority.urgent;
    }
  }

  /// Add a notification to the list
  void _addNotification(AppNotification notification) {
    _notifications.add(notification);
    
    // Keep only the most recent 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeAt(0);
    }
    
    if (kDebugMode) {
      print('🔔 Added notification: ${notification.title}');
    }
  }

  /// Check if a notification with the given ID already exists
  bool _hasNotification(String id) {
    return _notifications.any((n) => n.id == id);
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  /// Get active notifications (not expired)
  List<AppNotification> getActiveNotifications() {
    return _notifications.where((n) => n.isActive).toList();
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type && n.isActive).toList();
  }

  /// Get high priority notifications
  List<AppNotification> getHighPriorityNotifications() {
    return _notifications.where((n) => 
      (n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent) 
      && n.isActive
    ).toList();
  }

  /// Run comprehensive notification check
  Future<void> runComprehensiveCheck() async {
    print('🔔 Notification Service: Running comprehensive check...');
    
    // Clean up expired notifications first
    _cleanupExpiredNotifications();
    
    // Check goal alerts
    await checkGoalAlerts();
    
    // Process financial suggestions
    await processFinancialSuggestions();
    
    print('🔔 Notification Service: Comprehensive check complete. ${_notifications.length} total notifications.');
  }

  /// Clean up expired notifications
  void _cleanupExpiredNotifications() {
    final sizeBefore = _notifications.length;
    _notifications.removeWhere((n) => !n.isActive);
    final sizeAfter = _notifications.length;
    
    if (sizeBefore != sizeAfter) {
      print('🔔 Cleaned up ${sizeBefore - sizeAfter} expired notifications');
      _notifyListeners();
    }
  }

  /// Notify all listeners of notification changes
  void _notifyListeners() {
    if (!_notificationsController.isClosed) {
      _notificationsController.add(List.unmodifiable(_notifications));
    }
  }

  /// Schedule periodic notification checks
  Timer? _periodicTimer;

  void startPeriodicChecks({Duration interval = const Duration(hours: 6)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) {
      runComprehensiveCheck();
    });
    
    // Run initial check
    runComprehensiveCheck();
  }

  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Dispose of resources
  void dispose() {
    _periodicTimer?.cancel();
    _notificationsController.close();
  }
}