import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../core/error/failures.dart';
import '../data/models/freezed/budget.dart';
import '../data/models/freezed/budget_template.dart';
import '../data/repositories/budget_template_repository.dart';

@injectable
class BudgetTemplateService {
  final IBudgetTemplateRepository _repository;

  BudgetTemplateService(this._repository);

  /// Get all templates (presets + custom)
  Future<Either<Failure, List<BudgetTemplate>>> getAllTemplates() async {
    return await _repository.getAllTemplates();
  }

  /// Get only preset templates
  Future<Either<Failure, List<BudgetTemplate>>> getPresetTemplates() async {
    return await _repository.getPresetTemplates();
  }

  /// Get only user-created custom templates
  Future<Either<Failure, List<BudgetTemplate>>> getCustomTemplates() async {
    return await _repository.getCustomTemplates();
  }

  /// Get template by ID
  Future<Either<Failure, BudgetTemplate?>> getTemplateById(int id) async {
    return await _repository.getTemplateById(id);
  }

  /// Create a new custom template from current budget
  Future<Either<Failure, int>> createTemplateFromBudget({
    required Budget budget,
    required String name,
    required String description,
  }) async {
    try {
      // Validate percentages sum to 1.0 (with 1% tolerance for floating point rounding)
      final sum = budget.needsPercentage + budget.wantsPercentage + budget.savingsPercentage;
      if ((sum - 1.0).abs() > 0.01) {
        return Left(ValidationFailure('Budget percentages must sum to 100%'));
      }

      final template = BudgetTemplate(
        id: null,
        name: name,
        description: description,
        needsPercentage: budget.needsPercentage,
        wantsPercentage: budget.wantsPercentage,
        savingsPercentage: budget.savingsPercentage,
        isPreset: false,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      return await _repository.createTemplate(template);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create template from budget: $e'));
    }
  }

  /// Create a new custom template with specified percentages
  Future<Either<Failure, int>> createCustomTemplate({
    required String name,
    required String description,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) async {
    try {
      // Validate percentages sum to 1.0 (with 1% tolerance for floating point rounding)
      final sum = needsPercentage + wantsPercentage + savingsPercentage;
      if ((sum - 1.0).abs() > 0.01) {
        return Left(ValidationFailure('Percentages must sum to 100%'));
      }

      final template = BudgetTemplate(
        id: null,
        name: name,
        description: description,
        needsPercentage: needsPercentage,
        wantsPercentage: wantsPercentage,
        savingsPercentage: savingsPercentage,
        isPreset: false,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      return await _repository.createTemplate(template);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create custom template: $e'));
    }
  }

  /// Update a custom template
  Future<Either<Failure, bool>> updateTemplate({
    required int templateId,
    required String name,
    required String description,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
  }) async {
    try {
      // Validate percentages sum to 1.0 (with 1% tolerance for floating point rounding)
      final sum = needsPercentage + wantsPercentage + savingsPercentage;
      if ((sum - 1.0).abs() > 0.01) {
        return Left(ValidationFailure('Percentages must sum to 100%'));
      }

      // Get existing template to check if it's a preset
      final templateResult = await _repository.getTemplateById(templateId);

      return templateResult.fold(
        (failure) => Left(failure),
        (existingTemplate) async {
          if (existingTemplate == null) {
            return Left(ValidationFailure('Template not found'));
          }

          if (existingTemplate.isPreset) {
            return Left(ValidationFailure('Cannot edit preset templates'));
          }

          final updatedTemplate = BudgetTemplate(
            id: templateId,
            name: name,
            description: description,
            needsPercentage: needsPercentage,
            wantsPercentage: wantsPercentage,
            savingsPercentage: savingsPercentage,
            isPreset: false,
            createdAt: existingTemplate.createdAt,
            updatedAt: DateTime.now(),
          );

          return await _repository.updateTemplate(updatedTemplate);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to update template: $e'));
    }
  }

  /// Delete a custom template
  Future<Either<Failure, bool>> deleteTemplate(int templateId) async {
    return await _repository.deleteTemplate(templateId);
  }

  /// Apply template to a budget (returns updated budget with template percentages)
  Budget applyTemplateToBudget({
    required Budget budget,
    required BudgetTemplate template,
  }) {
    return budget.copyWith(
      needsPercentage: template.needsPercentage,
      wantsPercentage: template.wantsPercentage,
      savingsPercentage: template.savingsPercentage,
    );
  }

  /// Create a new budget from a template
  Budget createBudgetFromTemplate({
    required BudgetTemplate template,
    required int month,
    required int year,
    required double monthlyIncome,
    required int cycleStartDay,
  }) {
    return Budget(
      id: 0, // Will be set by database
      month: month,
      year: year,
      monthlyIncome: monthlyIncome,
      cycleStartDay: cycleStartDay,
      needsPercentage: template.needsPercentage,
      wantsPercentage: template.wantsPercentage,
      savingsPercentage: template.savingsPercentage,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
