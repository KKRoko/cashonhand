import 'package:flutter/widgets.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/category_budget.dart';
import '../data/models/enums/bucket_type.dart';
import '../services/budget_service.dart';

class BudgetNotifier extends ChangeNotifier {
  final BudgetService _service;

  Budget? _activeBudget;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  Map<BucketType, List<CategoryBudget>> _categoryBudgets = {
    BucketType.needs: [],
    BucketType.wants: [],
    BucketType.savings: [],
  };
  Map<BucketType, double> _actualSpending = {
    BucketType.needs: 0.0,
    BucketType.wants: 0.0,
    BucketType.savings: 0.0,
  };
  Map<BucketType, bool> _overspendingStatus = {
    BucketType.needs: false,
    BucketType.wants: false,
    BucketType.savings: false,
  };

  bool _isLoading = false;
  String? _error;

  BudgetNotifier(this._service);

  // Getters
  Budget? get activeBudget => _activeBudget;
  DateTime get selectedMonth => _selectedMonth;
  Map<BucketType, List<CategoryBudget>> get categoryBudgets => _categoryBudgets;
  Map<BucketType, double> get actualSpending => _actualSpending;
  Map<BucketType, bool> get overspendingStatus => _overspendingStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBudget => _activeBudget != null;
  bool get hasAnyOverspending => _overspendingStatus.values.any((isOver) => isOver);

  /// Set selected month and reload data
  Future<void> setSelectedMonth(DateTime month) async {
    _selectedMonth = DateTime(month.year, month.month, 1);
    print('📅 NOTIFIER: Month changed to ${_selectedMonth.month}/${_selectedMonth.year}');
    print('📅 NOTIFIER: About to load budget for this month...');
    notifyListeners();
    await loadActiveBudget();
  }

  /// Load the active budget and its category allocations
  Future<void> loadActiveBudget() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Run cleanup to remove any income category budgets (migration/fix)
      await _service.cleanupIncomeCategoryBudgets();

      // Load budget for the selected month instead of "active" budget
      print('📅 NOTIFIER: Loading budget for ${_selectedMonth.month}/${_selectedMonth.year}');
      final budgetResult = await _service.getBudgetForMonth(_selectedMonth.month, _selectedMonth.year);

