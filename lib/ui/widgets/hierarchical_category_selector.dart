import 'package:flutter/material.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../core/di/injection.dart';

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
  State<HierarchicalCategorySelector> createState() => _HierarchicalCategorySelectorState();
}

class _HierarchicalCategorySelectorState extends State<HierarchicalCategorySelector> {
  List<CategoryTableData> _mainCategories = [];
  List<CategoryTableData> _subcategories = [];
  CategoryTableData? _selectedMainCategory;
  bool _isLoading = true;
  bool _showSubcategories = false;

  @override
  void initState() {
    super.initState();
    _loadMainCategories();
  }

  Future<void> _loadMainCategories() async {
    try {
      final database = getIt<Database>();
      final categories = await database.getMainCategories(type: widget.categoryType);
      
      print('🔍 DEBUG: Loaded ${categories.length} main categories for type ${widget.categoryType}');
      for (var cat in categories) {
        print('  - ${cat.name} (ID: ${cat.id}, Icon: ${cat.icon}, ParentID: ${cat.parentCategoryId})');
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
      
      print('🔍 DEBUG: Selected main category: ${category.name} (ID: ${category.id})');
      print('🔍 DEBUG: Loaded ${subcategories.length} subcategories');
      for (var subcat in subcategories) {
        print('  - ${subcat.name} (ID: ${subcat.id}, ParentID: ${subcat.parentCategoryId})');
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
    });
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (_showSubcategories) ...[
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
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
                    onPressed: widget.onClose,
                    iconSize: 20,
                  ),
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
              child: _showSubcategories ? _buildSubcategoryList() : _buildMainCategoryGrid(),
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
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectMainCategory(category),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = _subcategories[index];
        return _buildSubcategoryTile(subcategory);
      },
    );
  }

  Widget _buildSubcategoryTile(CategoryTableData subcategory) {
    final isSelected = widget.selectedCategory?.id == subcategory.id;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _selectSubcategory(subcategory),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Category icon (use parent's icon or default)
                Text(
                  _selectedMainCategory?.icon ?? '📄',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                // Category name
                Expanded(
                  child: Text(
                    subcategory.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                ),
                // Selection indicator
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