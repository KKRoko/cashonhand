// lib/ui/calendar/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/freezed/event.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/saving_goal_repository.dart';
import '../../../data/database/database.dart';
import '../../../services/settings_service.dart';
import '../../../theme/design_tokens.dart';
import '../../components/cash_components.dart';

class EnhancedCalendarWidget extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime)? onPageChanged;
  final List<Event> Function(DateTime) eventLoader;
  final double Function(DateTime) getDayAmount;
  final CalendarFormat calendarFormat;
  final Map<DateTime, double> monthSummary;

  const EnhancedCalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onFormatChanged,
    this.onPageChanged,
    required this.eventLoader,
    required this.getDayAmount,
    required this.calendarFormat,
    required this.monthSummary,
  });

  @override
  State<EnhancedCalendarWidget> createState() => _EnhancedCalendarWidgetState();
}

class _EnhancedCalendarWidgetState extends State<EnhancedCalendarWidget> {
  List<SavingGoal> _goals = [];
  Map<DateTime, List<GoalAllocationHistory>> _dailyAllocations = {};
  Map<DateTime, bool> _savingsStreak = {};
  Set<DateTime> _goalMilestones = {};
  bool _isLoading = true;
  
  // Monthly Summary expansion state
  bool _isMonthlySummaryExpanded = false;
  Map<String, double> _monthlyIncomeByCategory = {};
  Map<String, double> _monthlyExpenseByCategory = {};
  List<Event> _monthlyIncomeTransactions = [];
  List<Event> _monthlyExpenseTransactions = [];
  double _monthlyTotalIncome = 0.0;
  double _monthlyTotalExpenses = 0.0;
  bool _isLoadingMonthlyData = false;

  @override
  void initState() {
    super.initState();
    _loadGoalData();
    _loadMonthlyBreakdown();
  }

  @override
  void didUpdateWidget(EnhancedCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload monthly data when month changes
    if (oldWidget.focusedDay.month != widget.focusedDay.month ||
        oldWidget.focusedDay.year != widget.focusedDay.year) {
      _loadMonthlyBreakdown();
    }
    if (oldWidget.focusedDay.month != widget.focusedDay.month ||
        oldWidget.focusedDay.year != widget.focusedDay.year) {
      _loadGoalData();
    }
    
    // Also reload monthly data when the month summary changes (indicates events have loaded/changed)
    if (oldWidget.monthSummary != widget.monthSummary) {
      _loadMonthlyBreakdown();
    }
  }

