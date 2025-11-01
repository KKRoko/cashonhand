import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
class Budget with _$Budget {
  const factory Budget({
    required int id,
    required int month, // 1-12
    required int year, // e.g., 2025
    required double monthlyIncome,
    required int cycleStartDay, // 1-31
    required double needsPercentage, // 0.0-1.0 (e.g., 0.50 = 50%)
    required double wantsPercentage,
    required double savingsPercentage,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;

  const Budget._();

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  // Calculate dollar amounts from percentages
  double get needsAmount => monthlyIncome * needsPercentage;
  double get wantsAmount => monthlyIncome * wantsPercentage;
  double get savingsAmount => monthlyIncome * savingsPercentage;

  // Validate that percentages sum to 100% (with 1% tolerance for floating point rounding)
  bool get isValid => (needsPercentage + wantsPercentage + savingsPercentage - 1.0).abs() < 0.01;

  // Helper to get bucket amount by name
  double getBucketAmount(String bucketType) {
    switch (bucketType.toLowerCase()) {
      case 'needs':
        return needsAmount;
      case 'wants':
        return wantsAmount;
      case 'savings':
        return savingsAmount;
      default:
        return 0.0;
    }
  }

  // Helper to get bucket percentage by name
  double getBucketPercentage(String bucketType) {
    switch (bucketType.toLowerCase()) {
      case 'needs':
        return needsPercentage;
      case 'wants':
        return wantsPercentage;
      case 'savings':
        return savingsPercentage;
      default:
        return 0.0;
    }
  }
}
