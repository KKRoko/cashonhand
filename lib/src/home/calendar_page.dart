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
  static const routeName = '/calendar';

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
    print('Adding event: ${event.title}, Amount: ${event.amount}, RepeatOption: ${event.repeatOption}');

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
        _addEventToDay(day, event);

        if (event.repeatOption != RepeatOption.none) {
          DateTime nextDay = _getNextRepeatDate(day, event.repeatOption, event.customRecurrence);
          while (nextDay.isBefore(DateTime.now().add(const Duration(days: 365)))) {
            _addEventToDay(nextDay, event);
            nextDay = _getNextRepeatDate(nextDay, event.repeatOption, event.customRecurrence);
          }
        } 
      }
      
      print('Total events after adding: ${kEvents.values.expand((events) => events).length}');

      _selectedEvents.value = _getEventsForDay(day);
    });
  }

  void _addEventToDay(DateTime day, Event event) {
    if (kEvents[day] != null) {
      kEvents[day]!.add(event);
    } else {
      kEvents[day] = [event];
    }
    print('Added event to ${day.toString()}: ${event.title}');
  }

  void _editEvent(DateTime day, Event oldEvent, Event newEvent) {
    setState(() {
      _removeRepeatingEvents(day, oldEvent);

      if (kEvents[day] != null) {
        final index = kEvents[day]!.indexOf(oldEvent);
        if (index != -1) {
          kEvents[day]![index] = newEvent;
        }
      }
      _addEvent(day, newEvent);

      _selectedEvents.value = _getEventsForDay(day);
    
      if (newEvent.repeatOption != RepeatOption.none) {
        DateTime nextDay = day;
        while (true) {
          nextDay = _getNextRepeatDate(nextDay, newEvent.repeatOption, newEvent.customRecurrence);
          if (nextDay.isAfter(DateTime.now().add(const Duration(days: 365)))) break;
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog() {
    showAddEventDialog(context, _selectedDay!, (event) async {
      try {
        await _addEvent(_selectedDay!, event);
        setState(() {
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      } catch (e) {
        print('Error adding event: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding event: $e')),
        );
      }
    });
  }

  void _showEditEventDialog(DateTime day, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Cash Flow'),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: event.title),
                    decoration: const InputDecoration(labelText: 'Cash Flow Name'),
                    onChanged: (value) => event = event.copyWith(title: value),
                  ),
                  TextField(
                    controller: TextEditingController(text: event.amount?.toString() ?? ''),
                    decoration: const InputDecoration(labelText: 'Amount in USD'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) => event = event.copyWith(amount: double.tryParse(value)),
                  ),
                  CheckboxListTile(
                    title: const Text('Positive Cashflow'),
                    value: event.isPositiveCashflow,
                    onChanged: (value) {
                      setState(() {
                        event = event.copyWith(isPositiveCashflow: value, isNegativeCashflow: value! ? false : event.isNegativeCashflow);
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Negative Cashflow'),
                    value: event.isNegativeCashflow,
                    onChanged: (value) {
                      setState(() {
                        event = event.copyWith(isNegativeCashflow: value, isPositiveCashflow: value! ? false : event.isPositiveCashflow);
                      });
                    },
                  ),
                  DropdownButton<RepeatOption>(
                    value: event.repeatOption,
                    onChanged: (RepeatOption? newValue) {
                      setState(() {
                        event = event.copyWith(repeatOption: newValue);
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
              ),
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
              _editEvent(day, event, event);
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
        case RepeatOption.daily:
          return currentDay.add(Duration(days: customRecurrence.frequency));
        case RepeatOption.weekly:
          if (customRecurrence.selectedDays.isNotEmpty) {
            int currentWeekday = currentDay.weekday % 7;
            int daysUntilNextOccurrence = 0;
            
            for (int i = 0; i < 7; i++) {
              int nextWeekday = (currentWeekday + i) % 7;
              if (customRecurrence.selectedDays[nextWeekday]) {
                daysUntilNextOccurrence = i;
                break;
              }
            }
            
            if (daysUntilNextOccurrence > 0) {
              DateTime nextOccurrence = currentDay.add(Duration(days: daysUntilNextOccurrence));
              
              if (nextOccurrence.difference(currentDay).inDays < 7) {
                return nextOccurrence;
              }
              
              while (nextOccurrence.difference(currentDay).inDays < 7 * customRecurrence.frequency) {
                nextOccurrence = nextOccurrence.add(const Duration(days: 7));
              }
              
              return nextOccurrence;
            }
          }
          
          return currentDay.add(Duration(days: 7 * customRecurrence.frequency));
        case RepeatOption.monthly:
          int targetDay = customRecurrence.dayOfMonth ?? currentDay.day;
          DateTime nextMonth = DateTime(currentDay.year, currentDay.month + customRecurrence.frequency, 1);
          return DateTime(nextMonth.year, nextMonth.month, min(targetDay, DateTime(nextMonth.year, nextMonth.month + 1, 0).day));
        case RepeatOption.yearly:
          return DateTime(
            currentDay.year + customRecurrence.frequency,
            customRecurrence.month ?? currentDay.month,
            min(customRecurrence.dayOfMonth ?? currentDay.day, DateTime(currentDay.year + customRecurrence.frequency, (customRecurrence.month ?? currentDay.month) + 1, 0).day)
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
        return DateTime(currentDay.year, currentDay.month + 1, min(currentDay.day, DateTime(currentDay.year, currentDay.month + 2, 0).day));
      case RepeatOption.yearly:
        return DateTime(currentDay.year + 1, currentDay.month, min(currentDay.day, DateTime(currentDay.year + 1, currentDay.month + 1, 0).day));
      default:
        return currentDay;
    }
  }
}
