import 'package:injectable/injectable.dart';
import '../data/models/enums/category_type.dart';
import '../data/models/freezed/category.dart';
import '../data/repositories/i_category_repository.dart';
import '../core/error/failures.dart';
import 'package:dartz/dartz.dart';

@injectable
class CategoryService {
  final ICategoryRepository _repository;

  CategoryService(this._repository);

  Future<Either<Failure, List<Category>>> getCategories() {
    return _repository.getCategories();
  }

  Future<Either<Failure, List<Category>>> getCategoriesByType(CategoryType type) {
    return _repository.getCategoriesByType(type);
  }

  // User category management
  Future<Either<Failure, List<Category>>> getUserCategories() {
    return _repository.getUserCategories();
  }

  Future<Either<Failure, List<Category>>> getSystemCategories() {
    return _repository.getSystemCategories();
  }

  Future<Either<Failure, List<Category>>> getActiveCategories() {
    return _repository.getActiveCategories();
  }

  Future<Either<Failure, Category>> createUserCategory({
    required String name,
    required CategoryType type,
    required int parentCategoryId,
  }) async {
    // Validate name is not empty
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Category name cannot be empty'));
    }

    // Check for duplicate names under the same parent
    final existingCategoriesResult = await _repository.getCategories();
    final isDuplicate = existingCategoriesResult.fold(
      (failure) => false,
      (categories) => categories.any(
        (cat) => cat.name.toLowerCase() == name.trim().toLowerCase(),
      ),
    );

    if (isDuplicate) {
      return Left(ValidationFailure('A category with this name already exists'));
    }

    return _repository.createUserCategory(
      name: name.trim(),
      type: type,
      parentCategoryId: parentCategoryId,
    );
  }

  Future<Either<Failure, Category>> updateCategory(Category category) {
    return _repository.updateCategory(category);
  }

  Future<Either<Failure, bool>> deleteUserCategory(int id) async {
    // Use soft delete instead of hard delete
    return _repository.softDeleteCategory(id);
  }

  Future<Either<Failure, bool>> hardDeleteCategory(int id) {
    return _repository.deleteCategory(id);
  }
}