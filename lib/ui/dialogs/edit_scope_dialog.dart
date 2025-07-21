import 'package:flutter/material.dart';
import '../../data/models/enums/edit_option.dart';
import '../../data/models/freezed/event.dart';

class EditScopeDialog extends StatefulWidget {
  final Event event;
  final DateTime selectedDate;
  final int? totalEventsInSeries;
  final int? futureEventsCount;
  final int? pastEventsCount;

  const EditScopeDialog({
    super.key,
    required this.event,
    required this.selectedDate,
    this.totalEventsInSeries,
    this.futureEventsCount,
    this.pastEventsCount,
  });

  @override
  State<EditScopeDialog> createState() => _EditScopeDialogState();
}

class _EditScopeDialogState extends State<EditScopeDialog> {
  EditOption? selectedOption;

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
            'Choose what to edit:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : null,
      ),
      child: RadioListTile<EditOption>(
        title: Text(
          option.displayName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            _buildImpactText(option),
          ],
        ),
        value: option,
        groupValue: selectedOption,
        onChanged: (value) {
          setState(() {
            selectedOption = value;
          });
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildImpactText(EditOption option) {
    String impactText;
    Color impactColor = Colors.blue[600]!;
    
    switch (option) {
      case EditOption.thisInstance:
        impactText = _formatDate(widget.selectedDate);
        break;
      case EditOption.allInstances:
        final total = widget.totalEventsInSeries ?? 0;
        impactText = total > 0 ? 'Affects $total events' : 'Affects entire series';
        impactColor = total > 10 ? Colors.orange[600]! : Colors.blue[600]!;
        break;
      case EditOption.futureInstances:
        final future = widget.futureEventsCount ?? 0;
        impactText = future > 0 ? 'Affects $future future events' : 'Affects future events';
        impactColor = future > 5 ? Colors.orange[600]! : Colors.blue[600]!;
        break;
      case EditOption.pastInstances:
        final past = widget.pastEventsCount ?? 0;
        impactText = past > 0 ? 'Affects $past past events' : 'Affects past events';
        impactColor = past > 5 ? Colors.orange[600]! : Colors.blue[600]!;
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
}) {
  return showDialog<EditOption>(
    context: context,
    builder: (context) => EditScopeDialog(
      event: event,
      selectedDate: selectedDate,
      totalEventsInSeries: totalEventsInSeries,
      futureEventsCount: futureEventsCount,
      pastEventsCount: pastEventsCount,
    ),
  );
}