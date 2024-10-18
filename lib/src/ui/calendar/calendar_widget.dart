import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cash_on_hand/src/models/event_model.dart';
import 'package:cash_on_hand/src/utils/constants.dart';


Widget buildTableCalendar({
  required DateTime focusedDay,
  required DateTime? selectedDay,
  required Function(DateTime, DateTime) onDaySelected,
  required List<Event> Function(DateTime) eventLoader,
  required CalendarFormat calendarFormat,
  required RangeSelectionMode rangeSelectionMode,
  required void Function(CalendarFormat) onFormatChanged,
}) {
  return TableCalendar<Event>(
    firstDay: AppConstants.kFirstDay,
    lastDay: AppConstants.kLastDay,
    focusedDay: focusedDay,
    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
    calendarFormat: calendarFormat,
    rangeSelectionMode: rangeSelectionMode,
    eventLoader: eventLoader,
    onDaySelected: onDaySelected,
    onFormatChanged: onFormatChanged,
    calendarBuilders: CalendarBuilders(
      markerBuilder: (context, date, events) {
        if (events.isEmpty) return const SizedBox();
        return Positioned(
          bottom: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: events.map((event) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.isPositiveCashflow ? Colors.green : Colors.red,
              ),
            )).toList(),
          ),
        );
      },
    ),
  );
}