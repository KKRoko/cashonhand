import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../core/di/injection.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/models/freezed/budget.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';
import 'budget_setup_screen.dart';
import 'budget_settings_screen.dart';
import 'category_allocation_screen.dart';
import 'widgets/budget_pie_chart.dart';

enum BudgetViewMode {
  plan,
  actual,
}

enum TimePeriod {
  weekly,
  monthly,
  yearly,
}

class BudgetScreen extends StatefulWidget {
  static const routeName = '/budget';
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with AutomaticKeepAliveClientMixin {
  late final BudgetNotifier _budgetNotifier;
  BudgetViewMode _viewMode = BudgetViewMode.plan;
  TimePeriod _timePeriod = TimePeriod.monthly;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _budgetNotifier = getIt<BudgetNotifier>();
    _budgetNotifier.loadActiveBudget();

    // Listen to tab changes and reload when navigating back from calendar
    globalTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    globalTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // Reload budget data when navigating to budget tab from another tab
    // This ensures spending data is fresh if user added transactions in calendar
    if (globalTabNotifier.currentTabIndex == 2) { // Budget tab is index 2
      print('🔄 BUDGET: Tab navigated to Budget, reloading data...');
      _budgetNotifier.loadActiveBudget();
    }
  }

  void _changeMonth(int monthOffset) {
    final currentMonth = _budgetNotifier.selectedMonth;
    final newMonth = DateTime(currentMonth.year, currentMonth.month + monthOffset, 1);
    _budgetNotifier.setSelectedMonth(newMonth);
  }

