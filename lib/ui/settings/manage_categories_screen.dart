import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../data/models/freezed/category.dart';
import '../../data/models/enums/category_type.dart';
import '../../theme/design_tokens.dart';
import '../../core/di/injection.dart';

class ManageCategoriesScreen extends StatefulWidget {
  static const routeName = '/manageCategories';

  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late CategoryService _categoryService;
  List<Category> _userCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categoryService = getIt<CategoryService>();
    _loadUserCategories();
  }

  Future<void> _loadUserCategories() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _categoryService.getUserCategories();
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (categories) {
        setState(() {
          _userCategories = categories;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.color('error'),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _categoryService.deleteUserCategory(category.id);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category deleted successfully')),
            );
            _loadUserCategories();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Custom Categories'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userCategories.isEmpty
              ? _buildEmptyState()
              : _buildCategoryList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Custom Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create custom subcategories to better organize your income and expenses',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userCategories.length,
      itemBuilder: (context, index) {
        final category = _userCategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.type == CategoryType.income
                    ? DesignTokens.color('success').withOpacity(0.1)
                    : DesignTokens.color('error').withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.type == CategoryType.income
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: category.type == CategoryType.income
                    ? DesignTokens.color('success')
                    : DesignTokens.color('error'),
                size: 20,
              ),
            ),
            title: Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              category.type == CategoryType.income ? 'Income' : 'Expense',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: DesignTokens.color('error'), size: 20),
                      const SizedBox(width: 12),
                      const Text('Delete'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCategory(category);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final formKey = GlobalKey<FormState>();
    String categoryName = '';
    CategoryType selectedType = CategoryType.expense;
    int? selectedParentId;

    // Load system categories to use as parents
    final systemCategoriesResult = await _categoryService.getSystemCategories();
    final systemCategories = systemCategoriesResult.fold(
      (failure) => <Category>[],
      (categories) => categories.where((c) => c.id != 0).toList(), // Filter out any invalid categories
    );

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter parent categories based on selected type
          final availableParents = systemCategories
              .where((c) => c.type == selectedType)
              .toList();

          // Find parent categories (ones without parentCategoryId)
          // For now, we'll just show all system categories of the selected type
          // TODO: Properly filter to only show parent categories

          return AlertDialog(
            title: const Text('Add Custom Category'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Type Selection
                  const Text(
                    'Category Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<CategoryType>(
                          title: const Text('Expense'),
                          value: CategoryType.expense,
                          groupValue: selectedType,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value!;
                              selectedParentId = null; // Reset parent when type changes
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<CategoryType>(
                          title: const Text('Income'),
                          value: CategoryType.income,
                          groupValue: selectedType,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedType = value!;
                              selectedParentId = null; // Reset parent when type changes
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Parent Category Selection
                  const Text(
                    'Parent Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedParentId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a parent category',
                    ),
                    items: availableParents.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedParentId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a parent category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Name Input
                  const Text(
                    'Category Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter category name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a category name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      categoryName = value!;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    Navigator.of(context).pop();

                    // Create the category
                    final result = await _categoryService.createUserCategory(
                      name: categoryName,
                      type: selectedType,
                      parentCategoryId: selectedParentId!,
                    );

                    result.fold(
                      (failure) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${failure.message}')),
                          );
                        }
                      },
                      (_) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Category created successfully')),
                          );
                          _loadUserCategories();
                        }
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}
