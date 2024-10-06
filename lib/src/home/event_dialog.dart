import 'package:cash_on_hand/src/home/event_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> showAddEventDialog(BuildContext context, DateTime selectedDay, Function(Event) onEventAdded) async {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isPositiveCashflow = true;
  bool isNegativeCashflow = false;
  RepeatOption repeatOption = RepeatOption.today;
  CustomRecurrence? customRecurrence;

  return showDialog<void>(
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
                    decoration: const InputDecoration(labelText: 'Cash Flow Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount in USD'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  CheckboxListTile(
                    title: const Text('Positive Cashflow'),
                    value: isPositiveCashflow,
                    onChanged: (value) {
                      setState(() {
                        isPositiveCashflow = value!;
                        if (isPositiveCashflow) isNegativeCashflow = false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Negative Cashflow'),
                    value: isNegativeCashflow,
                    onChanged: (value) {
                      setState(() {
                        isNegativeCashflow = value!;
                        if (isNegativeCashflow) isPositiveCashflow = false;
                      });
                    },
                  ),
                  Row(
                    children: [
                      const Text('Repeat: '),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<RepeatOption>(
                          value: repeatOption,
                          isExpanded: true,
                          onChanged: (RepeatOption? newValue) {
                            setState(() {
                              repeatOption = newValue!;
                              if (repeatOption == RepeatOption.custom) {
                                _showCustomRecurrenceDialog(context, (newCustomRecurrence) {
                                  setState(() {
                                    customRecurrence = newCustomRecurrence;
                                  });
                                });
                              } else {
                                customRecurrence = null;
                              }
                            });
                          },
                          items: RepeatOption.values.map((RepeatOption option) {
                            return DropdownMenuItem<RepeatOption>(
                              value: option,
                              child: Text(_capitalizeRepeatOption(option)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  if (customRecurrence != null)
                    Text('Custom: ${_getCustomRecurrenceDescription(customRecurrence!)}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final eventAmount = double.tryParse(amountController.text);

                  if (titleController.text.isEmpty || eventAmount == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please provide a valid title and amount.')),
                    );
                    return;
                  }

                  final event = Event(
                    title: titleController.text,
                    amount: eventAmount,
                    isPositiveCashflow: isPositiveCashflow,
                    isNegativeCashflow: isNegativeCashflow,
                    repeatOption: repeatOption,
                    customRecurrence: customRecurrence,
                  );
                  try {
                    await onEventAdded(event);
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error adding event: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding event: $e')),
                    );
                  }
                  onEventAdded(event);
                  Navigator.pop(context);
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

void _showCustomRecurrenceDialog(BuildContext context, Function(CustomRecurrence) onCustomRecurrenceSelected) {
  RepeatOption interval = RepeatOption.daily;
  int frequency = 1;
  List<bool> selectedDays = List.generate(7, (_) => false);
  int? dayOfMonth = 1;
  int? month = 1;

  showDialog(
    context: context,
    builder: (context) {
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
                    items: [RepeatOption.daily, RepeatOption.weekly, RepeatOption.monthly] // removed RepeatOption.yearly
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
                  if (interval == RepeatOption.monthly ) // removed "|| interval == RepeatOption.yearly"
                    TextField(
                      decoration: const InputDecoration(labelText: 'Day of Month'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        dayOfMonth = int.tryParse(value);
                      },
                    ),
                  // if (interval == RepeatOption.yearly)
                  //   TextField(
                  //     decoration: const InputDecoration(labelText: 'Month'),
                  //     keyboardType: TextInputType.number,
                  //     onChanged: (value) {
                  //       month = int.tryParse(value);
                  //     },
                  //   ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  onCustomRecurrenceSelected(CustomRecurrence(
                    interval: interval,
                    frequency: frequency,
                    selectedDays: selectedDays,
                    dayOfMonth: dayOfMonth,
                    month: month,
                  ));
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
  } // else if (recurrence.interval == RepeatOption.yearly) {
  //   description += ' on ${DateFormat('MMMM').format(DateTime(2022, recurrence.month!))} ${recurrence.dayOfMonth}';
  // }

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
