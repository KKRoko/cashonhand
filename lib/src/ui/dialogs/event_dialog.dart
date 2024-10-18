import 'package:flutter/material.dart';
import 'package:cash_on_hand/src/models/event_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class EventDialog extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;

  const EventDialog({super.key, this.event, required this.onSave});

  @override
  _EventDialogState createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late EventFormData _formData;

  @override
  void initState() {
    super.initState();
    _formData = EventFormData(
      title: widget.event?.title ?? '',
      amount: widget.event?.amount,
      isPositiveCashflow: widget.event?.isPositiveCashflow ?? true,
      repeatOption: widget.event?.repeatOption ?? RepeatOption.today,
      customRecurrence: widget.event?.customRecurrence,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null 
        ? (AppLocalizations.of(context)?.addEvent ?? 'Add Event')
        : (AppLocalizations.of(context)?.editEvent ?? 'Edit Event')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: _formData.title),
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.title ?? 'Title'),
              onChanged: (value) => _formData.title = value,
            ),
            TextField(
              controller: TextEditingController(text: _formData.amount?.toString() ?? ''),
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.amount ?? 'Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _formData.amount = double.tryParse(value),
            ),
            CheckboxListTile(
              title: Text(AppLocalizations.of(context)?.positiveCashflow ?? 'Positive Cashflow'),
              value: _formData.isPositiveCashflow,
              onChanged: (value) => setState(() => _formData.isPositiveCashflow = value!),
            ),
            _buildRepeatOptionDropdown(),
            if (_formData.repeatOption == RepeatOption.custom && _formData.customRecurrence != null)
              Text(_getCustomRecurrenceDescription(_formData.customRecurrence!)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
        ),
      ],
    );
  }

  Widget _buildRepeatOptionDropdown() {
    return DropdownButtonFormField<RepeatOption>(
      value: _formData.repeatOption,
      items: RepeatOption.values.map((option) => DropdownMenuItem(
        value: option,
        child: Text(_capitalizeRepeatOption(option)),
      )).toList(),
      onChanged: (value) {
        setState(() {
          _formData.repeatOption = value!;
          if (value == RepeatOption.custom) {
            _showCustomRecurrenceDialog();
            } else {
            _formData.customRecurrence = null;
          }
        });
      },
      decoration: InputDecoration(labelText: AppLocalizations.of(context)?.repeatOption ?? 'Repeat Option'),
    );
  }

  void _showCustomRecurrenceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        RepeatOption interval = _formData.customRecurrence?.interval ?? RepeatOption.daily;
        int frequency = _formData.customRecurrence?.frequency ?? 1;
        List<bool> selectedDays = _formData.customRecurrence?.selectedDays ?? List.generate(7, (_) => false);
        int? dayOfMonth = _formData.customRecurrence?.dayOfMonth ?? 1;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Custom Recurrence Options'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<RepeatOption>(
                      value: interval,
                      onChanged: (RepeatOption? newValue) {
                        setState(() {
                          interval = newValue!;
                        });
                      },
                      items: [RepeatOption.daily, RepeatOption.weekly, RepeatOption.monthly]
                          .map((RepeatOption option) {
                        return DropdownMenuItem<RepeatOption>(
                          value: option,
                          child: Text(option.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: frequency.toString()),
                      onChanged: (value) {
                        frequency = int.tryParse(value) ?? 1;
                      },
                    ),
                    if (interval == RepeatOption.weekly)
                      Wrap(
                        children: List.generate(7, (index) {
                          return ChoiceChip(
                            label: Text(['S', 'M', 'T', 'W', 'T', 'F', 'S'][index]),
                            selected: selectedDays[index],
                            onSelected: (selected) {
                              setState(() {
                                selectedDays[index] = selected;
                              });
                            },
                          );
                        }),
                      ),
                    if (interval == RepeatOption.monthly)
                      TextField(
                        decoration: const InputDecoration(labelText: 'Day of Month'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: dayOfMonth.toString()),
                        onChanged: (value) {
                          dayOfMonth = int.tryParse(value);
                        },
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
                    setState(() {
                      _formData.customRecurrence = CustomRecurrence(
                        interval: interval,
                        frequency: frequency,
                        selectedDays: selectedDays,
                        dayOfMonth: dayOfMonth,
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getCustomRecurrenceDescription(CustomRecurrence recurrence) {
    String description = 'Every ${recurrence.frequency} ${recurrence.interval.toString().split('.').last}(s)';

    if (recurrence.interval == RepeatOption.weekly) {
      List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
      List<String> selectedDayNames = [];
      for (int i = 0; i < recurrence.selectedDays.length; i++) {
        if (recurrence.selectedDays[i]) selectedDayNames.add(days[i]);
      }
      description += ' on ${selectedDayNames.join(', ')}';
    } else if (recurrence.interval == RepeatOption.monthly) {
      description += ' on day ${recurrence.dayOfMonth}';
    }

    return description;
  }

  String _capitalizeRepeatOption(RepeatOption option) {
    switch (option) {
      case RepeatOption.today:
        return 'Today only';
      case RepeatOption.daily:
        return 'Daily';
      case RepeatOption.weekly:
        return 'Weekly';
      case RepeatOption.monthly:
        return 'Monthly';
      case RepeatOption.yearly:
        return 'Yearly';
      case RepeatOption.custom:
        return 'Custom';
      default:
        return option.toString().split('.').last;
    }
  }

  void _saveEvent() {
      developer.log('Attempting to save event: ${_formData.title}', name: 'EventDialog');

    if (!_formData.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.invalidEventData ?? 'Invalid event data')),
      );
      return;
    }

    final newEvent = Event(
      id: widget.event?.id,
      title: _formData.title,
      amount: _formData.amount,
      isPositiveCashflow: _formData.isPositiveCashflow,
      isNegativeCashflow: !_formData.isPositiveCashflow,
      repeatOption: _formData.repeatOption,
      customRecurrence: _formData.customRecurrence,
    );


    developer.log('Calling onSave with event: $newEvent', name: 'EventDialog');
    widget.onSave(newEvent);
    Navigator.of(context).pop();
  }
}

extension AppLocalizationsX on AppLocalizations {
  String get addEvent => 'Add Event';
  String get editEvent => 'Edit Event';
  String get eventTitleInput => 'Event Title';
  String get title => 'Title';
  String get amount => 'Amount';
  String get eventAmountInput => 'Event Amount';
  String get positiveCashflow => 'Positive Cashflow';
  String get repeatOption => 'Repeat Option';
  String get cancel => 'Cancel';
  String get invalidEventData => 'Invalid event data';
  String get save => 'Save';
}

class EventFormData {
  String title;
  double? amount;
  bool isPositiveCashflow;
  RepeatOption repeatOption;
  CustomRecurrence? customRecurrence;

  EventFormData({
    this.title = '',
    this.amount,
    this.isPositiveCashflow = true,
    this.repeatOption = RepeatOption.today,
    this.customRecurrence,
  });

  bool isValid() {
    return title.isNotEmpty && amount != null && amount! > 0;
  }
}