// lib/ui/dialogs/add_edit_event_dialog.dart

import 'package:flutter/material.dart';
import '../../data/models/event_model.dart';

class AddEditEventDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Event? event;

  const AddEditEventDialog({
    super.key,
    required this.selectedDay,
    this.event,
  });

  @override
  _AddEditEventDialogState createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late bool _isPositiveCashflow;
  late RepeatOption _repeatOption;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController = TextEditingController(text: widget.event?.amount?.toString() ?? '');
    _isPositiveCashflow = widget.event?.isPositiveCashflow ?? true;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Positive Cashflow'),
              value: _isPositiveCashflow,
              onChanged: (value) => setState(() => _isPositiveCashflow = value),
            ),
            DropdownButtonFormField<RepeatOption>(
              value: _repeatOption,
              onChanged: (value) => setState(() => _repeatOption = value!),
              items: RepeatOption.values.map((option) => 
                DropdownMenuItem(value: option, child: Text(option.toString().split('.').last))
              ).toList(),
              decoration: const InputDecoration(labelText: 'Repeat'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final event = Event(
              id: widget.event?.id,
              title: _titleController.text,
              amount: double.tryParse(_amountController.text),
              isPositiveCashflow: _isPositiveCashflow,
              isNegativeCashflow: !_isPositiveCashflow,
              repeatOption: _repeatOption,
            );
            Navigator.of(context).pop(event);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
