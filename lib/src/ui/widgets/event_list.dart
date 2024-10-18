import 'package:flutter/material.dart';
import 'package:cash_on_hand/src/models/event_model.dart'; 

Widget buildEventList(List<Event> events, Function(Event) onDeleteEvent, Function(Event) onEditEvent) {
  return ListView.builder(
    itemCount: events.length,
    itemBuilder: (context, index) {
      final event = events[index];
      return Dismissible(
        key: Key(event.id),
        background: Container(
          color: const Color.fromARGB(255, 16, 6, 5),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          onDeleteEvent(event);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(
              '${event.amount != null ? '\$${event.amount}' : ''} - ${event.repeatOption.toString().split('.').last}',
            ),
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
            onTap: () => onEditEvent(event),
          ),
        ),
      );
    },
  );
}