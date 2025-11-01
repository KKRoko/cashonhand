import 'package:flutter/material.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../data/repositories/saving_goal_repository.dart';
import '../../services/surplus_allocation_service.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';
import 'package:get_it/get_it.dart';

enum SurplusViewMode { category, bucket }

class SurplusAllocationItem {
  final int? categoryBudgetId; // null for bucket-level
  final BucketType bucketType;
  final String name;
  final double surplusAmount;
  int? selectedGoalId;
  double allocationAmount;

  SurplusAllocationItem({
    this.categoryBudgetId,
    required this.bucketType,
    required this.name,
    required this.surplusAmount,
    this.selectedGoalId,
    double? allocationAmount,
  }) : allocationAmount = allocationAmount ?? surplusAmount;
}

class SurplusAllocationScreen extends StatefulWidget {
  final BudgetNotifier budgetNotifier;

  const SurplusAllocationScreen({
    super.key,
    required this.budgetNotifier,
  });

  @override
  State<SurplusAllocationScreen> createState() => _SurplusAllocationScreenState();
}

class _SurplusAllocationScreenState extends State<SurplusAllocationScreen> {
  SurplusViewMode _viewMode = SurplusViewMode.category;
  final List<SurplusAllocationItem> _items = [];
  List<SavingGoal> _availableGoals = [];
  bool _isLoading = true;
  String? _error;

  final _surplusService = GetIt.instance<SurplusAllocationService>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load available goals
      final goalRepository = GetIt.instance.get<ISavingGoalRepository>();
      final goalsResult = await goalRepository.getActiveGoals();

