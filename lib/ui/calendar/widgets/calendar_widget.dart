// lib/ui/calendar/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/freezed/event.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../core/di/injection.dart';
import '../../../data/repositories/saving_goal_repository.dart';
import '../../../data/database/database.dart';

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
          const SizedBox(height: 5),
          _buildCalendar(context),
          if (!_isLoading) _buildSavingsStreakIndicator(context),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final currentMonthTotal = widget.monthSummary[DateTime(
      widget.focusedDay.year,
      widget.focusedDay.month,
      1,
    )] ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() => _isMonthlySummaryExpanded = !_isMonthlySummaryExpanded),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                width: 4,
                color: currentMonthTotal >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with expand/collapse icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Monthly Summary',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isMonthlySummaryExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Summary totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.focusedDay.year} ${_getMonthName(widget.focusedDay)}',
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    _formatAmount(currentMonthTotal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: currentMonthTotal >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Progress indicator
              LinearProgressIndicator(
                value: _calculateProgress(currentMonthTotal),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  currentMonthTotal >= 0 ? Colors.green : Colors.red,
                ),
              ),
              
              // Expanded content
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isMonthlySummaryExpanded ? null : 0,
                child: _isMonthlySummaryExpanded 
                  ? _buildExpandedMonthlyContent(theme)
                  : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedMonthlyContent(ThemeData theme) {
    if (_isLoadingMonthlyData) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Income and Expense totals
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Income',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_monthlyTotalIncome.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_down,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expenses',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${_monthlyTotalExpenses.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category breakdowns
          if (_monthlyIncomeByCategory.isNotEmpty) ...[
            _buildCategoryBreakdown(
              theme,
              'Income by Category',
              _monthlyIncomeByCategory,
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(height: 12),
          ],
          
          if (_monthlyExpenseByCategory.isNotEmpty) ...[
            _buildCategoryBreakdown(
              theme,
              'Expenses by Category',
              _monthlyExpenseByCategory,
              Colors.red,
              Icons.trending_down,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Detailed transaction lists
          Text(
            'Transaction Details',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income transactions column
              Expanded(
                child: _buildTransactionList(
                  theme,
                  'Income Transactions',
                  _monthlyIncomeTransactions,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              // Expense transactions column
              Expanded(
                child: _buildTransactionList(
                  theme,
                  'Expense Transactions',
                  _monthlyExpenseTransactions,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    ThemeData theme,
    String title,
    Map<String, double> categories,
    MaterialColor color,
    IconData icon,
  ) {
    // Sort categories by amount (descending)
    final sortedEntries = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Show top 5 categories
    final topCategories = sortedEntries.take(5).toList();
    final totalAmount = categories.values.fold<double>(0, (sum, amount) => sum + amount);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...topCategories.map((entry) {
            final percentage = (entry.value / totalAmount * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${percentage.toStringAsFixed(1)}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (sortedEntries.length > 5) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${sortedEntries.length - 5} more categories',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
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
    ThemeData theme,
    String title,
    List<Event> transactions,
    MaterialColor color,
  ) {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions this month',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
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

    return Container(
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color.shade800,
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
                return _buildTransactionListItem(theme, transaction, color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListItem(
    ThemeData theme,
    Event transaction,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color.shade200,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '\$${transaction.amount.abs().toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<String>(
                  future: _getTransactionCategoryName(transaction.categoryId),
                  builder: (context, snapshot) {
                    final categoryName = snapshot.data ?? 'Loading...';
                    return Text(
                      categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              Text(
                _formatTransactionDate(transaction.dateTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
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

 Widget _buildCalendar(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
          cellMargin: const EdgeInsets.all(4),
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
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
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getDayCellBackgroundColor(isSelected, hasSavings, isMilestone),
        borderRadius: BorderRadius.circular(8),
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: amount != 0 ? (amount > 0 ? Colors.green : Colors.red) : null,
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
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
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
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(
                  child: Icon(
                    Icons.savings,
                    color: Colors.white,
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
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '\$${totalAllocationAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
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
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: event.isPositiveCashflow ? Colors.green : Colors.red,
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
    const threshold = 10000; // Adjust based on your needs
    return (amount.abs() / threshold).clamp(0.0, 1.0);
  }

  // New goal-related methods

  Widget _buildGoalsSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final activeGoals = _goals.where((g) => g.currentAmount < g.targetAmount).length;
    final totalSaved = _goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(width: 4, color: Colors.green),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals Summary',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$activeGoals Active Goals',
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  '\$${totalSaved.toStringAsFixed(2)} Saved',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsStreakIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final currentStreak = _calculateCurrentSavingsStreak();
    
    if (currentStreak == 0) return const SizedBox();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade50],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Savings Streak',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                  Text(
                    '$currentStreak ${currentStreak == 1 ? 'day' : 'days'} of consistent saving!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$currentStreak',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
            borderRadius: BorderRadius.circular(1.5),
            color: Colors.grey.shade300,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1.5),
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
      return Colors.amber.withOpacity(0.1);
    }
    if (hasSavings) {
      return Colors.green.withOpacity(0.05);
    }
    if (isSelected) {
      return Colors.blue.withOpacity(0.1);
    }
    return Colors.transparent;
  }

  Color _getDayCellBorderColor(bool isSelected, bool hasSavings, bool isMilestone) {
    if (isMilestone) {
      return Colors.amber;
    }
    if (hasSavings) {
      return Colors.green.withOpacity(0.3);
    }
    if (isSelected) {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  Color _getGoalProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
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
