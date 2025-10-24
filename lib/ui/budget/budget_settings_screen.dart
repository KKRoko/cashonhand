import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/freezed/budget.dart';
import '../../theme/design_tokens.dart';

class BudgetSettingsScreen extends StatefulWidget {
  final Budget budget;
  final Function({
    required double monthlyIncome,
    required int cycleStartDay,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) onUpdateBudget;
  final VoidCallback? onDeleteBudget;

  const BudgetSettingsScreen({
    super.key,
    required this.budget,
    required this.onUpdateBudget,
    this.onDeleteBudget,
  });

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _incomeController;

  late double _needsPercentage;
  late double _wantsPercentage;
  late double _savingsPercentage;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(
      text: widget.budget.monthlyIncome.toStringAsFixed(0),
    );
    _needsPercentage = widget.budget.needsPercentage * 100;
    _wantsPercentage = widget.budget.wantsPercentage * 100;
    _savingsPercentage = widget.budget.savingsPercentage * 100;

    _incomeController.addListener(() {
      setState(() => _hasChanges = true);
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _updatePercentages(String type, double value) {
    setState(() {
      _hasChanges = true;
      switch (type) {
        case 'needs':
          _needsPercentage = value;
          break;
        case 'wants':
          _wantsPercentage = value;
          break;
        case 'savings':
          _savingsPercentage = value;
          break;
      }
    });
  }

  bool get _isPercentageValid {
    final total = _needsPercentage + _wantsPercentage + _savingsPercentage;
    return (total - 100.0).abs() < 0.1;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate() && _isPercentageValid) {
      final income = double.parse(_incomeController.text);

      widget.onUpdateBudget(
        monthlyIncome: income,
        cycleStartDay: 1, // Always use 1st of month
        needsPercentage: _needsPercentage / 100,
        wantsPercentage: _wantsPercentage / 100,
        savingsPercentage: _savingsPercentage / 100,
      );

      Navigator.of(context).pop(true);
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: const Text(
          'Are you sure you want to delete this budget? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDeleteBudget?.call();
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.color('error'),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPercentage = _needsPercentage + _wantsPercentage + _savingsPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Settings'),
        backgroundColor: DesignTokens.color('surface'),
        elevation: 0,
        actions: [
          if (_hasChanges && _isPercentageValid)
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Save',
                style: TextStyle(
                  color: DesignTokens.color('primary'),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Configuration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.color('textPrimary'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modify your monthly budget settings',
                style: TextStyle(
                  fontSize: 14,
                  color: DesignTokens.color('textSecondary'),
                ),
              ),
              const SizedBox(height: 32),

              // Monthly Income
              Text(
                'Monthly Income',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.color('textPrimary'),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _incomeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: 'Enter your monthly income',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly income';
                  }
                  final income = double.tryParse(value);
                  if (income == null || income <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Budget Allocation
              Text(
                'Budget Allocation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.color('textPrimary'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${totalPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: _isPercentageValid
                      ? DesignTokens.color('success')
                      : DesignTokens.color('error'),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_isPercentageValid) ...[
                const SizedBox(height: 4),
                Text(
                  'Percentages must sum to 100%',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.color('error'),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              _buildPercentageSlider(
                'Needs',
                'Essential expenses (housing, groceries, utilities)',
                _needsPercentage,
                DesignTokens.color('primary'),
                (value) => _updatePercentages('needs', value),
              ),
              const SizedBox(height: 16),

              _buildPercentageSlider(
                'Wants',
                'Discretionary spending (entertainment, dining out)',
                _wantsPercentage,
                DesignTokens.color('info'),
                (value) => _updatePercentages('wants', value),
              ),
              const SizedBox(height: 16),

              _buildPercentageSlider(
                'Savings',
                'Long-term goals (savings, investments, debt)',
                _savingsPercentage,
                DesignTokens.color('warning'),
                (value) => _updatePercentages('savings', value),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_hasChanges && _isPercentageValid) ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.color('primary'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Budget Button
              if (widget.onDeleteBudget != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _handleDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Budget'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.color('error'),
                      side: BorderSide(color: DesignTokens.color('error')),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageSlider(
    String title,
    String description,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.color('textPrimary'),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: DesignTokens.color('textSecondary'),
          ),
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
