// lib/ui/calendar/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../data/models/freezed/event.dart';

class EnhancedCalendarWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(  // Wrap with SingleChildScrollView
      child: Column(
        mainAxisSize: MainAxisSize.min,  // Add this
        children: [
          _buildMonthSummaryCard(context),
          const SizedBox(height: 5),
          _buildCalendar(context),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final currentMonthTotal = monthSummary[DateTime(
      focusedDay.year,
      focusedDay.month,
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
                  '${focusedDay.year} ${_getMonthName(focusedDay)}',
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
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: calendarFormat,
        eventLoader: eventLoader,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          cellMargin: const EdgeInsets.all(4),
          // Fixed: Removed conflicting decorations
          todayDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            return _buildDayIndicator(context, date, events);
          },
          selectedBuilder: (context, date, _) {
            return _buildDayCell(context, date, true);
          },
          defaultBuilder: (context, date, _) {
            return _buildDayCell(context, date, false);
          },
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, bool isSelected) {
    final amount = getDayAmount(date);
    final events = eventLoader(date);
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8), // Changed from 12 to 8 for better fit
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${date.day}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: amount != 0 ? (amount > 0 ? Colors.green : Colors.red) : null,
              ),
            ),
          ),
          if (events.isNotEmpty)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(8), // Changed from circle to rounded
                ),
                child: Center(
                  child: Text(
                    '${events.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
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
}
