import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../database/database.dart';
import '../models/freezed/budget.dart';
import '../models/freezed/category_budget.dart';
import '../models/enums/bucket_type.dart';

abstract class IBudgetRepository {
  Future<Either<Failure, Budget?>> getActiveBudget();
  Future<Either<Failure, Budget?>> getBudgetById(int id);
  Future<Either<Failure, Budget?>> getBudgetByMonth(int month, int year);
  Future<Either<Failure, int>> createBudget(Budget budget);
  Future<Either<Failure, bool>> updateBudget(Budget budget);
  Future<Either<Failure, bool>> deleteBudget(int budgetId);
  Future<Either<Failure, List<CategoryBudget>>> getCategoryBudgets(int budgetId);
  Future<Either<Failure, int>> createCategoryBudget(CategoryBudget categoryBudget);
  Future<Either<Failure, bool>> updateCategoryBudget(CategoryBudget categoryBudget);
  Future<Either<Failure, bool>> deleteCategoryBudget(int categoryBudgetId);
  Future<Either<Failure, List<CategoryBudget>>> getCategoryBudgetsByBucket(int budgetId, BucketType bucketType);
  Future<Either<Failure, Map<BucketType, double>>> getActualSpendingByBucket(int budgetId, DateTime start, DateTime end);
  Future<Either<Failure, Map<int, double>>> getActualSpendingByCategoryBudget(int budgetId, DateTime start, DateTime end);
  Future<Either<Failure, double>> getActualIncomeForMonth(DateTime start, DateTime end);
  Future<int> deleteIncomeCategoryBudgets();
}

@Injectable(as: IBudgetRepository)
class BudgetRepository implements IBudgetRepository {
  final Database _db;

  BudgetRepository(this._db);

