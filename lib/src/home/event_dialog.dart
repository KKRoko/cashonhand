import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

void showAddEventDialog(BuildContext context, DateTime selectedDay, Function(Event) onEventAdded) {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isPositiveCashflow = true;
  bool isNegativeCashflow = false;
  RepeatOption repeatOption = RepeatOption.none;

  // Custom recurrence options
  RepeatOption? customRepeatOption;
  int? customFrequency = 1;
  List<bool> selectedDays = List.generate(7, (_) => false);
  int? customDay = 1;
  int? customMonth = 1;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Cash Flow for ${DateFormat.yMMMMd().format(selectedDay)}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Cash Flow Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount in USD'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  CheckboxListTile(
                    title: Text('Positive Cashflow'),
                    value: isPositiveCashflow,
                    onChanged: (value) {
                      setState(() {
                        isPositiveCashflow = value!;
                        if (isPositiveCashflow) isNegativeCashflow = false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Negative Cashflow'),
                    value: isNegativeCashflow,
                    onChanged: (value) {
                      setState(() {
                        isNegativeCashflow = value!;
                        if (isNegativeCashflow) isPositiveCashflow = false;
                      });
                    },
                  ),
                  DropdownButton<RepeatOption>(
                    value: repeatOption,
                    onChanged: (RepeatOption? newValue) {
                      setState(() {
                        repeatOption = newValue!;
                        if (repeatOption == RepeatOption.custom) {
                          _showCustomRecurrenceDialog(context, (selectedOption, frequency, days, day, month) {
                            setState(() {
                              customRepeatOption = selectedOption;
                              customFrequency = frequency;
                              selectedDays = days;
                              customDay = day;
                              customMonth = month;
                            });
                          });
                        }
                      });
                    },
                    items: RepeatOption.values.map((RepeatOption option) {
                      return DropdownMenuItem<RepeatOption>(
                        value: option,
                        child: Text(option.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  if (repeatOption == RepeatOption.custom)
                    Text('Custom: ${_getCustomRecurrenceDescription(customRepeatOption, customFrequency, selectedDays, customDay, customMonth)}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final eventAmount = double.tryParse(amountController.text);

                  if (titleController.text.isEmpty || eventAmount == null) {
                    // Add validation feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please provide a valid title and amount.')),
                    );
                    return;
                  }

                  final event = Event(
                    title: titleController.text,
                    amount: eventAmount,
                    isPositiveCashflow: isPositiveCashflow,
                    isNegativeCashflow: isNegativeCashflow,
                    repeatOption: repeatOption,
                    customRepeatOption: customRepeatOption,
                    customFrequency: customFrequency,
                    selectedDays: selectedDays,
                    customDay: customDay,
                    customMonth: customMonth,
                  );

                  // Debug log for tracing event details
                  print('Event created: $event');
                  onEventAdded(event);
                  Navigator.pop(context); // Close the dialog after saving
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showCustomRecurrenceDialog(BuildContext context, Function(RepeatOption, int?, List<bool>, int?, int?) onCustomRecurrenceSelected) {
  RepeatOption? customRepeatOption;
  int? customFrequency = 1;
  List<bool> selectedDays = List.generate(7, (_) => false);
  int? customDay = 1;
  int? customMonth = 1;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Custom Recurrence Options'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<RepeatOption>(
                    value: customRepeatOption,
                    onChanged: (RepeatOption? newValue) {
                      setState(() {
                        customRepeatOption = newValue!;
                      });
                    },
                    items: RepeatOption.values.map((RepeatOption option) {
                      return DropdownMenuItem<RepeatOption>(
                        value: option,
                        child: Text(option.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Frequency'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      customFrequency = int.tryParse(value);
                    },
                  ),
                  Wrap(
                    children: List.generate(7, (index) {
                      return ChoiceChip(
                        label: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][index]),
                        selected: selectedDays[index],
                        onSelected: (selected) {
                          setState(() {
                            selectedDays[index] = selected;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Custom Day'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      customDay = int.tryParse(value);
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Custom Month'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      customMonth = int.tryParse(value);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onCustomRecurrenceSelected(customRepeatOption!, customFrequency, selectedDays, customDay, customMonth);
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _getCustomRecurrenceDescription(
  RepeatOption? customRepeatOption,
  int? customFrequency,
  List<bool> selectedDays,
  int? customDay,
  int? customMonth,
) {
  if (customRepeatOption == null) return '';

  String description = 'Every $customFrequency ${customRepeatOption.toString().split('.').last}(s)';

  if (customRepeatOption == RepeatOption.weekly) {
    List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    List<String> selectedDayNames = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) selectedDayNames.add(days[i]);
    }
    description += ' on ${selectedDayNames.join(', ')}';
  } else if (customRepeatOption == RepeatOption.monthly) {
    description += ' on day $customDay';
  } else if (customRepeatOption == RepeatOption.yearly) {
    description += ' on ${DateFormat('MMMM').format(DateTime(2022, customMonth!))} $customDay';
  }

  return description;
}

class CustomRecurrenceOptions {
  final RepeatOption customRepeatOption;
  final int customFrequency;
  final List<bool> selectedDays;
  final int customDay;
  final int customMonth;

  CustomRecurrenceOptions({
    required this.customRepeatOption,
    required this.customFrequency,
    required this.selectedDays,
    required this.customDay,
    required this.customMonth,
  });
}
