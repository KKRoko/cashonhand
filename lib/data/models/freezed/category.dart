import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/category_type.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class Category with _$Category {
  factory Category({
    required int id,
    required String name,
    required CategoryType type,
    String? color,
    @Default(true) bool isActive,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => 
      _$CategoryFromJson(json);
}
