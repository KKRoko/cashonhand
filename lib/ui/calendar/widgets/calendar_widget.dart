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

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  @override
  void didUpdateWidget(EnhancedCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay.month != widget.focusedDay.month ||
        oldWidget.focusedDay.year != widget.focusedDay.year) {
      _loadGoalData();
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
            Text(
              'Month Summary',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
            LinearProgressIndicator(
              value: _calculateProgress(currentMonthTotal),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(
                currentMonthTotal >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
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
