import 'package:flutter/widgets.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/category_budget.dart';
import '../data/models/freezed/allocation_template.dart';
import '../data/models/enums/bucket_type.dart';
import '../services/budget_service.dart';
import '../services/allocation_template_service.dart';
import '../services/alert_preferences.dart';
import '../services/notification_service.dart';
import '../services/surplus_allocation_service.dart';

/// Alert severity levels for budget warnings
enum AlertLevel {
  none,     // < 80% spent
  warning,  // 80-99% spent
  critical, // >= 100% spent
}

/// Budget alert for a specific category or bucket
class BudgetAlert {
  final String id;
  final String title;
  final String message;
  final AlertLevel level;
  final double budgetAmount;
  final double spentAmount;
  final double percentage;
  final BucketType? bucketType;
  final int? categoryBudgetId;

  BudgetAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.budgetAmount,
    required this.spentAmount,
    required this.percentage,
    this.bucketType,
    this.categoryBudgetId,
  });

  bool get isWarning => level == AlertLevel.warning;
  bool get isCritical => level == AlertLevel.critical;
}

class BudgetNotifier extends ChangeNotifier {
  final BudgetService _service;
  final AllocationTemplateService _templateService;
  final NotificationService? _notificationService;
  final SurplusAllocationService? _surplusAllocationService;

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
  double _actualIncome = 0.0; // Total income for selected month
  Map<int, double> _categorySpending = {}; // categoryBudgetId -> spending amount
  Map<BucketType, bool> _overspendingStatus = {
    BucketType.needs: false,
    BucketType.wants: false,
    BucketType.savings: false,
  };

  // Surplus tracking
  double _allocatedSurplus = 0.0; // Amount already allocated to savings goals

  // Alert system state
  List<BudgetAlert> _alerts = [];
  Map<BucketType, AlertLevel> _bucketAlertLevels = {
    BucketType.needs: AlertLevel.none,
    BucketType.wants: AlertLevel.none,
    BucketType.savings: AlertLevel.none,
  };
  Map<int, AlertLevel> _categoryAlertLevels = {}; // categoryBudgetId -> AlertLevel
  AlertPreferences? _alertPreferences;

  bool _isLoading = false;
  String? _error;

  // Allocation templates state
  List<AllocationTemplate> _templates = [];
  bool _templatesLoaded = false;

  BudgetNotifier(
    this._service,
    this._templateService,
    this._notificationService,
    this._surplusAllocationService,
  ) {
    _loadAlertPreferences();
  }

  Future<void> _loadAlertPreferences() async {
    _alertPreferences = await AlertPreferences.load();
    // Recalculate alerts if budget is loaded
    if (_activeBudget != null) {
      _calculateAlerts();
      notifyListeners();
    }
  }

  /// Reload alert preferences (call this after settings change)
  Future<void> reloadAlertPreferences() async {
    await _loadAlertPreferences();
  }

  // Getters
  Budget? get activeBudget => _activeBudget;
  DateTime get selectedMonth => _selectedMonth;
  Map<BucketType, List<CategoryBudget>> get categoryBudgets => _categoryBudgets;
  Map<BucketType, double> get actualSpending => _actualSpending;
  double get actualIncome => _actualIncome;
  Map<int, double> get categorySpending => _categorySpending;
  Map<BucketType, bool> get overspendingStatus => _overspendingStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBudget => _activeBudget != null;
  bool get hasAnyOverspending => _overspendingStatus.values.any((isOver) => isOver);

  // Alert getters
  List<BudgetAlert> get alerts => _alerts;
  Map<BucketType, AlertLevel> get bucketAlertLevels => _bucketAlertLevels;
  Map<int, AlertLevel> get categoryAlertLevels => _categoryAlertLevels;

  // Template getters
  List<AllocationTemplate> get templates => _templates;
  bool get templatesLoaded => _templatesLoaded;

  bool get hasAlerts => _alerts.isNotEmpty;
  int get criticalAlertCount => _alerts.where((a) => a.isCritical).length;

  // Surplus getters (unspent budget)
  Map<int, double> get categorySurplus {
    final surplus = <int, double>{};
    for (final bucket in BucketType.values) {
      final categories = _categoryBudgets[bucket] ?? [];
      for (final category in categories) {
        final allocated = category.allocatedAmount;
        final spent = _categorySpending[category.id] ?? 0.0;
        final unspent = allocated - spent;
        if (unspent > 0) {
          surplus[category.id] = unspent;
        }
      }
    }
    return surplus;
  }

