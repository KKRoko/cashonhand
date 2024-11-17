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
}