  void _navigateToSetup() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetSetupScreen(
          onCreateBudget: ({
            required double monthlyIncome,
            required int cycleStartDay,
            required double needsPercentage,
            required double wantsPercentage,
            required double savingsPercentage,
          }) async {
            final success = await _budgetNotifier.createBudget(
              monthlyIncome: monthlyIncome,
              cycleStartDay: cycleStartDay,
              needsPercentage: needsPercentage,
              wantsPercentage: wantsPercentage,
              savingsPercentage: savingsPercentage,
            );

            if (success && mounted) {
              Navigator.of(context).pop(true);
            }
          },
        ),
      ),
    );

    if (result == true) {
      _budgetNotifier.loadActiveBudget();
    }
  }

  void _navigateToSettings(BudgetNotifier notifier) async {
    final budget = notifier.activeBudget;
    if (budget == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetSettingsScreen(
          budget: budget,
          onUpdateBudget: ({
            required double monthlyIncome,
            required int cycleStartDay,
            required double needsPercentage,
            required double wantsPercentage,
            required double savingsPercentage,
          }) async {
            final updated = budget.copyWith(
              monthlyIncome: monthlyIncome,
              cycleStartDay: cycleStartDay,
              needsPercentage: needsPercentage,
              wantsPercentage: wantsPercentage,
              savingsPercentage: savingsPercentage,
            );
            await _budgetNotifier.updateBudget(updated);
          },
          onDeleteBudget: () async {
            // For now, just show a message - we'll implement delete in the database later
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget deleted successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            await _budgetNotifier.loadActiveBudget();
          },
        ),
      ),
    );

    if (result == true) {
      _budgetNotifier.loadActiveBudget();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider.value(
      value: _budgetNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget'),
          backgroundColor: DesignTokens.color('surface'),
          elevation: 0,
          actions: [
            Consumer<BudgetNotifier>(
              builder: (context, notifier, _) {
                if (notifier.hasBudget) {
                  return IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => _navigateToSettings(notifier),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<BudgetNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifier.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: DesignTokens.color('error'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: DesignTokens.color('textPrimary'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        notifier.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.color('textSecondary'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => notifier.loadActiveBudget(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!notifier.hasBudget) {
              return _buildEmptyState();
            }

            return _buildBudgetView(notifier);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedMonth = _budgetNotifier.selectedMonth;
    final monthName = DateFormat('MMMM yyyy').format(selectedMonth);

    return Column(
      children: [
        // Month Navigation (always visible)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: DesignTokens.color('surfaceVariant'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                  color: DesignTokens.color('primary'),
                ),
                Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.color('textPrimary'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                  color: DesignTokens.color('primary'),
                ),
              ],
            ),
          ),
        ),
        // Empty state message
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: DesignTokens.color('textSecondary'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Budget for $monthName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('textPrimary'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a budget for this month to track your spending and save more effectively',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: DesignTokens.color('textSecondary'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _navigateToSetup,
                    icon: const Icon(Icons.add),
                    label: Text('Create Budget for $monthName'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.color('primary'),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getTimePeriodMultiplier() {
    switch (_timePeriod) {
      case TimePeriod.weekly:
        return 0.25; // 1 week ≈ 1/4 month
      case TimePeriod.monthly:
        return 1.0;
      case TimePeriod.yearly:
        return 12.0;
    }
  }

  String _getTimePeriodLabel() {
    switch (_timePeriod) {
      case TimePeriod.weekly:
        return 'Weekly';
      case TimePeriod.monthly:
        return 'Monthly';
      case TimePeriod.yearly:
        return 'Yearly';
    }
  }

  Widget _buildBudgetView(BudgetNotifier notifier) {
    final budget = notifier.activeBudget!;

    // Calculate amounts based on time period
    final multiplier = _getTimePeriodMultiplier();
    final planData = {
      BucketType.needs: budget.needsAmount * multiplier,
      BucketType.wants: budget.wantsAmount * multiplier,
      BucketType.savings: budget.savingsAmount * multiplier,
    };

    // Adjust actual spending based on time period
    final actualData = {
      BucketType.needs: (notifier.actualSpending[BucketType.needs] ?? 0.0) * multiplier,
      BucketType.wants: (notifier.actualSpending[BucketType.wants] ?? 0.0) * multiplier,
      BucketType.savings: (notifier.actualSpending[BucketType.savings] ?? 0.0) * multiplier,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: DesignTokens.color('surfaceVariant'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(-1),
                  color: DesignTokens.color('primary'),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(notifier.selectedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.color('textPrimary'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(1),
                  color: DesignTokens.color('primary'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // View Mode Toggle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.color('surfaceVariant'),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton('Budget Plan', BudgetViewMode.plan),
                  const SizedBox(width: 4),
                  _buildToggleButton('Actual', BudgetViewMode.actual),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Time Period Selector
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: DesignTokens.color('surfaceVariant'),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTimePeriodButton('Weekly', TimePeriod.weekly),
                  const SizedBox(width: 4),
                  _buildTimePeriodButton('Monthly', TimePeriod.monthly),
                  const SizedBox(width: 4),
                  _buildTimePeriodButton('Yearly', TimePeriod.yearly),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Pie Chart
          BudgetPieChart(
            bucketAmounts: _viewMode == BudgetViewMode.plan ? planData : actualData,
            centerText: '\$${(budget.monthlyIncome * multiplier).toStringAsFixed(0)}',
            subtitle: _viewMode == BudgetViewMode.plan
                ? '${_getTimePeriodLabel()} Plan'
                : '${_getTimePeriodLabel()} Spending',
          ),
          const SizedBox(height: 32),

          // Budget Details
          Text(
            'Budget Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('textPrimary'),
            ),
          ),
          const SizedBox(height: 16),

          _buildBudgetDetailCard(
            'Allocated',
            notifier.isFullyAllocated ? 'Fully allocated' : 'Needs allocation',
            notifier.isFullyAllocated ? Icons.check_circle_outline : Icons.warning_outlined,
            color: notifier.isFullyAllocated
                ? DesignTokens.color('success')
                : DesignTokens.color('warning'),
          ),
          const SizedBox(height: 12),

          // Overspending Alert
          if (notifier.hasAnyOverspending)
            _buildBudgetDetailCard(
              'Alert',
              'Overspending detected in ${_getOverspendingBuckets(notifier)}',
              Icons.warning_rounded,
              color: DesignTokens.color('error'),
            ),
          const SizedBox(height: 32),

          // Budget vs Actual Comparison
          if (_viewMode == BudgetViewMode.actual) ...[
            Text(
              'Budget vs Actual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.color('textPrimary'),
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonCard(BucketType.needs, budget, notifier),
            const SizedBox(height: 12),
            _buildComparisonCard(BucketType.wants, budget, notifier),
            const SizedBox(height: 12),
            _buildComparisonCard(BucketType.savings, budget, notifier),
            const SizedBox(height: 32),
          ],

          // Allocate Categories Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryAllocationScreen(
                      budget: budget,
                      budgetNotifier: _budgetNotifier,
                    ),
                  ),
                );
                // Reload budget after returning
                _budgetNotifier.loadActiveBudget();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Allocate to Categories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignTokens.color('primary'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, BudgetViewMode mode) {
    final isSelected = _viewMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.color('primary') : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : DesignTokens.color('textSecondary'),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodButton(String label, TimePeriod period) {
    final isSelected = _timePeriod == period;

    return GestureDetector(
      onTap: () => setState(() => _timePeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.color('primary') : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : DesignTokens.color('textSecondary'),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetDetailCard(String title, String subtitle, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.color('surfaceVariant'),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? DesignTokens.color('textSecondary')),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.color('textPrimary'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? DesignTokens.color('textSecondary'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOverspendingBuckets(BudgetNotifier notifier) {
    final buckets = <String>[];
    if (notifier.overspendingStatus[BucketType.needs] == true) buckets.add('Needs');
    if (notifier.overspendingStatus[BucketType.wants] == true) buckets.add('Wants');
    if (notifier.overspendingStatus[BucketType.savings] == true) buckets.add('Savings');
    return buckets.join(', ');
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return DesignTokens.color('primary');
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }

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

  Widget _buildComparisonCard(BucketType bucket, Budget budget, BudgetNotifier notifier) {
    final multiplier = _getTimePeriodMultiplier();
    final budgetAmount = budget.getBucketAmount(bucket.toString().split('.').last) * multiplier;
    final actualAmount = (notifier.actualSpending[bucket] ?? 0.0) * multiplier;
    final remaining = budgetAmount - actualAmount;
    final percentage = budgetAmount > 0 ? (actualAmount / budgetAmount * 100).clamp(0, 100) : 0.0;
    final isOverspending = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.color('surfaceVariant'),
        borderRadius: BorderRadius.circular(12),
        border: isOverspending
            ? Border.all(color: DesignTokens.color('error'), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getBucketColor(bucket),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.category, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getBucketLabel(bucket),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('textPrimary'),
                    ),
                  ),
                ],
              ),
              if (isOverspending)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.color('error').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OVER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('error'),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.color('textSecondary'),
                    ),
                  ),
                  Text(
                    '\$${budgetAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.color('textPrimary'),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.color('textSecondary'),
                    ),
                  ),
                  Text(
                    '\$${actualAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverspending
                          ? DesignTokens.color('error')
                          : DesignTokens.color('textPrimary'),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.color('textSecondary'),
                    ),
                  ),
                  Text(
                    isOverspending
                        ? '-\$${(-remaining).toStringAsFixed(0)}'
                        : '\$${remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverspending
                          ? DesignTokens.color('error')
                          : DesignTokens.color('success'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              isOverspending
                  ? DesignTokens.color('error')
                  : _getBucketColor(bucket),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% of budget used',
            style: TextStyle(
              fontSize: 12,
              color: DesignTokens.color('textSecondary'),
            ),
          ),
        ],
      ),
    );
  }
}
