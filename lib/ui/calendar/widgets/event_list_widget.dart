// lib/ui/calendar/widgets/event_list_widget.dart

import 'package:flutter/material.dart';
import '../../../data/models/event_model.dart';

class EventListWidget extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onDeleteEvent;
  final Function(Event) onEditEvent;

  const EventListWidget({
    super.key,
    required this.events,
    required this.onDeleteEvent,
    required this.onEditEvent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text('${event.amount != null ? '\$${event.amount}' : 'No amount'} - ${event.repeatOption.toString().split('.').last}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEditEvent(event),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDeleteEvent(event),
              ),
            ],
          ),
        );
      },
    );
  }
}
