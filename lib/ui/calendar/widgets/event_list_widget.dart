import 'package:flutter/material.dart';
import '../../../data/models/freezed/event.dart';
import '../../../theme/app_theme.dart';
import 'event_list_item.dart';

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
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.defaultPadding / 2),
      itemBuilder: (context, index) {
        return EventListItem(
          event: events[index],
          onDeleteEvent: onDeleteEvent,
          onEditEvent: onEditEvent,
        );
      },
    );
  }
}