import 'package:flutter/material.dart';
import '../../../data/models/freezed/event.dart';
import '../../../theme/app_theme.dart';

class EventListItem extends StatefulWidget {
  final Event event;
  final Function(Event) onDeleteEvent;
  final Function(Event) onEditEvent;

  const EventListItem({
    super.key,
    required this.event,
    required this.onDeleteEvent,
    required this.onEditEvent,
  });

  @override
  State<EventListItem> createState() => _EventListItemState();
}

class _EventListItemState extends State<EventListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine amount color based on cashflow type
    final amountColor = widget.event.isPositiveCashflow
        ? colorScheme.tertiary
        : colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.defaultPadding / 2,
      ),
      child: Card(
        elevation: AppTheme.cardElevation,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          child: Column(
            children: [
              // Main Tile Content
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.event.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      widget.event.formattedAmount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded Content
              AppTheme.expandTransition(
                expand: _isExpanded,
                child: Column(
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Repeat Information
                          Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.event.repeatDescription,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Date Information
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Next: ${_formatDate(widget.event.dateTime)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    widget.onEditEvent(widget.event),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    widget.onDeleteEvent(widget.event),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
