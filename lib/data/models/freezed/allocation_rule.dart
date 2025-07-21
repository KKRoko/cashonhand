import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/trigger_type.dart';
import '../enums/allocation_method.dart';

part 'allocation_rule.freezed.dart';
part 'allocation_rule.g.dart';

@freezed
class AllocationRule with _$AllocationRule {
  const factory AllocationRule({
    required int? id,
    required int goalId,
    required String ruleName,
    required TriggerType triggerType,
    int? triggerCategoryId,
    required AllocationMethod allocationMethod,
    required double allocationValue,
    double? minimumTriggerAmount,
    double? maximumAllocationAmount,
    @Default(true) bool isActive,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Additional fields for UI/display purposes
    @Default('') String goalTitle,
    @Default('') String categoryName,
  }) = _AllocationRule;

  factory AllocationRule.fromJson(Map<String, dynamic> json) =>
      _$AllocationRuleFromJson(json);
}

// Extension for business logic
extension AllocationRuleExtension on AllocationRule {
  bool get isPercentageAllocation => allocationMethod == AllocationMethod.percentage;
  bool get isFixedAmountAllocation => allocationMethod == AllocationMethod.fixedAmount;
  bool get isRoundUpAllocation => allocationMethod == AllocationMethod.roundUp;
  
  String get displayAllocationValue {
    switch (allocationMethod) {
      case AllocationMethod.percentage:
        return '${(allocationValue * 100).toStringAsFixed(1)}%';
      case AllocationMethod.fixedAmount:
        return '\$${allocationValue.toStringAsFixed(2)}';
      case AllocationMethod.roundUp:
        return 'Round up';
    }
  }
  
  String get ruleDescription {
    final trigger = _getTriggerDescription();
    final allocation = displayAllocationValue;
    final goal = goalTitle.isNotEmpty ? goalTitle : 'Goal';
    
    return 'Allocate $allocation to $goal when $trigger';
  }
  
  String _getTriggerDescription() {
    switch (triggerType) {
      case TriggerType.income:
        return 'receiving income';
      case TriggerType.expense:
        return 'spending money';
      case TriggerType.category:
        return categoryName.isNotEmpty 
            ? 'spending in $categoryName' 
            : 'spending in specific category';
      case TriggerType.anyTransaction:
        return 'any transaction occurs';
    }
  }
  
  double calculateAllocation(double transactionAmount) {
    if (!isActive) return 0.0;
    
    // Check minimum trigger amount
    if (minimumTriggerAmount != null && transactionAmount < minimumTriggerAmount!) {
      return 0.0;
    }
    
    double calculatedAmount = 0.0;
    
    switch (allocationMethod) {
      case AllocationMethod.percentage:
        calculatedAmount = transactionAmount * allocationValue;
        break;
      case AllocationMethod.fixedAmount:
        calculatedAmount = allocationValue;
        break;
      case AllocationMethod.roundUp:
        calculatedAmount = transactionAmount.ceilToDouble() - transactionAmount;
        break;
    }
    
    // Apply maximum allocation limit
    if (maximumAllocationAmount != null && calculatedAmount > maximumAllocationAmount!) {
      calculatedAmount = maximumAllocationAmount!;
    }
    
    return calculatedAmount;
  }
  
  bool shouldTrigger(double transactionAmount, int? categoryId, bool isIncome) {
    if (!isActive) return false;
    
    // Check minimum trigger amount
    if (minimumTriggerAmount != null && transactionAmount.abs() < minimumTriggerAmount!) {
      return false;
    }
    
    switch (triggerType) {
      case TriggerType.income:
        return isIncome;
      case TriggerType.expense:
        return !isIncome;
      case TriggerType.category:
        return triggerCategoryId != null && categoryId == triggerCategoryId;
      case TriggerType.anyTransaction:
        return true;
    }
  }
}