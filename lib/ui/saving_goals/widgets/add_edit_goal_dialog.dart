import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../state/saving_goal_notifier.dart';
import '../../../utils/formatters.dart';

class AddEditGoalDialog extends StatefulWidget {
  final SavingGoal? goal;

  const AddEditGoalDialog({
    super.key,
    this.goal,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddEditGoalDialogState createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;      // Changed from _nameController
  late TextEditingController _descriptionController; // Added for required description
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late DateTime _deadlineDate;
  final NumberFormat _numberFormat = NumberFormat('#,##0.##');   

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');  // Changed from name
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');  // Added
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount != null ? _numberFormat.format(widget.goal!.targetAmount) : '',
    );
    _currentAmountController = TextEditingController(
      text: widget.goal?.currentAmount != null ? _numberFormat.format(widget.goal!.currentAmount) : '0',
    );
    _deadlineDate = widget.goal?.deadlineDate ?? DateTime(DateTime.now().year, 12, 31);  // Default to end of current year
    
    // Add listeners for real-time calculation updates
    _targetAmountController.addListener(_updateCalculations);
    _currentAmountController.addListener(_updateCalculations);
  }
  
  void _updateCalculations() {
    setState(() {
      // This will trigger a rebuild and update the calculations
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();  
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.dark
            ? ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  surface: Colors.black,
                  onSurface: Colors.white,
                  surfaceContainerHighest: Color(0xFF333333),
                ),
                dialogBackgroundColor: Colors.black,
              )
            : Theme.of(context),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _deadlineDate) {
      setState(() {
        _deadlineDate = picked;
      });
      _updateCalculations(); // Update calculations when date changes
    }
  }

  Future<void> _saveGoal() async {
    print('🔍 DEBUG: AddEditGoalDialog._saveGoal called');
    print('🔍 DEBUG: Form validation: ${_formKey.currentState!.validate()}');
    
    if (_formKey.currentState!.validate()) {
      final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);
      final isEditing = widget.goal != null;
      
      print('🔍 DEBUG: Is editing: $isEditing, Goal ID: ${widget.goal?.id}');

      final goal = SavingGoal.withDeadline(  // Using the factory constructor
        title: _titleController.text,         // Changed from name
        description: _descriptionController.text,  // Added
        targetAmount: _parseAmountFromFormatted(_targetAmountController.text),
        deadlineDate: _deadlineDate,         // Changed from targetDate
      ).copyWith(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch,
        currentAmount: _parseAmountFromFormatted(_currentAmountController.text),
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
      );

      print('🔍 DEBUG: Goal object created - ID: ${goal.id}, Title: "${goal.title}", Target: ${goal.targetAmount}');

      if (widget.goal != null) {
        print('🔍 DEBUG: Calling notifier.updateGoal');
        await notifier.updateGoal(goal);
      } else {
        print('🔍 DEBUG: Calling notifier.addGoal');
        await notifier.addGoal(goal);
      }
      
      // Immediately refresh the goals list to show the new/updated goal
      print('🔍 DEBUG: Calling notifier.loadGoals to refresh goals list');
      await notifier.loadGoals();
      print('🔍 DEBUG: Goals list refreshed, closing dialog');

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
        ? Colors.black 
        : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.goal != null ? 'Edit Goal' : 'Create New Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : null,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Goal Name
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : null,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Goal Name',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                    filled: false, // Remove any background fill
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.bookmark_outline,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                       TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : null,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                    filled: false, // Remove any background fill
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  maxLines: 3,  // Allow multiple lines for description
                ),
                const SizedBox(height: 16),
                
                // Target Amount
                TextFormField(
                  controller: _targetAmountController,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : null,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                    filled: false, // Remove any background fill
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount';
                    }
                    final amount = _parseAmountFromFormatted(value);
                    if (amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current Amount
                TextFormField(
                  controller: _currentAmountController,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : null,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Current Amount Saved',
                    labelStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                    filled: false, // Remove any background fill
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : Colors.grey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white 
                          : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.savings_outlined,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white70 
                        : null,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    _ThousandsSeparatorInputFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current amount';
                    }
                    final amount = _parseAmountFromFormatted(value);
                    if (amount < 0) {
                      return 'Please enter a valid amount';
                    }
                    final targetAmount = _parseAmountFromFormatted(_targetAmountController.text);
                    if (amount > targetAmount) {
                      return 'Current amount cannot exceed target';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Target Date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Target Date',
                      labelStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : null,
                      ),
                      filled: false, // Remove any background fill
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.grey,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.white70 
                          : null,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FormatUtils.formatDate(_deadlineDate),
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : null,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white70 
                            : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Monthly Savings Calculator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black 
                      : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Monthly Savings',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMonthlySavingsCalculation(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveGoal,
                      child: Text(
                        widget.goal != null ? 'Update Goal' : 'Create Goal',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _parseAmountFromFormatted(String formattedText) {
    // Remove commas and parse as double
    final cleanText = formattedText.replaceAll(',', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  Widget _buildMonthlySavingsCalculation() {
    final targetAmount = _parseAmountFromFormatted(_targetAmountController.text);
    final currentAmount = _parseAmountFromFormatted(_currentAmountController.text);
    final monthsLeft = _deadlineDate.difference(DateTime.now()).inDays / 30;
    final requiredMonthly = monthsLeft > 0
        ? (targetAmount - currentAmount) / monthsLeft
        : double.infinity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'You\'ll need to save',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : null,
          ),
        ),
        Text(
          monthsLeft > 0 && requiredMonthly >= 0
              ? FormatUtils.formatCurrency(requiredMonthly)
              : '---',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.green 
              : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'monthly',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : null,
          ),
        ),
      ]
      );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0.##');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only numbers and decimal points
    final newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Don't allow multiple decimal points
    final parts = newText.split('.');
    if (parts.length > 2) {
      return oldValue;
    }
    
    // If empty, return empty
    if (newText.isEmpty) {
      return const TextEditingValue(text: '');
    }
    
    // Parse and format the number
    final double? number = double.tryParse(newText);
    if (number == null) {
      return oldValue;
    }
    
    // Format with thousands separators
    String formattedText;
    if (newText.endsWith('.')) {
      // Preserve trailing decimal point
      formattedText = _formatter.format(number.floor()) + '.';
    } else if (parts.length == 2 && parts[1].isNotEmpty) {
      // Preserve decimal places
      final integerPart = int.tryParse(parts[0]) ?? 0;
      final decimalPart = parts[1];
      formattedText = _formatter.format(integerPart) + '.' + decimalPart;
    } else {
      formattedText = _formatter.format(number);
    }
    
    // Calculate cursor position
    final int cursorPosition = formattedText.length;
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
