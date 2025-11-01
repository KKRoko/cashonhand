import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/allocation_template.dart';
import '../data/models/freezed/allocation_template_item.dart';
import '../data/models/freezed/category_budget.dart';
import '../data/repositories/allocation_template_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/i_category_repository.dart';
import 'category_bucket_mapper.dart';

@singleton
class AllocationTemplateService {
  final IAllocationTemplateRepository _templateRepository;
  final IBudgetRepository _budgetRepository;
  final ICategoryRepository _categoryRepository;
  final CategoryBucketMapper _bucketMapper;

  AllocationTemplateService(
    this._templateRepository,
    this._budgetRepository,
    this._categoryRepository,
    this._bucketMapper,
  );

  /// Get all saved allocation templates
  Future<Either<Failure, List<AllocationTemplate>>> getAllTemplates() {
    return _templateRepository.getAllTemplates();
  }

  /// Get a specific template by ID
  Future<Either<Failure, AllocationTemplate?>> getTemplateById(int id) {
    return _templateRepository.getTemplateById(id);
  }

  /// Get template items (category allocations) for a template
  Future<Either<Failure, List<AllocationTemplateItem>>> getTemplateItems(int templateId) {
    return _templateRepository.getTemplateItems(templateId);
  }

  /// Save current budget allocations as a new template
  /// Takes the current CategoryBudget list and saves it as a reusable template
  Future<Either<Failure, int>> saveAsTemplate({
    required String name,
    String? description,
    required List<CategoryBudget> categoryBudgets,
  }) async {
    if (categoryBudgets.isEmpty) {
      return Left(ValidationFailure('Cannot save empty allocation template'));
    }

    // Calculate total allocation amount
    final totalAmount = categoryBudgets.fold<double>(
      0.0,
      (sum, cb) => sum + cb.allocatedAmount,
    );

    // Create template metadata
    final template = AllocationTemplate(
      id: 0, // Will be set by database
      name: name,
      description: description,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final createResult = await _templateRepository.createTemplate(template);

    return createResult.fold(
      (failure) => Left(failure),
      (templateId) async {
        // Create template items for each category allocation
        for (final categoryBudget in categoryBudgets) {
          // Only save categories with non-zero allocations
          if (categoryBudget.allocatedAmount > 0) {
            final item = AllocationTemplateItem(
              id: 0, // Will be set by database
              templateId: templateId,
              categoryId: categoryBudget.categoryId,
              allocatedAmount: categoryBudget.allocatedAmount,
              bucketType: categoryBudget.bucketType,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              categoryName: categoryBudget.categoryName,
            );

            await _templateRepository.createTemplateItem(item);
          }
        }

        return Right(templateId);
      },
    );
  }

  /// Apply a template to a budget
  /// Creates CategoryBudget records from the template items
  /// Also creates $0 allocations for categories not in the template
  Future<Either<Failure, int>> applyTemplateTobudget({
    required int templateId,
    required int budgetId,
    bool scaleToIncome = false,
    double? targetIncome,
  }) async {
    // Get template items
    final itemsResult = await _templateRepository.getTemplateItems(templateId);

    return await itemsResult.fold(
      (failure) => Left(failure),
      (items) async {
        if (items.isEmpty) {
          return Left(ValidationFailure('Template has no items'));
        }

        // Get template to check total amount
        final templateResult = await _templateRepository.getTemplateById(templateId);
        final template = templateResult.fold(
          (_) => null,
          (t) => t,
        );

        if (template == null) {
          return Left(ValidationFailure('Template not found'));
        }

        // Calculate scaling factor if needed
        double scaleFactor = 1.0;
        if (scaleToIncome && targetIncome != null && template.totalAmount > 0) {
          scaleFactor = targetIncome / template.totalAmount;
        }

        // Track which category IDs are in the template
        final templateCategoryIds = <int>{};

        // Create category budgets from template items
        int createdCount = 0;
        for (final item in items) {
          templateCategoryIds.add(item.categoryId);
          final scaledAmount = item.allocatedAmount * scaleFactor;

          final categoryBudget = CategoryBudget(
            id: 0, // Will be set by database
            budgetId: budgetId,
            categoryId: item.categoryId,
            allocatedAmount: scaledAmount,
            bucketType: item.bucketType,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            categoryName: item.categoryName,
          );

          final createResult = await _budgetRepository.createCategoryBudget(categoryBudget);
          createResult.fold(
            (failure) {
              // Log error but continue with other categories
              print('Warning: Could not create category budget for ${item.categoryName}: $failure');
            },
            (_) {
              createdCount++;
            },
          );
        }

        // Get all expense child categories and create $0 entries for those not in template
        final categoriesResult = await _categoryRepository.getExpenseChildCategories();

        await categoriesResult.fold(
          (failure) {
            print('Warning: Could not load expense categories to create zero entries: ${failure.message}');
          },
          (expenseCategories) async {
            for (final category in expenseCategories) {
              // Skip if this category is already in the template
              if (templateCategoryIds.contains(category.id)) {
                continue;
              }

              // Create $0 allocation for this category
              final suggestedBucket = _bucketMapper.suggestBucket(category.name);
              final categoryBudget = CategoryBudget(
                id: 0,
                budgetId: budgetId,
                categoryId: category.id,
                allocatedAmount: 0.0,
                bucketType: suggestedBucket,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                categoryName: category.name,
              );

              final createResult = await _budgetRepository.createCategoryBudget(categoryBudget);
              createResult.fold(
                (failure) {
                  print('Warning: Could not create zero allocation for ${category.name}: $failure');
                },
                (_) {
                  createdCount++;
                },
              );
            }
          },
        );

        if (createdCount == 0) {
          return Left(DatabaseFailure('Failed to apply template - no categories were created'));
        }

        return Right(createdCount);
      },
    );
  }

  /// Update a template's metadata (name, description)
  Future<Either<Failure, bool>> updateTemplate(AllocationTemplate template) {
    return _templateRepository.updateTemplate(template);
  }

  /// Delete a template and all its items
  Future<Either<Failure, bool>> deleteTemplate(int templateId) {
    return _templateRepository.deleteTemplate(templateId);
  }

  /// Get template summary info (for UI display)
  Future<Either<Failure, Map<String, dynamic>>> getTemplateSummary(int templateId) async {
    final templateResult = await _templateRepository.getTemplateById(templateId);
    final itemsResult = await _templateRepository.getTemplateItems(templateId);

    return await templateResult.fold(
      (failure) => Left(failure),
      (template) async {
        if (template == null) {
          return Left(ValidationFailure('Template not found'));
        }

        return itemsResult.fold(
          (failure) => Left(failure),
          (items) {
            // Group items by bucket
            final needsItems = items.where((i) => i.bucketType.toString().contains('needs')).toList();
            final wantsItems = items.where((i) => i.bucketType.toString().contains('wants')).toList();
            final savingsItems = items.where((i) => i.bucketType.toString().contains('savings')).toList();

            final needsTotal = needsItems.fold<double>(0, (sum, i) => sum + i.allocatedAmount);
            final wantsTotal = wantsItems.fold<double>(0, (sum, i) => sum + i.allocatedAmount);
            final savingsTotal = savingsItems.fold<double>(0, (sum, i) => sum + i.allocatedAmount);

            return Right({
              'template': template,
              'items': items,
              'totalCategories': items.length,
              'needs': {'count': needsItems.length, 'total': needsTotal},
              'wants': {'count': wantsItems.length, 'total': wantsTotal},
              'savings': {'count': savingsItems.length, 'total': savingsTotal},
            });
          },
        );
      },
    );
  }
}
