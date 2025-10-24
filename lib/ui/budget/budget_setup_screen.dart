import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';

class BudgetSetupScreen extends StatefulWidget {
  final Function({
    required double monthlyIncome,
    required int cycleStartDay,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) onCreateBudget;

  const BudgetSetupScreen({
    super.key,
    required this.onCreateBudget,
  });

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();

  double _needsPercentage = 50.0;
  double _wantsPercentage = 30.0;
  double _savingsPercentage = 20.0;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  void _updatePercentages(String type, double value) {
    setState(() {
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

  void _handleSubmit() {
    if (_formKey.currentState!.validate() && _isPercentageValid) {
      final income = double.parse(_incomeController.text);

      widget.onCreateBudget(
        monthlyIncome: income,
        cycleStartDay: 1, // Always use 1st of month
        needsPercentage: _needsPercentage / 100,
        wantsPercentage: _wantsPercentage / 100,
        savingsPercentage: _savingsPercentage / 100,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPercentage = _needsPercentage + _wantsPercentage + _savingsPercentage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Budget'),
        backgroundColor: DesignTokens.color('surface'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budget Setup',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.color('textPrimary'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your monthly income and budget allocation using the 50/30/20 rule',
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

              // Create Budget Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPercentageValid ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.color('primary'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Budget',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
