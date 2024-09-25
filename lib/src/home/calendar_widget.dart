// calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart'; // Import Event and other utilities from here

Widget buildTableCalendar({
  required DateTime focusedDay,
  required DateTime? selectedDay,
  required Function(DateTime, DateTime) onDaySelected,
  required List<Event> Function(DateTime) eventLoader,
  required CalendarFormat calendarFormat,
  required RangeSelectionMode rangeSelectionMode,
  required void Function(CalendarFormat) onFormatChanged, // Add this line
}) {
  return TableCalendar<Event>(
    firstDay: kFirstDay,
    lastDay: kLastDay,
    focusedDay: focusedDay,
    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
    calendarFormat: calendarFormat,
    rangeSelectionMode: rangeSelectionMode,
    eventLoader: eventLoader,
    onDaySelected: onDaySelected,
    onFormatChanged: onFormatChanged, // Add this line
  );
}