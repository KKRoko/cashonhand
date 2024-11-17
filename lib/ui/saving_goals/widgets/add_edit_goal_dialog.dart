import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');  // Changed from name
    _descriptionController = TextEditingController(text: widget.goal?.description ?? '');  // Added
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount.toString() ?? '',
    );
    _currentAmountController = TextEditingController(
      text: widget.goal?.currentAmount.toString() ?? '0',
    );
    _deadlineDate = widget.goal?.deadlineDate ?? DateTime.now().add(  // Changed from targetDate
      const Duration(days: 365),
    );
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
    );
    if (picked != null && picked != _deadlineDate) {
      setState(() {
        _deadlineDate = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);

      final goal = SavingGoal.withDeadline(  // Using the factory constructor
        title: _titleController.text,         // Changed from name
        description: _descriptionController.text,  // Added
        targetAmount: double.parse(_targetAmountController.text),
        deadlineDate: _deadlineDate,         // Changed from targetDate
      ).copyWith(
        id: widget.goal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        currentAmount: double.parse(_currentAmountController.text),
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
      );

      if (widget.goal != null) {
        notifier.updateGoal(goal);
      } else {
        notifier.addGoal(goal);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                
                // Goal Name
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bookmark_outline),
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
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
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
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Current Amount
                TextFormField(
                  controller: _currentAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Current Amount Saved',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.savings_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter current amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Please enter a valid amount';
                    }
                    final targetAmount = double.tryParse(
                      _targetAmountController.text,
                    ) ?? 0;
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
                    decoration: const InputDecoration(
                      labelText: 'Target Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(FormatUtils.formatDate(_deadlineDate)),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Monthly Savings Calculator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Monthly Savings',
                        style: Theme.of(context).textTheme.titleSmall,
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

  Widget _buildMonthlySavingsCalculation() {
    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final currentAmount = double.tryParse(_currentAmountController.text) ?? 0;
    final monthsLeft = _deadlineDate.difference(DateTime.now()).inDays / 30;
    final requiredMonthly = monthsLeft > 0
        ? (targetAmount - currentAmount) / monthsLeft
        : double.infinity;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Youll need to save'),
        Text(
          monthsLeft > 0
              ? FormatUtils.formatCurrency(requiredMonthly)
              : '---',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text('monthly'),
      ]
      );
  }
}
