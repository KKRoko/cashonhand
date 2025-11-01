import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/category_budget.dart';
import '../data/models/enums/bucket_type.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/i_category_repository.dart';
import 'category_bucket_mapper.dart';

@singleton
class BudgetService {
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;
  final CategoryBucketMapper _bucketMapper;

  BudgetService(
    this._budgetRepository,
    this._categoryRepository,
    this._bucketMapper,
  );

  /// Get the currently active budget
  Future<Either<Failure, Budget?>> getActiveBudget() {
    return _budgetRepository.getActiveBudget();
  }

  /// Get budget for a specific month/year
  Future<Either<Failure, Budget?>> getBudgetForMonth(int month, int year) {
    return _budgetRepository.getBudgetByMonth(month, year);
  }

  /// Create a new budget with default category mappings
  /// This will auto-map all existing categories to buckets
  Future<Either<Failure, int>> createBudgetWithDefaults({
    required int month,
    required int year,
    required double monthlyIncome,
    required int cycleStartDay,
    double needsPercentage = 0.50,
    double wantsPercentage = 0.30,
    double savingsPercentage = 0.20,
  }) async {
    // Validate percentages sum to 100% (with 1% tolerance for floating point rounding)
    if ((needsPercentage + wantsPercentage + savingsPercentage - 1.0).abs() > 0.01) {
      return Left(ValidationFailure('Percentages must sum to 100%'));
    }

    // Create the budget
    final budget = Budget(
      id: 0, // Will be set by database
      month: month,
      year: year,
      monthlyIncome: monthlyIncome,
      cycleStartDay: cycleStartDay,
      needsPercentage: needsPercentage,
      wantsPercentage: wantsPercentage,
      savingsPercentage: savingsPercentage,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final createResult = await _budgetRepository.createBudget(budget);

    return createResult.fold(
      (failure) => Left(failure),
      (budgetId) async {
        // Auto-create category budgets for all expense categories
        await _createDefaultCategoryBudgets(budgetId, budget);
        return Right(budgetId);
      },
    );
  }

  /// Auto-create category budgets for all active expense categories
  Future<void> _createDefaultCategoryBudgets(int budgetId, Budget budget) async {
    // Get only expense child categories (excludes parent/folder categories)
    final categoriesResult = await _categoryRepository.getExpenseChildCategories();

    await categoriesResult.fold(
      (failure) async {
        // Log error but don't fail budget creation
        print('Warning: Could not load categories for budget setup: $failure');
      },
      (categories) async {
        // categories are already filtered to only child expense categories

        // Create category budgets with zero initial allocation
        // Users will manually allocate amounts later
        for (final category in categories) {
          final suggestedBucket = _bucketMapper.suggestBucket(category.name);

          final categoryBudget = CategoryBudget(
            id: 0, // Will be set by database
            budgetId: budgetId,
            categoryId: category.id,
            allocatedAmount: 0.0, // Start with zero, user will allocate
            bucketType: suggestedBucket,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            categoryName: category.name,
          );

          await _budgetRepository.createCategoryBudget(categoryBudget);
        }
      },
    );
  }

  /// Update budget settings (income, percentages, cycle day)
  Future<Either<Failure, bool>> updateBudget(Budget budget) {
    return _budgetRepository.updateBudget(budget);
  }

  /// Delete a budget and all its associated category budgets
  Future<Either<Failure, bool>> deleteBudget(int budgetId) {
    return _budgetRepository.deleteBudget(budgetId);
  }

  /// Get all category budgets for a budget, grouped by bucket
  Future<Either<Failure, Map<BucketType, List<CategoryBudget>>>> getCategoryBudgetsByBucket(int budgetId) async {
    final result = await _budgetRepository.getCategoryBudgets(budgetId);

    return result.fold(
      (failure) => Left(failure),
      (categoryBudgets) {
        final grouped = <BucketType, List<CategoryBudget>>{
          BucketType.needs: [],
          BucketType.wants: [],
          BucketType.savings: [],
        };

        for (final cb in categoryBudgets) {
          grouped[cb.bucketType]?.add(cb);
        }

        return Right(grouped);
      },
    );
  }

  /// Update a category budget allocation amount
  Future<Either<Failure, bool>> updateCategoryBudget(CategoryBudget categoryBudget) async {
    // Allow over-allocation - UI will show visual warnings when budget is exceeded
    return await _budgetRepository.updateCategoryBudget(categoryBudget);
  }

  /// Move a category to a different bucket
  Future<Either<Failure, bool>> moveCategoryToBucket(
    CategoryBudget categoryBudget,
    BucketType newBucket,
  ) {
    final updated = categoryBudget.copyWith(bucketType: newBucket);
    return _budgetRepository.updateCategoryBudget(updated);
  }

  /// Delete all category budgets for a budget
  /// Used when replacing allocations (e.g., when applying a template)
  Future<Either<Failure, int>> clearAllCategoryBudgets(int budgetId) async {
    final result = await _budgetRepository.getCategoryBudgets(budgetId);

    return await result.fold(
      (failure) => Left(failure),
      (categoryBudgets) async {
        int deletedCount = 0;

        for (final cb in categoryBudgets) {
          final deleteResult = await _budgetRepository.deleteCategoryBudget(cb.id);
          deleteResult.fold(
            (failure) {
              // Log error but continue deleting others
              print('Warning: Failed to delete category budget ${cb.id}: ${failure.message}');
            },
            (_) {
              deletedCount++;
            },
          );
        }

        return Right(deletedCount);
      },
    );
  }

  /// Calculate total allocated for a bucket
  Future<Either<Failure, double>> getTotalAllocatedForBucket(int budgetId, BucketType bucket) async {
    final result = await _budgetRepository.getCategoryBudgetsByBucket(budgetId, bucket);

    return result.fold(
      (failure) => Left(failure),
      (categoryBudgets) {
        final total = categoryBudgets.fold<double>(
          0.0,
          (sum, cb) => sum + cb.allocatedAmount,
        );
        return Right(total);
      },
    );
  }

  /// Get unallocated amount for a bucket (budget amount - allocated amount)
  Future<Either<Failure, double>> getUnallocatedForBucket(Budget budget, BucketType bucket) async {
    final budgetAmount = budget.getBucketAmount(bucket.toString().split('.').last);
    final allocatedResult = await getTotalAllocatedForBucket(budget.id, bucket);

    return allocatedResult.fold(
      (failure) => Left(failure),
      (allocated) => Right(budgetAmount - allocated),
    );
  }

  /// Check if budget is fully allocated across all categories
  Future<Either<Failure, bool>> isBudgetFullyAllocated(Budget budget) async {
    for (final bucket in BucketType.values) {
      final unallocatedResult = await getUnallocatedForBucket(budget, bucket);
      final isUnallocated = unallocatedResult.fold(
        (failure) => false,
        (unallocated) => unallocated.abs() > 0.01, // Allow small rounding errors
      );

      if (isUnallocated) {
        return const Right(false);
      }
    }

    return const Right(true);
  }

  /// Suggest bucket for a category name (for UI hints)
  BucketType suggestBucketForCategory(String categoryName) {
    return _bucketMapper.suggestBucket(categoryName);
  }

  /// Get explanation for why a category was mapped to a bucket
  String getMappingReason(String categoryName, BucketType bucket) {
    return _bucketMapper.getReasonForMapping(categoryName, bucket);
  }

  /// Clean up any category budgets that incorrectly reference income categories
  /// This is a migration/fix for budgets created before the expense filter was added
  Future<int> cleanupIncomeCategoryBudgets() async {
    try {
      final deleted = await _budgetRepository.deleteIncomeCategoryBudgets();
      if (deleted > 0) {
        print('🧹 Budget cleanup: Removed $deleted income category budget(s)');
      }
      return deleted;
    } catch (e) {
      print('⚠️ Budget cleanup failed: $e');
      return 0;
    }
  }

  /// Calculate the current budget cycle date range
  (DateTime start, DateTime end) getCurrentCycleDates(Budget budget) {
    final now = DateTime.now();
    return getCycleDatesForMonth(budget, now);
  }

  /// Calculate budget cycle dates for a specific month
  /// Respects the cycleStartDay to support custom billing cycles
  (DateTime start, DateTime end) getCycleDatesForMonth(Budget budget, DateTime month) {
    final cycleDay = budget.cycleStartDay;

    // Calculate cycle start date
    // If cycleStartDay is 1, cycle runs from 1st to last day of month
    // If cycleStartDay is 15, cycle runs from 15th of this month to 14th of next month
    final DateTime cycleStart;
    final DateTime cycleEnd;

    if (cycleDay == 1) {
      // Standard month: 1st to last day
      cycleStart = DateTime(month.year, month.month, 1);
      cycleEnd = DateTime(month.year, month.month + 1, 1).subtract(const Duration(seconds: 1));
    } else {
      // Custom cycle: cycleDay of this month to (cycleDay - 1) of next month
      cycleStart = DateTime(month.year, month.month, cycleDay);

      // End is the day before cycle start in the next month
      // e.g., if cycle starts on 15th, it ends on 14th of next month at 23:59:59
      final nextCycleStart = DateTime(month.year, month.month + 1, cycleDay);
      cycleEnd = nextCycleStart.subtract(const Duration(seconds: 1));
    }

    print('📅 SERVICE: Cycle dates for ${month.month}/${month.year} (cycle day ${cycleDay}): $cycleStart to $cycleEnd');
    return (cycleStart, cycleEnd);
  }

  /// Get actual spending by bucket for the current budget cycle
  Future<Either<Failure, Map<BucketType, double>>> getActualSpendingForCurrentCycle(Budget budget) async {
    final (start, end) = getCurrentCycleDates(budget);
    return _budgetRepository.getActualSpendingByBucket(budget.id, start, end);
  }

  /// Get actual spending by bucket for a specific month
  Future<Either<Failure, Map<BucketType, double>>> getActualSpendingForMonth(
    Budget budget,
    DateTime month,
  ) async {
    final (start, end) = getCycleDatesForMonth(budget, month);
    print('💰 SERVICE: Getting spending for ${month.month}/${month.year} from $start to $end');
    return _budgetRepository.getActualSpendingByBucket(budget.id, start, end);
  }

  /// Get actual spending per category budget for a specific month
  Future<Either<Failure, Map<int, double>>> getCategorySpendingForMonth(
    Budget budget,
    DateTime month,
  ) async {
    final (start, end) = getCycleDatesForMonth(budget, month);
    print('💰 SERVICE: Getting category spending for ${month.month}/${month.year}');
    return _budgetRepository.getActualSpendingByCategoryBudget(budget.id, start, end);
  }

  /// Get actual income for a specific month
  Future<Either<Failure, double>> getActualIncomeForMonth(
    Budget budget,
    DateTime month,
  ) async {
    final (start, end) = getCycleDatesForMonth(budget, month);
    print('💵 SERVICE: Getting actual income for ${month.month}/${month.year} from $start to $end');
    return _budgetRepository.getActualIncomeForMonth(start, end);
  }

  /// Get actual spending by bucket for a specific date range
  Future<Either<Failure, Map<BucketType, double>>> getActualSpendingForRange(
    Budget budget,
    DateTime start,
    DateTime end,
  ) async {
    return _budgetRepository.getActualSpendingByBucket(budget.id, start, end);
  }

  /// Check if any bucket is overspending
  Future<Either<Failure, Map<BucketType, bool>>> getOverspendingStatus(Budget budget) async {
    final actualResult = await getActualSpendingForCurrentCycle(budget);

    return actualResult.fold(
      (failure) => Left(failure),
      (actualSpending) {
        final status = <BucketType, bool>{};

        for (final bucket in BucketType.values) {
          final budgetAmount = budget.getBucketAmount(bucket.toString().split('.').last);
          final actualAmount = actualSpending[bucket] ?? 0.0;
          status[bucket] = actualAmount > budgetAmount;
        }

        return Right(status);
      },
    );
  }

  /// Get spending remaining in each bucket for current cycle
  Future<Either<Failure, Map<BucketType, double>>> getRemainingBudget(Budget budget) async {
    final actualResult = await getActualSpendingForCurrentCycle(budget);

    return actualResult.fold(
      (failure) => Left(failure),
      (actualSpending) {
        final remaining = <BucketType, double>{};

        for (final bucket in BucketType.values) {
          final budgetAmount = budget.getBucketAmount(bucket.toString().split('.').last);
          final actualAmount = actualSpending[bucket] ?? 0.0;
          remaining[bucket] = budgetAmount - actualAmount;
        }

        return Right(remaining);
      },
    );
  }
}
