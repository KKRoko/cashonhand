// lib/ui/calendar/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data/models/freezed/event.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final List<Event> Function(DateTime) eventLoader;
  final CalendarFormat calendarFormat;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.eventLoader,
    required this.calendarFormat,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      calendarFormat: calendarFormat,
      eventLoader: eventLoader,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Colors.red[800]),
        holidayTextStyle: TextStyle(color: Colors.blue[800]),
      ),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox();
          return Positioned(
            right: 1,
            bottom: 1,
            child: _buildEventsMarker(date, events),
          );
        },
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Event> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSameDay(date, selectedDay) 
            ? Colors.brown[500] 
            : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: const TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
