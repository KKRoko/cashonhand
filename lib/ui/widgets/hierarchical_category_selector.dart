import '../../theme/design_tokens.dart';

import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../core/di/injection.dart';
import '../../utils/category_helpers.dart';
import '../../services/budget_service.dart';

class HierarchicalCategorySelector extends StatefulWidget {
  final CategoryType categoryType;
  final CategoryTableData? selectedCategory;
  final Function(CategoryTableData) onCategorySelected;
  final VoidCallback? onClose;

  const HierarchicalCategorySelector({
    super.key,
    required this.categoryType,
    this.selectedCategory,
    required this.onCategorySelected,
    this.onClose,
  });

  @override
  State<HierarchicalCategorySelector> createState() =>
      _HierarchicalCategorySelectorState();
}

class _HierarchicalCategorySelectorState
    extends State<HierarchicalCategorySelector> {
  List<CategoryTableData> _mainCategories = [];
  List<CategoryTableData> _subcategories = [];
  CategoryTableData? _selectedMainCategory;
  Map<int, BucketType> _categoryBuckets = {}; // Maps category ID to bucket type
  Map<int, CategoryTableData> _categoryCache =
      {}; // Cache all categories for parent lookup
  Map<int, double> _categoryAllocations =
      {}; // Maps category ID to allocated amount
  Map<int, int> _categoryUsageCount = {}; // Maps category ID to usage frequency
  bool _isLoading = true;
  bool _showSubcategories = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load categories and their bucket assignments
  Future<void> _loadCategoryData() async {
    await _loadMainCategories();
    await _loadBucketAssignments();
    await _loadCategoryAllocations();
    await _loadCategoryUsage();
  }

  /// Load bucket type assignments for categories
  Future<void> _loadBucketAssignments() async {
    try {
      final budgetService = getIt<BudgetService>();
      final database = getIt<Database>();

      // Load all categories for parent lookup
      final allCategories = await database.getAllCategories();
      for (final category in allCategories) {
        _categoryCache[category.id] = category;
      }

      // Try to get active budget
      final activeBudgetResult = await budgetService.getActiveBudget();

      activeBudgetResult.fold(
        (failure) {
          // No active budget - use default bucket types based on parent
          print('No active budget, using default bucket types');
          _useDefaultBucketTypes();
        },
        (budget) async {
          if (budget == null) {
            _useDefaultBucketTypes();
            return;
          }

          // Load category budgets to get actual bucket assignments
          final categoryBudgetsResult =
              await budgetService.getCategoryBudgetsByBucket(budget.id);

          categoryBudgetsResult.fold(
            (failure) => _useDefaultBucketTypes(),
            (grouped) {
              // Map category IDs to their assigned bucket types
              for (final entry in grouped.entries) {
                final bucketType = entry.key;
                final categoryBudgets = entry.value;
                for (final cb in categoryBudgets) {
                  _categoryBuckets[cb.categoryId] = bucketType;
                }
              }

              // For categories not in budget, use default
              for (final category in _categoryCache.values) {
                if (!_categoryBuckets.containsKey(category.id)) {
                  final parentCategory = category.parentCategoryId != null
                      ? _categoryCache[category.parentCategoryId]
                      : null;
                  if (parentCategory != null) {
                    _categoryBuckets[category.id] =
                        CategoryHelpers.getDefaultBucketType(
                            parentCategory.name);
                  }
                }
              }

              if (mounted) setState(() {});
            },
          );
        },
      );
    } catch (e) {
      print('Error loading bucket assignments: $e');
      _useDefaultBucketTypes();
    }
  }

  /// Use default bucket types based on parent category
  void _useDefaultBucketTypes() {
    for (final category in _categoryCache.values) {
      final parentCategory = category.parentCategoryId != null
          ? _categoryCache[category.parentCategoryId]
          : null;
      if (parentCategory != null) {
        _categoryBuckets[category.id] =
            CategoryHelpers.getDefaultBucketType(parentCategory.name);
      }
    }
    if (mounted) setState(() {});
  }

  /// Load category allocations from budget
  Future<void> _loadCategoryAllocations() async {
    if (widget.categoryType == CategoryType.income)
      return; // No allocations for income

    try {
      final budgetService = getIt<BudgetService>();
      final activeBudgetResult = await budgetService.getActiveBudget();

      await activeBudgetResult.fold(
        (failure) async {},
        (budget) async {
          if (budget == null) return;

          final categoryBudgetsResult =
              await budgetService.getCategoryBudgetsByBucket(budget.id);
          categoryBudgetsResult.fold(
            (failure) {},
            (grouped) {
              for (final entry in grouped.entries) {
                for (final cb in entry.value) {
                  if (cb.allocatedAmount > 0) {
                    _categoryAllocations[cb.categoryId] = cb.allocatedAmount;
                  }
                }
              }
              if (mounted) setState(() {});
            },
          );
        },
      );
    } catch (e) {
      print('Error loading category allocations: $e');
    }
  }

  /// Load category usage frequency from transaction history
  Future<void> _loadCategoryUsage() async {
    try {
      final database = getIt<Database>();

      // Query to count transactions per category
      final result = await database.customSelect(
        'SELECT category_id, COUNT(*) as count FROM events WHERE category_id IS NOT NULL GROUP BY category_id',
        readsFrom: {database.events},
      ).get();

      for (final row in result) {
        final categoryId = row.read<int>('category_id');
        final count = row.read<int>('count');
        _categoryUsageCount[categoryId] = count;
      }

      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading category usage: $e');
    }
  }

  Future<void> _loadMainCategories() async {
    try {
      final database = getIt<Database>();
      final categories =
          await database.getMainCategories(type: widget.categoryType);

      print(
          '🔍 DEBUG: Loaded ${categories.length} main categories for type ${widget.categoryType}');
      for (var cat in categories) {
        print(
            '  - ${cat.name} (ID: ${cat.id}, Icon: ${cat.icon}, ParentID: ${cat.parentCategoryId})');
      }

      setState(() {
        _mainCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectMainCategory(CategoryTableData category) async {
    setState(() {
      _selectedMainCategory = category;
      _isLoading = true;
    });

    try {
      final database = getIt<Database>();
      final subcategories = await database.getSubcategories(category.id);

      print(
          '🔍 DEBUG: Selected main category: ${category.name} (ID: ${category.id})');
      print('🔍 DEBUG: Loaded ${subcategories.length} subcategories');
      for (var subcat in subcategories) {
        print(
            '  - ${subcat.name} (ID: ${subcat.id}, ParentID: ${subcat.parentCategoryId})');
      }

      setState(() {
        _subcategories = subcategories;
        _showSubcategories = true;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading subcategories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectSubcategory(CategoryTableData subcategory) {
    widget.onCategorySelected(subcategory);
    widget.onClose?.call();
  }

  void _goBack() {
    setState(() {
      _showSubcategories = false;
      _selectedMainCategory = null;
      _subcategories.clear();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  /// Get filtered and sorted subcategories based on search and sorting criteria
  List<CategoryTableData> _getFilteredAndSortedSubcategories() {
    var categories = _subcategories.where((cat) {
      if (_searchQuery.isEmpty) return true;
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort: allocated first, then by usage, then alphabetical
    categories.sort((a, b) {
      final aHasAllocation = _categoryAllocations.containsKey(a.id);
      final bHasAllocation = _categoryAllocations.containsKey(b.id);

      // 1. Categories with allocations come first
      if (aHasAllocation && !bHasAllocation) return -1;
      if (!aHasAllocation && bHasAllocation) return 1;

      // 2. If both have allocations or both don't, sort by usage
      final aUsage = _categoryUsageCount[a.id] ?? 0;
      final bUsage = _categoryUsageCount[b.id] ?? 0;
      if (aUsage != bUsage) return bUsage.compareTo(aUsage);

      // 3. Finally, alphabetical
      return a.name.compareTo(b.name);
    });

    return categories;
  }

  /// Get top 3-5 most frequently used subcategories
  List<CategoryTableData> _getTopUsedCategories() {
    if (_subcategories.isEmpty) return [];

    var sorted = List<CategoryTableData>.from(_subcategories);
    sorted.sort((a, b) {
      final aUsage = _categoryUsageCount[a.id] ?? 0;
      final bUsage = _categoryUsageCount[b.id] ?? 0;
      return bUsage.compareTo(aUsage);
    });

    // Return top 3-5 that have been used at least once
    return sorted
        .where((cat) => (_categoryUsageCount[cat.id] ?? 0) > 0)
        .take(4)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(
                  top: (DesignTokens.borderRadius['md']!).topLeft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_showSubcategories) ...[
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Go back',
                        onPressed: _goBack,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        _showSubcategories
                            ? '${_selectedMainCategory?.icon ?? ''} ${_selectedMainCategory?.name}'
                            : '${widget.categoryType == CategoryType.income ? '💰' : '💳'} Select Category',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        onPressed: widget.onClose,
                        iconSize: 20,
                      ),
                  ],
                ),
                // Search bar (only show when viewing subcategories)
                if (_showSubcategories) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              tooltip: 'Clear search',
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: DesignTokens.borderRadius['sm']!,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else
            // Category grid
            Flexible(
              child: _showSubcategories
                  ? _buildSubcategoryList()
                  : _buildMainCategoryGrid(),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _mainCategories.length,
      itemBuilder: (context, index) {
        final category = _mainCategories[index];
        return _buildMainCategoryCard(category);
      },
    );
  }

  Widget _buildMainCategoryCard(CategoryTableData category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: DesignTokens.borderRadius['md']!,
        onTap: () => _selectMainCategory(category),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: DesignTokens.borderRadius['md']!,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon
              Text(
                category.icon ?? '📁',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              // Category name
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryList() {
    final topUsed = _getTopUsedCategories();
    final filteredCategories = _getFilteredAndSortedSubcategories();

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Quick access chips for frequently used categories
        if (topUsed.isNotEmpty && _searchQuery.isEmpty) ...[
          const Text(
            'Frequently Used',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topUsed.map((cat) => _buildQuickChip(cat)).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
        ],
        // All categories (filtered and sorted)
        ...filteredCategories.map((cat) => _buildSubcategoryTile(cat)),
      ],
    );
  }

  /// Build quick access chip for frequently used category
  Widget _buildQuickChip(CategoryTableData category) {
    final allocation = _categoryAllocations[category.id];
    final usageCount = _categoryUsageCount[category.id] ?? 0;

    return InkWell(
      onTap: () => _selectSubcategory(category),
      borderRadius: DesignTokens.borderRadius['sm']!,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: DesignTokens.borderRadius['sm']!,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedMainCategory?.icon ?? '📄',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            if (allocation != null) ...[
              const SizedBox(width: 6),
              Text(
                '\$${allocation.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build bucket type badge for a category
  Widget? _buildBucketBadge(int categoryId) {
    if (widget.categoryType == CategoryType.income) {
      // Don't show bucket badges for income categories
      return null;
    }

    final bucketType = _categoryBuckets[categoryId];
    if (bucketType == null) {
      return null;
    }

    final bucketColor = CategoryHelpers.getBucketColor(bucketType);
    final bucketLabel = CategoryHelpers.getBucketLabel(bucketType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bucketColor.withOpacity(0.1),
        borderRadius: DesignTokens.borderRadius['xs']!,
        border: Border.all(color: bucketColor, width: 1.5),
      ),
      child: Text(
        bucketLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: bucketColor,
        ),
      ),
    );
  }

  Widget _buildSubcategoryTile(CategoryTableData subcategory) {
    final isSelected = widget.selectedCategory?.id == subcategory.id;
    final allocation = _categoryAllocations[subcategory.id];
    final hasAllocation = allocation != null && allocation > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: DesignTokens.borderRadius['sm']!,
          onTap: () => _selectSubcategory(subcategory),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : hasAllocation
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withOpacity(0.5),
              borderRadius: DesignTokens.borderRadius['sm']!,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : hasAllocation
                        ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Category icon (use parent's icon or default)
                Opacity(
                  opacity: hasAllocation ? 1.0 : 0.5,
                  child: Text(
                    _selectedMainCategory?.icon ?? '📄',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Category name and bucket badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subcategory.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: hasAllocation
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : hasAllocation
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                        ),
                      ),
                      if (_buildBucketBadge(subcategory.id) != null) ...[
                        const SizedBox(height: 4),
                        _buildBucketBadge(subcategory.id)!,
                      ],
                    ],
                  ),
                ),
                // Allocation amount or selection indicator
                if (hasAllocation && !isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: DesignTokens.borderRadius['xs']!,
                    ),
                    child: Text(
                      '\$${allocation.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
