import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/repeat_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/freezed/custom_recurrence.dart';
import '../../data/models/freezed/goal_allocation.dart';
import '../../data/models/event_creation_result.dart';
import '../../utils/event_date_utils.dart';
import '../../utils/formatters.dart';
import '../widgets/goal_allocation_widget.dart';
import '../widgets/hierarchical_category_selector.dart';
import '../../data/models/enums/category_type.dart';
import '../../services/smart_categorization_service.dart';
import '../../core/di/injection.dart';
import '../../theme/design_tokens.dart';

class AddEditEventDialog extends StatefulWidget {
  final DateTime selectedDay;
  final Event? event;
  final bool isPositiveCashflow;
  final List<CategoryTableData> categories;
  final List<SavingGoalTableData> availableGoals;

  const AddEditEventDialog({
    super.key,
    required this.selectedDay,
    this.event,
    required this.isPositiveCashflow,
    required this.categories,
    required this.availableGoals,
  });

  @override
  State<AddEditEventDialog> createState() => _AddEditEventDialogState();
}

class _AddEditEventDialogState extends State<AddEditEventDialog> {
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _frequencyController;
  late TextEditingController _dayOfMonthController;

  // State variables
  late int _selectedCategoryId;
  CategoryTableData? _selectedCategory;
  late bool _isPositiveCashflow;
  late RepeatOption _repeatOption;
  late DateTime selectedDate;
  CustomRecurrence? _customRecurrence;
  
  // UI state
  bool _showAmountError = false;
  bool _showTitleError = false;
  String _firstOccurrenceText = '';
  bool _isBasicExpanded = false;
  bool _showCategorySelector = false;
  bool _isRecurrenceExpanded = false;
  
  // Goal allocation state
  List<GoalAllocation> _goalAllocations = [];
  
  // Smart categorization state
  SmartCategorizationResult? _smartSuggestion;
  bool _isSmartSuggestionActive = false;
  bool _userHasSelectedCategory = false;
  late SmartCategorizationService _smartCategorizationService;

  @override
  void initState() {
    super.initState();
    _smartCategorizationService = getIt<SmartCategorizationService>();
    _initializeControllers();
    _initializeState();
    
    // Load existing allocations if editing an event
    if (widget.event != null) {
      _loadExistingAllocations();
    }
    
    // Calculate initial first occurrence text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFirstOccurrenceText();
      _suggestCategoryFromTitle(); // Initial suggestion if editing and no category selected
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _amountController = TextEditingController(text: widget.event?.amount.toString() ?? '');
    _frequencyController = TextEditingController(text: widget.event?.customRecurrence?.frequency.toString() ?? '1');
    _dayOfMonthController = TextEditingController(
      text: widget.event?.customRecurrence?.dayOfMonth?.toString() ?? 
            widget.selectedDay.day.toString()
    );
  }

  void _initializeState() {
    // Only set category if editing existing event
    if (widget.event != null) {
      _selectedCategoryId = widget.event!.categoryId;
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == _selectedCategoryId,
        orElse: () => widget.categories.first,
      );
      _userHasSelectedCategory = true; // User already has a category selected
    } else {
      // For new events, start with no category selected to allow smart suggestions
      _selectedCategoryId = -1; // Invalid ID to indicate no selection
      _selectedCategory = null;
      _userHasSelectedCategory = false;
    }
    
