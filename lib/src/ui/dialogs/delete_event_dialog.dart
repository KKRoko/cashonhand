import 'package:flutter/material.dart';
import 'package:cash_on_hand/src/models/event_model.dart';

enum DeleteOption {
  thisDay,
  allTime,
  futureOnly,
  pastOnly,
}

Future<DeleteOption?> showDeleteEventDialog(BuildContext context, Event event) {
  return showDialog<DeleteOption>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Event'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('How would you like to delete "${event.title}"?'),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('For this day only'),
                onPressed: () => Navigator.of(context).pop(DeleteOption.thisDay),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('For all time (past and future)'),
                onPressed: () => Navigator.of(context).pop(DeleteOption.allTime),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('From current day to future'),
                onPressed: () => Navigator.of(context).pop(DeleteOption.futureOnly),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                child: const Text('From current day to past'),
                onPressed: () => Navigator.of(context).pop(DeleteOption.pastOnly),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      );
    },
  );
}
