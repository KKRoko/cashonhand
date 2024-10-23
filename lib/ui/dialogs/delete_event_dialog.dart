import 'package:flutter/material.dart';
import '../../data/models/enums/delete_option.dart';
import '../../data/models/freezed/event.dart';

Future<DeleteOption?> showDeleteEventDialog(BuildContext context, Event event) {
  return showDialog<DeleteOption>(
    context: context,
    builder: (BuildContext context) => _DeleteEventDialog(event: event),
  );
}

class _DeleteEventDialog extends StatelessWidget {
  final Event event;

  const _DeleteEventDialog({required this.event});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Event'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('How would you like to delete "${event.title}"?'),
            const SizedBox(height: 20),
            _deleteButton(
              context,
              'For this day only',
              DeleteOption.thisDay,
            ),
            const SizedBox(height: 10),
            _deleteButton(
              context,
              'For all time (past and future)',
              DeleteOption.allTime,
            ),
            const SizedBox(height: 10),
            _deleteButton(
              context,
              'From this day to future',
              DeleteOption.futureOnly,
            ),
            const SizedBox(height: 10),
            _deleteButton(
              context,
              'From this day to past',
              DeleteOption.pastOnly,
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
  }

  Widget _deleteButton(BuildContext context, String text, DeleteOption option) {
    return ElevatedButton(
      child: Text(text),
      onPressed: () => Navigator.of(context).pop(option),
    );
  }
}
