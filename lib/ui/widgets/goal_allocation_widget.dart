import '../../theme/design_tokens.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/database/database.dart';
import '../../data/models/freezed/goal_allocation.dart';
import '../../data/models/enums/allocation_type.dart';

class GoalAllocationWidget extends StatefulWidget {
  final List<SavingGoalTableData> availableGoals;
  final List<GoalAllocation> currentAllocations;
  final double transactionAmount;
  final bool isIncome;
  final Function(List<GoalAllocation>) onAllocationsChanged;

  const GoalAllocationWidget({
    super.key,
    required this.availableGoals,
    required this.currentAllocations,
    required this.transactionAmount,
    required this.isIncome,
    required this.onAllocationsChanged,
  });

  @override
  State<GoalAllocationWidget> createState() => _GoalAllocationWidgetState();
}

class _GoalAllocationWidgetState extends State<GoalAllocationWidget> {
  late List<GoalAllocation> _allocations;
  bool _isExpanded = false;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _allocations = List.from(widget.currentAllocations);
    _initializeControllers();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    for (int i = 0; i < _allocations.length; i++) {
      if (!_controllers.containsKey(i)) {
        _controllers[i] = TextEditingController(
            text: _allocations[i].allocationAmount.toStringAsFixed(2));
      }
    }
  }

  double get _totalAllocated {
    return _allocations.fold(
        0.0, (sum, allocation) => sum + allocation.allocationAmount);
  }

  double get _remainingAmount {
    return widget.transactionAmount - _totalAllocated;
  }

  void _addAllocation(SavingGoalTableData goal) {
    final suggestedAmount = _getSuggestedAmount();
    final allocation = GoalAllocation(
      id: null,
      eventId: 0,
      goalId: goal.id,
      allocationAmount: suggestedAmount,
      allocationType: AllocationType.manual,
      goalTitle: goal.title,
    );

    setState(() {
      _allocations.add(allocation);
      // Create controller for new allocation
      final newIndex = _allocations.length - 1;
      _controllers[newIndex] =
          TextEditingController(text: suggestedAmount.toStringAsFixed(2));
    });
    widget.onAllocationsChanged(_allocations);
  }

  void _updateAllocation(int index, double amount) {
    if (amount >= 0) {
      // Allow any positive amount, show negative remaining as warning
      setState(() {
        _allocations[index] =
            _allocations[index].copyWith(allocationAmount: amount);
      });
      widget.onAllocationsChanged(_allocations);
      print(
          "Debug: Updated allocation $index to \$${amount.toStringAsFixed(2)}, remaining: \$${_remainingAmount.toStringAsFixed(2)}");
    }
  }

  void _removeAllocation(int index) {
    setState(() {
      _allocations.removeAt(index);
      // Dispose and remove controller
      _controllers[index]?.dispose();
      _controllers.remove(index);

      // Re-index remaining controllers
      final remainingControllers = <int, TextEditingController>{};
      for (int i = 0; i < _allocations.length; i++) {
        if (_controllers.containsKey(i < index ? i : i + 1)) {
          remainingControllers[i] = _controllers[i < index ? i : i + 1]!;
        }
      }
      _controllers.clear();
      _controllers.addAll(remainingControllers);
    });
    widget.onAllocationsChanged(_allocations);
  }

  double _getSuggestedAmount() {
    final remaining = _remainingAmount;
    if (widget.isIncome && remaining > 50) {
      // Suggest 10% for income over $50 remaining
      return (remaining * 0.1).roundToDouble();
    } else if (remaining > 10) {
      // Suggest $10 or 25% of remaining, whichever is smaller
      return (remaining * 0.25).clamp(5.0, 50.0).roundToDouble();
    }
    return 5.0;
  }

  Widget _buildQuickAllocateButton() {
    if (widget.availableGoals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: _showQuickAllocateOptions,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.color('success').withOpacity(0.1),
          foregroundColor: DesignTokens.color('success'),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.flash_on, size: 20),
        label: Text(
          widget.isIncome ? 'Quick Save from Income' : 'Round-up to Save',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showQuickAllocateOptions() {
    final quickOptions = <String, double>{};

    if (widget.isIncome) {
      quickOptions['10% to Emergency Fund'] = widget.transactionAmount * 0.1;
      quickOptions['5% to Each Goal'] = widget.transactionAmount * 0.05;
      quickOptions['20% Split Evenly'] =
          widget.transactionAmount * 0.2 / widget.availableGoals.length;
    } else {
      final roundUp =
          widget.transactionAmount.ceilToDouble() - widget.transactionAmount;
      if (roundUp > 0) {
        quickOptions['Round-up (\$${roundUp.toStringAsFixed(2)})'] = roundUp;
      }
      quickOptions['\$5 to First Goal'] = 5.0;
      quickOptions['\$10 Split Evenly'] = 10.0 / widget.availableGoals.length;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _buildQuickAllocateSheet(quickOptions),
    );
  }

  Widget _buildQuickAllocateSheet(Map<String, double> options) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quick Allocate',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...options.entries.map((entry) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(entry.key),
                  trailing: Text(
                    '\$${(entry.value * widget.availableGoals.length).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _applyQuickAllocate(entry.value);
                  },
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _applyQuickAllocate(double amountPerGoal) {
    setState(() {
      _allocations.clear();
      for (final goal in widget.availableGoals) {
        if (amountPerGoal > 0) {
          final allocation = GoalAllocation(
            id: null,
            eventId: 0,
            goalId: goal.id,
            allocationAmount: amountPerGoal,
            allocationType: AllocationType.manual,
            goalTitle: goal.title,
          );
          _allocations.add(allocation);
        }
      }
    });
    widget.onAllocationsChanged(_allocations);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // Header with expand/collapse
          ListTile(
            leading: Icon(
              Icons.savings,
              color: _allocations.isEmpty
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : DesignTokens.color('success'),
            ),
            title: const Text(
              'Allocate to Savings Goals',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: _allocations.isNotEmpty
                ? Text(
                    '${_allocations.length} allocations • \$${_totalAllocated.toStringAsFixed(2)} total',
                  )
                : const Text(
                    'Add allocations to your savings goals',
                  ),
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              tooltip: _isExpanded ? 'Collapse' : 'Expand',
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Quick allocate button
                  _buildQuickAllocateButton(),

                  // Current allocations list
                  if (_allocations.isNotEmpty) ...[
                    ...List.generate(_allocations.length, (index) {
                      final allocation = _allocations[index];
                      return _buildAllocationItem(allocation, index);
                    }),
                    const Divider(),
                  ],

                  // Available goals to add
                  if (_availableGoalsToAdd.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableGoalsToAdd
                          .map((goal) => ActionChip(
                                avatar: const Icon(
                                  Icons.add,
                                  size: 18,
                                ),
                                label: Text(goal.title),
                                onPressed: () => _addAllocation(goal),
                              ))
                          .toList(),
                    ),
                  ],

                  // Summary
                  if (_allocations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: DesignTokens.borderRadius['sm']!,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Remaining:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '\$${_remainingAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _remainingAmount < 0
                                  ? DesignTokens.color('error')
                                  : DesignTokens.color('success'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllocationItem(GoalAllocation allocation, int index) {
    // Get or create controller for this index
    if (!_controllers.containsKey(index)) {
      _controllers[index] = TextEditingController(
          text: allocation.allocationAmount.toStringAsFixed(2));
    }
    final controller = _controllers[index]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              allocation.goalTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              decoration: const InputDecoration(
                prefixText: '\$',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                _updateAllocation(index, amount);
              },
              onSubmitted: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                _updateAllocation(index, amount);
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
            ),
            tooltip: 'Remove allocation',
            onPressed: () => _removeAllocation(index),
          ),
        ],
      ),
    );
  }

  List<SavingGoalTableData> get _availableGoalsToAdd {
    final allocatedGoalIds = _allocations.map((a) => a.goalId).toSet();
    return widget.availableGoals
        .where((goal) => !allocatedGoalIds.contains(goal.id))
        .toList();
  }
}
