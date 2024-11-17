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
}