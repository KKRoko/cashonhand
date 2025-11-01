import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/enums/bucket_type.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/year_end_goal.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/year_end_goal_repository.dart';

/// Time range for analytics
enum AnalyticsTimeRange {
  threeMonths,
  sixMonths,
  yearToDate,
}

/// Monthly spending data for a specific bucket
class MonthlyBucketSpending {
  final DateTime month;
  final BucketType bucket;
  final double budgeted;
  final double actual;
  final double difference;
  final double percentageUsed;

  MonthlyBucketSpending({
    required this.month,
    required this.bucket,
    required this.budgeted,
    required this.actual,
  })  : difference = budgeted - actual,
        percentageUsed = budgeted > 0 ? (actual / budgeted) * 100 : 0;

  bool get isOverspent => actual > budgeted;
}

/// Category spending data over time
class CategorySpendingTrend {
  final int categoryBudgetId;
  final String categoryName;
  final BucketType bucket;
  final Map<DateTime, double> monthlySpending; // month -> amount spent

  CategorySpendingTrend({
    required this.categoryBudgetId,
    required this.categoryName,
    required this.bucket,
    required this.monthlySpending,
  });

  double get averageMonthlySpending {
    if (monthlySpending.isEmpty) return 0;
    final total = monthlySpending.values.fold<double>(0.0, (sum, v) => sum + v);
    return total / monthlySpending.length;
  }

  double get totalSpending {
    return monthlySpending.values.fold<double>(0.0, (sum, v) => sum + v);
  }
}

/// Month-over-month comparison data
class MonthOverMonthComparison {
  final DateTime currentMonth;
  final DateTime previousMonth;
  final double currentTotal;
  final double previousTotal;
  final Map<BucketType, double> currentByBucket;
  final Map<BucketType, double> previousByBucket;

  MonthOverMonthComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.currentTotal,
    required this.previousTotal,
    required this.currentByBucket,
    required this.previousByBucket,
  });

  double get totalChange => currentTotal - previousTotal;
  double get totalChangePercentage {
    if (previousTotal == 0) return 0;
    return (totalChange / previousTotal) * 100;
  }

  Map<BucketType, double> get bucketChanges {
    final changes = <BucketType, double>{};
    for (final bucket in BucketType.values) {
      final current = currentByBucket[bucket] ?? 0.0;
      final previous = previousByBucket[bucket] ?? 0.0;
      changes[bucket] = current - previous;
    }
    return changes;
  }

  Map<BucketType, double> get bucketChangePercentages {
    final percentages = <BucketType, double>{};
    for (final bucket in BucketType.values) {
      final current = currentByBucket[bucket] ?? 0.0;
      final previous = previousByBucket[bucket] ?? 0.0;
      if (previous == 0) {
        percentages[bucket] = 0;
      } else {
        percentages[bucket] = ((current - previous) / previous) * 100;
      }
    }
    return percentages;
  }
}

/// Overspending pattern for a category
class OverspendingPattern {
  final int categoryBudgetId;
  final String categoryName;
  final BucketType bucket;
  final int monthsOverspent;
  final int totalMonths;
  final double averageOverspendAmount;

  OverspendingPattern({
    required this.categoryBudgetId,
    required this.categoryName,
    required this.bucket,
    required this.monthsOverspent,
    required this.totalMonths,
    required this.averageOverspendAmount,
  });

  double get overspendingFrequency {
    if (totalMonths == 0) return 0;
    return (monthsOverspent / totalMonths) * 100;
  }

  bool get isConsistentPattern => overspendingFrequency >= 50; // Overspent in 50%+ of months
}

/// Year-end goal progress data
class YearEndGoalProgress {
  final YearEndGoal? goal;
  final Map<BucketType, double> actualSpending; // Actual spending YTD
  final double totalAnnualIncome; // Total income from all budgets for the year
  final int monthsTracked; // How many months have budgets
  final int totalMonthsInYear; // Usually 12, but pro-rated if mid-year

  YearEndGoalProgress({
    this.goal,
    required this.actualSpending,
    required this.totalAnnualIncome,
    required this.monthsTracked,
    required this.totalMonthsInYear,
  });

  bool get hasGoal => goal != null;

