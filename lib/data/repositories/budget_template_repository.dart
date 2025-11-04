import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../database/database.dart';
import '../models/freezed/budget_template.dart';
import '../../core/error/failures.dart';
import 'package:drift/drift.dart' as drift;

abstract class IBudgetTemplateRepository {
  Future<Either<Failure, List<BudgetTemplate>>> getAllTemplates();
  Future<Either<Failure, List<BudgetTemplate>>> getPresetTemplates();
  Future<Either<Failure, List<BudgetTemplate>>> getCustomTemplates();
  Future<Either<Failure, BudgetTemplate?>> getTemplateById(int id);
  Future<Either<Failure, int>> createTemplate(BudgetTemplate template);
  Future<Either<Failure, bool>> updateTemplate(BudgetTemplate template);
  Future<Either<Failure, bool>> deleteTemplate(int id);
}

@LazySingleton(as: IBudgetTemplateRepository)
class BudgetTemplateRepository implements IBudgetTemplateRepository {
  final Database _database;

  BudgetTemplateRepository(this._database);

  @override
  Future<Either<Failure, List<BudgetTemplate>>> getAllTemplates() async {
    try {
      final results = await (_database.select(_database.budgetTemplates)
            ..orderBy([
              (t) => drift.OrderingTerm(
                    expression: t.isPreset,
                    mode: drift.OrderingMode.desc,
                  ), // Presets first
              (t) => drift.OrderingTerm(expression: t.createdAt),
            ]))
          .get();

      final templates = results.map(_mapToModel).toList();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load templates: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetTemplate>>> getPresetTemplates() async {
    try {
      final results = await (_database.select(_database.budgetTemplates)
            ..where((t) => t.isPreset.equals(true))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt)]))
          .get();

      final templates = results.map(_mapToModel).toList();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load preset templates: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetTemplate>>> getCustomTemplates() async {
    try {
      final results = await (_database.select(_database.budgetTemplates)
            ..where((t) => t.isPreset.equals(false))
            ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]))
          .get();

      final templates = results.map(_mapToModel).toList();
      return Right(templates);
    } catch (e) {
      return Left(DatabaseFailure('Failed to load custom templates: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetTemplate?>> getTemplateById(int id) async {
    try {
      final result = await (_database.select(_database.budgetTemplates)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (result == null) {
        return const Right(null);
      }

      return Right(_mapToModel(result));
    } catch (e) {
      return Left(DatabaseFailure('Failed to load template: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createTemplate(BudgetTemplate template) async {
    try {
      final id = await _database.into(_database.budgetTemplates).insert(
            BudgetTemplatesCompanion(
              name: drift.Value(template.name),
              description: drift.Value(template.description),
              needsPercentage: drift.Value(template.needsPercentage),
              wantsPercentage: drift.Value(template.wantsPercentage),
              savingsPercentage: drift.Value(template.savingsPercentage),
              isPreset: drift.Value(template.isPreset),
              createdAt: drift.Value(template.createdAt),
              updatedAt: drift.Value(template.updatedAt),
              monthlyIncome: drift.Value(template.monthlyIncome),
            ),
          );

      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create template: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTemplate(BudgetTemplate template) async {
    try {
      if (template.id == null) {
        return Left(ValidationFailure('Template ID is required for update'));
      }

      final updatedRows = await (_database.update(_database.budgetTemplates)
            ..where((t) => t.id.equals(template.id!)))
          .write(
        BudgetTemplatesCompanion(
          name: drift.Value(template.name),
          description: drift.Value(template.description),
          needsPercentage: drift.Value(template.needsPercentage),
          wantsPercentage: drift.Value(template.wantsPercentage),
          savingsPercentage: drift.Value(template.savingsPercentage),
          updatedAt: drift.Value(DateTime.now()),
          monthlyIncome: drift.Value(template.monthlyIncome),
        ),
      );

      return Right(updatedRows > 0);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update template: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTemplate(int id) async {
    try {
      // Check if template is a preset (cannot be deleted)
      final template = await getTemplateById(id);

      return template.fold(
        (failure) => Left(failure),
        (template) async {
          if (template == null) {
            return Left(ValidationFailure('Template not found'));
          }

          if (template.isPreset) {
            return Left(ValidationFailure('Cannot delete preset templates'));
          }

          final deletedRows = await (_database.delete(_database.budgetTemplates)
                ..where((t) => t.id.equals(id)))
              .go();

          return Right(deletedRows > 0);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete template: $e'));
    }
  }

  /// Map database row to domain model
  BudgetTemplate _mapToModel(BudgetTemplateTableData data) {
    return BudgetTemplate(
      id: data.id,
      name: data.name,
      description: data.description,
      needsPercentage: data.needsPercentage,
      wantsPercentage: data.wantsPercentage,
      savingsPercentage: data.savingsPercentage,
      isPreset: data.isPreset,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      monthlyIncome: data.monthlyIncome,
    );
  }
}
