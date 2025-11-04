import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../services/budget_analytics_service.dart';
import '../../theme/design_tokens.dart';
import 'package:get_it/get_it.dart';

class BudgetAnalyticsScreen extends StatefulWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  State<BudgetAnalyticsScreen> createState() => _BudgetAnalyticsScreenState();
}

class _BudgetAnalyticsScreenState extends State<BudgetAnalyticsScreen> {
  final _analyticsService = GetIt.instance<BudgetAnalyticsService>();

  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.threeMonths;
  List<MonthlyBucketSpending>? _spendingTrends;
  List<CategorySpendingTrend>? _categoryTrends;
  List<OverspendingPattern>? _overspendingPatterns;
  YearEndGoalProgress? _yearEndGoalProgress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load year-end goal progress (current year)
      final now = DateTime.now();
      final yearGoalResult = await _analyticsService.getYearEndGoalProgress(now.year);
      await yearGoalResult.fold(
        (failure) async {
          // No goal set yet, that's okay
          _yearEndGoalProgress = null;
        },
        (progress) async {
          _yearEndGoalProgress = progress;
        },
      );

      // Load spending trends
      final trendsResult = await _analyticsService.getSpendingTrends(_selectedRange);
      await trendsResult.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (trends) async {
          _spendingTrends = trends;
        },
      );

      // Load category trends
      final categoryResult = await _analyticsService.getCategoryTrends(_selectedRange);
      await categoryResult.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (trends) async {
          _categoryTrends = trends;
        },
      );

      // Load overspending patterns
      final patternsResult = await _analyticsService.getOverspendingPatterns(_selectedRange);
      await patternsResult.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (patterns) async {
          _overspendingPatterns = patterns;
        },
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Analytics'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year-End Goal Progress Section
                      _buildYearEndGoalSection(),
                      const SizedBox(height: 24),
                      _buildTimeRangeSelector(),
                      const SizedBox(height: 24),
                      _buildBucketComparisonChart(),
                      const SizedBox(height: 24),
                      _buildTopCategoriesSection(),
                      const SizedBox(height: 24),
                      if (_overspendingPatterns != null && _overspendingPatterns!.isNotEmpty)
                        _buildOverspendingPatternsSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Failed to load analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['md']!,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeRangeButton('3M', AnalyticsTimeRange.threeMonths),
          ),
          Expanded(
            child: _buildTimeRangeButton('6M', AnalyticsTimeRange.sixMonths),
          ),
          Expanded(
            child: _buildTimeRangeButton('YTD', AnalyticsTimeRange.yearToDate),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, AnalyticsTimeRange range) {
    final isSelected = _selectedRange == range;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRange = range;
        });
        _loadAnalytics();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: DesignTokens.borderRadius['sm']!,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBucketComparisonChart() {
    if (_spendingTrends == null || _spendingTrends!.isEmpty) {
      return _buildEmptyCard('No bucket data available');
    }

    // Calculate totals by bucket
    final bucketTotals = <BucketType, double>{};
    for (final trend in _spendingTrends!) {
      bucketTotals[trend.bucket] = (bucketTotals[trend.bucket] ?? 0) + trend.actual;
    }

    // If all buckets have 0 spending, show empty state
    final maxBucketSpending = bucketTotals.values.isEmpty
        ? 0.0
        : bucketTotals.values.reduce((a, b) => a > b ? a : b);

    if (maxBucketSpending == 0) {
      return _buildEmptyCard('No bucket data available');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['lg']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Bucket',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxBucketSpending * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final bucket = BucketType.values[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getBucketLabel(bucket),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                barGroups: BucketType.values.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: bucketTotals[entry.value] ?? 0,
                        color: _getBucketColor(entry.value),
                        width: 40,
                        borderRadius: BorderRadius.only(
                          topLeft: (DesignTokens.borderRadius['xs']!).topLeft,
                          topRight: (DesignTokens.borderRadius['xs']!).topRight,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoriesSection() {
    if (_categoryTrends == null || _categoryTrends!.isEmpty) {
      return _buildEmptyCard('No category data available');
    }

    // Sort by total spending
    final sorted = List<CategorySpendingTrend>.from(_categoryTrends!)
      ..sort((a, b) => b.totalSpending.compareTo(a.totalSpending));

    final topCategories = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['lg']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Spending Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...topCategories.map((trend) => _buildCategoryItem(trend)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategorySpendingTrend trend) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getBucketColor(trend.bucket),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Avg: \$${trend.averageMonthlySpending.toStringAsFixed(0)}/mo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${trend.totalSpending.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverspendingPatternsSection() {
    final consistentPatterns = _overspendingPatterns!
        .where((p) => p.isConsistentPattern)
        .toList();

    if (consistentPatterns.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.color('error').withOpacity(0.1),
        borderRadius: DesignTokens.borderRadius['lg']!,
        border: Border.all(
          color: DesignTokens.color('error').withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: DesignTokens.color('error'),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Overspending Patterns',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'These categories frequently exceed their budget:',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...consistentPatterns.map((pattern) => _buildPatternItem(pattern)),
        ],
      ),
    );
  }

  Widget _buildPatternItem(OverspendingPattern pattern) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getBucketColor(pattern.bucket),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${pattern.monthsOverspent} of ${pattern.totalMonths} months (${pattern.overspendingFrequency.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+\$${pattern.averageOverspendAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['lg']!,
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildYearEndGoalSection() {
    final now = DateTime.now();
    final progress = _yearEndGoalProgress;

    if (progress == null || !progress.hasGoal) {
      // No goal set - show prompt to set one
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadius['lg']!,
        ),
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Set Your ${now.year} Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your annual spending goals for each bucket',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showSetGoalDialog(now.year),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Set Year Goal'),
            ),
          ],
        ),
      );
    }

    // Goal is set - show progress
    final progressPercentages = progress.progressPercentages;
    final remainingAmounts = progress.remainingAmounts;
    final isOverspent = progress.isOverspent;
    final dollarGoals = progress.dollarGoals;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['lg']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${now.year} Year-End Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: () => _showSetGoalDialog(now.year),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${progress.monthsTracked} of ${progress.totalMonthsInYear} months tracked',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '• Total income: \$${progress.totalAnnualIncome.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bars for each bucket
          for (final bucket in BucketType.values) ...[
            _buildGoalProgressBar(
              bucket: bucket,
              goalPercentage: progress.goal!.getBucketPercentage(bucket.toString().split('.').last) * 100,
              goalAmount: dollarGoals[bucket] ?? 0.0,
              actualAmount: progress.actualSpending[bucket] ?? 0.0,
              progressPercentage: progressPercentages[bucket] ?? 0.0,
              remaining: remainingAmounts[bucket] ?? 0.0,
              isOver: isOverspent[bucket] ?? false,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalProgressBar({
    required BucketType bucket,
    required double goalPercentage, // Goal percentage (0-100)
    required double goalAmount, // Dollar amount calculated from percentage
    required double actualAmount,
    required double progressPercentage, // Progress percentage (how much of goal is spent)
    required double remaining,
    required bool isOver,
  }) {
    final color = _getBucketColor(bucket);
    final progressColor = isOver ? DesignTokens.color('error') : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _getBucketLabel(bucket),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: DesignTokens.borderRadius['xs']!,
                  ),
                  child: Text(
                    '${goalPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '\$${actualAmount.toStringAsFixed(0)} / \$${goalAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOver ? DesignTokens.color('error') : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: DesignTokens.borderRadius['xs']!,
          child: LinearProgressIndicator(
            value: (progressPercentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isOver
              ? 'Over by \$${(-remaining).toStringAsFixed(0)} (${progressPercentage.toStringAsFixed(0)}%)'
              : 'Remaining: \$${remaining.toStringAsFixed(0)} (${progressPercentage.toStringAsFixed(0)}%)',
          style: TextStyle(
            fontSize: 11,
            color: isOver ? DesignTokens.color('error') : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _showSetGoalDialog(int year) async {
    final progress = _yearEndGoalProgress;
    final existingGoal = progress?.goal;

    final needsController = TextEditingController(
      text: existingGoal != null ? (existingGoal.needsPercentage * 100).toStringAsFixed(0) : '50',
    );
    final wantsController = TextEditingController(
      text: existingGoal != null ? (existingGoal.wantsPercentage * 100).toStringAsFixed(0) : '30',
    );
    final savingsController = TextEditingController(
      text: existingGoal != null ? (existingGoal.savingsPercentage * 100).toStringAsFixed(0) : '20',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Set $year Year Goal',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set percentage goals for each bucket',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total must equal 100%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: needsController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Needs (%)',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  hintText: 'e.g., 50',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    fontSize: 18,
                  ),
                  suffixText: '%',
                  suffixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: wantsController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Wants (%)',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  hintText: 'e.g., 30',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    fontSize: 18,
                  ),
                  suffixText: '%',
                  suffixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: savingsController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Savings (%)',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  hintText: 'e.g., 20',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    fontSize: 18,
                  ),
                  suffixText: '%',
                  suffixStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.borderRadius['sm']!,
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    // Read values and dispose controllers before async operations
    final needsPercent = result == true ? (double.tryParse(needsController.text) ?? 0.0) : 0.0;
    final wantsPercent = result == true ? (double.tryParse(wantsController.text) ?? 0.0) : 0.0;
    final savingsPercent = result == true ? (double.tryParse(savingsController.text) ?? 0.0) : 0.0;

    // Dispose controllers immediately after reading values
    needsController.dispose();
    wantsController.dispose();
    savingsController.dispose();

    // Now do async operations
    if (result == true) {
      // Validate percentages sum to 100
      final total = needsPercent + wantsPercent + savingsPercent;
      if ((total - 100.0).abs() > 1.0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Percentages must sum to 100% (current total: ${total.toStringAsFixed(0)}%)'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
        return;
      }

      // Save the goal (convert from percentage 0-100 to decimal 0.0-1.0)
      final setResult = await _analyticsService.setYearEndGoal(
        year: year,
        needsPercentage: needsPercent / 100.0,
        wantsPercentage: wantsPercent / 100.0,
        savingsPercentage: savingsPercent / 100.0,
      );

      await setResult.fold(
        (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save goal: ${failure.message}')),
            );
          }
        },
        (goal) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Year goal saved successfully!')),
            );
            // Reload analytics to show updated goal
            _loadAnalytics();
          }
        },
      );
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

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return Theme.of(context).colorScheme.primary;
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }
}
