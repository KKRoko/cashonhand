import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/bucket_type.dart';

part 'category_budget.freezed.dart';
part 'category_budget.g.dart';

@freezed
class CategoryBudget with _$CategoryBudget {
  const factory CategoryBudget({
    required int id,
    required int budgetId,
    required int categoryId,
    required double allocatedAmount, // monthly dollar amount
    required BucketType bucketType,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? categoryName, // Optional, for display purposes
  }) = _CategoryBudget;

  const CategoryBudget._();

  factory CategoryBudget.fromJson(Map<String, dynamic> json) =>
      _$CategoryBudgetFromJson(json);

  // Calculate weekly amount
  double get weeklyAmount => allocatedAmount / 4.33; // Average weeks per month

  // Calculate yearly amount
  double get yearlyAmount => allocatedAmount * 12;

  // Calculate as percentage of budget
  double percentageOf(double totalBudget) {
    if (totalBudget == 0) return 0.0;
    return (allocatedAmount / totalBudget) * 100;
  }
}