  // Convert database model to domain model
  Budget _convertBudgetToModel(BudgetTableData data) {
    return Budget(
      id: data.id,
      month: data.month,
      year: data.year,
      monthlyIncome: data.monthlyIncome,
      cycleStartDay: data.cycleStartDay,
      needsPercentage: data.needsPercentage,
      wantsPercentage: data.wantsPercentage,
      savingsPercentage: data.savingsPercentage,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  // Convert domain model to database companion
  BudgetsCompanion _convertBudgetToCompanion(Budget budget, {bool isUpdate = false}) {
    if (isUpdate) {
      return BudgetsCompanion(
        id: Value(budget.id),
        month: Value(budget.month),
        year: Value(budget.year),
        monthlyIncome: Value(budget.monthlyIncome),
        cycleStartDay: Value(budget.cycleStartDay),
        needsPercentage: Value(budget.needsPercentage),
        wantsPercentage: Value(budget.wantsPercentage),
        savingsPercentage: Value(budget.savingsPercentage),
        isActive: Value(budget.isActive),
        updatedAt: Value(DateTime.now()),
      );
    }

    return BudgetsCompanion.insert(
      month: budget.month,
      year: budget.year,
      monthlyIncome: budget.monthlyIncome,
      cycleStartDay: Value(budget.cycleStartDay),
      needsPercentage: Value(budget.needsPercentage),
      wantsPercentage: Value(budget.wantsPercentage),
      savingsPercentage: Value(budget.savingsPercentage),
      isActive: Value(budget.isActive),
    );
  }

  // Convert CategoryBudget database model to domain model
  CategoryBudget _convertCategoryBudgetToModel(CategoryBudgetTableData data, {String? categoryName}) {
    return CategoryBudget(
      id: data.id,
      budgetId: data.budgetId,
      categoryId: data.categoryId,
      allocatedAmount: data.allocatedAmount,
      bucketType: data.bucketType,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      categoryName: categoryName,
    );
  }

  // Convert CategoryBudget domain model to database companion
  CategoryBudgetsCompanion _convertCategoryBudgetToCompanion(CategoryBudget categoryBudget, {bool isUpdate = false}) {
    if (isUpdate) {
      return CategoryBudgetsCompanion(
        id: Value(categoryBudget.id),
        budgetId: Value(categoryBudget.budgetId),
        categoryId: Value(categoryBudget.categoryId),
        allocatedAmount: Value(categoryBudget.allocatedAmount),
        bucketType: Value(categoryBudget.bucketType),
        updatedAt: Value(DateTime.now()),
      );
    }

    return CategoryBudgetsCompanion.insert(
      budgetId: categoryBudget.budgetId,
      categoryId: categoryBudget.categoryId,
      allocatedAmount: categoryBudget.allocatedAmount,
      bucketType: categoryBudget.bucketType,
    );
  }

  @override
  Future<Either<Failure, Budget?>> getActiveBudget() async {
    try {
      final budget = await _db.getActiveBudget();
      if (budget == null) {
        return const Right(null);
      }
      return Right(_convertBudgetToModel(budget));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active budget: $e'));
    }
  }

  @override
  Future<Either<Failure, Budget?>> getBudgetById(int id) async {
    try {
      final budget = await _db.getBudgetById(id);
      if (budget == null) {
        return const Right(null);
      }
      return Right(_convertBudgetToModel(budget));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get budget: $e'));
    }
  }

  @override
  Future<Either<Failure, Budget?>> getBudgetByMonth(int month, int year) async {
    try {
      print('🔍 REPOSITORY: Querying database for budget with month=$month, year=$year');
      final budget = await _db.getBudgetByMonth(month, year);
      if (budget == null) {
        print('⚠️ REPOSITORY: No budget found in database for $month/$year');
        return const Right(null);
      }
      print('✅ REPOSITORY: Found budget ID ${budget.id} for month=${budget.month}, year=${budget.year}');
      return Right(_convertBudgetToModel(budget));
    } catch (e) {
      print('❌ REPOSITORY: Error querying budget for $month/$year: $e');
      return Left(DatabaseFailure('Failed to get budget for $month/$year: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createBudget(Budget budget) async {
    try {
      final companion = _convertBudgetToCompanion(budget);
      final id = await _db.createBudget(companion);
      return Right(id);
    } catch (e) {
      // Check if it's a unique constraint violation (budget already exists for this month)
      if (e.toString().contains('UNIQUE constraint failed')) {
        return Left(DatabaseFailure('A budget already exists for ${budget.month}/${budget.year}'));
      }
      return Left(DatabaseFailure('Failed to create budget: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBudget(Budget budget) async {
    try {
      final companion = _convertBudgetToCompanion(budget, isUpdate: true);
      await _db.updateBudget(companion);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update budget: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBudget(int budgetId) async {
    try {
      await _db.deleteBudget(budgetId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete budget: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBudget>>> getCategoryBudgets(int budgetId) async {
    try {
      final results = await _db.getCategoryBudgets(budgetId);
      return Right(results.map((row) {
        final categoryName = row['category_name'] as String?;
        final bucketTypeString = row['bucket_type'] as String;
        final bucketType = BucketType.values.firstWhere(
          (bt) => bt.toString().split('.').last == bucketTypeString,
          orElse: () => BucketType.wants,
        );
        final categoryBudgetData = CategoryBudgetTableData(
          id: row['id'] as int,
          budgetId: row['budget_id'] as int,
          categoryId: row['category_id'] as int,
          allocatedAmount: row['allocated_amount'] as double,
          bucketType: bucketType,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
        );
        return _convertCategoryBudgetToModel(categoryBudgetData, categoryName: categoryName);
      }).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category budgets: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> createCategoryBudget(CategoryBudget categoryBudget) async {
    try {
      final companion = _convertCategoryBudgetToCompanion(categoryBudget);
      final id = await _db.createCategoryBudget(companion);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to create category budget: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategoryBudget(CategoryBudget categoryBudget) async {
    try {
      final companion = _convertCategoryBudgetToCompanion(categoryBudget, isUpdate: true);
      await _db.updateCategoryBudget(companion);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update category budget: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategoryBudget(int categoryBudgetId) async {
    try {
      await _db.deleteCategoryBudget(categoryBudgetId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete category budget: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBudget>>> getCategoryBudgetsByBucket(int budgetId, BucketType bucketType) async {
    try {
      final results = await _db.getCategoryBudgetsByBucket(budgetId, bucketType);
      return Right(results.map((row) {
        final categoryName = row['category_name'] as String?;
        final bucketTypeString = row['bucket_type'] as String;
        final bucket = BucketType.values.firstWhere(
          (bt) => bt.toString().split('.').last == bucketTypeString,
          orElse: () => BucketType.wants,
        );
        final categoryBudgetData = CategoryBudgetTableData(
          id: row['id'] as int,
          budgetId: row['budget_id'] as int,
          categoryId: row['category_id'] as int,
          allocatedAmount: row['allocated_amount'] as double,
          bucketType: bucket,
          createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
        );
        return _convertCategoryBudgetToModel(categoryBudgetData, categoryName: categoryName);
      }).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category budgets by bucket: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<BucketType, double>>> getActualSpendingByBucket(int budgetId, DateTime start, DateTime end) async {
    try {
      final spendingMap = await _db.getActualSpendingByBucket(budgetId, start, end);

      // Convert string keys to BucketType enum
      final result = <BucketType, double>{
        BucketType.needs: 0.0,
        BucketType.wants: 0.0,
        BucketType.savings: 0.0,
      };

      for (final entry in spendingMap.entries) {
        final bucketType = BucketType.values.firstWhere(
          (bt) => bt.toString().split('.').last == entry.key,
          orElse: () => BucketType.wants, // Default fallback
        );
        result[bucketType] = entry.value;
      }

      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get actual spending: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<int, double>>> getActualSpendingByCategoryBudget(int budgetId, DateTime start, DateTime end) async {
    try {
      final spendingMap = await _db.getActualSpendingByCategoryBudget(budgetId, start, end);
      return Right(spendingMap);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category spending: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getActualIncomeForMonth(DateTime start, DateTime end) async {
    try {
      final income = await _db.getActualIncomeForMonth(start, end);
      return Right(income);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get actual income: $e'));
    }
  }

  @override
  Future<int> deleteIncomeCategoryBudgets() async {
    return await _db.deleteIncomeCategoryBudgets();
  }
}