  Map<BucketType, double> get bucketSurplus {
    final surplus = <BucketType, double>{};
    for (final bucket in BucketType.values) {
      final categories = _categoryBudgets[bucket] ?? [];
      double bucketUnspent = 0.0;
      for (final category in categories) {
        final allocated = category.allocatedAmount;
        final spent = _categorySpending[category.id] ?? 0.0;
        final unspent = allocated - spent;
        if (unspent > 0) {
          bucketUnspent += unspent;
        }
      }
      if (bucketUnspent > 0) {
        surplus[bucket] = bucketUnspent;
      }
    }
    return surplus;
  }

  double get totalSurplus {
    return bucketSurplus.values.fold<double>(0.0, (sum, amount) => sum + amount);
  }

  /// Amount of surplus already allocated to savings goals this cycle
  double get allocatedSurplus => _allocatedSurplus;

  /// Available surplus that hasn't been allocated yet
  double get availableSurplus {
    final total = totalSurplus;
    final available = total - _allocatedSurplus;
    return available > 0 ? available : 0.0;
  }

  bool get hasSurplus => totalSurplus > 0;
  bool get hasAvailableSurplus => availableSurplus > 0;
  int get warningAlertCount => _alerts.where((a) => a.isWarning).length;
  BudgetAlert? get mostCriticalAlert => _alerts.isEmpty ? null : _alerts.first;

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
          _allocatedSurplus = 0.0;
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

            // Load category-level spending for selected month
            final categorySpendingResult = await _service.getCategorySpendingForMonth(budget, _selectedMonth);
            categorySpendingResult.fold(
              (failure) {
                print('⚠️ NOTIFIER: Failed to load category spending - ${failure.message}');
                _categorySpending = {};
              },
              (spending) {
                print('✅ NOTIFIER: Loaded category spending (${spending.length} categories)');
                _categorySpending = spending;
              },
            );

            // Load actual income for selected month
            final actualIncomeResult = await _service.getActualIncomeForMonth(budget, _selectedMonth);
            actualIncomeResult.fold(
              (failure) {
                print('⚠️ NOTIFIER: Failed to load actual income - ${failure.message}');
                _actualIncome = 0.0;
              },
              (income) {
                print('✅ NOTIFIER: Loaded actual income: \$${income.toStringAsFixed(2)} for ${_selectedMonth.month}/${_selectedMonth.year}');
                _actualIncome = income;
              },
            );

            // Load already-allocated surplus for this budget cycle
            if (_surplusAllocationService != null) {
              final allocationsResult = await _surplusAllocationService!.getSurplusAllocationsForBudget(
                budget.id,
                _selectedMonth.month,
                _selectedMonth.year,
              );
              allocationsResult.fold(
                (failure) {
                  print('⚠️ NOTIFIER: Failed to load surplus allocations - ${failure.message}');
                  _allocatedSurplus = 0.0;
                },
                (allocations) {
                  final totalAllocated = allocations.fold<double>(
                    0.0,
                    (sum, allocation) => sum + allocation.allocationAmount,
                  );
                  _allocatedSurplus = totalAllocated;
                  if (totalAllocated > 0) {
                    print('✅ NOTIFIER: Loaded allocated surplus: \$${totalAllocated.toStringAsFixed(2)} (${allocations.length} allocations)');
                  }
                },
              );
            } else {
              _allocatedSurplus = 0.0;
            }

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

            // Calculate alerts after all data is loaded
            _calculateAlerts();

