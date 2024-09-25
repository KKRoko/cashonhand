// calendar_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils.dart';
import 'event_dialog.dart';
import 'event_list.dart';
import 'calendar_widget.dart';

class CalendarPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  void _addEvent(DateTime day, Event event) {
    setState(() {
      _addEventToDay(day, event);

      if (event.repeatOption != RepeatOption.none) {
        DateTime nextDay = day;
        while (true) {
          nextDay = _getNextRepeatDate(nextDay, event.repeatOption);
          if (nextDay.isAfter(DateTime.now().add(Duration(days: 365)))) break; // Limit to one year for performance
          _addEventToDay(nextDay, event);
        }
      }

      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _addEventToDay(DateTime day, Event event) {
    if (kEvents[day] != null) {
      kEvents[day]!.add(event);
    } else {
      kEvents[day] = [event];
    }
  }

  DateTime _getNextRepeatDate(DateTime date, RepeatOption repeatOption) {
    switch (repeatOption) {
      case RepeatOption.daily:
        return date.add(Duration(days: 1));
      case RepeatOption.weekly:
        return date.add(Duration(days: 7));
      case RepeatOption.monthly:
        return DateTime(date.year, date.month + 1, date.day);
      case RepeatOption.yearly:
        return DateTime(date.year + 1, date.month, date.day);
      default:
        return date;
    }
  }

  void _deleteEvent(DateTime day, Event event) {
    setState(() {
      if (kEvents[day] != null) {
        kEvents[day]!.remove(event);
        if (kEvents[day]!.isEmpty) {
          kEvents.remove(day);
        }
      }
      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _editEvent(DateTime day, Event oldEvent, Event newEvent) {
    setState(() {
      // Remove old repeating events
      _removeRepeatingEvents(day, oldEvent);

      // Add the new event
      if (kEvents[day] != null) {
        final index = kEvents[day]!.indexOf(oldEvent);
        if (index != -1) {
          kEvents[day]![index] = newEvent;
        }
      }

      // Add new repeating events
      if (newEvent.repeatOption != RepeatOption.none) {
        DateTime nextDay = day;
        while (true) {
          nextDay = _getNextRepeatDate(nextDay, newEvent.repeatOption);
          if (nextDay.isAfter(DateTime.now().add(Duration(days: 365)))) break; // Limit to one year for performance
          _addEventToDay(nextDay, newEvent);
        }
      }

      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _removeRepeatingEvents(DateTime day, Event event) {
    DateTime nextDay = day;
    while (true) {
      nextDay = _getNextRepeatDate(nextDay, event.repeatOption);
      if (kEvents[nextDay] != null) {
        kEvents[nextDay]!.remove(event);
        if (kEvents[nextDay]!.isEmpty) {
          kEvents.remove(nextDay);
        }
      }
      if (nextDay.isAfter(DateTime.now().add(Duration(days: 365)))) break; // Limit to one year for performance
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _selectedEvents.value = _getEventsForDay(selectedDay);
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Cash on Hand - Events'),
    ),
    body: Column(
      children: [
        buildTableCalendar(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          onDaySelected: _onDaySelected,
          onFormatChanged: _onFormatChanged,
          eventLoader: _getEventsForDay,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return buildEventList(
                value,
                (event) => _deleteEvent(_selectedDay!, event),
                (event) => _showEditEventDialog(_selectedDay!, event),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
  onPressed: () {
    showAddEventDialog(context, _selectedDay!, (event) {
      print('Adding event: $event');  // Debug statement
      _addEvent(_selectedDay!, event);  // Add the new event
      _selectedEvents.value = _getEventsForDay(_selectedDay!);  // Refresh events
      Navigator.pop(context);  // Close the dialog after adding the event
      print('Event added and dialog closed');  // Debug statement
    });
  },
  child: const Text('Add Cash Flow'),
),
        ),
      ],
    ),
  );
}
  void _showEditEventDialog(DateTime day, Event event) {
    TextEditingController titleController = TextEditingController(text: event.title);
    TextEditingController amountController = TextEditingController(text: event.amount?.toString() ?? '');
    bool isPositiveCashflow = event.isPositiveCashflow;
    bool isNegativeCashflow = event.isNegativeCashflow;
    RepeatOption repeatOption = event.repeatOption;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Cash Flow'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Cash Flow Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount in USD'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                CheckboxListTile(
                  title: Text('Positive Cashflow'),
                  value: isPositiveCashflow,
                  onChanged: (value) {
                    setState(() {
                      isPositiveCashflow = value!;
                      if (isPositiveCashflow) isNegativeCashflow = false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('Negative Cashflow'),
                  value: isNegativeCashflow,
                  onChanged: (value) {
                    setState(() {
                      isNegativeCashflow = value!;
                      if (isNegativeCashflow) isPositiveCashflow = false;
                    });
                  },
                ),
                DropdownButton<RepeatOption>(
                  value: repeatOption,
                  onChanged: (RepeatOption? newValue) {
                    setState(() {
                      repeatOption = newValue!;
                    });
                  },
                  items: RepeatOption.values.map((RepeatOption option) {
                    return DropdownMenuItem<RepeatOption>(
                      value: option,
                      child: Text(option.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newEvent = Event(
                title: titleController.text,
                amount: double.tryParse(amountController.text),
                isPositiveCashflow: isPositiveCashflow,
                isNegativeCashflow: isNegativeCashflow,
                repeatOption: repeatOption,
              );
              _editEvent(day, event, newEvent);
              Navigator.pop(context); // Close the dialog after editing
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}