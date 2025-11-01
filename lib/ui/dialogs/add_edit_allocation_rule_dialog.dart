import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection.dart';
import '../../data/models/freezed/auto_allocation_rule.dart';
import '../../data/models/enums/trigger_type.dart';
import '../../data/models/enums/allocation_method.dart';
import '../../services/category_service.dart';
import '../../state/saving_goal_notifier.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../theme/design_tokens.dart';

class AddEditAllocationRuleDialog extends StatefulWidget{
  final AutoAllocationRule? existingRule;
  final Function(AutoAllocationRule) onSave;

  const AddEditAllocationRuleDialog({
    super.key,
    this.existingRule,
    required this.onSave,
  });

  @override
  State<AddEditAllocationRuleDialog> createState() => _AddEditAllocationRuleDialogState();
}

class _AddEditAllocationRuleDialogState extends State<AddEditAllocationRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ruleNameController = TextEditingController();
  final _allocationValueController = TextEditingController();
  final _minTriggerController = TextEditingController();
  final _maxAllocationController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AutoAllocationRuleForm _form;
  List<dynamic> _categories = [];
  List<SavingGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadData();
  }

  void _initializeForm() {
    if (widget.existingRule != null) {
      _form = AutoAllocationRuleForm.fromRule(widget.existingRule!);
    } else {
      _form = const AutoAllocationRuleForm();
    }

    _ruleNameController.text = _form.ruleName;
    _allocationValueController.text = _form.allocationMethod == AllocationMethod.percentage 
        ? (_form.allocationValue * 100).toStringAsFixed(1)
        : _form.allocationValue.toStringAsFixed(2);
    _minTriggerController.text = _form.minimumTriggerAmount?.toStringAsFixed(2) ?? '';
    _maxAllocationController.text = _form.maximumAllocationAmount?.toStringAsFixed(2) ?? '';
    _descriptionController.text = _form.description;
  }

  Future<void> _loadData() async {
    try {
      // Load categories
      final categoryService = getIt<CategoryService>();
      final categoriesResult = await categoryService.getCategories();
      categoriesResult.fold(
        (failure) => print('Error loading categories: ${failure.message}'),
        (categories) => setState(() => _categories = categories),
      );

      // Load goals from provider
      final goalNotifier = context.read<SavingGoalNotifier>();
      setState(() {
        _goals = goalNotifier.goals.toList();
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _ruleNameController.dispose();
    _allocationValueController.dispose();
    _minTriggerController.dispose();
    _maxAllocationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.existingRule == null ? 'Create Allocation Rule' : 'Edit Allocation Rule',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rule Name
                      _buildSectionHeader('Rule Details'),
                      TextFormField(
                        controller: _ruleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Rule Name',
                          hintText: 'e.g., "Save 10% of restaurant spending"',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Rule name is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _form = _form.copyWith(ruleName: value);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Brief description of this rule',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          setState(() {
                            _form = _form.copyWith(description: value);
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),

                      // Goal Selection
                      _buildSectionHeader('Target Goal'),
                      _buildGoalSelector(),
                      
                      const SizedBox(height: 24),

                      // Trigger Conditions
                      _buildSectionHeader('When to Trigger'),
                      _buildTriggerTypeSelector(),
                      
                      if (_form.triggerType == TriggerType.category) ...[
                        const SizedBox(height: 16),
                        _buildCategorySelector(),
                      ],
                      
                      const SizedBox(height: 16),
                      _buildMinimumAmountField(),
                      
                      const SizedBox(height: 24),

                      // Allocation Settings
                      _buildSectionHeader('How Much to Allocate'),
                      _buildAllocationMethodSelector(),
                      
                      const SizedBox(height: 16),
                      _buildAllocationValueField(),
                      
                      const SizedBox(height: 16),
                      _buildMaximumAllocationField(),
                      
                      const SizedBox(height: 24),

                      // Preview
                      _buildRulePreview(),
                      
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _canSave ? _saveRule : null,
                              child: Text(widget.existingRule == null ? 'Create Rule' : 'Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _form.goalId,
          hint: const Text('Select a savings goal'),
          items: _goals.map((goal) => DropdownMenuItem<int>(
            value: goal.id,
            child: Row(
              children: [
                Icon(Icons.flag, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(child: Text(goal.title)),
              ],
            ),
          )).toList(),
          onChanged: (goalId) {
            setState(() {
              _form = _form.copyWith(goalId: goalId);
            });
          },
        ),
      ),
    );
  }

  Widget _buildTriggerTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TriggerType.values.map((type) {
        final isSelected = _form.triggerType == type;
        return ChoiceChip(
          label: Text(type.displayName),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _form = _form.copyWith(
                  triggerType: type,
                  triggerCategoryId: type == TriggerType.category ? _form.triggerCategoryId : null,
                );
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _form.triggerCategoryId,
          hint: const Text('Select category'),
          items: _categories.map((category) => DropdownMenuItem<int>(
            value: category.id,
            child: Text(category.name),
          )).toList(),
          onChanged: (categoryId) {
            setState(() {
              _form = _form.copyWith(triggerCategoryId: categoryId);
            });
          },
        ),
      ),
    );
  }

  Widget _buildAllocationMethodSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AllocationMethod.values.where((method) => method != AllocationMethod.roundUp).map((method) {
        final isSelected = _form.allocationMethod == method;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(method.symbol),
              const SizedBox(width: 4),
              Text(method.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _form = _form.copyWith(allocationMethod: method);
                // Reset value when changing method
                if (method == AllocationMethod.percentage) {
                  _allocationValueController.text = '10.0';
                  _form = _form.copyWith(allocationValue: 0.1);
                } else {
                  _allocationValueController.text = '5.00';
                  _form = _form.copyWith(allocationValue: 5.0);
                }
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildAllocationValueField() {
    final isPercentage = _form.allocationMethod == AllocationMethod.percentage;
    return TextFormField(
      controller: _allocationValueController,
      decoration: InputDecoration(
        labelText: isPercentage ? 'Percentage' : 'Fixed Amount',
        hintText: isPercentage ? 'e.g., 10.0' : 'e.g., 5.00',
        prefixText: isPercentage ? '' : '\$',
        suffixText: isPercentage ? '%' : '',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Allocation value is required';
        }
        final parsed = double.tryParse(value);
        if (parsed == null || parsed <= 0) {
          return 'Must be a positive number';
        }
        if (isPercentage && parsed > 100) {
          return 'Percentage cannot exceed 100%';
        }
        return null;
      },
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          setState(() {
            _form = _form.copyWith(
              allocationValue: isPercentage ? parsed / 100 : parsed,
            );
          });
        }
      },
    );
  }

  Widget _buildMinimumAmountField() {
    return TextFormField(
      controller: _minTriggerController,
      decoration: const InputDecoration(
        labelText: 'Minimum Transaction Amount (Optional)',
        hintText: 'e.g., 10.00',
        prefixText: '\$',
        border: OutlineInputBorder(),
        helperText: 'Only trigger on transactions above this amount',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final parsed = double.tryParse(value);
          if (parsed == null || parsed < 0) {
            return 'Must be a positive number';
          }
        }
        return null;
      },
      onChanged: (value) {
        final parsed = value.isEmpty ? null : double.tryParse(value);
        setState(() {
          _form = _form.copyWith(minimumTriggerAmount: parsed);
        });
      },
    );
  }

  Widget _buildMaximumAllocationField() {
    return TextFormField(
      controller: _maxAllocationController,
      decoration: const InputDecoration(
        labelText: 'Maximum Allocation Amount (Optional)',
        hintText: 'e.g., 20.00',
        prefixText: '\$',
        border: OutlineInputBorder(),
        helperText: 'Cap the allocation amount at this value',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final parsed = double.tryParse(value);
          if (parsed == null || parsed <= 0) {
            return 'Must be a positive number';
          }
        }
        return null;
      },
      onChanged: (value) {
        final parsed = value.isEmpty ? null : double.tryParse(value);
        setState(() {
          _form = _form.copyWith(maximumAllocationAmount: parsed);
        });
      },
    );
  }

  Widget _buildRulePreview() {
    if (!_form.isValid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete the required fields to preview your rule',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    final rule = _form.toRule();
    final goalTitle = _goals.where((g) => g.id == _form.goalId).firstOrNull?.title ?? 'Selected Goal';
    final categoryName = _categories.where((c) => c.id == _form.triggerCategoryId).firstOrNull?.name;
    
    final ruleWithInfo = rule.withDisplayInfo(
      goalTitle: goalTitle,
      categoryName: categoryName,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.color('info').withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignTokens.color('info').withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: DesignTokens.color('info')),
              const SizedBox(width: 8),
              Text(
                'Rule Preview',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.color('info'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ruleWithInfo.humanReadableDescription,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  bool get _canSave {
    return _form.isValid && _formKey.currentState?.validate() == true;
  }

  void _saveRule() {
    if (_formKey.currentState?.validate() == true) {
      final rule = _form.toRule();
      widget.onSave(rule);
      Navigator.of(context).pop();
    }
  }
}