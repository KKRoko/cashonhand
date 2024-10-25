import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/freezed/event.dart';
import '../../services/event_service.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../dialogs/delete_event_dialog.dart' show showDeleteEventDialog;
import '../../state/event_notifier.dart';
import 'widgets/index.dart';
import 'widgets/calendar_widget.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EventService _eventService;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventService = EventService(Provider.of<EventNotifier>(context));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

Future<void> _showAddEventDialog() async {
  final newEvent = await showDialog<Event>(
    context: context,
    builder: (BuildContext context) {
      return AddEditEventDialog(
        selectedDay: _selectedDay!,
      );
    },
  );

  if (newEvent != null) {
    _eventService.addEvent(_selectedDay!, newEvent);
  }
}

Future<void> _showEditEventDialog(Event event) async {
  final editedEvent = await showDialog<Event>(
    context: context,
    builder: (BuildContext context) {
      return AddEditEventDialog(
        selectedDay: _selectedDay!,
        event: event,
      );
    },
  );

  if (editedEvent != null) {
    _eventService.editEvent(_selectedDay!, event, editedEvent);
  }
}

 Future<void> _showDeleteEventDialog(Event event) async {
  final deleteOption = await showDeleteEventDialog(context, event);
  if (deleteOption != null) {
    _eventService.deleteEvent(_selectedDay!, event, deleteOption);
  }
 }

  // Add this method to get day amounts
  double _getDayAmount(DateTime day) {
    final events = _eventService.getEventsForDay(day);
    return events.fold(0.0, (sum, event) => sum + (event.amount ?? 0.0));
  }

  // Add this method to get month summary
  Map<DateTime, double> _getMonthSummary() {
    // You'll need to implement this based on your EventService
    // This is a basic implementation
    final summary = <DateTime, double>{};
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    for (var day = firstDayOfMonth; day.isBefore(lastDayOfMonth); day = day.add(const Duration(days: 1))) {
      summary[day] = _getDayAmount(day);
    }
    
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          EnhancedCalendarWidget(  // Changed from CalendarWidget to EnhancedCalendarWidget
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
            onFormatChanged: _onFormatChanged,
            eventLoader: _eventService.getEventsForDay,
            getDayAmount: _getDayAmount,  // New property
            calendarFormat: _calendarFormat,
            monthSummary: _getMonthSummary(),  // New property
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Consumer<EventNotifier>(
              builder: (context, eventNotifier, _) {
                final events = eventNotifier.getEventsForDay(_selectedDay!);
                return EventListWidget(
                  events: events,
                  onDeleteEvent: _showDeleteEventDialog,
                  onEditEvent: _showEditEventDialog,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}