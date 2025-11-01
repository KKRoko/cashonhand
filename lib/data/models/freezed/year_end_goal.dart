import 'package:freezed_annotation/freezed_annotation.dart';

part 'year_end_goal.freezed.dart';
part 'year_end_goal.g.dart';

@freezed
class YearEndGoal with _$YearEndGoal {
  const factory YearEndGoal({
    required int id,
    required int year, // e.g., 2025
    required double needsPercentage, // annual percentage goal for needs bucket (0.0-1.0)
    required double wantsPercentage, // annual percentage goal for wants bucket (0.0-1.0)
    required double savingsPercentage, // annual percentage goal for savings bucket (0.0-1.0)
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _YearEndGoal;

  const YearEndGoal._();

  factory YearEndGoal.fromJson(Map<String, dynamic> json) =>
      _$YearEndGoalFromJson(json);

  // Validate that percentages sum to 100% (with 1% tolerance for floating point rounding)
  bool get isValid => (needsPercentage + wantsPercentage + savingsPercentage - 1.0).abs() < 0.01;

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

  // Calculate dollar goal for a bucket based on total annual income
  double getBucketDollarGoal(String bucketType, double totalAnnualIncome) {
    return getBucketPercentage(bucketType) * totalAnnualIncome;
  }
}
