import 'package:flutter/material.dart';
import '../../data/models/enums/edit_option.dart';
import '../../data/models/freezed/event.dart';

class EditScopeDialog extends StatefulWidget {
  final Event event;
  final DateTime selectedDate;
  final int? totalEventsInSeries;
  final int? futureEventsCount;
  final int? pastEventsCount;
  final bool hasAllocationChanges;

  const EditScopeDialog({
    super.key,
    required this.event,
    required this.selectedDate,
    this.totalEventsInSeries,
    this.futureEventsCount,
    this.pastEventsCount,
    this.hasAllocationChanges = false,
  });

  @override
  State<EditScopeDialog> createState() => _EditScopeDialogState();
}

class _EditScopeDialogState extends State<EditScopeDialog> {
  EditOption? selectedOption;

  @override
  void initState() {
    super.initState();
    // Auto-select "This event only" for single events
    final isSingleEvent = (widget.totalEventsInSeries ?? 1) <= 1;
    if (isSingleEvent) {
      selectedOption = EditOption.thisInstance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit "${widget.event.title}"',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hasAllocationChanges 
              ? 'Choose which events to update with your allocation changes:'
              : 'Choose what to edit:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (widget.hasAllocationChanges) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Goal allocation changes will be applied to the selected events',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...EditOption.values.map((option) => _buildEditOptionTile(option)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedOption != null
              ? () => Navigator.of(context).pop(selectedOption)
              : null,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildEditOptionTile(EditOption option) {
    final isSelected = selectedOption == option;
    final isSingleEvent = (widget.totalEventsInSeries ?? 1) <= 1;
    final isDisabled = _isOptionDisabled(option, isSingleEvent);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDisabled 
              ? Colors.grey[300]! 
              : isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDisabled
            ? Colors.grey[50]
            : isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
      ),
      child: RadioListTile<EditOption>(
        title: Text(
          option.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isDisabled ? Colors.grey[400] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              option.description,
              style: TextStyle(
                fontSize: 12,
                color: isDisabled ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            _buildImpactText(option, isDisabled),
          ],
        ),
        value: option,
        groupValue: selectedOption,
        onChanged: isDisabled ? null : (value) {
          setState(() {
            selectedOption = value;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  bool _isOptionDisabled(EditOption option, bool isSingleEvent) {
    if (!isSingleEvent) return false; // All options available for recurring events
    
    // For single events, disable options that don't make sense
    switch (option) {
      case EditOption.thisInstance:
        return false; // Always available
      case EditOption.allInstances:
      case EditOption.futureInstances:
      case EditOption.pastInstances:
        return true; // Disabled for single events
    }
  }

  Widget _buildImpactText(EditOption option, bool isDisabled) {
    String impactText;
    Color impactColor = isDisabled ? Colors.grey[400]! : Colors.blue[600]!;
    
    switch (option) {
      case EditOption.thisInstance:
        if (widget.hasAllocationChanges) {
          impactText = 'Update allocation for ${_formatDate(widget.selectedDate)} only';
        } else {
          impactText = _formatDate(widget.selectedDate);
        }
        break;
      case EditOption.allInstances:
        final total = widget.totalEventsInSeries ?? 0;
        if (total <= 1) {
          impactText = 'Not applicable for single events';
          impactColor = Colors.grey[400]!;
        } else {
          if (widget.hasAllocationChanges) {
            impactText = total > 0 ? 'Update allocations for all $total events' : 'Update allocations for entire series';
          } else {
            impactText = total > 0 ? 'Affects $total events' : 'Affects entire series';
          }
          impactColor = isDisabled ? Colors.grey[400]! : (total > 10 ? Colors.orange[600]! : Colors.blue[600]!);
        }
        break;
      case EditOption.futureInstances:
        final future = widget.futureEventsCount ?? 0;
        if (future == 0) {
          impactText = 'No future events';
          impactColor = Colors.grey[400]!;
        } else {
          if (widget.hasAllocationChanges) {
            impactText = 'Update allocations for $future future events';
          } else {
            impactText = 'Affects $future future events';
          }
          impactColor = isDisabled ? Colors.grey[400]! : (future > 5 ? Colors.orange[600]! : Colors.blue[600]!);
        }
        break;
      case EditOption.pastInstances:
        final past = widget.pastEventsCount ?? 0;
        if (past == 0) {
          impactText = 'No past events';
          impactColor = Colors.grey[400]!;
        } else {
          if (widget.hasAllocationChanges) {
            impactText = 'Update allocations for $past past events';
          } else {
            impactText = 'Affects $past past events';
          }
          impactColor = isDisabled ? Colors.grey[400]! : (past > 5 ? Colors.orange[600]! : Colors.blue[600]!);
        }
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: impactColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        impactText,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: impactColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }
}

/// Helper function to show the edit scope dialog
Future<EditOption?> showEditScopeDialog({
  required BuildContext context,
  required Event event,
  required DateTime selectedDate,
  int? totalEventsInSeries,
  int? futureEventsCount,
  int? pastEventsCount,
  bool hasAllocationChanges = false,
}) {
  return showDialog<EditOption>(
    context: context,
    builder: (context) => EditScopeDialog(
      event: event,
      selectedDate: selectedDate,
      totalEventsInSeries: totalEventsInSeries,
      futureEventsCount: futureEventsCount,
      pastEventsCount: pastEventsCount,
      hasAllocationChanges: hasAllocationChanges,
    ),
  );
}