  // Get dollar goal for each bucket (percentage * total annual income)
  Map<BucketType, double> get dollarGoals {
    if (goal == null) return {};

    final goals = <BucketType, double>{};
    for (final bucket in BucketType.values) {
      goals[bucket] = goal!.getBucketDollarGoal(
        bucket.toString().split('.').last,
        totalAnnualIncome,
      );
    }
    return goals;
  }

  // Progress percentage for each bucket (actual spent / dollar goal * 100)
  Map<BucketType, double> get progressPercentages {
    if (goal == null) return {};

    final percentages = <BucketType, double>{};
    final goals = dollarGoals;
    for (final bucket in BucketType.values) {
      final goalAmount = goals[bucket] ?? 0.0;
      final actual = actualSpending[bucket] ?? 0.0;
      percentages[bucket] = goalAmount > 0 ? (actual / goalAmount) * 100 : 0;
    }
    return percentages;
  }

  // Remaining amount to reach goal for each bucket
  Map<BucketType, double> get remainingAmounts {
    if (goal == null) return {};

    final remaining = <BucketType, double>{};
    final goals = dollarGoals;
    for (final bucket in BucketType.values) {
      final goalAmount = goals[bucket] ?? 0.0;
      final actual = actualSpending[bucket] ?? 0.0;
      remaining[bucket] = goalAmount - actual;
    }
    return remaining;
  }

  // Is the bucket overspent relative to goal?
  Map<BucketType, bool> get isOverspent {
    if (goal == null) return {};

    final overspent = <BucketType, bool>{};
    final goals = dollarGoals;
    for (final bucket in BucketType.values) {
      final goalAmount = goals[bucket] ?? 0.0;
      final actual = actualSpending[bucket] ?? 0.0;
      overspent[bucket] = actual > goalAmount;
    }
    return overspent;
  }
}

/// Service for budget analytics and insights
@injectable
class BudgetAnalyticsService {
  final IBudgetRepository _budgetRepository;
  final IYearEndGoalRepository _yearEndGoalRepository;

  BudgetAnalyticsService(
    this._budgetRepository,
    this._yearEndGoalRepository,
  );