    _isPositiveCashflow = widget.event?.isPositiveCashflow ?? widget.isPositiveCashflow;
    _repeatOption = widget.event?.repeatOption ?? RepeatOption.today;
    _customRecurrence = widget.event?.customRecurrence;
    selectedDate = widget.event?.dateTime ?? widget.selectedDay;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dayOfMonthController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  // Load existing goal allocations when editing an event
  Future<void> _loadExistingAllocations() async {
    if (widget.event?.id == null) return;
    
    try {
      print('🔍 DEBUG: Loading existing allocations for event ID: ${widget.event!.id}');
      final database = getIt<Database>();
      final allocations = await database.getAllocationsForEvent(widget.event!.id!);
      
      print('🔍 DEBUG: Found ${allocations.length} existing allocations');
      
      // Convert database allocations to domain model
      final goalAllocations = allocations.map((allocation) => 
        GoalAllocation(
          id: allocation.id,
          eventId: allocation.eventId,
          goalId: allocation.goalId,
          allocationAmount: allocation.allocationAmount,
          allocationType: allocation.allocationType,
        )
      ).toList();
      
      // Update the state with existing allocations
      if (mounted) {
        setState(() {
          _goalAllocations = goalAllocations;
          print('🔍 DEBUG: Set ${_goalAllocations.length} allocations in state');
          for (final allocation in _goalAllocations) {
            print('  - Goal ${allocation.goalId}: \$${allocation.allocationAmount}');
          }
        });
      }
    } catch (e) {
      print('❌ ERROR: Failed to load existing allocations: $e');
    }
  }

  // Event handlers
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

