import 'package:cash_on_hand/src/ui/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cash_on_hand/src/models/event_model.dart';
import 'package:cash_on_hand/src/providers/event_provider.dart';
import 'package:cash_on_hand/src/ui/dialogs/event_dialog.dart';
import 'package:cash_on_hand/src/ui/dialogs/delete_event_dialog.dart';
import 'dart:developer' as developer;


class CalendarPage extends StatelessWidget {
  static const routeName = '/calendar';

  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cash on Hand - Events'),
          ),
          body: Column(
            children: [
              _buildTableCalendar(context, eventProvider),
              const SizedBox(height: 8.0),
              Expanded(
                child: _buildEventList(context, eventProvider),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEventDialog(context, eventProvider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildTableCalendar(BuildContext context, EventProvider eventProvider) {
    return buildTableCalendar(
      focusedDay: eventProvider.focusedDay,
      selectedDay: eventProvider.selectedDay,
      onDaySelected: (selectedDay, focusedDay) {
        eventProvider.selectDay(selectedDay);
        eventProvider.focusDay(focusedDay);
      },
      eventLoader: (day) {
        var events = eventProvider.getEventsForDay(day);
        developer.log('Loading events for day: ${day.toString()}, Events: $events', name: 'CalendarPage');
        return events;
      },
      calendarFormat: CalendarFormat.month,
      rangeSelectionMode: RangeSelectionMode.disabled,
      onFormatChanged: (_) {}, // Add format changing functionality if needed
    );
  }

  Widget _buildEventList(BuildContext context, EventProvider eventProvider) {
    final events = eventProvider.getEventsForDay(eventProvider.selectedDay);
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${event.isPositiveCashflow ? "+" : "-"}\$${event.amount?.toStringAsFixed(2) ?? "0.00"}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditEventDialog(context, eventProvider, event),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteEventDialog(context, eventProvider, event),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context, EventProvider eventProvider) {
    developer.log('Showing add event dialog', name: 'CalendarPage');
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        onSave: (event) {
          developer.log('onSave called with event: $event', name: 'CalendarPage');
          eventProvider.addEvent(eventProvider.selectedDay, event);
          developer.log('Event added, refreshing state', name: 'CalendarPage');
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, EventProvider eventProvider, Event event) {
    showDialog(
      context: context,
      builder: (context) => EventDialog(
        event: event,
        onSave: (updatedEvent) {
          eventProvider.updateEvent(eventProvider.selectedDay, event, updatedEvent);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showDeleteEventDialog(BuildContext context, EventProvider eventProvider, Event event) {
    showDeleteEventDialog(context, event).then((deleteOption) {
      if (deleteOption != null) {
        switch (deleteOption) {
          case DeleteOption.thisDay:
            eventProvider.deleteEvent(eventProvider.selectedDay, event);
            break;
          case DeleteOption.allTime:
            eventProvider.deleteAllEvents(event);
            break;
          case DeleteOption.futureOnly:
            eventProvider.deleteFutureEvents(eventProvider.selectedDay, event);
            break;
          case DeleteOption.pastOnly:
            eventProvider.deletePastEvents(eventProvider.selectedDay, event);
            break;
        }
      }
    });
  }
}