      goalsResult.fold(
        (failure) {
          setState(() {
            _error = 'Failed to load savings goals: ${failure.message}';
            _isLoading = false;
          });
        },
        (goals) {
          setState(() {
            _availableGoals = goals;
            _buildSurplusItems();
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _buildSurplusItems() {
    _items.clear();

    if (_viewMode == SurplusViewMode.category) {
      // Category-level view
      final categorySurplus = widget.budgetNotifier.categorySurplus;

      for (final bucket in BucketType.values) {
        final categories = widget.budgetNotifier.categoryBudgets[bucket] ?? [];
        for (final category in categories) {
          final surplus = categorySurplus[category.id];
          if (surplus != null && surplus > 0) {
            _items.add(SurplusAllocationItem(
              categoryBudgetId: category.id,
              bucketType: bucket,
              name: category.categoryName ?? 'Unknown',
              surplusAmount: surplus,
            ));
          }
        }
      }
    } else {
      // Bucket-level view
      final bucketSurplus = widget.budgetNotifier.bucketSurplus;

      for (final entry in bucketSurplus.entries) {
        _items.add(SurplusAllocationItem(
          bucketType: entry.key,
          name: _getBucketLabel(entry.key),
          surplusAmount: entry.value,
        ));
      }
    }
  }

  String _getBucketLabel(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return Theme.of(context).colorScheme.primary;
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }

  double get _totalAllocated {
    return _items.fold<double>(0.0, (sum, item) {
      return sum + (item.selectedGoalId != null ? item.allocationAmount : 0.0);
    });
  }

  int get _itemsWithAllocations {
    return _items.where((item) => item.selectedGoalId != null).length;
  }

  Future<void> _allocateSurplus() async {
    // Validate
    if (_itemsWithAllocations == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one goal to allocate to')),
      );
      return;
    }

    final budget = widget.budgetNotifier.activeBudget;
    if (budget == null) return;

    // Validate total allocation doesn't exceed available surplus
    final availableSurplus = widget.budgetNotifier.availableSurplus;
    if (_totalAllocated > availableSurplus + 0.01) {  // 0.01 tolerance for floating point
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot allocate \$${_totalAllocated.toStringAsFixed(2)}. '
            'Only \$${availableSurplus.toStringAsFixed(2)} is available.'
          ),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
      return;
    }

    // Build allocation map (goalId -> totalAmount)
    final Map<int, double> goalAllocations = {};

    for (final item in _items) {
      if (item.selectedGoalId != null && item.allocationAmount > 0) {
        goalAllocations[item.selectedGoalId!] =
            (goalAllocations[item.selectedGoalId!] ?? 0.0) + item.allocationAmount;
      }
    }

    setState(() => _isLoading = true);

    final request = SurplusAllocationRequest(
      budgetId: budget.id,
      month: widget.budgetNotifier.selectedMonth.month,
      year: widget.budgetNotifier.selectedMonth.year,
      goalAllocations: goalAllocations,
      notes: 'Allocated via ${_viewMode == SurplusViewMode.category ? "category" : "bucket"} view',
    );

    final result = await _surplusService.allocateSurplus(request);

    result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to allocate surplus: ${failure.message}'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
      },
      (success) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully allocated \$${success.totalAllocated.toStringAsFixed(2)} to ${success.updatedGoals.length} goals',
              ),
              backgroundColor: DesignTokens.color('success'),
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocate Surplus'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _availableGoals.isEmpty
                  ? _buildNoGoalsState()
                  : Column(
                      children: [
                        _buildViewModeToggle(),
                        _buildSummaryCard(),
                        Expanded(child: _buildSurplusList()),
                        _buildBottomBar(),
                      ],
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: DesignTokens.color('error'),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGoalsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Savings Goals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a savings goal first to allocate your surplus budget',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: _buildViewModeButton('By Category', SurplusViewMode.category),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildViewModeButton('By Bucket', SurplusViewMode.bucket),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(String label, SurplusViewMode mode) {
    final isSelected = _viewMode == mode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = mode;
          _buildSurplusItems();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalSurplus = widget.budgetNotifier.totalSurplus;
    final allocatedSurplus = widget.budgetNotifier.allocatedSurplus;
    final availableSurplus = widget.budgetNotifier.availableSurplus;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Total unspent surplus
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Unspent:',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${totalSurplus.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.color('success'),
                ),
              ),
            ],
          ),

          // Already allocated to goals (if any)
          if (allocatedSurplus > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Already Allocated:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '-\$${allocatedSurplus.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available to Allocate:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '\$${availableSurplus.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],

          // User's pending allocation
          if (_totalAllocated > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'To Allocate Now:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${_totalAllocated.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.color('warning'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurplusList() {
    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No surplus available in ${_viewMode == SurplusViewMode.category ? "categories" : "buckets"}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildSurplusItem(_items[index]);
      },
    );
  }

  Widget _buildSurplusItem(SurplusAllocationItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and surplus amount
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getBucketColor(item.bucketType),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '\$${item.surplusAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.color('success'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Goal selector
            DropdownButtonFormField<int>(
              value: item.selectedGoalId,
              decoration: InputDecoration(
                labelText: 'Select Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('- No allocation -'),
                ),
                ..._availableGoals.map((goal) {
                  return DropdownMenuItem<int>(
                    value: goal.id,
                    child: Text(goal.title),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  item.selectedGoalId = value;
                  if (value == null) {
                    item.allocationAmount = item.surplusAmount;
                  }
                });
              },
            ),

            // Amount input (only if goal selected)
            if (item.selectedGoalId != null) ...[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: item.allocationAmount.toStringAsFixed(2),
                decoration: InputDecoration(
                  labelText: 'Allocation Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final amount = double.tryParse(value);
                  if (amount != null && amount >= 0 && amount <= item.surplusAmount) {
                    setState(() {
                      item.allocationAmount = amount;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_itemsWithAllocations > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Allocating to $_itemsWithAllocations goal${_itemsWithAllocations == 1 ? "" : "s"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _itemsWithAllocations > 0 ? _allocateSurplus : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _itemsWithAllocations > 0
                      ? 'Allocate \$${_totalAllocated.toStringAsFixed(2)}'
                      : 'Select goals to allocate',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
