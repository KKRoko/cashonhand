import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../models/freezed/category.dart';
import '../models/enums/category_type.dart';

abstract class ICategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, Category>> addCategory(Category category);
  Future<Either<Failure, Category>> updateCategory(Category category);
  Future<Either<Failure, bool>> deleteCategory(int id);
  Future<Either<Failure, List<Category>>> getCategoriesByType(CategoryType type);

  // User category management
  Future<Either<Failure, List<Category>>> getUserCategories();
  Future<Either<Failure, List<Category>>> getSystemCategories();
  Future<Either<Failure, Category>> createUserCategory({
    required String name,
    required CategoryType type,
    required int parentCategoryId,
  });
  Future<Either<Failure, bool>> softDeleteCategory(int id);
  Future<Either<Failure, List<Category>>> getActiveCategories();

  // Get child categories for budgeting (excludes parent/folder categories)
  Future<Either<Failure, List<Category>>> getExpenseChildCategories();
}