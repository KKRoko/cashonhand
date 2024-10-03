import 'dart:math';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'event_model.dart';
import 'event_dialog.dart';
import 'event_list.dart';
import 'calendar_widget.dart';
import 'delete_event_dialog.dart';




class CalendarPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
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


Future<void> _addEvent(DateTime day, Event event) async {
  setState(() {
    if (event.repeatOption == RepeatOption.custom && 
        event.customRecurrence?.interval == RepeatOption.weekly) {
      // For custom weekly events, find the first occurrence
      DateTime firstOccurrence = _getNextRepeatDate(day, event.repeatOption, event.customRecurrence);
      _addEventToDay(firstOccurrence, event);
      
      // Add subsequent occurrences
      DateTime nextDay = _getNextRepeatDate(firstOccurrence, event.repeatOption, event.customRecurrence);
      while (nextDay.isBefore(DateTime.now().add(const Duration(days: 365)))) {
        _addEventToDay(nextDay, event);
        nextDay = _getNextRepeatDate(nextDay, event.repeatOption, event.customRecurrence);
      }
    } else {
      // For other repeat options, add to the current day and future occurrences
      _addEventToDay(day, event);

    if (event.repeatOption != RepeatOption.none) {
      DateTime nextDay = _getNextRepeatDate(day, event.repeatOption, event.customRecurrence);
      while (nextDay.isBefore(DateTime.now().add(const Duration(days: 365)))) {
        _addEventToDay(nextDay, event);
        nextDay = _getNextRepeatDate(nextDay, event.repeatOption, event.customRecurrence);
      }
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
    _addEvent(day, newEvent);

    _selectedEvents.value = _getEventsForDay(day);
    
      // Add new repeating events
      if (newEvent.repeatOption != RepeatOption.none) {
        DateTime nextDay = day;
        while (true) {
          nextDay = _getNextRepeatDate(nextDay, newEvent.repeatOption, newEvent.customRecurrence);
          if (nextDay.isAfter(DateTime.now().add(const Duration(days: 365)))) break; // Limit to one year for performance
          _addEventToDay(nextDay, newEvent);
        }
      }

      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _removeRepeatingEvents(DateTime day, Event event) {
    kEvents.forEach((date, events) {
      events.removeWhere((e) => e.title == event.title && e.amount == event.amount);
    });
    kEvents.removeWhere((date, events) => events.isEmpty);
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

Future<void> _handleEventDeletion(DateTime day, Event event) async {
    final deleteOption = await showDeleteEventDialog(context, event);
    if (deleteOption == null) return;

    setState(() {
      switch (deleteOption) {
        case DeleteOption.thisDay:
          _deleteSingleEvent(day, event);
          break;
        case DeleteOption.allTime:
          _deleteAllEvents(event);
          break;
        case DeleteOption.futureOnly:
          _deleteFutureEvents(day, event);
          break;
        case DeleteOption.pastOnly:
          _deletePastEvents(day, event);
          break;
      }
      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _deleteSingleEvent(DateTime day, Event event) {
    if (kEvents[day] != null) {
      kEvents[day]!.removeWhere((e) => e.id == event.id);
      if (kEvents[day]!.isEmpty) {
        kEvents.remove(day);
      }
    }
  }

  void _deleteAllEvents(Event event) {
    kEvents.forEach((date, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    kEvents.removeWhere((date, events) => events.isEmpty);
  }

  void _deleteFutureEvents(DateTime day, Event event) {
    kEvents.forEach((date, events) {
      if (date.isAtSameMomentAs(day) || date.isAfter(day)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    kEvents.removeWhere((date, events) => events.isEmpty);
  }

  void _deletePastEvents(DateTime day, Event event) {
    kEvents.forEach((date, events) {
      if (date.isAtSameMomentAs(day) || date.isBefore(day)) {
        events.removeWhere((e) => e.id == event.id);
      }
    });
    kEvents.removeWhere((date, events) => events.isEmpty);
  }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Cash on Hand - Events'),
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
                (event) => _handleEventDeletion(_selectedDay!, event),
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
        title: const Text('Edit Cash Flow'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Cash Flow Name'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount in USD'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                CheckboxListTile(
                  title: const Text('Positive Cashflow'),
                  value: isPositiveCashflow,
                  onChanged: (value) {
                    setState(() {
                      isPositiveCashflow = value!;
                      if (isPositiveCashflow) isNegativeCashflow = false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Negative Cashflow'),
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
            child: const Text('Cancel'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

DateTime _getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
  if (repeatOption == RepeatOption.custom && customRecurrence != null) {
    switch (customRecurrence.interval) {
      case RepeatOption.daily:
        return currentDay.add(Duration(days: customRecurrence.frequency));
case RepeatOption.weekly:
  if (customRecurrence.selectedDays.isNotEmpty) {
    int currentWeekday = currentDay.weekday % 7;
    int daysUntilNextOccurrence = 0;
    
    // Find the next occurrence
          for (int i = 0; i < 7; i++) {
            int nextWeekday = (currentWeekday + i) % 7;
            if (customRecurrence.selectedDays[nextWeekday]) {
              daysUntilNextOccurrence = i;
              break;
            }
          }
    
    // If found, return the next occurrence date
    if (daysUntilNextOccurrence > 0) {
            DateTime nextOccurrence = currentDay.add(Duration(days: daysUntilNextOccurrence));
            
            // If it's the first occurrence and it's within the same week, return it
            if (nextOccurrence.difference(currentDay).inDays < 7) {
              return nextOccurrence;
            }
            
            // Otherwise, adjust for frequency
            while (nextOccurrence.difference(currentDay).inDays < 7 * customRecurrence.frequency) {
              nextOccurrence = nextOccurrence.add(const Duration(days: 7));
            }
            
            return nextOccurrence;
          }
  }
  
  // If no specific days are selected or no valid occurrence found, jump by the frequency
  return currentDay.add(Duration(days: 7 * customRecurrence.frequency));
      case RepeatOption.monthly:
        int targetDay = customRecurrence.dayOfMonth ?? currentDay.day;
        DateTime nextMonth = DateTime(currentDay.year, currentDay.month + customRecurrence.frequency, 1);
        return DateTime(nextMonth.year, nextMonth.month, min(targetDay, DateUtils.getDaysInMonth(nextMonth.year, nextMonth.month)));
      case RepeatOption.yearly:
        return DateTime(
          currentDay.year + customRecurrence.frequency,
          customRecurrence.month ?? currentDay.month,
          min(customRecurrence.dayOfMonth ?? currentDay.day, DateUtils.getDaysInMonth(currentDay.year + customRecurrence.frequency, customRecurrence.month ?? currentDay.month))
        );
      default:
        return currentDay;
    }
  }

  switch (repeatOption) {
    case RepeatOption.daily:
      return currentDay.add(const Duration(days: 1));
    case RepeatOption.weekly:
      return currentDay.add(const Duration(days: 7));
    case RepeatOption.monthly:
      return DateTime(currentDay.year, currentDay.month + 1, currentDay.day);
    case RepeatOption.yearly:
      return DateTime(currentDay.year + 1, currentDay.month, currentDay.day);
    default:
      return currentDay;
  }
}