  Future<void> _loadGoalData() async {
    setState(() => _isLoading = true);
    
    try {
      final goalRepository = getIt<ISavingGoalRepository>();
      final database = getIt<Database>();
      
      // Load goals
      final goalsResult = await goalRepository.getAllGoals();
      final goals = goalsResult.fold(
        (failure) => <SavingGoal>[],
        (goals) => goals,
      );

      // Load allocations for the current month
      final monthStart = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
      final monthEnd = DateTime(widget.focusedDay.year, widget.focusedDay.month + 1, 0);
      
      final dailyAllocations = <DateTime, List<GoalAllocationHistory>>{};
      final savingsStreak = <DateTime, bool>{};
      final goalMilestones = <DateTime>{};

      for (final goal in goals) {
        // Load allocation history for this goal
        final allocationsResult = await goalRepository.getGoalAllocationHistory(goal.id!);
        await allocationsResult.fold(
          (failure) => null,
          (allocations) async {
            for (final allocation in allocations) {
              if (allocation.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                  allocation.date.isBefore(monthEnd.add(const Duration(days: 1)))) {
                final day = DateTime(allocation.date.year, allocation.date.month, allocation.date.day);
                dailyAllocations.putIfAbsent(day, () => []).add(allocation);
                savingsStreak[day] = true; // Mark as savings day
              }
            }
          },
        );

        // Check for goal milestones
        _checkGoalMilestones(goal, goalMilestones);
            }

      // Calculate savings streak
      _calculateSavingsStreak(savingsStreak, monthStart, monthEnd);

      if (mounted) {
        setState(() {
          _goals = goals;
          _dailyAllocations = dailyAllocations;
          _savingsStreak = savingsStreak;
          _goalMilestones = goalMilestones;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading goal data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _checkGoalMilestones(SavingGoal goal, Set<DateTime> milestones) {
    final progress = goal.currentAmount / goal.targetAmount;
    
    // Check if goal hits major milestones (25%, 50%, 75%, 100%)
    final milestonePercentages = [0.25, 0.5, 0.75, 1.0];
    
    for (final milestone in milestonePercentages) {
      if (progress >= milestone && progress < milestone + 0.05) { // 5% tolerance
        // Estimate when this milestone was reached (could be more sophisticated)
        if (goal.deadlineDate != null) {
          final daysFromStart = goal.deadlineDate!.difference(DateTime.now()).inDays;
          final estimatedDate = DateTime.now().subtract(Duration(days: (daysFromStart * (1 - progress)).round()));
          
          if (estimatedDate.month == widget.focusedDay.month && 
              estimatedDate.year == widget.focusedDay.year) {
            milestones.add(DateTime(estimatedDate.year, estimatedDate.month, estimatedDate.day));
          }
        }
      }
    }
  }

  void _calculateSavingsStreak(Map<DateTime, bool> savingsStreak, DateTime monthStart, DateTime monthEnd) {
    // Calculate consecutive savings days
    for (var day = monthStart; !day.isAfter(monthEnd); day = day.add(const Duration(days: 1))) {
      final dayKey = DateTime(day.year, day.month, day.day);
      if (!savingsStreak.containsKey(dayKey)) {
        savingsStreak[dayKey] = false;
      }
    }
  }

  Future<void> _loadMonthlyBreakdown() async {
    setState(() => _isLoadingMonthlyData = true);
    
    try {
      final database = getIt<Database>();
      final monthStart = DateTime(widget.focusedDay.year, widget.focusedDay.month, 1);
      final monthEnd = DateTime(widget.focusedDay.year, widget.focusedDay.month + 1, 0);
      
      // Get all events for the month
      final allEvents = <Event>[];
      for (var day = monthStart; !day.isAfter(monthEnd); day = day.add(const Duration(days: 1))) {
        final dayEvents = widget.eventLoader(day);
        allEvents.addAll(dayEvents);
      }
      
      // Initialize breakdown maps and transaction lists
      final incomeByCategory = <String, double>{};
      final expenseByCategory = <String, double>{};
      final incomeTransactions = <Event>[];
      final expenseTransactions = <Event>[];
      double totalIncome = 0.0;
      double totalExpenses = 0.0;
      
      // Process each event and categorize
      for (final event in allEvents) {
        final amount = event.amount.abs();
        
        // Get category name
        String categoryName = 'Unknown';
        try {
          final category = await database.getCategoryById(event.categoryId);
          if (category != null) {
            categoryName = category.name;
            // If it's a subcategory, show parent > child format
            if (category.parentCategoryId != null) {
              final parentCategory = await database.getCategoryById(category.parentCategoryId!);
              if (parentCategory != null) {
                categoryName = '${parentCategory.name} > ${category.name}';
              }
            }
          }
        } catch (e) {
          print('Error loading category for event: $e');
        }
        
        if (event.isPositiveCashflow) {
          incomeByCategory[categoryName] = (incomeByCategory[categoryName] ?? 0) + amount;
          incomeTransactions.add(event);
          totalIncome += amount;
        } else {
          expenseByCategory[categoryName] = (expenseByCategory[categoryName] ?? 0) + amount;
          expenseTransactions.add(event);
          totalExpenses += amount;
        }
      }
      
      if (mounted) {
        setState(() {
          _monthlyIncomeByCategory = incomeByCategory;
          _monthlyExpenseByCategory = expenseByCategory;
          _monthlyIncomeTransactions = incomeTransactions;
          _monthlyExpenseTransactions = expenseTransactions;
          _monthlyTotalIncome = totalIncome;
          _monthlyTotalExpenses = totalExpenses;
          _isLoadingMonthlyData = false;
        });
      }
    } catch (e) {
      print('Error loading monthly breakdown: $e');
      if (mounted) {
        setState(() => _isLoadingMonthlyData = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMonthSummaryCard(context),
          if (_goals.isNotEmpty) _buildGoalsSummaryCard(context),
          VSpace('xs'),
          _buildCalendar(context),
          if (!_isLoading) _buildSavingsStreakIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryCard(BuildContext context) {
    final currentMonthTotal = widget.monthSummary[DateTime(
      widget.focusedDay.year,
      widget.focusedDay.month,
      1,
    )] ?? 0.0;

    // Determine financial context for smart theming
    final financialContext = currentMonthTotal > 0 
        ? FinancialContext.income 
        : currentMonthTotal < 0 
            ? FinancialContext.expense 
            : FinancialContext.neutral;

    return CashCard(
      financialContext: financialContext,
      onTap: () => setState(() => _isMonthlySummaryExpanded = !_isMonthlySummaryExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse icon
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Summary',
                  style: DesignTokens.textStyle('titleMedium'),
                ),
              ),
              AnimatedRotation(
                turns: _isMonthlySummaryExpanded ? 0.5 : 0,
                duration: DesignTokens.duration('fast'),
                child: Icon(
                  Icons.expand_more,
                  color: DesignTokens.color('textSecondary'),
                ),
              ),
            ],
          ),
          VSpace('sm'),
          
          // Summary totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.focusedDay.year} ${_getMonthName(widget.focusedDay)}',
                style: DesignTokens.textStyle('titleLarge'),
              ),
              FinancialAmount(
                amount: currentMonthTotal,
                size: FinancialAmountSize.large,
              ),
            ],
          ),
          VSpace('sm'),
          
          // Progress indicator with design system
          GestureDetector(
            onLongPress: () => _showProgressThresholdDialog(context),
            child: FinancialProgressBar(
              value: currentMonthTotal.abs(),
              total: _getProgressThreshold(),
              showLabels: false,
              financialContext: financialContext,
              height: 6,
            ),
          ),
          
          // Expanded content
          ExpandTransition(
            expanded: _isMonthlySummaryExpanded,
            duration: 'normal',
            child: _isMonthlySummaryExpanded 
                ? Column(
                    children: [
                      VSpace('md'),
                      _buildExpandedMonthlyContent(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  double _getProgressThreshold() {
    final settingsService = getIt<SettingsService>();
    return settingsService.monthlyProgressThreshold;
  }

  Widget _buildExpandedMonthlyContent() {
    if (_isLoadingMonthlyData) {
      return Padding(
        padding: EdgeInsets.only(top: DesignTokens.space('md')),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income and Expense totals using design system
        Row(
          children: [
            Expanded(
              child: CashCard(
                financialContext: FinancialContext.income,
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: DesignTokens.color('income'),
                      size: 20,
                    ),
                    VSpace('xs'),
                    Text(
                      'Income',
                      style: DesignTokens.textStyle('labelMedium').copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FinancialAmount(
                      amount: _monthlyTotalIncome,
                      size: FinancialAmountSize.medium,
                      showSign: false,
                    ),
                  ],
                ),
              ),
            ),
            HSpace('md'),
            Expanded(
              child: CashCard(
                financialContext: FinancialContext.expense,
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_down,
                      color: DesignTokens.color('expense'),
                      size: 20,
                    ),
                    VSpace('xs'),
                    Text(
                      'Expenses',
                      style: DesignTokens.textStyle('labelMedium').copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FinancialAmount(
                      amount: _monthlyTotalExpenses,
                      size: FinancialAmountSize.medium,
                      showSign: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        VSpace('lg'),
        
        // Category breakdowns using design system
        if (_monthlyIncomeByCategory.isNotEmpty) ...[
          _buildCategoryBreakdown(
            'Income by Category',
            _monthlyIncomeByCategory,
            FinancialContext.income,
            Icons.trending_up,
          ),
          VSpace('md'),
        ],
        
        if (_monthlyExpenseByCategory.isNotEmpty) ...[
          _buildCategoryBreakdown(
            'Expenses by Category',
            _monthlyExpenseByCategory,
            FinancialContext.expense,
            Icons.trending_down,
          ),
        ],
        
        VSpace('lg'),
        
        // Detailed transaction lists using design system
        Text(
          'Transaction Details',
          style: DesignTokens.textStyle('titleMedium').copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        VSpace('sm'),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Income transactions column
            Expanded(
              child: _buildTransactionList(
                'Income Transactions',
                _monthlyIncomeTransactions,
                FinancialContext.income,
              ),
            ),
            HSpace('md'),
            // Expense transactions column
            Expanded(
              child: _buildTransactionList(
                'Expense Transactions',
                _monthlyExpenseTransactions,
                FinancialContext.expense,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
    String title,
    Map<String, double> categories,
    FinancialContext financialContext,
    IconData icon,
  ) {
    // Sort categories by amount (descending)
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Show top 5 categories
    final topCategories = sortedEntries.take(5).toList();
    final totalAmount = categories.values.fold<double>(0, (sum, amount) => sum + amount);
    
    return CashCard(
      financialContext: financialContext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: DesignTokens.color(financialContext == FinancialContext.income ? 'income' : 'expense'),
              ),
              HSpace('sm'),
              Text(
                title,
                style: DesignTokens.textStyle('titleSmall').copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          VSpace('sm'),
          ...topCategories.map((entry) {
            final percentage = (entry.value / totalAmount * 100);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: DesignTokens.space('xs') / 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: DesignTokens.textStyle('bodySmall'),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  HSpace('sm'),
                  FinancialAmount(
                    amount: entry.value,
                    size: FinancialAmountSize.small,
                    showSign: false,
                  ),
                  HSpace('xs'),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: DesignTokens.textStyle('bodySmall').copyWith(
                      color: DesignTokens.color('textTertiary'),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (sortedEntries.length > 5) ...[
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.space('xs')),
              child: Text(
                '+ ${sortedEntries.length - 5} more categories',
                style: DesignTokens.textStyle('bodySmall').copyWith(
                  color: DesignTokens.color('textTertiary'),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    String title,
    List<Event> transactions,
    FinancialContext financialContext,
  ) {
    if (transactions.isEmpty) {
      return CashCard(
        financialContext: financialContext,
        child: Column(
          children: [
            Text(
              title,
              style: DesignTokens.textStyle('titleSmall').copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            VSpace('sm'),
            Text(
              'No transactions this month',
              style: DesignTokens.textStyle('bodySmall').copyWith(
                color: DesignTokens.color('textTertiary'),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Sort transactions by date (most recent first)
    final sortedTransactions = List<Event>.from(transactions)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return CashCard(
      financialContext: financialContext,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(DesignTokens.space('md')),
            child: Text(
              title,
              style: DesignTokens.textStyle('titleSmall').copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Transaction list
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                return _buildTransactionListItem(transaction, financialContext);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListItem(
    Event transaction,
    FinancialContext financialContext,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.space('md'),
        vertical: DesignTokens.space('sm'),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.color('border'),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transaction.title,
                  style: DesignTokens.textStyle('bodyMedium').copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FinancialAmount(
                amount: transaction.amount.abs(),
                size: FinancialAmountSize.small,
                showSign: false,
              ),
            ],
          ),
          VSpace('xs'),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<String>(
                  future: _getTransactionCategoryName(transaction.categoryId),
                  builder: (context, snapshot) {
                    final categoryName = snapshot.data ?? 'Loading...';
                    return Text(
                      categoryName,
                      style: DesignTokens.textStyle('bodySmall').copyWith(
                        color: DesignTokens.color('textTertiary'),
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              Text(
                _formatTransactionDate(transaction.dateTime),
                style: DesignTokens.textStyle('bodySmall').copyWith(
                  color: DesignTokens.color('textTertiary'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String> _getTransactionCategoryName(int categoryId) async {
    try {
      final database = getIt<Database>();
      final category = await database.getCategoryById(categoryId);
      if (category != null) {
        // If it's a subcategory, show parent > child format
        if (category.parentCategoryId != null) {
          final parentCategory = await database.getCategoryById(category.parentCategoryId!);
          if (parentCategory != null) {
            return '${parentCategory.name} > ${category.name}';
          }
        }
        return category.name;
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  Future<void> _showProgressThresholdDialog(BuildContext context) async {
    final settingsService = getIt<SettingsService>();
    final currentThreshold = settingsService.monthlyProgressThreshold;
    final controller = TextEditingController(text: currentThreshold.toStringAsFixed(0));
    
    final result = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Monthly Progress Threshold'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set the target amount for the monthly progress bar. The bar will show your progress toward this goal.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (\$)',
                  hintText: 'e.g., 10000',
                  prefixText: '\$',
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(),
              size: ButtonSize.small,
              child: const Text('Cancel'),
            ),
            HSpace('sm'),
            PrimaryButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null && value > 0) {
                  Navigator.of(context).pop(value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a valid amount greater than 0'),
                      backgroundColor: DesignTokens.color('error'),
                    ),
                  );
                }
              },
              size: ButtonSize.small,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final updateResult = await settingsService.updateMonthlyProgressThreshold(result);
      updateResult.fold(
        (failure) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update threshold: ${failure.message}'),
                backgroundColor: DesignTokens.color('error'),
              ),
            );
          }
        },
        (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Progress threshold updated to \$${result.toStringAsFixed(0)}'),
                backgroundColor: DesignTokens.color('success'),
              ),
            );
            // Trigger a rebuild to update the progress bar
            setState(() {});
          }
        },
      );
    }
  }

 Widget _buildCalendar(BuildContext context) {
    return CashCard(
      child: TableCalendar<Event>(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: widget.focusedDay,
        selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
        calendarFormat: widget.calendarFormat,
        eventLoader: widget.eventLoader,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: EdgeInsets.all(DesignTokens.space('xs')),
          defaultDecoration: BoxDecoration(
            color: DesignTokens.color('surface'),
            borderRadius: DesignTokens.radius('sm'),
            border: Border.all(
              color: DesignTokens.color('border'),
              width: 1,
            ),
          ),
          todayDecoration: BoxDecoration(
            color: DesignTokens.color('primary').withOpacity(0.3),
            borderRadius: DesignTokens.radius('sm'),
            border: Border.all(
              color: DesignTokens.color('primary'),
              width: 2,
            ),
          ),
          selectedDecoration: BoxDecoration(
            color: DesignTokens.color('primary').withOpacity(0.7),
            borderRadius: DesignTokens.radius('sm'),
            border: Border.all(
              color: DesignTokens.color('primary'),
              width: 2,
            ),
          ),
        ),
        onDaySelected: widget.onDaySelected,
        onFormatChanged: widget.onFormatChanged,
        onPageChanged: widget.onPageChanged,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            return _buildDayIndicator(context, date, events);
          },
          selectedBuilder: (context, date, _) {
            return _buildEnhancedDayCell(context, date, true);
          },
          defaultBuilder: (context, date, _) {
            return _buildEnhancedDayCell(context, date, false);
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedDayCell(BuildContext context, DateTime date, bool isSelected) {
    final amount = widget.getDayAmount(date);
    final events = widget.eventLoader(date);
    final theme = Theme.of(context);
    final dayKey = DateTime(date.year, date.month, date.day);
    
    // Get goal-related data for this day
    final allocations = _dailyAllocations[dayKey] ?? [];
    final hasSavings = _savingsStreak[dayKey] ?? false;
    final isMilestone = _goalMilestones.contains(dayKey);
    final totalAllocationAmount = allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.all(DesignTokens.space('xs') / 2),
      decoration: BoxDecoration(
        color: _getDayCellBackgroundColor(isSelected, hasSavings, isMilestone),
        borderRadius: DesignTokens.radius('sm'),
        border: Border.all(
          color: _getDayCellBorderColor(isSelected, hasSavings, isMilestone),
          width: isMilestone ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Day number
          Center(
            child: Text(
              '${date.day}',
              style: DesignTokens.textStyle('bodyLarge').copyWith(
                color: amount != 0 
                    ? (amount > 0 ? DesignTokens.color('income') : DesignTokens.color('expense'))
                    : DesignTokens.color('textPrimary'),
                fontWeight: isMilestone ? FontWeight.bold : null,
              ),
            ),
          ),
          
          // Event count indicator
          if (events.isNotEmpty)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: DesignTokens.radius('sm'),
                ),
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.color('onPrimary'),
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
            
          // Goal allocation indicator
          if (allocations.isNotEmpty)
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: DesignTokens.color('income'),
                  borderRadius: DesignTokens.radius('sm'),
                ),
                child: Center(
                  child: Icon(
                    Icons.savings,
                    color: DesignTokens.color('onPrimary'),
                    size: 8,
                  ),
                ),
              ),
            ),
          
          // Mini goal progress indicators (bottom row)
          if (_goals.isNotEmpty && !_isLoading)
            Positioned(
              bottom: 2,
              left: 2,
              right: 2,
              child: _buildMiniGoalProgressIndicators(),
            ),
          
          // Milestone marker
          if (isMilestone)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: DesignTokens.color('warning'),
                  borderRadius: DesignTokens.radius('xs'),
                ),
                child: Center(
                  child: Icon(
                    Icons.star,
                    color: DesignTokens.color('onPrimary'),
                    size: 8,
                  ),
                ),
              ),
            ),
            
          // Allocation amount text
          if (totalAllocationAmount > 0)
            Positioned(
              bottom: 1,
              left: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: DesignTokens.space('xs') / 2, vertical: 1),
                decoration: BoxDecoration(
                  color: DesignTokens.color('income').withOpacity(0.8),
                  borderRadius: DesignTokens.radius('xs'),
                ),
                child: Text(
                  '\$${totalAllocationAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: DesignTokens.color('onPrimary'),
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


Widget _buildDayIndicator(BuildContext context, DateTime date, List<Event> events) {
  if (events.isEmpty) return const SizedBox();

  return Positioned(
    bottom: 1,
    left: 1,
    right: 1,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: events.map((event) => Padding(
        padding: EdgeInsets.symmetric(horizontal: DesignTokens.space('xs') / 4),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: event.isPositiveCashflow ? DesignTokens.color('income') : DesignTokens.color('expense'),
          ),
        ),
      )).toList(),
    ),
  );
}

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  String _formatAmount(double amount) {
    return '\$${amount.abs().toStringAsFixed(2)}';
  }

  double _calculateProgress(double amount) {
    final settingsService = getIt<SettingsService>();
    final threshold = settingsService.monthlyProgressThreshold;
    return (amount.abs() / threshold).clamp(0.0, 1.0);
  }

  // New goal-related methods

  Widget _buildGoalsSummaryCard(BuildContext context) {
    final activeGoals = _goals.where((g) => g.currentAmount < g.targetAmount).length;
    final totalSaved = _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);

    return CashCard(
      financialContext: FinancialContext.income,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goals Summary',
            style: DesignTokens.textStyle('titleMedium'),
          ),
          VSpace('sm'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$activeGoals Active Goals',
                style: DesignTokens.textStyle('bodyLarge'),
              ),
              FinancialAmount(
                amount: totalSaved,
                size: FinancialAmountSize.medium,
                showSign: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsStreakIndicator(BuildContext context) {
    final currentStreak = _calculateCurrentSavingsStreak();
    
    if (currentStreak == 0) return const SizedBox();

    return CashCard(
      financialContext: FinancialContext.neutral,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.space('sm')),
            decoration: BoxDecoration(
              color: DesignTokens.color('warning'),
              borderRadius: DesignTokens.radius('sm'),
            ),
            child: Icon(
              Icons.local_fire_department,
              color: DesignTokens.color('onWarning'),
              size: 20,
            ),
          ),
          HSpace('md'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savings Streak',
                  style: DesignTokens.textStyle('titleMedium').copyWith(
                    color: DesignTokens.color('warning'),
                  ),
                ),
                Text(
                  '$currentStreak ${currentStreak == 1 ? 'day' : 'days'} of consistent saving!',
                  style: DesignTokens.textStyle('bodyMedium').copyWith(
                    color: DesignTokens.color('textSecondary'),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$currentStreak',
            style: DesignTokens.textStyle('headlineMedium').copyWith(
              color: DesignTokens.color('warning'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGoalProgressIndicators() {
    if (_goals.isEmpty) return const SizedBox();
    
    const maxIndicators = 3; // Limit to show only top 3 goals
    final topGoals = _goals.take(maxIndicators).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: topGoals.map((goal) {
        final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
        return Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: DesignTokens.radius('xs'),
            color: DesignTokens.color('borderLight'),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: DesignTokens.radius('xs'),
                color: _getGoalProgressColor(progress),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getDayCellBackgroundColor(bool isSelected, bool hasSavings, bool isMilestone) {
    if (isMilestone) {
      return DesignTokens.color('warning').withOpacity(0.1);
    }
    if (hasSavings) {
      return DesignTokens.color('income').withOpacity(0.05);
    }
    if (isSelected) {
      return DesignTokens.color('primary').withOpacity(0.1);
    }
    return DesignTokens.color('surface');
  }

  Color _getDayCellBorderColor(bool isSelected, bool hasSavings, bool isMilestone) {
    if (isMilestone) {
      return DesignTokens.color('warning');
    }
    if (hasSavings) {
      return DesignTokens.color('income').withOpacity(0.3);
    }
    if (isSelected) {
      return DesignTokens.color('primary');
    }
    return DesignTokens.color('border');
  }

  Color _getGoalProgressColor(double progress) {
    if (progress >= 0.8) return DesignTokens.color('success');
    if (progress >= 0.5) return DesignTokens.color('warning');
    return DesignTokens.color('error');
  }

  int _calculateCurrentSavingsStreak() {
    final today = DateTime.now();
    int streak = 0;
    
    // Count backwards from today
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      
      if (_savingsStreak[dayKey] == true) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
}