      await budgetResult.fold(
        (failure) async {
          print('❌ NOTIFIER: No budget found for ${_selectedMonth.month}/${_selectedMonth.year}');
          _error = 'Failed to load budget: ${failure.message}';
          _activeBudget = null;
          _categoryBudgets = {
            BucketType.needs: [],
            BucketType.wants: [],
            BucketType.savings: [],
          };
        },
        (budget) async {
          if (budget != null) {
            print('✅ NOTIFIER: Loaded budget ID ${budget.id} for ${budget.month}/${budget.year}');
            print('   Income: \$${budget.monthlyIncome}, Needs: ${(budget.needsPercentage * 100).toStringAsFixed(0)}%, Wants: ${(budget.wantsPercentage * 100).toStringAsFixed(0)}%, Savings: ${(budget.savingsPercentage * 100).toStringAsFixed(0)}%');
          } else {
            print('⚠️ NOTIFIER: No budget exists for ${_selectedMonth.month}/${_selectedMonth.year}');
          }
          _activeBudget = budget;

          if (budget != null) {
            // Load category budgets grouped by bucket
            final categoryBudgetsResult = await _service.getCategoryBudgetsByBucket(budget.id);
            categoryBudgetsResult.fold(
              (failure) {
                _error = 'Failed to load category budgets: ${failure.message}';
                _categoryBudgets = {
                  BucketType.needs: [],
                  BucketType.wants: [],
                  BucketType.savings: [],
                };
              },
              (grouped) {
                _categoryBudgets = grouped;
              },
            );

            // Load actual spending for selected month
            final actualSpendingResult = await _service.getActualSpendingForMonth(budget, _selectedMonth);
            actualSpendingResult.fold(
              (failure) {
                // Don't set error, just use zero spending
                print('⚠️ NOTIFIER: Failed to load spending - ${failure.message}');
                _actualSpending = {
                  BucketType.needs: 0.0,
                  BucketType.wants: 0.0,
                  BucketType.savings: 0.0,
                };
              },
              (spending) {
                print('✅ NOTIFIER: Loaded spending for ${_selectedMonth.month}/${_selectedMonth.year}');
                _actualSpending = spending;
              },
            );

            // Load overspending status
            final overspendingResult = await _service.getOverspendingStatus(budget);
            overspendingResult.fold(
              (failure) {
                _overspendingStatus = {
                  BucketType.needs: false,
                  BucketType.wants: false,
                  BucketType.savings: false,
                };
              },
              (status) {
                _overspendingStatus = status;
              },
            );
          }
        },
      );
    } catch (e) {
      _error = 'Failed to load budget: ${e.toString()}';
      _activeBudget = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new budget with default settings
  Future<bool> createBudget({
    required double monthlyIncome,
    required int cycleStartDay,
    double needsPercentage = 0.50,
    double wantsPercentage = 0.30,
    double savingsPercentage = 0.20,
  }) async {
    _error = null;

    // Use the currently selected month/year
    final result = await _service.createBudgetWithDefaults(
      month: _selectedMonth.month,
      year: _selectedMonth.year,
      monthlyIncome: monthlyIncome,
      cycleStartDay: cycleStartDay,
      needsPercentage: needsPercentage,
      wantsPercentage: wantsPercentage,
      savingsPercentage: savingsPercentage,
    );

    return result.fold(
      (failure) {
        _error = 'Failed to create budget: ${failure.message}';
        notifyListeners();
        return false;
      },
      (budgetId) async {
        // Reload the budget after creation
        await loadActiveBudget();
        return true;
      },
    );
  }

  /// Update budget settings (income, percentages, cycle day)
  Future<bool> updateBudget(Budget budget) async {
    _error = null;

    final result = await _service.updateBudget(budget);

    return result.fold(
      (failure) {
        _error = 'Failed to update budget: ${failure.message}';
        notifyListeners();
        return false;
      },
      (success) async {
        await loadActiveBudget();
        return true;
      },
    );
  }

  /// Update a category budget allocation
  Future<bool> updateCategoryBudget(CategoryBudget categoryBudget) async {
    print('🔔 NOTIFIER: updateCategoryBudget called for ${categoryBudget.categoryName} with amount \$${categoryBudget.allocatedAmount}');
    _error = null;

    final result = await _service.updateCategoryBudget(categoryBudget);

    return result.fold(
      (failure) {
        print('❌ NOTIFIER: Update failed - ${failure.message}');
        _error = 'Failed to update category budget: ${failure.message}';
        notifyListeners();
        return false;
      },
      (success) async {
        print('✅ NOTIFIER: Update successful, updating local state');
        // Update the local state immediately for instant feedback
        final bucket = categoryBudget.bucketType;
        final categories = _categoryBudgets[bucket] ?? [];
        final index = categories.indexWhere((c) => c.id == categoryBudget.id);
        print('🔍 NOTIFIER: Found category at index $index in bucket $bucket');
        if (index != -1) {
          categories[index] = categoryBudget;
          _categoryBudgets[bucket] = categories;
          print('📝 NOTIFIER: Updated local state, calling notifyListeners()');
        }
        notifyListeners();

        // Then reload from database to ensure consistency
        print('🔄 NOTIFIER: Reloading budget from database');
        await loadActiveBudget();
        print('✅ NOTIFIER: Reload complete');
        return true;
      },
    );
  }

  /// Move a category to a different bucket
  Future<bool> moveCategoryToBucket(CategoryBudget categoryBudget, BucketType newBucket) async {
    _error = null;

    final result = await _service.moveCategoryToBucket(categoryBudget, newBucket);

    return result.fold(
      (failure) {
        _error = 'Failed to move category: ${failure.message}';
        notifyListeners();
        return false;
      },
      (success) async {
        // Update local state immediately for instant feedback
        final oldBucket = categoryBudget.bucketType;
        final oldCategories = _categoryBudgets[oldBucket] ?? [];
        oldCategories.removeWhere((c) => c.id == categoryBudget.id);
        _categoryBudgets[oldBucket] = oldCategories;

        final updatedCategory = categoryBudget.copyWith(bucketType: newBucket);
        final newCategories = _categoryBudgets[newBucket] ?? [];
        newCategories.add(updatedCategory);
        _categoryBudgets[newBucket] = newCategories;

        notifyListeners();

        // Then reload from database to ensure consistency
        await loadActiveBudget();
        return true;
      },
    );
  }

  /// Get total allocated amount for a bucket
  double getTotalAllocatedForBucket(BucketType bucket) {
    final categories = _categoryBudgets[bucket] ?? [];
    return categories.fold<double>(0.0, (sum, cb) => sum + cb.allocatedAmount);
  }

  /// Get unallocated amount for a bucket
  double getUnallocatedForBucket(BucketType bucket) {
    if (_activeBudget == null) return 0.0;

    final budgetAmount = _activeBudget!.getBucketAmount(bucket.toString().split('.').last);
    final allocated = getTotalAllocatedForBucket(bucket);
    return budgetAmount - allocated;
  }

  /// Get budget amount for a bucket
  double getBucketBudgetAmount(BucketType bucket) {
    if (_activeBudget == null) return 0.0;
    return _activeBudget!.getBucketAmount(bucket.toString().split('.').last);
  }

  /// Check if budget is fully allocated
  bool get isFullyAllocated {
    if (_activeBudget == null) return false;

    print('💯 ALLOCATION CHECK:');
    for (final bucket in BucketType.values) {
      final budgetAmount = getBucketBudgetAmount(bucket);
      final allocated = getTotalAllocatedForBucket(bucket);
      final unallocated = getUnallocatedForBucket(bucket);
      print('  $bucket: Budget=\$$budgetAmount, Allocated=\$$allocated, Unallocated=\$$unallocated');
      if (unallocated.abs() > 0.01) {
        print('  ❌ $bucket not fully allocated (unallocated: \$${unallocated.toStringAsFixed(2)})');
        return false;
      }
    }

    print('  ✅ All buckets fully allocated!');
    return true;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
