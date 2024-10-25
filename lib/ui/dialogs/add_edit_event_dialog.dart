import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/enums/repeat_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/freezed/custom_recurrence.dart';

class AddEditEventDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Event? event;

  const AddEditEventDialog({
    super.key,
    required this.selectedDay,
    this.event,
  });

  @override
  State<AddEditEventDialog> createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late bool _isPositiveCashflow;
  late RepeatOption _repeatOption;
  late DateTime selectedDate;
  CustomRecurrence? _customRecurrence;
  
  bool _isBasicExpanded = false;
  bool _isRecurrenceExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController = TextEditingController(text: widget.event?.amount?.toString() ?? '');
    _isPositiveCashflow = widget.event?.isPositiveCashflow ?? true;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
    _customRecurrence = widget.event?.customRecurrence;
    selectedDate = widget.event?.dateTime ?? widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAmountCard(),
              const SizedBox(height: 16),
              _buildBasicDetailsSection(),
              const SizedBox(height: 8),
              _buildRecurrenceSection(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isPositiveCashflow ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _isPositiveCashflow ? Colors.green : Colors.red,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPositiveCashflow ? Icons.add : Icons.remove,
                      color: _isPositiveCashflow ? Colors.green : Colors.red,
                    ),
                    onPressed: () => setState(() => _isPositiveCashflow = !_isPositiveCashflow),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      style: Theme.of(context).textTheme.headlineSmall,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "What's this for?",
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isBasicExpanded = !_isBasicExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 8),
                  const Text('When?', style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(selectedDate),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: _isBasicExpanded ? 2 : 0,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          if (_isBasicExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDateChip('Today', DateTime.now()),
                      _buildDateChip('Tomorrow', 
                        DateTime.now().add(const Duration(days: 1))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, DateTime date) {
    final isSelected = selectedDate.year == date.year && 
                      selectedDate.month == date.month && 
                      selectedDate.day == date.day;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            selectedDate = date;
          });
        }
      },
    );
  }

  Widget _buildRecurrenceSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isRecurrenceExpanded = !_isRecurrenceExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 20),
                  const SizedBox(width: 8),
                  const Text('Does this repeat?', 
                    style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  RotatedBox(
                    quarterTurns: _isRecurrenceExpanded ? 2 : 0,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          if (_isRecurrenceExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildRepeatOptionChip(RepeatOption.today, 'One-time'),
                      _buildRepeatOptionChip(RepeatOption.daily, 'Daily'),
                      _buildRepeatOptionChip(RepeatOption.weekly, 'Weekly'),
                      _buildRepeatOptionChip(RepeatOption.monthly, 'Monthly'),
                    ],
                  ),
                  if (_repeatOption != RepeatOption.today) ...[
                    const SizedBox(height: 16),
                    _buildFrequencySelector(),
                    if (_repeatOption == RepeatOption.weekly)
                      _buildWeeklySelector(),
                    if (_repeatOption == RepeatOption.monthly)
                      _buildMonthlySelector(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatOptionChip(RepeatOption option, String label) {
    final isSelected = _repeatOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _repeatOption = option;
            if (option == RepeatOption.today) {
              _customRecurrence = null;
            } else {
              _customRecurrence = CustomRecurrence(
                interval: option,
                frequency: 1,
                selectedDays: List.filled(7, false),
              );
            }
          });
        }
      },
    );
  }

  Widget _buildFrequencySelector() {
    return Row(
      children: [
        const Text('Repeat every'),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            controller: TextEditingController(
              text: _customRecurrence?.frequency.toString() ?? '1',
            ),
            onChanged: (value) {
              final frequency = int.tryParse(value) ?? 1;
              setState(() {
                _customRecurrence = _customRecurrence?.copyWith(frequency: frequency);
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(_getIntervalLabel()),
      ],
    );
  }

  String _getIntervalLabel() {
    switch (_repeatOption) {
      case RepeatOption.daily:
        return 'days';
      case RepeatOption.weekly:
        return 'weeks';
      case RepeatOption.monthly:
        return 'months';
      default:
        return '';
    }
  }

  Widget _buildWeeklySelector() {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Repeat on:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final isSelected = _customRecurrence?.selectedDays[index] ?? false;
            return InkWell(
              onTap: () {
                final newSelectedDays = List<bool>.from(
                  _customRecurrence?.selectedDays ?? List.filled(7, false),
                );
                newSelectedDays[index] = !isSelected;
                setState(() {
                  _customRecurrence = _customRecurrence?.copyWith(
                    selectedDays: newSelectedDays,
                  );
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
                child: Center(
                  child: Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Day of month:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter day (1-31)',
          ),
          controller: TextEditingController(
            text: _customRecurrence?.dayOfMonth?.toString() ?? '',
          ),
          onChanged: (value) {
            final day = int.tryParse(value);
            if (day != null && day >= 1 && day <= 31) {
              setState(() {
                _customRecurrence = _customRecurrence?.copyWith(dayOfMonth: day);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveEvent() {
      print('Selected Date before save: ${selectedDate}'); 
    final event = widget.event?.id != null
        ? Event(
            id: widget.event!.id,
            title: _titleController.text,
            amount: double.tryParse(_amountController.text),
            isPositiveCashflow: _isPositiveCashflow,
            isNegativeCashflow: !_isPositiveCashflow,
            repeatOption: _repeatOption,
            customRecurrence: _customRecurrence,
            dateTime: selectedDate,
            createdAt: widget.event!.createdAt,
            isYearEndSummary: widget.event!.isYearEndSummary,
          )
        : Event.create(
            title: _titleController.text,
            amount: double.tryParse(_amountController.text),
            isPositiveCashflow: _isPositiveCashflow,
            isNegativeCashflow: !_isPositiveCashflow,
            repeatOption: _repeatOption,
            customRecurrence: _customRecurrence,
            dateTime: selectedDate,
          );
           print('Event datetime after creation: ${event.dateTime}'); 
    Navigator.of(context).pop(event);
  }
}
