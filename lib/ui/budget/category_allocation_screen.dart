import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/budget.dart';
import '../../data/models/freezed/category_budget.dart';
import '../../data/models/freezed/allocation_template.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/database/database.dart';
import '../../core/di/injection.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';
import '../../utils/category_helpers.dart';

class CategoryAllocationScreen extends StatefulWidget {
  final Budget budget;
  final BudgetNotifier budgetNotifier;

  const CategoryAllocationScreen({
    super.key,
    required this.budget,
    required this.budgetNotifier,
  });

  @override
  State<CategoryAllocationScreen> createState() =>
      _CategoryAllocationScreenState();
}

class _CategoryAllocationScreenState extends State<CategoryAllocationScreen> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, Timer?> _debounceTimers = {}; // Debounce timers for each field
  final Map<int, CategoryBudget> _pendingUpdates = {}; // Track pending updates
  final Map<int, CategoryTableData> _categoryCache =
      {}; // Cache category details including parent
  bool _hasUnsavedChanges = false;
  BucketType? _expandedBucket; // Track which bucket is currently expanded

  @override
  void initState() {
    super.initState();
    _loadCategoryDetails();
  }

  /// Load full category details to get parent information
  Future<void> _loadCategoryDetails() async {
    final database = getIt<Database>();
    final allCategories = await database.getAllCategories();

    for (final category in allCategories) {
      _categoryCache[category.id] = category;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // Flush all pending updates before disposing
    _flushPendingUpdates();

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  /// Immediately process all pending debounced updates
  void _flushPendingUpdates() {
    for (final entry in _pendingUpdates.entries) {
      final categoryBudgetId = entry.key;
      final categoryBudget = entry.value;

      // Cancel the timer and immediately update
      _debounceTimers[categoryBudgetId]?.cancel();

      // Get the current value from the controller
      final controller = _controllers[categoryBudgetId];
      if (controller != null) {
        final amount = double.tryParse(controller.text) ?? 0.0;
        _updateCategoryBudget(categoryBudget, amount);
      }
    }
    _pendingUpdates.clear();
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

  Widget _buildAlertBadge(AlertLevel level) {
    final isCritical = level == AlertLevel.critical;
    final color = isCritical
        ? DesignTokens.color('error')
        : DesignTokens.color('warning');
    final icon = isCritical ? Icons.error : Icons.warning;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  void _updateCategoryBudget(
      CategoryBudget categoryBudget, double newAmount) async {
    print(
        '💰 BUDGET UPDATE: Updating ${categoryBudget.categoryName} to \$$newAmount');
    final updated = categoryBudget.copyWith(allocatedAmount: newAmount);
    final success = await widget.budgetNotifier.updateCategoryBudget(updated);
    print('💰 BUDGET UPDATE: Success=$success');
    setState(() {
      _hasUnsavedChanges = false;
    });
  }

  void _moveCategoryToBucket(
      CategoryBudget categoryBudget, BucketType newBucket) async {
    await widget.budgetNotifier.moveCategoryToBucket(categoryBudget, newBucket);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Moved ${categoryBudget.categoryName} to ${_getBucketLabel(newBucket)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show dialog to load and apply a saved allocation template
  Future<void> _showLoadTemplateDialog() async {
    // Load templates if not already loaded
    if (!widget.budgetNotifier.templatesLoaded) {
      await widget.budgetNotifier.loadTemplates();
    }

    if (!mounted) return;

    final templates = widget.budgetNotifier.templates;

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved templates found'),
        ),
      );
      return;
    }

    final selectedTemplate = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _LoadTemplateDialogContent(
        templates: templates,
        budgetNotifier: widget.budgetNotifier,
      ),
    );

    if (selectedTemplate != null && mounted) {
      final success =
          await widget.budgetNotifier.applyTemplate(selectedTemplate);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template applied successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  widget.budgetNotifier.error ?? 'Failed to apply template'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Show dialog to save current allocations as a template
  Future<void> _showSaveTemplateDialog() async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const _SaveTemplateDialogContent(),
    );

    if (result != null && mounted) {
      final success = await widget.budgetNotifier.saveAsTemplate(
        result['name']!,
        description:
            result['description']!.isEmpty ? null : result['description'],
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  widget.budgetNotifier.error ?? 'Failed to save template'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.budgetNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Allocate Budget'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Load Template',
              onPressed: _showLoadTemplateDialog,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Save as Template',
              onPressed: _showSaveTemplateDialog,
            ),
          ],
        ),
        body: Consumer<BudgetNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                // Monthly Budget Header - Always Sticky
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _MonthlyBudgetHeaderDelegate(
                    budget: widget.budget,
                    context: context,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // Needs Bucket - Sticky only when expanded
                _buildStickyBucketHeader(
                  BucketType.needs,
                  notifier.categoryBudgets[BucketType.needs] ?? [],
                  isSticky: _expandedBucket == BucketType.needs,
                ),
                // Needs Categories (if expanded)
                if (_expandedBucket == BucketType.needs)
                  _buildCategoryList(
                    notifier.categoryBudgets[BucketType.needs] ?? [],
                    BucketType.needs,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Wants Bucket - Sticky only when expanded
                _buildStickyBucketHeader(
                  BucketType.wants,
                  notifier.categoryBudgets[BucketType.wants] ?? [],
                  isSticky: _expandedBucket == BucketType.wants,
                ),
                // Wants Categories (if expanded)
                if (_expandedBucket == BucketType.wants)
                  _buildCategoryList(
                    notifier.categoryBudgets[BucketType.wants] ?? [],
                    BucketType.wants,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Savings Bucket - Sticky only when expanded
                _buildStickyBucketHeader(
                  BucketType.savings,
                  notifier.categoryBudgets[BucketType.savings] ?? [],
                  isSticky: _expandedBucket == BucketType.savings,
                ),
                // Savings Categories (if expanded)
                if (_expandedBucket == BucketType.savings)
                  _buildCategoryList(
                    notifier.categoryBudgets[BucketType.savings] ?? [],
                    BucketType.savings,
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['md']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Budget',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${widget.budget.monthlyIncome.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildStickyBucketHeader(
      BucketType bucket, List<CategoryBudget> categories,
      {required bool isSticky}) {
    return SliverPersistentHeader(
      pinned: isSticky,
      delegate: _BucketHeaderDelegate(
        bucket: bucket,
        categories: categories,
        budget: widget.budget,
        budgetNotifier: widget.budgetNotifier,
        isExpanded: _expandedBucket == bucket,
        onTap: () {
          setState(() {
            _expandedBucket = _expandedBucket == bucket ? null : bucket;
          });
        },
        getBucketColor: _getBucketColor,
        getBucketLabel: _getBucketLabel,
        getBucketDescription: _getBucketDescription,
        context: context,
      ),
    );
  }

  Widget _buildCategoryList(
      List<CategoryBudget> categories, BucketType bucket) {
    if (categories.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No categories in this bucket',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCategoryItem(categories[index], bucket),
          );
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildBucketHeader(
      BucketType bucket, List<CategoryBudget> categories) {
    final budgetAmount =
        widget.budget.getBucketAmount(bucket.toString().split('.').last);
    final allocated = widget.budgetNotifier.getTotalAllocatedForBucket(bucket);
    final unallocated = budgetAmount - allocated;
    final isOverAllocated = unallocated < -0.01;
    final isFullyAllocated = unallocated.abs() < 0.01;
    final isExpanded = _expandedBucket == bucket;

    return InkWell(
      onTap: () {
        setState(() {
          _expandedBucket = isExpanded ? null : bucket;
        });
      },
      borderRadius: DesignTokens.borderRadius['md']!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBucketColor(bucket).withOpacity(0.1),
          border: Border.all(
            color: _getBucketColor(bucket).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: DesignTokens.borderRadius['md']!,
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
                  child: Icon(Icons.category,
                      color: Theme.of(context).colorScheme.onPrimary, size: 18),
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _getBucketDescription(bucket),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Allocated: \$${allocated.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: budgetAmount > 0
                        ? (allocated / budgetAmount).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor:
                        Theme.of(context).colorScheme.outlineVariant,
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
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBucketSection(
      BucketType bucket, List<CategoryBudget> categories) {
    final budgetAmount =
        widget.budget.getBucketAmount(bucket.toString().split('.').last);
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
        borderRadius: DesignTokens.borderRadius['md']!,
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
                        child: Icon(Icons.category,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 18),
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              _getBucketDescription(bucket),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Allocated: \$${allocated.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: budgetAmount > 0
                              ? (allocated / budgetAmount).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor:
                              Theme.of(context).colorScheme.outlineVariant,
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
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...categories.map((categoryBudget) =>
                  _buildCategoryItem(categoryBudget, bucket)),
          ],
        ],
      ),
    );
  }

  /// Build parent category badge
  Widget? _buildParentBadge(int categoryId) {
    final category = _categoryCache[categoryId];
    if (category == null || category.parentCategoryId == null) {
      return null;
    }

    final parentCategory = _categoryCache[category.parentCategoryId!];
    if (parentCategory == null) {
      return null;
    }

    final parentColor =
        CategoryHelpers.getParentCategoryColor(parentCategory.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: parentColor, width: 1.5),
        borderRadius: DesignTokens.borderRadius['xs']!,
        color: parentColor.withOpacity(0.1),
      ),
      child: Text(
        parentCategory.name,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: parentColor,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      CategoryBudget categoryBudget, BucketType currentBucket) {
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
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category name and amount input on same line
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryBudget.categoryName ?? 'Unknown Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                // Alert badge
                if (widget.budgetNotifier
                            .categoryAlertLevels[categoryBudget.id] !=
                        null &&
                    widget.budgetNotifier
                            .categoryAlertLevels[categoryBudget.id] !=
                        AlertLevel.none) ...[
                  _buildAlertBadge(widget
                      .budgetNotifier.categoryAlertLevels[categoryBudget.id]!),
                  const SizedBox(width: 8),
                ],
                Semantics(
                  label:
                      'Budget amount for ${categoryBudget.categoryName ?? "Unknown Category"}',
                  child: SizedBox(
                    width: 100,
                    child: TextField(
                      controller: _controllers[categoryBudget.id],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: DesignTokens.borderRadius['sm']!,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: DesignTokens.borderRadius['sm']!,
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: DesignTokens.borderRadius['sm']!,
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        print(
                            '⌨️ INPUT: User typed "$value" for ${categoryBudget.categoryName}');

                        // Track this as a pending update
                        _pendingUpdates[categoryBudget.id] = categoryBudget;

                        // Cancel previous timer for this field
                        _debounceTimers[categoryBudget.id]?.cancel();

                        // Set new timer to update after 500ms of no typing
                        _debounceTimers[categoryBudget.id] =
                            Timer(const Duration(milliseconds: 500), () {
                          final amount = double.tryParse(value) ?? 0.0;
                          print(
                              '⏰ DEBOUNCE: Timer fired, updating to \$$amount');
                          _updateCategoryBudget(categoryBudget, amount);
                          // Remove from pending since it's now processed
                          _pendingUpdates.remove(categoryBudget.id);
                        });

                        setState(() {
                          _hasUnsavedChanges = true;
                        });
                      },
                      onSubmitted: (value) {
                        print('⏎ SUBMIT: User pressed enter with "$value"');
                        // Cancel debounce timer since we're submitting immediately
                        _debounceTimers[categoryBudget.id]?.cancel();
                        // Remove from pending since we're submitting now
                        _pendingUpdates.remove(categoryBudget.id);

                        final amount = double.tryParse(value) ?? 0.0;
                        _updateCategoryBudget(categoryBudget, amount);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<BucketType>(
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
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
                          Icon(Icons.home,
                              color: _getBucketColor(BucketType.needs),
                              size: 20),
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
                          Icon(Icons.favorite,
                              color: _getBucketColor(BucketType.wants),
                              size: 20),
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
                          Icon(Icons.savings,
                              color: _getBucketColor(BucketType.savings),
                              size: 20),
                          const SizedBox(width: 12),
                          Text('Move to Savings'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Parent badge below the name
            if (_buildParentBadge(categoryBudget.categoryId) != null) ...[
              const SizedBox(height: 8),
              _buildParentBadge(categoryBudget.categoryId)!,
            ],
            // Weekly/Yearly info at the bottom
            const SizedBox(height: 4),
            Text(
              'Weekly: \$${categoryBudget.weeklyAmount.toStringAsFixed(0)} • Yearly: \$${categoryBudget.yearlyAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delegate for sticky monthly budget header
class _MonthlyBudgetHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Budget budget;
  final BuildContext context;

  _MonthlyBudgetHeaderDelegate({
    required this.budget,
    required this.context,
  });

  @override
  double get minExtent => 180.0;

  @override
  double get maxExtent => 180.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadius['md']!,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${budget.monthlyIncome.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBudgetSummaryItem(
                    'Needs',
                    budget.needsAmount,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildBudgetSummaryItem(
                    'Wants',
                    budget.wantsAmount,
                    DesignTokens.color('info'),
                  ),
                ),
                Expanded(
                  child: _buildBudgetSummaryItem(
                    'Savings',
                    budget.savingsAmount,
                    DesignTokens.color('warning'),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  @override
  bool shouldRebuild(_MonthlyBudgetHeaderDelegate oldDelegate) {
    return budget.monthlyIncome != oldDelegate.budget.monthlyIncome ||
        budget.needsAmount != oldDelegate.budget.needsAmount ||
        budget.wantsAmount != oldDelegate.budget.wantsAmount ||
        budget.savingsAmount != oldDelegate.budget.savingsAmount;
  }
}

/// Delegate for sticky bucket headers
class _BucketHeaderDelegate extends SliverPersistentHeaderDelegate {
  final BucketType bucket;
  final List<CategoryBudget> categories;
  final Budget budget;
  final BudgetNotifier budgetNotifier;
  final bool isExpanded;
  final VoidCallback onTap;
  final Color Function(BucketType) getBucketColor;
  final String Function(BucketType) getBucketLabel;
  final String Function(BucketType) getBucketDescription;
  final BuildContext context;
  final double allocatedAmount; // Store the computed value

  _BucketHeaderDelegate({
    required this.bucket,
    required this.categories,
    required this.budget,
    required this.budgetNotifier,
    required this.isExpanded,
    required this.onTap,
    required this.getBucketColor,
    required this.getBucketLabel,
    required this.getBucketDescription,
    required this.context,
  }) : allocatedAmount = budgetNotifier.getTotalAllocatedForBucket(bucket);

  @override
  double get minExtent => 160.0; // Minimum height when collapsed

  @override
  double get maxExtent =>
      160.0; // Maximum height (same as min for fixed height)

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final budgetAmount =
        budget.getBucketAmount(bucket.toString().split('.').last);
    final allocated = allocatedAmount; // Use stored value
    final unallocated = budgetAmount - allocated;
    final isOverAllocated = unallocated < -0.01;
    final isFullyAllocated = unallocated.abs() < 0.01;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: DesignTokens.borderRadius['md']!,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getBucketColor(bucket).withOpacity(0.1),
            border: Border.all(
              color: getBucketColor(bucket).withOpacity(0.3),
              width: 2,
            ),
            borderRadius: DesignTokens.borderRadius['md']!,
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
                      color: getBucketColor(bucket),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.category,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getBucketLabel(bucket),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          getBucketDescription(bucket),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Allocated: \$${allocated.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: budgetAmount > 0
                          ? (allocated / budgetAmount).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor:
                          Theme.of(context).colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation(
                        isOverAllocated
                            ? DesignTokens.color('error')
                            : isFullyAllocated
                                ? DesignTokens.color('success')
                                : getBucketColor(bucket),
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
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_BucketHeaderDelegate oldDelegate) {
    return bucket != oldDelegate.bucket ||
        isExpanded != oldDelegate.isExpanded ||
        categories.length != oldDelegate.categories.length ||
        allocatedAmount != oldDelegate.allocatedAmount; // Compare stored values
  }
}

/// Separate stateful dialog for saving allocation templates
class _SaveTemplateDialogContent extends StatefulWidget {
  const _SaveTemplateDialogContent();

  @override
  State<_SaveTemplateDialogContent> createState() =>
      _SaveTemplateDialogContentState();
}

class _SaveTemplateDialogContentState
    extends State<_SaveTemplateDialogContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save as Template'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Template Name',
                hintText: 'e.g., Standard Monthly Budget',
                errorText: _errorMessage,
              ),
              autofocus: true,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., My typical monthly spending',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Template name is required');
      return;
    }

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
  }
}

/// Dialog for loading and applying saved allocation templates
/// Supports swipe-to-delete gesture for removing templates
class _LoadTemplateDialogContent extends StatefulWidget {
  final List<AllocationTemplate> templates;
  final BudgetNotifier budgetNotifier;

  const _LoadTemplateDialogContent({
    required this.templates,
    required this.budgetNotifier,
  });

  @override
  State<_LoadTemplateDialogContent> createState() =>
      _LoadTemplateDialogContentState();
}

class _LoadTemplateDialogContentState
    extends State<_LoadTemplateDialogContent> {
  late List<AllocationTemplate> _localTemplates;

  @override
  void initState() {
    super.initState();
    // Create a local copy of templates so we can update UI immediately on delete
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
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to delete template: ${widget.budgetNotifier.error ?? "Unknown error"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load Template'),
      content: _localTemplates.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No templates available'),
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
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteTemplate(template);
                    },
                    child: ListTile(
                      title: Text(
                        template.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (template.description != null &&
                              template.description!.isNotEmpty)
                            Text(template.description!),
                          const SizedBox(height: 4),
                          Text(
                            'Total: \$${template.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).pop(template.id),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