  // Helper methods
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
      final now = DateTime.now();
      if (adjustedDate.year == now.year && 
          adjustedDate.month == now.month && 
          adjustedDate.day == now.day) {
        _firstOccurrenceText = "Starts today";
      } else {
        final formatter = DateFormat('M/d/yyyy');
        _firstOccurrenceText = "Starts ${formatter.format(adjustedDate)}";
      }
    });
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
        useLastDayOfMonth: day >= 29,
      );
    });
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

  /// Smart categorization logic - suggests category based on title
  Future<void> _suggestCategoryFromTitle() async {
    // Only suggest if user hasn't manually selected a category
    if (_userHasSelectedCategory || _titleController.text.trim().isEmpty) {
      return;
    }

    try {
      final suggestion = await _smartCategorizationService.suggestCategory(
        _titleController.text,
        _isPositiveCashflow ? CategoryType.income : CategoryType.expense,
      );

      if (suggestion != null && mounted) {
        setState(() {
          _smartSuggestion = suggestion;
          _selectedCategory = suggestion.suggestedCategory;
          _selectedCategoryId = suggestion.suggestedCategory.id;
          _isSmartSuggestionActive = true;
        });

        print('✨ Smart suggestion: ${suggestion.suggestedCategory.name} (${suggestion.confidencePercentage} confidence)');
        print('   Reason: ${suggestion.reason}');
      }
    } catch (e) {
      print('❌ Error in smart categorization: $e');
    }
  }

  /// Called when user manually selects a category
  void _onCategoryManuallySelected(CategoryTableData category) {
    setState(() {
      _selectedCategory = category;
      _selectedCategoryId = category.id;
      _userHasSelectedCategory = true;
      _isSmartSuggestionActive = false;
      _smartSuggestion = null;
      _showCategorySelector = false;
    });
  }

  /// Called to show smart suggestion button for re-suggesting
  Future<void> _requestSmartSuggestion() async {
    setState(() {
      _userHasSelectedCategory = false;
    });
    await _suggestCategoryFromTitle();
  }

  // Accordion behavior helper methods
  void _toggleBasicExpanded() {
    setState(() {
      _isBasicExpanded = !_isBasicExpanded;
      if (_isBasicExpanded) {
        _showCategorySelector = false;
        _isRecurrenceExpanded = false;
      }
    });
  }

  void _toggleCategorySelector() {
    setState(() {
      _showCategorySelector = true;
      _isBasicExpanded = false;
      _isRecurrenceExpanded = false;
    });
  }

  void _toggleRecurrenceExpanded() {
    setState(() {
      _isRecurrenceExpanded = !_isRecurrenceExpanded;
      if (_isRecurrenceExpanded) {
        _isBasicExpanded = false;
        _showCategorySelector = false;
      }
    });
  }

  void _saveEvent() {
    print('🐛 DEBUG _saveEvent - Start');
    print('🐛 selectedDate: $selectedDate');
    print('🐛 _repeatOption: $_repeatOption');
    print('🐛 _customRecurrence: ${_customRecurrence?.toJson()}');
    
    // Validate required fields
    if (_amountController.text.isEmpty || _titleController.text.isEmpty) {
          setState(() {
      _showAmountError = _amountController.text.isEmpty;
      _showTitleError = _titleController.text.isEmpty;
    });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
      return;
    }

    // Validate category selection
    if (_selectedCategoryId == -1 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
      return;
    }

    // Validate and parse amount
final parsedAmount = CurrencyInputFormatter.parse(_amountController.text);
    if (parsedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
      return;
    }

    // Calculate final amount based on positive/negative cashflow
    final amount = _isPositiveCashflow ? parsedAmount : -parsedAmount;

    if (_repeatOption != RepeatOption.today) {
      final frequency = int.tryParse(_frequencyController.text) ?? 1;
      
      if (_repeatOption == RepeatOption.weekly) {
        _customRecurrence = CustomRecurrence(
          interval: _repeatOption,
          frequency: frequency,
          selectedDays: _customRecurrence?.selectedDays ?? List.filled(7, false),
          originalDate: selectedDate,
        );
      } else if (_repeatOption == RepeatOption.monthly) {
        _customRecurrence = CustomRecurrence(
          interval: _repeatOption,
          frequency: frequency,
          dayOfMonth: _customRecurrence?.dayOfMonth,
          repeatAtEndOfMonth: _customRecurrence?.repeatAtEndOfMonth ?? false,
          useLastDayOfMonth: _customRecurrence?.useLastDayOfMonth ?? false,
        );

           if (_customRecurrence?.repeatAtEndOfMonth == true) {
        selectedDate = EventDateUtils.getEndOfMonth(selectedDate);
      }
      } else {
        _customRecurrence = CustomRecurrence(
          interval: _repeatOption,
          frequency: frequency,
          selectedDays: List.filled(7, false),
        );
      }
    }

    print('DEBUG - Final CustomRecurrence before save: ${_customRecurrence?.toJson()}');

    if (_repeatOption == RepeatOption.weekly) {
      _customRecurrence = _customRecurrence?.copyWith(
        originalDate: selectedDate,
      );
    }


  print('🐛 DEBUG - Creating event with dateTime: $selectedDate');
  print('🐛 DEBUG - Final _customRecurrence: ${_customRecurrence?.toJson()}');
  
  final event = widget.event?.id != null
      ? Event(
          id: widget.event!.id,
          title: _titleController.text,
          categoryId: _selectedCategoryId,
          amount: amount,
          dateTime: selectedDate,
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
          dateTime: selectedDate,
          repeatOption: _repeatOption,
          isRecurring: _repeatOption != RepeatOption.today,
          customRecurrence: _customRecurrence,
          notes: null,
        );

  final result = EventCreationResult(
    event: event,
    allocations: _goalAllocations,
  );
  
  Navigator.of(context).pop(result);
}

  Widget _buildAmountCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount input field
        TextField(
              controller: _amountController,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _isPositiveCashflow
                    ? DesignTokens.color('income')
                    : DesignTokens.color('expense'),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                CurrencyInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                errorText:
                    _showAmountError ? 'Amount is required' : null,
              ),
              onChanged: (value) {
                setState(() {
                  // Clear error when user types
                  if (_showAmountError) {
                    _showAmountError = false;
                  }
                  // Trigger rebuild to show/hide goal allocation section
                });
              },
            ),
            const SizedBox(height: 16), // Padding between amount and title
            // Title/description input field
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: "What's this for?",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                errorText: _showTitleError ? 'Description is required' : null,
              ),
              onChanged: (value) {
                // Clear error when user types
                if (_showTitleError) {
                  setState(() => _showTitleError = false);
                }
                // Trigger smart categorization if no category selected
                _suggestCategoryFromTitle();
              },
            ),
          ],
    );
  }


    Widget _buildBasicDetailsSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.borderRadius['md']!,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleBasicExpanded();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  const Text('When?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, y').format(selectedDate),
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: _isBasicExpanded ? 2 : 0,
                    child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface),
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
                  SizedBox(
                    height: 300,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: _isPositiveCashflow ? DesignTokens.color('income') : DesignTokens.color('expense'),
                        ),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (DateTime newDate) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            selectedDate = newDate;
                            // Update day of month controller if it exists
                            if (_repeatOption == RepeatOption.monthly &&
                                !(_customRecurrence?.repeatAtEndOfMonth ?? false)) {
                              _dayOfMonthController.text = newDate.day.toString();
                              _updateMonthlyRecurrence(newDate.day);
                            }
                          });
                          // Update the "Starts" text in real-time when date changes
                          _updateFirstOccurrenceText();
                        },
                      ),
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

    Widget _buildRepeatOptionChip(RepeatOption option, String label) {
    final isSelected = _repeatOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1,
      ),
      onSelected: (bool selected) {
        if (selected) {
          FocusScope.of(context).unfocus();
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
                        // Add debug prints here
            print('DEBUG - Custom Recurrence set to: ${_customRecurrence?.toJson()}');
            print('DEBUG - Frequency: ${_customRecurrence?.frequency}');
          });
        }
      },
    );
  }


  Widget _buildFrequencySelector() {
  return Row(
    children: [
      Text('Repeat every', style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      )),
      const SizedBox(width: 8),
      SizedBox(
        width: 60,
        child: TextField(
          controller: _frequencyController,  // Use the existing controller
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              )).copyWith(frequency: frequency);  // Add copyWith here
                
              print('DEBUG - Updated frequency to: $frequency');
              print('DEBUG - Custom Recurrence: ${_customRecurrence?.toJson()}');
            });
            _updateFirstOccurrenceText();
          },
        ),
      ),
      const SizedBox(width: 8),
      Text(_getIntervalLabel(), style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
      )),
    ],
  );
}  

  Widget _buildWeeklySelector() {
    print(
        "Selected days in weekly selector: ${_customRecurrence?.selectedDays}");

    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Repeat on:', style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final isSelected = _customRecurrence?.selectedDays[index] ?? false;
            return InkWell(
            onTap: () {
                FocusScope.of(context).unfocus();
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
                  _updateFirstOccurrenceText(); 
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
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Center(
                  child: Text(
                    weekDays[index],
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
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

    Widget _buildSimplifiedMonthlySelector() {
    final isEndOfMonth = _customRecurrence?.repeatAtEndOfMonth ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: DesignTokens.borderRadius['sm']!,
          ),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Repeat at end of month'),
            value: isEndOfMonth,
            onChanged: (value) {
            FocusScope.of(context).unfocus();
            setState(() {
              if (value ?? false) {
                // When enabling end of month, immediately adjust the date
                final endOfMonth = EventDateUtils.getEndOfMonth(selectedDate);
                selectedDate = endOfMonth; // Update the selected date
                
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
        ),
        if (!isEndOfMonth) ...[
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Day of month',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _dayOfMonthController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              ),
              const SizedBox(height: 4),
              Text(
                'Enter a day between 1 and 31',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

   Widget _buildRecurrenceSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.borderRadius['md']!,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleRecurrenceExpanded();
            },
            borderRadius: DesignTokens.borderRadius['md']!,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 20, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(width: 8),
                  const Text('Repeat',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      )),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _repeatOption == RepeatOption.today 
                          ? 'One-time'
                          : (_customRecurrence?.getDescription() ??
                              _repeatOption.toString().split('.').last),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      if (_repeatOption != RepeatOption.today) ...[
                        if (_firstOccurrenceText.isNotEmpty)
                          const SizedBox(height: 2),
                        if (_firstOccurrenceText.isNotEmpty)
                          Text(
                            _firstOccurrenceText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
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
                    child: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurface),
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

  Widget _buildActions() {
    // Determine button text based on whether we're adding or editing
    final buttonText = widget.event?.id != null ? 'Update' : 'Add';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: !_isPositiveCashflow ? DesignTokens.color('expense') : null,
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _saveEvent, // Always enabled, validation happens inside _saveEvent
          style: FilledButton.styleFrom(
            backgroundColor: !_isPositiveCashflow ? DesignTokens.color('expense') : null,
          ),
          child: Text(buttonText),
        ),
      ],
    );
  }

  Widget _buildGoalAllocationSection() {
    // Only show goal allocation for meaningful amounts and if goals are available
    final amount = CurrencyInputFormatter.parse(_amountController.text) ?? 0.0;
    print("Debug Goal Allocation: availableGoals.length = ${widget.availableGoals.length}, amount = $amount, amountText = '${_amountController.text}'");
    if (widget.availableGoals.isEmpty || amount <= 0) {
      print("Debug: Hiding goal allocation section - goals empty: ${widget.availableGoals.isEmpty}, amount <= 0: ${amount <= 0}");
      return const SizedBox.shrink();
    }

    return GoalAllocationWidget(
      availableGoals: widget.availableGoals,
      currentAllocations: _goalAllocations,
      transactionAmount: amount.abs(),
      isIncome: _isPositiveCashflow,
      onAllocationsChanged: (allocations) {
        setState(() {
          _goalAllocations = allocations;
        });
      },
    );
  }

  Widget _buildCategorySection() {
    final categoryType = _isPositiveCashflow ? CategoryType.income : CategoryType.expense;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.borderRadius['md']!,
        side: BorderSide(
          color: _isSmartSuggestionActive
            ? DesignTokens.color('info')
            : Theme.of(context).colorScheme.outline,
          width: _isSmartSuggestionActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              _toggleCategorySelector();
            },
            borderRadius: DesignTokens.borderRadius['md']!,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isPositiveCashflow ? Icons.trending_up : Icons.trending_down,
                    size: 20,
                    color: _isPositiveCashflow ? DesignTokens.color('income') : DesignTokens.color('expense'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  
                  // Smart suggestion indicator
                  if (_isSmartSuggestionActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: DesignTokens.color('info').withOpacity(0.1),
                        borderRadius: DesignTokens.borderRadius['sm']!,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 12, color: DesignTokens.color('info')),
                          const SizedBox(width: 2),
                          Text(
                            'Smart',
                            style: TextStyle(
                              fontSize: 10,
                              color: DesignTokens.color('info'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Category display
                  if (_selectedCategory != null) ...[
                    if (_selectedCategory!.icon?.isNotEmpty == true)
                      Text(
                        _selectedCategory!.icon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _selectedCategory!.name,
                        style: TextStyle(
                          color: _isSmartSuggestionActive
                            ? DesignTokens.color('info')
                            : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Text('Select category'),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          
          // Smart suggestion details and controls
          if (_isSmartSuggestionActive && _smartSuggestion != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: DesignTokens.color('info')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_smartSuggestion!.reason} (${_smartSuggestion!.confidencePercentage} match)',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.color('info'),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Smart suggest button for manual requests
          if (!_isSmartSuggestionActive && _userHasSelectedCategory && _titleController.text.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                onPressed: _requestSmartSuggestion,
                icon: Icon(Icons.auto_awesome, size: 16, color: DesignTokens.color('info')),
                label: Text(
                  'Get Smart Suggestion',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.color('info'),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius['lg']!,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside text fields
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
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
                    _buildCategorySection(),
                    const SizedBox(height: 8),
                    _buildRecurrenceSection(),
                    const SizedBox(height: 8),
                    _buildGoalAllocationSection(),
                    const SizedBox(height: 16),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      
      // Category Selector Modal
      if (_showCategorySelector)
        Positioned.fill(
          child: Material(
            color: Theme.of(context).colorScheme.scrim.withOpacity(0.5),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: DesignTokens.borderRadius['lg']!,
                ),
                child: HierarchicalCategorySelector(
                  categoryType: _isPositiveCashflow ? CategoryType.income : CategoryType.expense,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategoryManuallySelected,
                  onClose: () {
                    setState(() {
                      _showCategorySelector = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
}