  /// Get spending trends by bucket over a time range
  Future<Either<Failure, List<MonthlyBucketSpending>>> getSpendingTrends(
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      final months = _getMonthsForRange(timeRange);
      final List<MonthlyBucketSpending> trends = [];

      for (final month in months) {
        // Get budget for this month
        final budgetResult = await _budgetRepository.getBudgetByMonth(
          month.month,
          month.year,
        );

        await budgetResult.fold(
          (failure) async {
            // No budget for this month, skip
          },
          (budget) async {
            if (budget == null) return;

            // Get actual spending for each bucket
            final spendingResult = await _budgetRepository.getActualSpendingByBucket(
              budget.id,
              DateTime(month.year, month.month, budget.cycleStartDay),
              DateTime(month.year, month.month + 1, budget.cycleStartDay)
                  .subtract(const Duration(days: 1)),
            );

            await spendingResult.fold(
              (failure) async {
                // Failed to get spending, skip
              },
              (actualSpending) async {
                // Create trend data for each bucket
                for (final bucket in BucketType.values) {
                  final budgeted = _getBudgetAmountForBucket(budget, bucket);
                  final actual = actualSpending[bucket] ?? 0.0;

                  trends.add(MonthlyBucketSpending(
                    month: month,
                    bucket: bucket,
                    budgeted: budgeted,
                    actual: actual,
                  ));
                }
              },
            );
          },
        );
      }

      return Right(trends);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get spending trends: $e'));
    }
  }

  /// Get category spending breakdown over time
  Future<Either<Failure, List<CategorySpendingTrend>>> getCategoryTrends(
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      final months = _getMonthsForRange(timeRange);
      final Map<int, CategorySpendingTrend> trendMap = {};

      for (final month in months) {
        // Get budget for this month
        final budgetResult = await _budgetRepository.getBudgetByMonth(
          month.month,
          month.year,
        );

        await budgetResult.fold(
          (failure) async {},
          (budget) async {
            if (budget == null) return;

            // Get category budgets
            final categoryBudgetsResult =
                await _budgetRepository.getCategoryBudgets(budget.id);

            await categoryBudgetsResult.fold(
              (failure) async {},
              (categoryBudgets) async {
                // Get spending for each category
                final spendingResult =
                    await _budgetRepository.getActualSpendingByCategoryBudget(
                  budget.id,
                  DateTime(month.year, month.month, budget.cycleStartDay),
                  DateTime(month.year, month.month + 1, budget.cycleStartDay)
                      .subtract(const Duration(days: 1)),
                );

                await spendingResult.fold(
                  (failure) async {},
                  (categorySpending) async {
                    for (final categoryBudget in categoryBudgets) {
                      if (!trendMap.containsKey(categoryBudget.id)) {
                        trendMap[categoryBudget.id] = CategorySpendingTrend(
                          categoryBudgetId: categoryBudget.id,
                          categoryName: categoryBudget.categoryName ?? 'Unknown',
                          bucket: categoryBudget.bucketType,
                          monthlySpending: {},
                        );
                      }

                      final spent = categorySpending[categoryBudget.id] ?? 0.0;
                      trendMap[categoryBudget.id]!.monthlySpending[month] = spent;
                    }
                  },
                );
              },
            );
          },
        );
      }

      return Right(trendMap.values.toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category trends: $e'));
    }
  }

  /// Get month-over-month comparison
  Future<Either<Failure, MonthOverMonthComparison>> getMonthOverMonthComparison(
    DateTime currentMonth,
  ) async {
    try {
      final previousMonth = DateTime(
        currentMonth.year,
        currentMonth.month - 1,
        1,
      );

      // Get current month data
      final currentBudgetResult = await _budgetRepository.getBudgetByMonth(
        currentMonth.month,
        currentMonth.year,
      );

      final currentBudget = await currentBudgetResult.fold(
        (failure) => throw Exception('Failed to get current budget'),
        (budget) async => budget,
      );

      if (currentBudget == null) {
        return Left(ValidationFailure('No budget for current month'));
      }

      final currentSpendingResult = await _budgetRepository.getActualSpendingByBucket(
        currentBudget.id,
        DateTime(currentMonth.year, currentMonth.month, currentBudget.cycleStartDay),
        DateTime(currentMonth.year, currentMonth.month + 1, currentBudget.cycleStartDay)
            .subtract(const Duration(days: 1)),
      );

      final currentSpending = await currentSpendingResult.fold(
        (failure) => throw Exception('Failed to get current spending'),
        (spending) async => spending,
      );

      // Get previous month data
      final previousBudgetResult = await _budgetRepository.getBudgetByMonth(
        previousMonth.month,
        previousMonth.year,
      );

      final previousBudget = await previousBudgetResult.fold(
        (failure) => throw Exception('Failed to get previous budget'),
        (budget) async => budget,
      );

      if (previousBudget == null) {
        return Left(ValidationFailure('No budget for previous month'));
      }

      final previousSpendingResult = await _budgetRepository.getActualSpendingByBucket(
        previousBudget.id,
        DateTime(previousMonth.year, previousMonth.month, previousBudget.cycleStartDay),
        DateTime(previousMonth.year, previousMonth.month + 1, previousBudget.cycleStartDay)
            .subtract(const Duration(days: 1)),
      );

      final previousSpending = await previousSpendingResult.fold(
        (failure) => throw Exception('Failed to get previous spending'),
        (spending) async => spending,
      );

      final currentTotal = currentSpending.values.fold<double>(0.0, (sum, v) => sum + v);
      final previousTotal = previousSpending.values.fold<double>(0.0, (sum, v) => sum + v);

      return Right(MonthOverMonthComparison(
        currentMonth: currentMonth,
        previousMonth: previousMonth,
        currentTotal: currentTotal,
        previousTotal: previousTotal,
        currentByBucket: currentSpending,
        previousByBucket: previousSpending,
      ));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get month-over-month comparison: $e'));
    }
  }

  /// Get overspending patterns
  Future<Either<Failure, List<OverspendingPattern>>> getOverspendingPatterns(
    AnalyticsTimeRange timeRange,
  ) async {
    try {
      final months = _getMonthsForRange(timeRange);
      final Map<int, List<bool>> categoryOverspendingMap = {}; // categoryBudgetId -> [true/false per month]
      final Map<int, List<double>> overspendAmountsMap = {}; // categoryBudgetId -> overspend amounts
      final Map<int, String> categoryNames = {};
      final Map<int, BucketType> categoryBuckets = {};

      for (final month in months) {
        final budgetResult = await _budgetRepository.getBudgetByMonth(
          month.month,
          month.year,
        );

        await budgetResult.fold(
          (failure) async {},
          (budget) async {
            if (budget == null) return;

            final categoryBudgetsResult =
                await _budgetRepository.getCategoryBudgets(budget.id);

            await categoryBudgetsResult.fold(
              (failure) async {},
              (categoryBudgets) async {
                final spendingResult =
                    await _budgetRepository.getActualSpendingByCategoryBudget(
                  budget.id,
                  DateTime(month.year, month.month, budget.cycleStartDay),
                  DateTime(month.year, month.month + 1, budget.cycleStartDay)
                      .subtract(const Duration(days: 1)),
                );

                await spendingResult.fold(
                  (failure) async {},
                  (categorySpending) async {
                    for (final categoryBudget in categoryBudgets) {
                      if (!categoryOverspendingMap.containsKey(categoryBudget.id)) {
                        categoryOverspendingMap[categoryBudget.id] = [];
                        overspendAmountsMap[categoryBudget.id] = [];
                        categoryNames[categoryBudget.id] =
                            categoryBudget.categoryName ?? 'Unknown';
                        categoryBuckets[categoryBudget.id] = categoryBudget.bucketType;
                      }

                      final spent = categorySpending[categoryBudget.id] ?? 0.0;
                      final budgeted = categoryBudget.allocatedAmount;
                      final isOverspent = spent > budgeted;

                      categoryOverspendingMap[categoryBudget.id]!.add(isOverspent);

                      if (isOverspent) {
                        overspendAmountsMap[categoryBudget.id]!.add(spent - budgeted);
                      }
                    }
                  },
                );
              },
            );
          },
        );
      }

      // Build patterns
      final patterns = <OverspendingPattern>[];

      for (final entry in categoryOverspendingMap.entries) {
        final categoryId = entry.key;
        final overspendingFlags = entry.value;
        final monthsOverspent = overspendingFlags.where((flag) => flag).length;

        if (monthsOverspent > 0) {
          final overspendAmounts = overspendAmountsMap[categoryId] ?? [];
          final averageOverspend = overspendAmounts.isEmpty
              ? 0.0
              : overspendAmounts.fold<double>(0.0, (sum, v) => sum + v) /
                  overspendAmounts.length;

          patterns.add(OverspendingPattern(
            categoryBudgetId: categoryId,
            categoryName: categoryNames[categoryId] ?? 'Unknown',
            bucket: categoryBuckets[categoryId] ?? BucketType.needs,
            monthsOverspent: monthsOverspent,
            totalMonths: overspendingFlags.length,
            averageOverspendAmount: averageOverspend,
          ));
        }
      }

      // Sort by frequency (most frequent first)
      patterns.sort((a, b) => b.overspendingFrequency.compareTo(a.overspendingFrequency));

      return Right(patterns);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get overspending patterns: $e'));
    }
  }

  /// Helper: Get list of months for a time range
  List<DateTime> _getMonthsForRange(AnalyticsTimeRange timeRange) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final months = <DateTime>[];

    switch (timeRange) {
      case AnalyticsTimeRange.threeMonths:
        // Current month and 2 months back
        for (int i = 0; i < 3; i++) {
          months.add(DateTime(currentMonth.year, currentMonth.month - i, 1));
        }
        break;

      case AnalyticsTimeRange.sixMonths:
        // Current month and 5 months back
        for (int i = 0; i < 6; i++) {
          months.add(DateTime(currentMonth.year, currentMonth.month - i, 1));
        }
        break;

      case AnalyticsTimeRange.yearToDate:
        // From January to current month
        final yearStart = DateTime(now.year, 1, 1);
        DateTime month = currentMonth;
        while (month.isAfter(yearStart) || month.isAtSameMomentAs(yearStart)) {
          months.add(month);
          month = DateTime(month.year, month.month - 1, 1);
        }
        break;
    }

    return months.reversed.toList(); // Return in chronological order
  }

  /// Helper: Get budget amount for a specific bucket
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

  /// Get year-end goal progress for a specific year
  Future<Either<Failure, YearEndGoalProgress>> getYearEndGoalProgress(int year) async {
    try {
      // Get the goal for this year
      final goalResult = await _yearEndGoalRepository.getGoalForYear(year);

      final goal = await goalResult.fold(
        (failure) async => null,
        (goal) async => goal,
      );

      // Calculate actual spending for the year so far
      final now = DateTime.now();

      final actualSpending = <BucketType, double>{
        BucketType.needs: 0.0,
        BucketType.wants: 0.0,
        BucketType.savings: 0.0,
      };

      int monthsTracked = 0;
      double totalAnnualIncome = 0.0;

      // Iterate through each month of the year (or YTD for current year)
      for (int month = 1; month <= 12; month++) {
        final monthDate = DateTime(year, month, 1);

        // Stop if we've reached future months
        if (monthDate.isAfter(now)) break;

        // Get budget for this month
        final budgetResult = await _budgetRepository.getBudgetByMonth(month, year);

        await budgetResult.fold(
          (failure) async {
            // No budget for this month, skip
          },
          (budget) async {
            if (budget == null) return;

            monthsTracked++;
            totalAnnualIncome += budget.monthlyIncome; // Add up all monthly incomes

            // Get actual spending for this budget
            final spendingResult = await _budgetRepository.getActualSpendingByBucket(
              budget.id,
              DateTime(year, month, budget.cycleStartDay),
              DateTime(year, month + 1, budget.cycleStartDay)
                  .subtract(const Duration(days: 1)),
            );

            await spendingResult.fold(
              (failure) async {
                // Failed to get spending, skip
              },
              (spending) async {
                // Add to year totals
                for (final bucket in BucketType.values) {
                  actualSpending[bucket] =
                      (actualSpending[bucket] ?? 0.0) + (spending[bucket] ?? 0.0);
                }
              },
            );
          },
        );
      }

      // Calculate total months (12 for full year, or months elapsed for current year)
      final totalMonthsInYear = year == now.year ? now.month : 12;

      return Right(YearEndGoalProgress(
        goal: goal,
        actualSpending: actualSpending,
        totalAnnualIncome: totalAnnualIncome,
        monthsTracked: monthsTracked,
        totalMonthsInYear: totalMonthsInYear,
      ));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get year-end goal progress: $e'));
    }
  }

  /// Set or update year-end goal (percentages are 0.0-1.0, e.g., 0.50 = 50%)
  Future<Either<Failure, YearEndGoal>> setYearEndGoal({
    required int year,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) async {
    try {
      // Validate percentages sum to 100% (with 1% tolerance for floating point rounding)
      if ((needsPercentage + wantsPercentage + savingsPercentage - 1.0).abs() > 0.01) {
        return Left(ValidationFailure('Percentages must sum to 100%'));
      }

      // Check if goal already exists for this year
      final existingResult = await _yearEndGoalRepository.getGoalForYear(year);

      final existingGoal = await existingResult.fold(
        (failure) async => null,
        (goal) async => goal,
      );

      if (existingGoal != null) {
        // Update existing goal
        final updatedGoal = existingGoal.copyWith(
          needsPercentage: needsPercentage,
          wantsPercentage: wantsPercentage,
          savingsPercentage: savingsPercentage,
        );

        final updateResult = await _yearEndGoalRepository.updateGoal(updatedGoal);

        return await updateResult.fold(
          (failure) async => Left(failure),
          (success) async => Right(updatedGoal),
        );
      } else {
        // Create new goal
        final newGoal = YearEndGoal(
          id: 0, // Will be set by database
          year: year,
          needsPercentage: needsPercentage,
          wantsPercentage: wantsPercentage,
          savingsPercentage: savingsPercentage,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createResult = await _yearEndGoalRepository.createGoal(newGoal);

        return await createResult.fold(
          (failure) async => Left(failure),
          (id) async => Right(newGoal.copyWith(id: id)),
        );
      }
    } catch (e) {
      return Left(DatabaseFailure('Failed to set year-end goal: $e'));
    }
  }

  /// Delete year-end goal
  Future<Either<Failure, bool>> deleteYearEndGoal(int year) async {
    return _yearEndGoalRepository.deleteGoal(year);
  }
}
