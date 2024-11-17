import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/repeat_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/freezed/custom_recurrence.dart';
import '../../utils/event_date_utils.dart';
import '../../utils/formatters.dart';

class AddEditEventDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Event? event;
  final bool isPositiveCashflow;
  final List<CategoryTableData> categories;

  const AddEditEventDialog({
    super.key,
    required this.selectedDay,
    this.event,
    required this.isPositiveCashflow,
    required this.categories,
  });

  @override
  State<AddEditEventDialog> createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  late int _selectedCategoryId;
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late bool _isPositiveCashflow;
  late RepeatOption _repeatOption;
  late DateTime selectedDate;
  CustomRecurrence? _customRecurrence;
  bool _showAmountError = false;
  bool _showTitleError = false;

  bool _isBasicExpanded = false;
  bool _isRecurrenceExpanded = false;

  // Controller for day of month input
  late TextEditingController _dayOfMonthController;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId =
        widget.event?.categoryId ?? widget.categories.first.id;
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController =
        TextEditingController(text: widget.event?.amount.toString() ?? '');
    _isPositiveCashflow =
        widget.event?.isPositiveCashflow ?? widget.isPositiveCashflow;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
    _customRecurrence = widget.event?.customRecurrence;
    selectedDate = widget.event?.dateTime ?? widget.selectedDay;

    // Initialize day of month controller
    _dayOfMonthController = TextEditingController(
        text: _customRecurrence?.dayOfMonth?.toString() ??
            selectedDate.day.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayOfMonthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
            child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
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
      ),
    );
  }

  // Modify the date selection handler
  void _handleDateSelected(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      // Update day of month if in monthly mode
      if (_repeatOption == RepeatOption.monthly &&
          !(_customRecurrence?.repeatAtEndOfMonth ?? false)) {
        _dayOfMonthController.text = newDate.day.toString();
        _updateMonthlyRecurrence(newDate.day);
      }
      // Auto-close the section
      _isBasicExpanded = false;
    });
  }

  // Modify the repeat option handler
  void _handleRepeatOptionSelected(RepeatOption option) {
    if (option == _repeatOption) return;
    
    setState(() {
      _repeatOption = option;
      if (option == RepeatOption.today) {
        _customRecurrence = null;
      } else if (option == RepeatOption.monthly) {
        _dayOfMonthController.text = selectedDate.day.toString();
        _customRecurrence = CustomRecurrence(
          interval: option,
          frequency: 1,
          dayOfMonth: selectedDate.day,
          useLastDayOfMonth: selectedDate.day >= 29,
          repeatAtEndOfMonth: false,
        );
      } else {
        _customRecurrence = CustomRecurrence(
          interval: option,
          frequency: 1,
          selectedDays: option == RepeatOption.weekly
              ? List.generate(7, (index) => index == selectedDate.weekday % 7)
              : List.filled(7, false),
        );
      }
      // Auto-close the section
      _isRecurrenceExpanded = false;
    });
  }


  Widget _buildAmountCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              _isPositiveCashflow ? Colors.green.shade200 : Colors.red.shade200,
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
                  Icon(
                    _isPositiveCashflow ? Icons.add : Icons.remove,
                    color: _isPositiveCashflow ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      style: Theme.of(context).textTheme.headlineSmall,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        CurrencyInputFormatter(),
                  
                      ],
                      decoration: InputDecoration(
                        hintText: '0.00',
                        border: InputBorder.none,
                        errorText:
                            _showAmountError ? 'Amount is required' : null,
                      ),
                      onChanged: (value) {
                        // Clear error when user types
                        if (_showAmountError) {
                          setState(() => _showAmountError = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "What's this for?",
                  border: InputBorder.none,
                  errorText: _showTitleError ? 'Description is required' : null,
                ),
                onChanged: (value) {
                  // Clear error when user types
                  if (_showTitleError) {
                    setState(() => _showTitleError = false);
                  }
                },
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
                  const Text('When?',
                      style: TextStyle(fontWeight: FontWeight.w500)),
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
                  SizedBox(
                    height: 300,
                    child:              CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onDateChanged: (DateTime newDate) {
                      setState(() {
                        selectedDate = newDate;
                        // Update day of month controller if it exists
                        if (_repeatOption == RepeatOption.monthly &&
                            !(_customRecurrence?.repeatAtEndOfMonth ?? false)) {
                          _dayOfMonthController.text = newDate.day.toString();
                          _updateMonthlyRecurrence(newDate.day);
                        }
                      });
                    },
                  ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
            onTap: () =>
                setState(() => _isRecurrenceExpanded = !_isRecurrenceExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 20),
                  const SizedBox(width: 8),
                  const Text('Does this repeat?',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (_repeatOption != RepeatOption.today)
                    Text(
                      _customRecurrence?.getDescription() ??
                          _repeatOption.toString().split('.').last,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  const SizedBox(width: 8),
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
                      _buildSimplifiedMonthlySelector(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimplifiedMonthlySelector() {
    final isEndOfMonth = _customRecurrence?.repeatAtEndOfMonth ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Repeat at end of month'),
          value: isEndOfMonth,
          onChanged: (value) {
            setState(() {
              if (value ?? false) {
                // Enable end of month and clear day of month
                _customRecurrence = (_customRecurrence ??
                        const CustomRecurrence(
                          interval: RepeatOption.monthly,
                          frequency: 1,
                        ))
                    .copyWith(
                  repeatAtEndOfMonth: true,
                  useLastDayOfMonth: true,
                  dayOfMonth: null,
                );
              } else {
                // Disable end of month and set day of month to current date
                final currentDay = selectedDate.day;
                _dayOfMonthController.text = currentDay.toString();
                _customRecurrence = (_customRecurrence ??
                        const CustomRecurrence(
                          interval: RepeatOption.monthly,
                          frequency: 1,
                        ))
                    .copyWith(
                  repeatAtEndOfMonth: false,
                  useLastDayOfMonth: false,
                  dayOfMonth: currentDay,
                );
              }
            });
          },
        ),
        if (!isEndOfMonth) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _dayOfMonthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Day of month',
                helperText: 'Enter a day between 1 and 31',
              ),
              onChanged: (value) {
                final day = int.tryParse(value);
                if (day != null && day >= 1 && day <= 31) {
                  _updateMonthlyRecurrence(day);
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  void _updateMonthlyRecurrence(int day) {
    setState(() {
      _customRecurrence = (_customRecurrence ??
              const CustomRecurrence(
                interval: RepeatOption.monthly,
                frequency: 1,
              ))
          .copyWith(
        dayOfMonth: day,
        repeatAtEndOfMonth: false,
        useLastDayOfMonth:
            day >= 29, // Set useLastDayOfMonth for internal calculations
      );
    });
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
            // Update day of month if in monthly mode
            if (_repeatOption == RepeatOption.monthly &&
                !(_customRecurrence?.repeatAtEndOfMonth ?? false)) {
              _dayOfMonthController.text = date.day.toString();
              _updateMonthlyRecurrence(date.day);
            }
          });
        }
      },
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
            } else if (option == RepeatOption.monthly) {
              // Initialize monthly recurrence with current date's day
              _dayOfMonthController.text = selectedDate.day.toString();
              _customRecurrence = CustomRecurrence(
                interval: option,
                frequency: 1,
                dayOfMonth: selectedDate.day,
                useLastDayOfMonth: selectedDate.day >= 29,
                repeatAtEndOfMonth: false,
              );
            } else {
              _customRecurrence = CustomRecurrence(
                interval: option,
                frequency: 1,
                selectedDays: option == RepeatOption.weekly
                    ? List.generate(
                        7, (index) => index == selectedDate.weekday % 7)
                    : List.filled(7, false),
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
                _customRecurrence =
                    _customRecurrence?.copyWith(frequency: frequency);
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

  Widget _buildActions() {
    bool isValid = _amountController.text.isNotEmpty &&
        _titleController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: isValid ? _saveEvent : null,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveEvent() {
    // Validate required fields
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) {
          setState(() {
      _showAmountError = _amountController.text.isEmpty;
      _showTitleError = _titleController.text.isEmpty;
    });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate and parse amount
final parsedAmount = CurrencyInputFormatter.parse(_amountController.text);
    if (parsedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate final amount based on positive/negative cashflow
    final amount = _isPositiveCashflow ? parsedAmount : -parsedAmount;

    if (_repeatOption == RepeatOption.weekly) {
      _customRecurrence = _customRecurrence?.copyWith(
        originalDate: selectedDate,
      );
    }

DateTime adjustedDate = selectedDate;
  if (_repeatOption == RepeatOption.weekly && _customRecurrence != null) {
    final selectedDayIndices = _customRecurrence!.selectedDayIndices;
    if (selectedDayIndices.isNotEmpty) {
      int currentWeekdayIndex = selectedDate.weekday % 7;
      
      int nextDayIndex = selectedDayIndices.firstWhere(
        (dayIndex) => dayIndex >= currentWeekdayIndex,
        orElse: () => selectedDayIndices.first
      );
      
      int daysUntilNext;
      if (nextDayIndex >= currentWeekdayIndex) {
        daysUntilNext = nextDayIndex - currentWeekdayIndex;
      } else {
        daysUntilNext = 7 - currentWeekdayIndex + nextDayIndex;
      }
      
      adjustedDate = selectedDate.add(Duration(days: daysUntilNext));
    }
  } else {
    adjustedDate = EventDateUtils.adjustDateForEndOfMonth(selectedDate, _customRecurrence);
  }

  final event = widget.event?.id != null
      ? Event(
          id: widget.event!.id,
          title: _titleController.text,
          categoryId: _selectedCategoryId,
          amount: amount,
          dateTime: adjustedDate,
          repeatOption: _repeatOption,
          isRecurring: _repeatOption != RepeatOption.today,
          customRecurrence: _customRecurrence,
          createdAt: widget.event!.createdAt,
          updatedAt: DateTime.now(),
          isYearEndSummary: widget.event!.isYearEndSummary,
          notes: null,
        )
      : Event.create(
          title: _titleController.text,
          categoryId: _selectedCategoryId,
          amount: amount,
          dateTime: adjustedDate,
          repeatOption: _repeatOption,
          isRecurring: _repeatOption != RepeatOption.today,
          customRecurrence: _customRecurrence,
          notes: null,
        );

  Navigator.of(context).pop(event);
}

  Widget _buildWeeklySelector() {
    print(
        "Selected days in weekly selector: ${_customRecurrence?.selectedDays}");

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
                // Create new list of all false values
                final newSelectedDays = List.filled(7, false);
                // Set only the tapped day to true
                newSelectedDays[index] = true;
                
                setState(() {
                  _customRecurrence = _customRecurrence?.copyWith(
                        selectedDays: newSelectedDays,
                      ) ??
                      CustomRecurrence(
                        interval: RepeatOption.weekly,
                        frequency: 1,
                        selectedDays: newSelectedDays,
                      );
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
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
}
