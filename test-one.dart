import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController _frequencyController;
  late bool _isPositiveCashflow;
  late RepeatOption _repeatOption;
  late DateTime selectedDate;
  CustomRecurrence? _customRecurrence;
  bool _showAmountError = false;
  bool _showTitleError = false;
  String _firstOccurrenceText = '';

  bool _isBasicExpanded = false;
  bool _isRecurrenceExpanded = false;

  // Controller for day of month input
  late TextEditingController _dayOfMonthController;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.event?.categoryId ?? widget.categories.first.id;
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController = TextEditingController(text: widget.event?.amount.toString() ?? '');
    _frequencyController = TextEditingController(text: widget.event?.customRecurrence?.frequency.toString() ?? '1');
    _isPositiveCashflow = widget.event?.isPositiveCashflow ?? widget.isPositiveCashflow;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
    _customRecurrence = widget.event?.customRecurrence;
    selectedDate = widget.event?.dateTime ?? widget.selectedDay;

    // Initialize day of month controller
    _dayOfMonthController = TextEditingController(
        text: _customRecurrence?.dayOfMonth?.toString() ??
            selectedDate.day.toString());
    
    // Calculate initial first occurrence text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFirstOccurrenceText();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayOfMonthController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  void _updateFirstOccurrenceText() {
    if (_repeatOption == RepeatOption.today) {
      setState(() {
        _firstOccurrenceText = '';
      });
      return;
    }

    DateTime adjustedDate = selectedDate;
    
    if (_repeatOption == RepeatOption.weekly && _customRecurrence != null) {
      final selectedDayIndices = _customRecurrence!.selectedDayIndices;
      if (selectedDayIndices.isNotEmpty) {
        int currentWeekdayIndex = selectedDate.weekday % 7;
        bool todayIsSelectedDay = selectedDayIndices.contains(currentWeekdayIndex);
        
        if (!todayIsSelectedDay) {
          int nextDayIndex = selectedDayIndices.firstWhere(
            (dayIndex) => dayIndex > currentWeekdayIndex,
            orElse: () => selectedDayIndices.first
          );
          
          int daysUntilNext;
          if (nextDayIndex > currentWeekdayIndex) {
            daysUntilNext = nextDayIndex - currentWeekdayIndex;
          } else {
            daysUntilNext = 7 - currentWeekdayIndex + nextDayIndex;
          }
          
          adjustedDate = selectedDate.add(Duration(days: daysUntilNext));
        }
      }
    } else if (_repeatOption == RepeatOption.monthly && _customRecurrence != null) {
      if (_customRecurrence!.repeatAtEndOfMonth) {
        adjustedDate = EventDateUtils.getEndOfMonth(selectedDate);
      } else {
        adjustedDate = selectedDate;
      }
    }
    
    setState(() {
      if (adjustedDate.year == selectedDate.year && 
          adjustedDate.month == selectedDate.month && 
          adjustedDate.day == selectedDate.day) {
        _firstOccurrenceText = "Starts today";
      } else {
        final formatter = DateFormat('EEE, MMM d');
        _firstOccurrenceText = "Starts ${formatter.format(adjustedDate)}";
      }
    });
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
    _updateFirstOccurrenceText();
  }

  void _handleRepeatOptionSelected(RepeatOption option) {
    if (option == _repeatOption) return;
    
    setState(() {
      _repeatOption = option;
      final frequency = int.tryParse(_frequencyController.text) ?? 1;
      
      if (option == RepeatOption.today) {
        _customRecurrence = null;
      } else if (option == RepeatOption.monthly) {
        _dayOfMonthController.text = selectedDate.day.toString();
        _customRecurrence = CustomRecurrence(
          interval: option,
          frequency: frequency,
          dayOfMonth: selectedDate.day,
          useLastDayOfMonth: selectedDate.day >= 29,
          repeatAtEndOfMonth: false,
        );
      } else {
        _customRecurrence = CustomRecurrence(
          interval: option,
          frequency: frequency,
          selectedDays: option == RepeatOption.weekly
              ? List.generate(7, (index) => index == selectedDate.weekday % 7)
              : List.filled(7, false),
        );
      }

      // Auto-close the section
      _isRecurrenceExpanded = false;

      print('DEBUG - Custom Recurrence set to: ${_customRecurrence?.toJson()}');
      print('DEBUG - Frequency: ${_customRecurrence?.frequency}');
    });
    
    _updateFirstOccurrenceText();
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
          borderRadius: BorderRadius.circular(12),
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
            borderRadius: BorderRadius.circular(12),
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
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateChanged: _handleDateSelected,
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
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.repeat, size: 20),
                  const SizedBox(width: 8),
                  const Text('Repeat',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_repeatOption != RepeatOption.today) ...[
                        Text(
                          _customRecurrence?.getDescription() ??
                              _repeatOption.toString().split('.').last,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        if (_firstOccurrenceText.isNotEmpty)
                          const SizedBox(height: 2),
                        if (_firstOccurrenceText.isNotEmpty)
                          Text(
                            _firstOccurrenceText,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ],
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

  Widget _buildFrequencySelector() {
    return Row(
      children: [
        const Text('Repeat every'),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _frequencyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            onChanged: (value) {
              final frequency = int.tryParse(value) ?? 1;
              setState(() {
                _customRecurrence = (_customRecurrence ?? CustomRecurrence(
                  interval: _repeatOption,
                  frequency: frequency,
                  selectedDays: _repeatOption == RepeatOption.weekly
                      ? List.generate(7, (index) => index == selectedDate.weekday % 7)
                      : List.filled(7, false),
                )).copyWith(frequency: frequency);
                
                print('DEBUG - Updated frequency to: $frequency');
                print('DEBUG - Custom Recurrence: ${_customRecurrence?.toJson()}');
              });
              _updateFirstOccurrenceText();
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