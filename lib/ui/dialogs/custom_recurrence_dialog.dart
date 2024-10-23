import 'package:flutter/material.dart';
import '../../data/models/enums/repeat_option.dart';

import '../../data/models/freezed/custom_recurrence.dart';

class CustomRecurrenceDialog extends StatefulWidget {
  final CustomRecurrence? initialRecurrence;

  const CustomRecurrenceDialog({
    super.key,
    this.initialRecurrence,
  });

  @override
  State<CustomRecurrenceDialog> createState() => _CustomRecurrenceDialogState();
}

class _CustomRecurrenceDialogState extends State<CustomRecurrenceDialog> {
  late RepeatOption _interval;
  late int _frequency;
  late List<bool> _selectedDays;
  late int? _dayOfMonth;
  late int? _weekOfMonth;
  late int? _month;

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _weeks = ['First', 'Second', 'Third', 'Fourth', 'Last'];

  @override
  void initState() {
    super.initState();
    _interval = widget.initialRecurrence?.interval ?? RepeatOption.daily;
    _frequency = widget.initialRecurrence?.frequency ?? 1;
    _selectedDays = widget.initialRecurrence?.selectedDays ?? List.filled(7, false);
    _dayOfMonth = widget.initialRecurrence?.dayOfMonth;
    _weekOfMonth = widget.initialRecurrence?.weekOfMonth;
    _month = widget.initialRecurrence?.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Recurrence'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _intervalSelector,
            const SizedBox(height: 16),
            _frequencyInput,
            const SizedBox(height: 16),
            _weeklySelector,
            _monthlySelector,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveRecurrence,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget get _intervalSelector => DropdownButtonFormField<RepeatOption>(
    value: _interval,
    decoration: const InputDecoration(labelText: 'Repeat Every'),
    items: _intervalItems,
    onChanged: _onIntervalChanged,
  );

  List<DropdownMenuItem<RepeatOption>> get _intervalItems => [
    RepeatOption.daily,
    RepeatOption.weekly,
    RepeatOption.monthly,
    RepeatOption.yearly,
  ].map((option) => DropdownMenuItem(
    value: option,
    child: Text(option.toString().split('.').last),
  )).toList();

  Widget get _frequencyInput => Row(
    children: [
      Expanded(
        child: TextFormField(
          initialValue: _frequency.toString(),
          decoration: const InputDecoration(labelText: 'Frequency'),
          keyboardType: TextInputType.number,
          onChanged: _onFrequencyChanged,
        ),
      ),
      const SizedBox(width: 8),
      Text(_interval.toString().split('.').last),
    ],
  );

  Widget get _weeklySelector {
    if (_interval != RepeatOption.weekly) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Repeat on:'),
        ),
        _weekDayChips,
      ],
    );
  }

  Widget get _weekDayChips => Wrap(
    spacing: 8.0,
    children: List.generate(7, (index) => _weekDayChip(index)),
  );

  Widget _weekDayChip(int index) => FilterChip(
    label: Text(_weekDays[index]),
    selected: _selectedDays[index],
    onSelected: (bool selected) {
      setState(() {
        _selectedDays[index] = selected;
      });
    },
  );

  Widget get _monthlySelector {
    if (_interval != RepeatOption.monthly) return const SizedBox.shrink();

    return Column(
      children: [
        _weekOfMonthSelector,
        const SizedBox(height: 8),
        _dayOfMonthField,
      ],
    );
  }

  Widget get _weekOfMonthSelector => DropdownButtonFormField<int>(
    value: _weekOfMonth,
    decoration: const InputDecoration(labelText: 'Week of Month'),
    items: _weekOfMonthItems,
    onChanged: _onWeekOfMonthChanged,
  );

  List<DropdownMenuItem<int>> get _weekOfMonthItems => 
    List.generate(5, (index) => DropdownMenuItem(
      value: index,
      child: Text(_weeks[index]),
    ));

  Widget get _dayOfMonthField => TextFormField(
    initialValue: _dayOfMonth?.toString() ?? '',
    decoration: const InputDecoration(
      labelText: 'Day of Month',
      hintText: 'Enter 1-31',
    ),
    keyboardType: TextInputType.number,
    onChanged: _onDayOfMonthChanged,
  );

  void _onIntervalChanged(RepeatOption? value) {
    setState(() {
      _interval = value!;
      if (_interval != RepeatOption.weekly) _selectedDays = List.filled(7, false);
      if (_interval != RepeatOption.monthly) {
        _dayOfMonth = null;
        _weekOfMonth = null;
      }
      if (_interval != RepeatOption.yearly) _month = null;
    });
  }

  void _onFrequencyChanged(String value) {
    setState(() {
      _frequency = int.tryParse(value) ?? 1;
    });
  }

  void _onWeekOfMonthChanged(int? value) {
    setState(() {
      _weekOfMonth = value;
    });
  }

  void _onDayOfMonthChanged(String value) {
    setState(() {
      _dayOfMonth = int.tryParse(value);
    });
  }

  void _saveRecurrence() {
    final customRecurrence = CustomRecurrence(
      interval: _interval,
      frequency: _frequency,
      selectedDays: _selectedDays,
      dayOfMonth: _dayOfMonth,
      weekOfMonth: _weekOfMonth,
      month: _month,
    );
    Navigator.of(context).pop(customRecurrence);
  }
}
