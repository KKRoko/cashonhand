import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_template.freezed.dart';

/// A reusable budget template with predefined bucket allocations
@freezed
class BudgetTemplate with _$BudgetTemplate {
  const factory BudgetTemplate({
    required int? id,
    required String name,
    required String description,
    required double needsPercentage,
    required double wantsPercentage,
    required double savingsPercentage,
    required bool isPreset, // True for system presets, false for user-created
    required DateTime createdAt,
    DateTime? updatedAt,
    double? monthlyIncome, // Optional: Store the income used when template was created
  }) = _BudgetTemplate;

  const BudgetTemplate._();

  /// Validate that percentages sum to 1.0
  bool get isValid {
    final sum = needsPercentage + wantsPercentage + savingsPercentage;
    return (sum - 1.0).abs() < 0.001; // Allow small floating point errors
  }

  /// Get a display string for the percentages
  String get percentageDisplay {
    return '${(needsPercentage * 100).toInt()}/${(wantsPercentage * 100).toInt()}/${(savingsPercentage * 100).toInt()}';
  }
}
