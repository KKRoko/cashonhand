import '../../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/design_tokens.dart';
import '../../data/models/freezed/budget_template.dart';
import '../../data/models/freezed/allocation_template.dart';
import '../../state/budget_notifier.dart';
import '../../core/di/injection.dart';
import 'budget_template_library_screen.dart';

class BudgetSetupScreen extends StatefulWidget {
  final Function({
    required double monthlyIncome,
    required int cycleStartDay,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) onCreateBudget;
  final DateTime targetMonth;

  const BudgetSetupScreen({
    super.key,
    required this.onCreateBudget,
    required this.targetMonth,
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

  String _getMonthYearString(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
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

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate() && _isPercentageValid) {
      final income = double.parse(_incomeController.text);

      // Ask if user wants to load a category allocation template FIRST
      final loadTemplate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Load Allocation Template?',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Would you like to load a saved allocation template to quickly set up your budget categories?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Load Template'),
            ),
          ],
        ),
      );

      // Show the template selection dialog if user wants to load
      int? selectedTemplateId;
      if (loadTemplate == true && mounted) {
        selectedTemplateId = await _showLoadAllocationTemplateDialogAndReturn();
      }

      // Create the budget first
      final budgetNotifier = getIt<BudgetNotifier>();

      // Ensure we're creating the budget for the target month, not the current selected month
      final previousMonth = budgetNotifier.selectedMonth;
      budgetNotifier.setSelectedMonth(widget.targetMonth);

      print('🔵 SETUP: Creating budget for target month ${widget.targetMonth}');
      print('🔵 SETUP: Income=$income, Needs=${_needsPercentage / 100}, Wants=${_wantsPercentage / 100}, Savings=${_savingsPercentage / 100}');

      final success = await budgetNotifier.createBudget(
        monthlyIncome: income,
        cycleStartDay: 1,
        needsPercentage: _needsPercentage / 100,
        wantsPercentage: _wantsPercentage / 100,
        savingsPercentage: _savingsPercentage / 100,
      );

      print('🔵 SETUP: Budget creation result: $success, error: ${budgetNotifier.error}');

      if (!success) {
        // Budget creation failed, show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create budget: ${budgetNotifier.error ?? "Unknown error"}'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
        return;
      }

      // Apply the selected template after budget is created
      if (selectedTemplateId != null && mounted) {
        final templateSuccess = await budgetNotifier.applyTemplate(selectedTemplateId);

        if (!templateSuccess && mounted) {
          // Template application failed, show error but still navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Budget created but failed to apply template: ${budgetNotifier.error ?? "Unknown error"}'),
              backgroundColor: DesignTokens.color('warning'),
            ),
          );
        } else if (mounted) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Budget created with allocation template'),
              backgroundColor: DesignTokens.color('success'),
            ),
          );
        }
      }

      // Navigate back after everything is complete
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  /// Show dialog to select an allocation template and return the ID
  Future<int?> _showLoadAllocationTemplateDialogAndReturn() async {
    final budgetNotifier = getIt<BudgetNotifier>();

    // Load templates if not already loaded
    if (!budgetNotifier.templatesLoaded) {
      await budgetNotifier.loadTemplates();
    }

    if (!mounted) return null;

    final templates = budgetNotifier.templates;

    if (templates.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No saved allocation templates found'),
            backgroundColor: DesignTokens.color('info'),
          ),
        );
      }
      return null;
    }

    final selectedTemplate = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _LoadAllocationTemplateDialog(
        templates: templates,
        budgetNotifier: budgetNotifier,
      ),
    );

    return selectedTemplate;
  }

  /// Show dialog to load and apply a category allocation template
  Future<void> _showLoadAllocationTemplateDialog() async {
    final selectedTemplateId = await _showLoadAllocationTemplateDialogAndReturn();

    if (selectedTemplateId != null && mounted) {
      final budgetNotifier = getIt<BudgetNotifier>();
      final success = await budgetNotifier.applyTemplate(selectedTemplateId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Allocation template applied successfully'),
              backgroundColor: DesignTokens.color('success'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(budgetNotifier.error ?? 'Failed to apply template'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
      }
    }
  }

  Future<void> _browseTemplates() async {
    final template = await Navigator.of(context).push<BudgetTemplate>(
      MaterialPageRoute(
        builder: (context) => const BudgetTemplateLibraryScreen(),
      ),
    );

    if (template != null) {
      await _applyTemplate(template);
    }
  }

  Future<void> _applyTemplate(BudgetTemplate template) async {
    setState(() {
      _needsPercentage = template.needsPercentage * 100;
      _wantsPercentage = template.wantsPercentage * 100;
      _savingsPercentage = template.savingsPercentage * 100;

      // Pre-fill monthly income if template has one
      if (template.monthlyIncome != null && template.monthlyIncome! > 0) {
        _incomeController.text = template.monthlyIncome!.toStringAsFixed(2);
      }
    });

    // If template has income, automatically create the budget
    if (template.monthlyIncome != null && template.monthlyIncome! > 0) {
      // Validate the form
      if (_formKey.currentState!.validate() && _isPercentageValid) {
        // Ask if user wants to load a category allocation template FIRST
        final loadTemplate = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Load Allocation Template?',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Would you like to load a saved allocation template to quickly set up your budget categories?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Skip'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Load Template'),
              ),
            ],
          ),
        );

        // Show the template selection dialog if user wants to load
        int? selectedTemplateId;
        if (loadTemplate == true && mounted) {
          selectedTemplateId = await _showLoadAllocationTemplateDialogAndReturn();
        }

        // Create the budget first
        final budgetNotifier = getIt<BudgetNotifier>();

        // Ensure we're creating the budget for the target month
        budgetNotifier.setSelectedMonth(widget.targetMonth);

        final success = await budgetNotifier.createBudget(
          monthlyIncome: template.monthlyIncome!,
          cycleStartDay: 1,
          needsPercentage: _needsPercentage / 100,
          wantsPercentage: _wantsPercentage / 100,
          savingsPercentage: _savingsPercentage / 100,
        );

        if (!success) {
          // Budget creation failed, show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create budget: ${budgetNotifier.error ?? "Unknown error"}'),
                backgroundColor: DesignTokens.color('error'),
              ),
            );
          }
          return;
        }

        // Apply the selected template after budget is created
        if (selectedTemplateId != null && mounted) {
          final templateSuccess = await budgetNotifier.applyTemplate(selectedTemplateId);

          if (!templateSuccess && mounted) {
            // Template application failed, show error but still navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Budget created but failed to apply template: ${budgetNotifier.error ?? "Unknown error"}'),
                backgroundColor: DesignTokens.color('warning'),
              ),
            );
          } else if (mounted) {
            // Success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Budget created with allocation template'),
                backgroundColor: DesignTokens.color('success'),
              ),
            );
          }
        }

        // Navigate back after everything is complete
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      // If no income in template, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Applied "${template.name}" template. Please enter your monthly income.'),
          backgroundColor: DesignTokens.color('success'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPercentage = _needsPercentage + _wantsPercentage + _savingsPercentage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up Budget - ${_getMonthYearString(widget.targetMonth)}'),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                'Budget Setup for ${_getMonthYearString(widget.targetMonth)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set your monthly income and budget allocation using the 50/30/20 rule',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Template Selection Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _browseTemplates,
                  icon: const Icon(Icons.library_books_outlined),
                  label: const Text('Use a Budget Template'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Monthly Income
              Text(
                'Monthly Income',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _incomeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Enter your monthly income',
                  hintStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.5)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  color: Theme.of(context).colorScheme.onSurface,
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
                Theme.of(context).colorScheme.primary,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

/// Dialog for loading and applying category allocation templates
class _LoadAllocationTemplateDialog extends StatefulWidget {
  final List<AllocationTemplate> templates;
  final BudgetNotifier budgetNotifier;

  const _LoadAllocationTemplateDialog({
    required this.templates,
    required this.budgetNotifier,
  });

  @override
  State<_LoadAllocationTemplateDialog> createState() => _LoadAllocationTemplateDialogState();
}

class _LoadAllocationTemplateDialogState extends State<_LoadAllocationTemplateDialog> {
  late List<AllocationTemplate> _localTemplates;

  @override
  void initState() {
    super.initState();
    _localTemplates = List.from(widget.templates);
  }

  Future<void> _deleteTemplate(AllocationTemplate template) async {
    final success = await widget.budgetNotifier.deleteTemplate(template.id);

    if (success && mounted) {
      setState(() {
        _localTemplates.removeWhere((t) => t.id == template.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted template "${template.name}"'),
          backgroundColor: DesignTokens.color('success'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete template: ${widget.budgetNotifier.error ?? "Unknown error"}'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Load Allocation Template',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: _localTemplates.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No templates available',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _localTemplates.length,
                itemBuilder: (context, index) {
                  final template = _localTemplates[index];
                  return Dismissible(
                    key: Key('template_${template.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: DesignTokens.color('error'),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          title: Text(
                            'Delete Template',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete "${template.name}"?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (direction) {
                      _deleteTemplate(template);
                    },
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        template.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: template.description != null
                          ? Text(
                              template.description!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => Navigator.pop(context, template.id),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
