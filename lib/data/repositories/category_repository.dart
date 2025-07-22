import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/error/exception.dart';
import '../database/database.dart';
import '../models/enums/category_type.dart';
import '../models/freezed/category.dart';
import 'base_repository.dart';
import 'i_category_repository.dart';

@Injectable(as: ICategoryRepository)
class CategoryRepository extends BaseRepository<Category> implements ICategoryRepository {
  final Database _database;
  
  CategoryRepository(this._database);

  @override
  Future<Either<Failure, List<Category>>> getCategories() {
    return catchError(() async {
      final categories = await _database.getAllCategories();
      return _convertToCategories(categories);
    });
  }

  @override
  Future<Either<Failure, Category>> addCategory(Category category) {
    return catchError(() async {
      final categoryCompanion = CategoriesCompanion.insert(
        name: category.name,
        type: category.type,
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      final id = await _database.createCategory(categoryCompanion);
      return category.copyWith(id: id);
    });
  }

  @override
  Future<Either<Failure, Category>> updateCategory(Category category) {
    return catchError(() async {
      final categoryData = CategoryTableData(
        id: category.id,
        name: category.name,
        type: category.type,
        createdAt: DateTime.now(), // You might want to preserve the original createdAt
        updatedAt: DateTime.now(),
      );
      
      final success = await _database.updateCategory(categoryData);
      if (success) {
        return category;
      } else {
        throw const DatabaseException('Failed to update category');
      }
    });
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(int id) {
    return catchError(() async {
      final deletedCount = await _database.deleteCategory(id);
      return deletedCount > 0;
    });
  }

  @override
  Future<Either<Failure, List<Category>>> getCategoriesByType(CategoryType type) {
    return catchError(() async {
      final categories = await _database.getCategories(type: type);
      return _convertToCategories(categories);
    });
  }

  // Helper method to convert database categories to domain categories
  List<Category> _convertToCategories(List<CategoryTableData> categoryData) {
    return categoryData.map((c) => Category(
      id: c.id,
      name: c.name,
      type: c.type,
    )).toList();
  }
}