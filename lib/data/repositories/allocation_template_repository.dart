import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../database/database.dart';
import '../models/freezed/allocation_template.dart';
import '../models/freezed/allocation_template_item.dart';
import '../models/enums/bucket_type.dart';

abstract class IAllocationTemplateRepository {
  Future<Either<Failure, List<AllocationTemplate>>> getAllTemplates();
  Future<Either<Failure, AllocationTemplate?>> getTemplateById(int id);
  Future<Either<Failure, int>> createTemplate(AllocationTemplate template);
  Future<Either<Failure, bool>> updateTemplate(AllocationTemplate template);
  Future<Either<Failure, bool>> deleteTemplate(int templateId);
  Future<Either<Failure, List<AllocationTemplateItem>>> getTemplateItems(int templateId);
  Future<Either<Failure, int>> createTemplateItem(AllocationTemplateItem item);
  Future<Either<Failure, bool>> updateTemplateItem(AllocationTemplateItem item);
  Future<Either<Failure, bool>> deleteTemplateItem(int itemId);
}

@Injectable(as: IAllocationTemplateRepository)
class AllocationTemplateRepository implements IAllocationTemplateRepository {
  final Database _db;

  AllocationTemplateRepository(this._db);

  // Convert database model to domain model
  AllocationTemplate _convertTemplateToModel(AllocationTemplateTableData data) {
    return AllocationTemplate(
      id: data.id,
      name: data.name,
      description: data.description,
      totalAmount: data.totalAmount,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // Convert domain model to database companion
  AllocationTemplatesCompanion _convertTemplateToCompanion(
    AllocationTemplate template, {
    bool isUpdate = false,
  }) {
    if (isUpdate) {
      return AllocationTemplatesCompanion(
        id: Value(template.id),
        name: Value(template.name),
        description: Value(template.description),
        totalAmount: Value(template.totalAmount),
        updatedAt: Value(DateTime.now()),
      );
    }

    return AllocationTemplatesCompanion.insert(
      name: template.name,
      description: Value(template.description),
      totalAmount: template.totalAmount,
    );
  }

  // Convert database model to domain model for items
  AllocationTemplateItem _convertItemToModel(
    Map<String, dynamic> data,
  ) {
    final bucketTypeString = data['bucket_type'] as String;
    final bucketType = BucketType.values.firstWhere(
      (bt) => bt.toString().split('.').last == bucketTypeString,
      orElse: () => BucketType.wants,
    );

    return AllocationTemplateItem(
      id: data['id'] as int,
      templateId: data['template_id'] as int,
      categoryId: data['category_id'] as int,
      allocatedAmount: data['allocated_amount'] as double,
      bucketType: bucketType,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updated_at'] as int),
      categoryName: data['category_name'] as String?,
    );
  }

  // Convert domain model to database companion for items
  AllocationTemplateItemsCompanion _convertItemToCompanion(
    AllocationTemplateItem item, {
    bool isUpdate = false,
  }) {
    if (isUpdate) {
      return AllocationTemplateItemsCompanion(
        id: Value(item.id),
        templateId: Value(item.templateId),
        categoryId: Value(item.categoryId),
        allocatedAmount: Value(item.allocatedAmount),
        bucketType: Value(item.bucketType),
        updatedAt: Value(DateTime.now()),
      );
    }

    return AllocationTemplateItemsCompanion.insert(
      templateId: item.templateId,
      categoryId: item.categoryId,
      allocatedAmount: item.allocatedAmount,
      bucketType: item.bucketType,
    );
  }

  @override
  Future<Either<Failure, List<AllocationTemplate>>> getAllTemplates() async {
    try {
      final templates = await _db.getAllocationTemplates();
      return Right(templates.map(_convertTemplateToModel).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get allocation templates: $e'));
    }
  }

  @override
  Future<Either<Failure, AllocationTemplate?>> getTemplateById(int id) async {
    try {
      final template = await _db.getAllocationTemplateById(id);
      if (template == null) {
        return const Right(null);
      }
      return Right(_convertTemplateToModel(template));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get allocation template: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createTemplate(AllocationTemplate template) async {
    try {
      final companion = _convertTemplateToCompanion(template);
      final id = await _db.createAllocationTemplate(companion);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create allocation template: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTemplate(AllocationTemplate template) async {
    try {
      final companion = _convertTemplateToCompanion(template, isUpdate: true);
      await _db.updateAllocationTemplate(companion);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update allocation template: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTemplate(int templateId) async {
    try {
      // Delete all items first (cascade should handle this, but be explicit)
      await _db.deleteAllocationTemplateItemsByTemplate(templateId);
      // Delete the template
      await _db.deleteAllocationTemplate(templateId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete allocation template: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AllocationTemplateItem>>> getTemplateItems(int templateId) async {
    try {
      final results = await _db.getAllocationTemplateItems(templateId);
      return Right(results.map(_convertItemToModel).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get template items: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createTemplateItem(AllocationTemplateItem item) async {
    try {
      final companion = _convertItemToCompanion(item);
      final id = await _db.createAllocationTemplateItem(companion);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create template item: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateTemplateItem(AllocationTemplateItem item) async {
    try {
      final companion = _convertItemToCompanion(item, isUpdate: true);
      await _db.updateAllocationTemplateItem(companion);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update template item: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTemplateItem(int itemId) async {
    try {
      await _db.deleteAllocationTemplateItem(itemId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete template item: $e'));
    }
  }
}
