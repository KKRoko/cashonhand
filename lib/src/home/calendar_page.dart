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

Future<void> _addEvent(DateTime selectedDay, Event event) async {
  print("Starting _addEvent method");
  await Future(() {
    DateTime endOfYear = DateTime(selectedDay.year, 12, 31);
    DateTime initialEventDay = selectedDay;

    if (event.repeatOption == RepeatOption.custom && event.customRecurrence != null) {
      if (event.customRecurrence!.interval == RepeatOption.weekly ||
          event.customRecurrence!.interval == RepeatOption.monthly) {
        // Find the next occurrence based on selectedDays
        initialEventDay = _findNextOccurrence(selectedDay, event.customRecurrence!);
      }
    }

    print("Adding initial event for day: $initialEventDay");
    _addEventToDay(initialEventDay, event);

    if (event.repeatOption != RepeatOption.today) {
      DateTime nextDay = _getNextRepeatDate(initialEventDay, event.repeatOption, event.customRecurrence);
      
      print("Starting repeat loop. First nextDay: $nextDay");
      int loopCount = 0;
      while (!nextDay.isAfter(endOfYear)) {
        print("Loop iteration $loopCount: Adding event for $nextDay");
        _addEventToDay(nextDay, event);
        DateTime previousDay = nextDay;
        nextDay = _getNextRepeatDate(nextDay, event.repeatOption, event.customRecurrence);
        
        loopCount++;
        if (loopCount > 1000 || nextDay.isAtSameMomentAs(previousDay) || nextDay.isBefore(previousDay)) {
          print("Loop ended due to count limit or date not advancing.");
          break;
        }
      }
    }
  });
  
  setState(() {
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
  });
  
  print("Finished _addEvent method");
}

DateTime _findNextOccurrence(DateTime fromDate, CustomRecurrence recurrence) {
  int daysToAdd = 0;
  while (daysToAdd < 7) {
    DateTime checkDate = fromDate.add(Duration(days: daysToAdd));
    if (recurrence.selectedDays[checkDate.weekday % 7]) {
      return checkDate;
    }
    daysToAdd++;
  }
  return fromDate; // Fallback to original date if no day is selected
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
      _removeRepeatingEvents(oldEvent);
      _addEvent(day, newEvent);
      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _removeRepeatingEvents(Event event) {
    kEvents.forEach((date, events) {
      events.removeWhere((e) => e.id == event.id);
    });
    kEvents.removeWhere((date, events) => events.isEmpty);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    });
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
              onPressed: () async {
                showAddEventDialog(context, _selectedDay!, (event) async {
                  print('Adding event: $event');
                  await _addEvent(_selectedDay!, event);
                  setState(() {
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });
                  Navigator.pop(context);
                  print('Event added and dialog closed');
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
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
DateTime _getNextRepeatDate(DateTime currentDay, RepeatOption repeatOption, CustomRecurrence? customRecurrence) {
  if (repeatOption == RepeatOption.custom && customRecurrence != null) {
    switch (customRecurrence.interval) {
      case RepeatOption.weekly:
        // For weekly custom events, add the frequency * 7 days to get to the next occurrence week
        DateTime nextWeek = currentDay.add(Duration(days: 7 * customRecurrence.frequency));
        // Then find the next selected day within that week
        return _findNextOccurrence(nextWeek, customRecurrence);
      
      case RepeatOption.monthly:
        // For monthly custom events, move to the next month based on frequency
        DateTime nextMonth = DateTime(currentDay.year, currentDay.month + customRecurrence.frequency, 1);
        // Then find the next selected day within that month
        return _findNextOccurrence(nextMonth, customRecurrence);
      
      default:
        // For any other custom interval (which shouldn't happen in this context)
        return currentDay;
    }
  } else {
    // This part remains unchanged for non-custom repeat options
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
}

}