            // Trigger notification checks
            _checkBudgetNotifications();
          }
        },
      );
    } catch (e) {
      _error = 'Failed to load budget: ${e.toString()}';
      _activeBudget = null;
      _allocatedSurplus = 0.0;
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

  /// Delete a budget and all its associated category budgets
  Future<bool> deleteBudget(int budgetId) async {
    _error = null;

    final result = await _service.deleteBudget(budgetId);

    return result.fold(
      (failure) {
        _error = 'Failed to delete budget: ${failure.message}';
        notifyListeners();
        return false;
      },
      (success) async {
        // Clear active budget and reload
        _activeBudget = null;
        notifyListeners();
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

  /// Clear all budget state (used during app reset)
  void clearState() {
    _activeBudget = null;
    _categoryBudgets = {
      BucketType.needs: [],
      BucketType.wants: [],
      BucketType.savings: [],
    };
    _actualSpending = {
      BucketType.needs: 0.0,
      BucketType.wants: 0.0,
      BucketType.savings: 0.0,
    };
    _actualIncome = 0.0;
    _categorySpending = {};
    _overspendingStatus = {
      BucketType.needs: false,
      BucketType.wants: false,
      BucketType.savings: false,
    };
    _allocatedSurplus = 0.0;
    _error = null;
    _isLoading = false;
    _templates = [];
    _templatesLoaded = false;
    notifyListeners();
  }

  /// Calculate alert level based on percentage spent and user preferences
  AlertLevel _calculateAlertLevel(double percentage) {
    final prefs = _alertPreferences ?? AlertPreferences(
      warningThreshold: AlertPreferences.defaultWarningThreshold,
      criticalThreshold: AlertPreferences.defaultCriticalThreshold,
      enableBucketAlerts: AlertPreferences.defaultEnableBucketAlerts,
      enableCategoryAlerts: AlertPreferences.defaultEnableCategoryAlerts,
      showAlertBanner: AlertPreferences.defaultShowAlertBanner,
      showPercentage: AlertPreferences.defaultShowPercentage,
      enableIncomeVarianceAlerts: AlertPreferences.defaultEnableIncomeVarianceAlerts,
    );

    final percentageDecimal = percentage / 100.0;

    if (percentageDecimal >= prefs.criticalThreshold) {
      return AlertLevel.critical;
    } else if (percentageDecimal >= prefs.warningThreshold) {
      return AlertLevel.warning;
    }
    return AlertLevel.none;
  }

  /// Calculate and update all budget alerts
  void _calculateAlerts() {
    if (_activeBudget == null) {
      _alerts = [];
      _bucketAlertLevels = {
        BucketType.needs: AlertLevel.none,
        BucketType.wants: AlertLevel.none,
        BucketType.savings: AlertLevel.none,
      };
      _categoryAlertLevels = {};
      return;
    }

    // Get preferences (or use defaults)
    final prefs = _alertPreferences ?? AlertPreferences(
      warningThreshold: AlertPreferences.defaultWarningThreshold,
      criticalThreshold: AlertPreferences.defaultCriticalThreshold,
      enableBucketAlerts: AlertPreferences.defaultEnableBucketAlerts,
      enableCategoryAlerts: AlertPreferences.defaultEnableCategoryAlerts,
      showAlertBanner: AlertPreferences.defaultShowAlertBanner,
      showPercentage: AlertPreferences.defaultShowPercentage,
      enableIncomeVarianceAlerts: AlertPreferences.defaultEnableIncomeVarianceAlerts,
    );

    final List<BudgetAlert> newAlerts = [];
    final Map<BucketType, AlertLevel> newBucketLevels = {};
    final Map<int, AlertLevel> newCategoryLevels = {};

    // Calculate bucket-level alerts (only if enabled)
    if (prefs.enableBucketAlerts) {
      for (final bucket in BucketType.values) {
      final budgetAmount = getBucketBudgetAmount(bucket);
      final spentAmount = _actualSpending[bucket] ?? 0.0;
      final percentage = budgetAmount > 0 ? (spentAmount / budgetAmount) * 100 : 0.0;
      final alertLevel = _calculateAlertLevel(percentage);

      newBucketLevels[bucket] = alertLevel;

      if (alertLevel != AlertLevel.none) {
        final bucketName = bucket.toString().split('.').last;
        final bucketNameCapitalized = bucketName[0].toUpperCase() + bucketName.substring(1);

        newAlerts.add(BudgetAlert(
          id: 'bucket_${bucket.toString()}',
          title: '$bucketNameCapitalized Bucket ${alertLevel == AlertLevel.critical ? "Exceeded" : "Almost Full"}',
          message: alertLevel == AlertLevel.critical
              ? 'You\'ve spent \$${spentAmount.toStringAsFixed(2)} of \$${budgetAmount.toStringAsFixed(2)} budget'
              : 'You\'ve spent ${percentage.toStringAsFixed(0)}% of your $bucketNameCapitalized budget',
          level: alertLevel,
          budgetAmount: budgetAmount,
          spentAmount: spentAmount,
          percentage: percentage,
          bucketType: bucket,
        ));
      }
      }
    }

    // Calculate category-level alerts (only if enabled)
    if (prefs.enableCategoryAlerts) {
      print('📊 ALERTS: Checking category alerts (enabled=${prefs.enableCategoryAlerts})');
      int categoriesChecked = 0;
      int categoriesWithAlerts = 0;

      for (final bucket in BucketType.values) {
      final categories = _categoryBudgets[bucket] ?? [];
      for (final category in categories) {
        if (category.allocatedAmount > 0) {
          categoriesChecked++;
          final spentAmount = _categorySpending[category.id] ?? 0.0;
          final percentage = (spentAmount / category.allocatedAmount) * 100;
          final alertLevel = _calculateAlertLevel(percentage);

          newCategoryLevels[category.id] = alertLevel;

          if (alertLevel != AlertLevel.none) {
            categoriesWithAlerts++;
            print('   🔔 ${category.categoryName}: \$${spentAmount.toStringAsFixed(0)}/\$${category.allocatedAmount.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%) - ${alertLevel.toString()}');
            newAlerts.add(BudgetAlert(
              id: 'category_${category.id}',
              title: '${category.categoryName} ${alertLevel == AlertLevel.critical ? "Over Budget" : "Almost Full"}',
              message: alertLevel == AlertLevel.critical
                  ? 'Spent \$${spentAmount.toStringAsFixed(2)} of \$${category.allocatedAmount.toStringAsFixed(2)}'
                  : '${percentage.toStringAsFixed(0)}% of budget used',
              level: alertLevel,
              budgetAmount: category.allocatedAmount,
              spentAmount: spentAmount,
              percentage: percentage,
              bucketType: bucket,
              categoryBudgetId: category.id,
            ));
          }
        }
      }
      }

      print('📊 ALERTS: Checked ${categoriesChecked} categories, found ${categoriesWithAlerts} with alerts');
    }

    // Sort alerts: critical first, then by percentage (highest first)
    newAlerts.sort((a, b) {
      if (a.level != b.level) {
        return b.level.index.compareTo(a.level.index); // Critical > Warning
      }
      return b.percentage.compareTo(a.percentage); // Higher percentage first
    });

    _alerts = newAlerts;
    _bucketAlertLevels = newBucketLevels;
    _categoryAlertLevels = newCategoryLevels;

    if (newAlerts.isNotEmpty) {
      print('🚨 ALERTS: Generated ${newAlerts.length} alerts (${criticalAlertCount} critical, ${warningAlertCount} warnings)');
      if (mostCriticalAlert != null) {
        print('   Most critical: ${mostCriticalAlert!.title}');
      }
    }
  }

  /// Trigger notification checks for budget thresholds
  void _checkBudgetNotifications() {
    if (_notificationService == null || _activeBudget == null) {
      return;
    }

    print('🔔 NOTIFIER: Checking budget notifications...');

    // Trigger threshold alerts
    _notificationService!.checkBudgetThresholdAlerts(
      budget: _activeBudget!,
      bucketSpending: _actualSpending,
      categorySpending: _categorySpending,
      categoryBudgets: _categoryBudgets,
      actualIncome: _actualIncome,
    );
  }

  /// Generate end-of-cycle budget summary notification
  void generateCycleSummary() {
    if (_notificationService == null || _activeBudget == null) {
      return;
    }

    print('🔔 NOTIFIER: Generating cycle summary notification...');

    _notificationService!.generateBudgetCycleSummary(
      budget: _activeBudget!,
      bucketSpending: _actualSpending,
      categorySpending: _categorySpending,
      categoryBudgets: _categoryBudgets,
    );
  }

  /// Generate pattern-based budget suggestions
  Future<void> generatePatternSuggestions() async {
    if (_notificationService == null) {
      return;
    }

    print('🔔 NOTIFIER: Generating pattern-based suggestions...');

    await _notificationService!.generatePatternBasedSuggestions();
  }

  // ============================================================================
  // Allocation Template Methods
  // ============================================================================

  /// Load all saved allocation templates
  Future<void> loadTemplates() async {
    final result = await _templateService.getAllTemplates();
    result.fold(
      (failure) {
        _error = 'Failed to load templates: ${failure.message}';
        print('❌ NOTIFIER: Failed to load templates: ${failure.message}');
      },
      (templates) {
        _templates = templates;
        _templatesLoaded = true;
        print('✅ NOTIFIER: Loaded ${templates.length} templates');
      },
    );
    notifyListeners();
  }

  /// Save current allocations as a new template
  Future<bool> saveAsTemplate(String name, {String? description}) async {
    if (_activeBudget == null) {
      _error = 'No active budget to save as template';
      return false;
    }

    // Get all category budgets (flatten the map)
    final allCategoryBudgets = <CategoryBudget>[];
    for (final bucketList in _categoryBudgets.values) {
      allCategoryBudgets.addAll(bucketList);
    }

    if (allCategoryBudgets.isEmpty) {
      _error = 'No category allocations to save';
      return false;
    }

    _error = null;
    final result = await _templateService.saveAsTemplate(
      name: name,
      description: description,
      categoryBudgets: allCategoryBudgets,
    );

    return result.fold(
      (failure) {
        _error = 'Failed to save template: ${failure.message}';
        print('❌ NOTIFIER: Failed to save template: ${failure.message}');
        notifyListeners();
        return false;
      },
      (templateId) async {
        print('✅ NOTIFIER: Template saved with ID $templateId');
        // Reload templates to update the list
        await loadTemplates();
        return true;
      },
    );
  }

  /// Apply a template to the current budget
  /// REPLACES all existing allocations with the template allocations
  /// If scaleToIncome is true, scales amounts proportionally to the current budget's income
  Future<bool> applyTemplate(int templateId, {bool scaleToIncome = false}) async {
    if (_activeBudget == null) {
      _error = 'No active budget to apply template to';
      return false;
    }

    _error = null;

    // Step 1: Clear all existing category budgets
    print('🔄 NOTIFIER: Clearing existing category budgets before applying template...');
    final clearResult = await _service.clearAllCategoryBudgets(_activeBudget!.id);

    final clearSuccess = await clearResult.fold(
      (failure) {
        _error = 'Failed to clear existing allocations: ${failure.message}';
        print('❌ NOTIFIER: Failed to clear existing allocations: ${failure.message}');
        notifyListeners();
        return false;
      },
      (deletedCount) {
        print('✅ NOTIFIER: Cleared $deletedCount existing category budgets');
        return true;
      },
    );

    if (!clearSuccess) {
      return false;
    }

    // Step 2: Apply the template
    final result = await _templateService.applyTemplateTobudget(
      templateId: templateId,
      budgetId: _activeBudget!.id,
      scaleToIncome: scaleToIncome,
      targetIncome: scaleToIncome ? _activeBudget!.monthlyIncome : null,
    );

    return result.fold(
      (failure) {
        _error = 'Failed to apply template: ${failure.message}';
        print('❌ NOTIFIER: Failed to apply template: ${failure.message}');
        notifyListeners();
        return false;
      },
      (createdCount) {
        print('✅ NOTIFIER: Applied template - created $createdCount category allocations');
        // Reload budget data to reflect new allocations
        loadActiveBudget();
        return true;
      },
    );
  }

  /// Delete a template
  Future<bool> deleteTemplate(int templateId) async {
    _error = null;
    final result = await _templateService.deleteTemplate(templateId);

    return result.fold(
      (failure) {
        _error = 'Failed to delete template: ${failure.message}';
        print('❌ NOTIFIER: Failed to delete template: ${failure.message}');
        notifyListeners();
        return false;
      },
      (_) {
        print('✅ NOTIFIER: Template deleted');
        // Reload templates to update the list
        loadTemplates();
        return true;
      },
    );
  }

  /// Get template summary (for preview/display)
  Future<Map<String, dynamic>?> getTemplateSummary(int templateId) async {
    final result = await _templateService.getTemplateSummary(templateId);

    return result.fold(
      (failure) {
        _error = 'Failed to get template summary: ${failure.message}';
        print('❌ NOTIFIER: Failed to get template summary: ${failure.message}');
        return null;
      },
      (summary) => summary,
    );
  }
}
