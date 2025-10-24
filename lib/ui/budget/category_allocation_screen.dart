import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/budget.dart';
import '../../data/models/freezed/category_budget.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';

class CategoryAllocationScreen extends StatefulWidget {
  final Budget budget;
  final BudgetNotifier budgetNotifier;

  const CategoryAllocationScreen({
    super.key,
    required this.budget,
    required this.budgetNotifier,
  });

  @override
  State<CategoryAllocationScreen> createState() => _CategoryAllocationScreenState();
}

class _CategoryAllocationScreenState extends State<CategoryAllocationScreen> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, Timer?> _debounceTimers = {}; // Debounce timers for each field
  bool _hasUnsavedChanges = false;
  BucketType? _expandedBucket; // Track which bucket is currently expanded

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return DesignTokens.color('primary');
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
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

  String _getBucketDescription(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Essential expenses (housing, utilities, groceries)';
      case BucketType.wants:
        return 'Discretionary spending (entertainment, dining out)';
      case BucketType.savings:
        return 'Long-term goals (savings, investments, debt)';
    }
  }

  void _updateCategoryBudget(CategoryBudget categoryBudget, double newAmount) async {
    print('💰 BUDGET UPDATE: Updating ${categoryBudget.categoryName} to \$$newAmount');
    final updated = categoryBudget.copyWith(allocatedAmount: newAmount);
    final success = await widget.budgetNotifier.updateCategoryBudget(updated);
    print('💰 BUDGET UPDATE: Success=$success');
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  void _moveCategoryToBucket(CategoryBudget categoryBudget, BucketType newBucket) async {
    await widget.budgetNotifier.moveCategoryToBucket(categoryBudget, newBucket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved ${categoryBudget.categoryName} to ${_getBucketLabel(newBucket)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.budgetNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Allocate Budget'),
          backgroundColor: DesignTokens.color('surface'),
          elevation: 0,
        ),
        body: Consumer<BudgetNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  _buildHeaderCard(),
                  const SizedBox(height: 24),

                  // Needs Bucket
                  _buildBucketSection(
                    BucketType.needs,
                    notifier.categoryBudgets[BucketType.needs] ?? [],
                  ),
                  const SizedBox(height: 16),

                  // Wants Bucket
                  _buildBucketSection(
                    BucketType.wants,
                    notifier.categoryBudgets[BucketType.wants] ?? [],
                  ),
                  const SizedBox(height: 16),

                  // Savings Bucket
                  _buildBucketSection(
                    BucketType.savings,
                    notifier.categoryBudgets[BucketType.savings] ?? [],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.color('surfaceVariant'),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Budget',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.color('textSecondary'),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${widget.budget.monthlyIncome.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('textPrimary'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBudgetSummaryItem(
                  'Needs',
                  widget.budget.needsAmount,
                  _getBucketColor(BucketType.needs),
                ),
              ),
              Expanded(
                child: _buildBudgetSummaryItem(
                  'Wants',
                  widget.budget.wantsAmount,
                  _getBucketColor(BucketType.wants),
                ),
              ),
              Expanded(
                child: _buildBudgetSummaryItem(
                  'Savings',
                  widget.budget.savingsAmount,
                  _getBucketColor(BucketType.savings),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DesignTokens.color('textSecondary'),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBucketSection(BucketType bucket, List<CategoryBudget> categories) {
    final budgetAmount = widget.budget.getBucketAmount(bucket.toString().split('.').last);
    final allocated = widget.budgetNotifier.getTotalAllocatedForBucket(bucket);
    final unallocated = budgetAmount - allocated;
    final isOverAllocated = unallocated < -0.01;
    final isFullyAllocated = unallocated.abs() < 0.01;
    final isExpanded = _expandedBucket == bucket;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBucketColor(bucket).withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bucket Header - Now tappable
          InkWell(
            onTap: () {
              setState(() {
                // Toggle: if clicking on already expanded bucket, collapse it; otherwise expand new bucket
                _expandedBucket = isExpanded ? null : bucket;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBucketColor(bucket).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getBucketColor(bucket),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.category, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getBucketLabel(bucket),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: DesignTokens.color('textPrimary'),
                            ),
                          ),
                          Text(
                            _getBucketDescription(bucket),
                            style: TextStyle(
                              fontSize: 12,
                              color: DesignTokens.color('textSecondary'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: DesignTokens.color('textSecondary'),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: \$${budgetAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.color('textPrimary'),
                      ),
                    ),
                    Text(
                      'Allocated: \$${allocated.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.color('textPrimary'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: budgetAmount > 0 ? (allocated / budgetAmount).clamp(0.0, 1.0) : 0.0,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          isOverAllocated
                              ? DesignTokens.color('error')
                              : isFullyAllocated
                                  ? DesignTokens.color('success')
                                  : _getBucketColor(bucket),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isOverAllocated
                          ? 'Over by \$${(-unallocated).toStringAsFixed(0)}'
                          : isFullyAllocated
                              ? 'Fully allocated'
                              : '\$${unallocated.toStringAsFixed(0)} left',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverAllocated
                            ? DesignTokens.color('error')
                            : isFullyAllocated
                                ? DesignTokens.color('success')
                                : DesignTokens.color('textSecondary'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),

          // Category List - Only show when expanded
          if (isExpanded) ...[
            if (categories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No categories in this bucket',
                    style: TextStyle(
                      fontSize: 14,
                      color: DesignTokens.color('textSecondary'),
                    ),
                  ),
                ),
              )
            else
              ...categories.map((categoryBudget) => _buildCategoryItem(categoryBudget, bucket)),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryItem(CategoryBudget categoryBudget, BucketType currentBucket) {
    if (!_controllers.containsKey(categoryBudget.id)) {
      _controllers[categoryBudget.id] = TextEditingController(
        text: categoryBudget.allocatedAmount > 0
            ? categoryBudget.allocatedAmount.toStringAsFixed(0)
            : '',
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          categoryBudget.categoryName ?? 'Unknown Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: DesignTokens.color('textPrimary'),
          ),
        ),
        subtitle: Text(
          'Weekly: \$${categoryBudget.weeklyAmount.toStringAsFixed(0)} • Yearly: \$${categoryBudget.yearlyAmount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            color: DesignTokens.color('textSecondary'),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              child: TextField(
                controller: _controllers[categoryBudget.id],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  print('⌨️ INPUT: User typed "$value" for ${categoryBudget.categoryName}');

                  // Cancel previous timer for this field
                  _debounceTimers[categoryBudget.id]?.cancel();

                  // Set new timer to update after 500ms of no typing
                  _debounceTimers[categoryBudget.id] = Timer(const Duration(milliseconds: 500), () {
                    final amount = double.tryParse(value) ?? 0.0;
                    print('⏰ DEBOUNCE: Timer fired, updating to \$$amount');
                    _updateCategoryBudget(categoryBudget, amount);
                  });

                  setState(() {
                    _hasUnsavedChanges = true;
                  });
                },
                onSubmitted: (value) {
                  print('⏎ SUBMIT: User pressed enter with "$value"');
                  // Cancel debounce timer since we're submitting immediately
                  _debounceTimers[categoryBudget.id]?.cancel();

                  final amount = double.tryParse(value) ?? 0.0;
                  _updateCategoryBudget(categoryBudget, amount);
                },
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<BucketType>(
              icon: Icon(Icons.more_vert, color: DesignTokens.color('textSecondary')),
              onSelected: (bucket) {
                if (bucket != currentBucket) {
                  _moveCategoryToBucket(categoryBudget, bucket);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: BucketType.needs,
                  enabled: currentBucket != BucketType.needs,
                  child: Row(
                    children: [
                      Icon(Icons.home, color: _getBucketColor(BucketType.needs), size: 20),
                      const SizedBox(width: 12),
                      Text('Move to Needs'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: BucketType.wants,
                  enabled: currentBucket != BucketType.wants,
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: _getBucketColor(BucketType.wants), size: 20),
                      const SizedBox(width: 12),
                      Text('Move to Wants'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: BucketType.savings,
                  enabled: currentBucket != BucketType.savings,
                  child: Row(
                    children: [
                      Icon(Icons.savings, color: _getBucketColor(BucketType.savings), size: 20),
                      const SizedBox(width: 12),
                      Text('Move to Savings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
