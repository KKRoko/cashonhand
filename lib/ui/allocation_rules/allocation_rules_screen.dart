import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../../data/models/freezed/auto_allocation_rule.dart';
import '../../data/models/enums/trigger_type.dart';
import '../../data/models/enums/allocation_method.dart';
import '../../services/category_service.dart';
import '../../services/auto_allocation_rules_engine.dart';
import '../../state/saving_goal_notifier.dart';
import '../dialogs/add_edit_allocation_rule_dialog.dart';

class AllocationRulesScreen extends StatefulWidget {
  static const routeName = '/allocation-rules';

  const AllocationRulesScreen({super.key});

  @override
  State<AllocationRulesScreen> createState() => _AllocationRulesScreenState();
}

class _AllocationRulesScreenState extends State<AllocationRulesScreen> {
  final Database _database = getIt<Database>();
  final CategoryService _categoryService = getIt<CategoryService>();
  final AutoAllocationRulesEngine _rulesEngine =
      getIt<AutoAllocationRulesEngine>();

  List<AutoAllocationRule> _rules = [];
  Map<int, String> _goalTitles = {};
  Map<int, String> _categoryNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load rules
      final rulesData = await _database.getAllAllocationRules();
      final rules = rulesData.map((data) => _convertToRule(data)).toList();

      // Load goal titles
      final goalNotifier = context.read<SavingGoalNotifier>();
      final goalTitles = <int, String>{};
      for (final goal in goalNotifier.goals) {
        goalTitles[goal.id!] = goal.title;
      }

      // Load category names
      final categoriesResult = await _categoryService.getCategories();
      final categoryNames = <int, String>{};
      categoriesResult.fold(
        (failure) => print('Error loading categories: ${failure.message}'),
        (categories) {
          for (final category in categories) {
            categoryNames[category.id] = category.name;
          }
        },
      );

      setState(() {
        _rules = rules;
        _goalTitles = goalTitles;
        _categoryNames = categoryNames;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading allocation rules: $e');
      setState(() => _isLoading = false);
    }
  }

  AutoAllocationRule _convertToRule(AutoAllocationRuleTableData data) {
    return AutoAllocationRule(
      id: data.id,
      goalId: data.goalId,
      ruleName: data.ruleName,
      triggerType: data.triggerType,
      triggerCategoryId: data.triggerCategoryId,
      allocationMethod: data.allocationMethod,
      allocationValue: data.allocationValue,
      minimumTriggerAmount: data.minimumTriggerAmount,
      maximumAllocationAmount: data.maximumAllocationAmount,
      isActive: data.isActive,
      description: data.description,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Allocation Rules'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Show help',
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _rules.isEmpty ? _buildEmptyState() : _buildRulesList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRuleDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Rule'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Auto-Allocation Rules',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create rules to automatically allocate money to your savings goals when you make transactions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateRuleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Rule'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rules.length,
      itemBuilder: (context, index) {
        final rule = _rules[index];
        return _buildRuleCard(rule);
      },
    );
  }

  Widget _buildRuleCard(AutoAllocationRule rule) {
    final goalTitle = _goalTitles[rule.goalId] ?? 'Unknown Goal';
    final categoryName = rule.triggerCategoryId != null
        ? _categoryNames[rule.triggerCategoryId!] ?? 'Unknown Category'
        : null;

    final ruleWithInfo = rule.withDisplayInfo(
      goalTitle: goalTitle,
      categoryName: categoryName,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Column(
        children: [
          // Header with rule name and status
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: rule.isActive ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Rule name and goal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.ruleName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.flag,
                              size: 16, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            goalTitle,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Allocation display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    ruleWithInfo.allocationValueDisplay,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Menu button
                PopupMenuButton<String>(
                  onSelected: (action) => _handleRuleAction(action, rule),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit Rule')),
                    PopupMenuItem(
                      value: rule.isActive ? 'disable' : 'enable',
                      child:
                          Text(rule.isActive ? 'Disable Rule' : 'Enable Rule'),
                    ),
                    const PopupMenuItem(
                        value: 'test', child: Text('Test Rule')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Delete Rule')),
                  ],
                ),
              ],
            ),
          ),

          // Rule description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Text(
                ruleWithInfo.humanReadableDescription,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateRuleDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEditAllocationRuleDialog(
        onSave: _createRule,
      ),
    );
  }

  void _showEditRuleDialog(AutoAllocationRule rule) {
    showDialog(
      context: context,
      builder: (context) => AddEditAllocationRuleDialog(
        existingRule: rule,
        onSave: _updateRule,
      ),
    );
  }

  Future<void> _createRule(AutoAllocationRule rule) async {
    try {
      final companion = AutoAllocationRulesCompanion.insert(
        goalId: rule.goalId,
        ruleName: rule.ruleName,
        triggerType: rule.triggerType,
        triggerCategoryId: drift.Value(rule.triggerCategoryId),
        allocationMethod: rule.allocationMethod,
        allocationValue: rule.allocationValue,
        minimumTriggerAmount: drift.Value(rule.minimumTriggerAmount),
        maximumAllocationAmount: drift.Value(rule.maximumAllocationAmount),
        isActive: drift.Value(rule.isActive),
        description: drift.Value(rule.description),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      );

      await _database.createAllocationRule(companion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rule "${rule.ruleName}" created successfully')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating rule: $e')),
        );
      }
    }
  }

  Future<void> _updateRule(AutoAllocationRule rule) async {
    try {
      final updatedData = AutoAllocationRuleTableData(
        id: rule.id!,
        goalId: rule.goalId,
        ruleName: rule.ruleName,
        triggerType: rule.triggerType,
        triggerCategoryId: rule.triggerCategoryId,
        allocationMethod: rule.allocationMethod,
        allocationValue: rule.allocationValue,
        minimumTriggerAmount: rule.minimumTriggerAmount,
        maximumAllocationAmount: rule.maximumAllocationAmount,
        isActive: rule.isActive,
        description: rule.description,
        createdAt: rule.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _database.updateAllocationRule(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Rule "${rule.ruleName}" updated successfully')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating rule: $e')),
        );
      }
    }
  }

  Future<void> _deleteRule(AutoAllocationRule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Rule'),
        content: Text(
            'Are you sure you want to delete the rule "${rule.ruleName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && rule.id != null) {
      try {
        await _database.deleteAllocationRule(rule.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Rule "${rule.ruleName}" deleted successfully')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting rule: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleRuleStatus(AutoAllocationRule rule) async {
    final updatedRule = rule.copyWith(isActive: !rule.isActive);
    await _updateRule(updatedRule);
  }

  void _showTestDialog(AutoAllocationRule rule) {
    // TODO: Implement rule testing dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rule testing feature coming soon!')),
    );
  }

  void _handleRuleAction(String action, AutoAllocationRule rule) {
    switch (action) {
      case 'edit':
        _showEditRuleDialog(rule);
        break;
      case 'enable':
      case 'disable':
        _toggleRuleStatus(rule);
        break;
      case 'test':
        _showTestDialog(rule);
        break;
      case 'delete':
        _deleteRule(rule);
        break;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-Allocation Rules'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Auto-allocation rules automatically move money to your savings goals when you make transactions.\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Examples:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Save 10% of all restaurant spending for vacation'),
              Text('• Put \$5 from every grocery trip into emergency fund'),
              Text('• Allocate 5% of income to retirement savings'),
              Text(
                  '\nRules run automatically when you add transactions and can save you time by eliminating manual allocations.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
