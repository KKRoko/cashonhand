import 'package:flutter/material.dart';
import '../../data/models/enums/repeat_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/freezed/custom_recurrence.dart';
import 'custom_recurrence_dialog.dart';

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
  CustomRecurrence? _customRecurrence;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController = TextEditingController(text: widget.event?.amount?.toString() ?? '');
    _isPositiveCashflow = widget.event?.isPositiveCashflow ?? true;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
    _customRecurrence = widget.event?.customRecurrence;
  }

  Future<void> _showCustomRecurrenceDialog() async {
    final result = await showDialog<CustomRecurrence>(
      context: context,
      builder: (context) => CustomRecurrenceDialog(
        initialRecurrence: _customRecurrence,
      ),
    );

    if (result != null) {
      setState(() {
        _customRecurrence = result;
        _repeatOption = RepeatOption.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleField,
            _amountField,
            _cashflowSwitch,
            _repeatOptionRow,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget get _titleField => TextField(
    controller: _titleController,
    decoration: const InputDecoration(labelText: 'Title'),
  );

  Widget get _amountField => TextField(
    controller: _amountController,
    decoration: const InputDecoration(labelText: 'Amount'),
    keyboardType: TextInputType.number,
  );

  Widget get _cashflowSwitch => SwitchListTile(
    title: const Text('Positive Cashflow'),
    value: _isPositiveCashflow,
    onChanged: (value) => setState(() => _isPositiveCashflow = value),
  );

  Widget get _repeatOptionRow => Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<RepeatOption>(
          value: _repeatOption,
          onChanged: _onRepeatOptionChanged,
          items: _repeatOptionItems,
          decoration: const InputDecoration(labelText: 'Repeat'),
        ),
      ),
    ],
  );

  List<DropdownMenuItem<RepeatOption>> get _repeatOptionItems => 
    RepeatOption.values.map((option) => 
      DropdownMenuItem(
        value: option,
        child: Text(option.toString().split('.').last),
      )
    ).toList();

  void _onRepeatOptionChanged(RepeatOption? value) {
    setState(() {
      _repeatOption = value!;
      if (value != RepeatOption.custom) {
        _customRecurrence = null;
      } else {
        Future.delayed(Duration.zero, () => _showCustomRecurrenceDialog());
      }
    });
  }

  void _saveEvent() {
      final event = widget.event?.id != null 
        ? Event(  // If editing existing event, use all existing data
            id: widget.event!.id,
            title: _titleController.text,
            amount: double.tryParse(_amountController.text),
            isPositiveCashflow: _isPositiveCashflow,
            isNegativeCashflow: !_isPositiveCashflow,
            repeatOption: _repeatOption,
            customRecurrence: _customRecurrence,
            dateTime: widget.selectedDay,
            createdAt: widget.event!.createdAt,
            isYearEndSummary: widget.event!.isYearEndSummary,
        )
        : Event.create(  // If creating new event, use the create factory
            title: _titleController.text,
            amount: double.tryParse(_amountController.text),
            isPositiveCashflow: _isPositiveCashflow,
            isNegativeCashflow: !_isPositiveCashflow,
            repeatOption: _repeatOption,
            customRecurrence: _customRecurrence,
            dateTime: widget.selectedDay,
        );
      Navigator.of(context).pop(event);
  }
}
