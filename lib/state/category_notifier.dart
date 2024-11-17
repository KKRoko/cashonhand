import 'package:flutter/foundation.dart' hide Category; // Hide Flutter's Category
import 'package:injectable/injectable.dart';
import '../data/models/freezed/category.dart';
import '../data/models/enums/category_type.dart';
import '../services/category_service.dart';

@injectable
class CategoryNotifier extends ChangeNotifier {
  final CategoryService _categoryService;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryNotifier(this._categoryService) {
    loadCategories();
  }

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    final result = await _categoryService.getCategories();
    result.fold(
      (failure) {
        _error = failure.message;
        _categories = [];
      },
      (categories) {
        _categories = categories;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  List<Category> getCategoriesByType(CategoryType type) {
    return _categories.where((category) => 
      category.type == type || category.type == CategoryType.both
    ).toList();
  }
}
