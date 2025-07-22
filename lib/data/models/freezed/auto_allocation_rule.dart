import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/trigger_type.dart';
import '../enums/allocation_method.dart';

part 'auto_allocation_rule.freezed.dart';
part 'auto_allocation_rule.g.dart';

/// Domain model for auto-allocation rules
@freezed
class AutoAllocationRule with _$AutoAllocationRule {
  const factory AutoAllocationRule({
    int? id,
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
    
    // Additional computed fields for UI
    String? goalTitle,
    String? categoryName,
  }) = _AutoAllocationRule;

  const AutoAllocationRule._();

  factory AutoAllocationRule.fromJson(Map<String, dynamic> json) =>
      _$AutoAllocationRuleFromJson(json);

  /// Get human-readable description of the rule
  String get humanReadableDescription {
    final buffer = StringBuffer();
    
    // Trigger description
    switch (triggerType) {
      case TriggerType.income:
        buffer.write('When income is received');
        break;
      case TriggerType.expense:
        buffer.write('When money is spent');
        break;
      case TriggerType.category:
        buffer.write('When spending in ${categoryName ?? 'selected category'}');
        break;
      case TriggerType.anyTransaction:
        buffer.write('On any transaction');
        break;
    }
    
    // Amount threshold
    if (minimumTriggerAmount != null && minimumTriggerAmount! > 0) {
      buffer.write(' over \$${minimumTriggerAmount!.toStringAsFixed(2)}');
    }
    
    buffer.write(', allocate ');
    
    // Allocation description
    switch (allocationMethod) {
      case AllocationMethod.percentage:
        buffer.write('${(allocationValue * 100).toStringAsFixed(1)}% of the amount');
        break;
      case AllocationMethod.fixedAmount:
        buffer.write('\$${allocationValue.toStringAsFixed(2)}');
        break;
      case AllocationMethod.roundUp:
        buffer.write('round-up amount');
        break;
    }
    
    buffer.write(' to ${goalTitle ?? 'selected goal'}');
    
    // Maximum cap
    if (maximumAllocationAmount != null && maximumAllocationAmount! > 0) {
      buffer.write(' (max \$${maximumAllocationAmount!.toStringAsFixed(2)})');
    }
    
    return buffer.toString();
  }

  /// Get the allocation value display string
  String get allocationValueDisplay {
    switch (allocationMethod) {
      case AllocationMethod.percentage:
        return '${(allocationValue * 100).toStringAsFixed(1)}%';
      case AllocationMethod.fixedAmount:
        return '\$${allocationValue.toStringAsFixed(2)}';
      case AllocationMethod.roundUp:
        return 'Round-up';
    }
  }

  /// Get the trigger condition display string
  String get triggerConditionDisplay {
    switch (triggerType) {
      case TriggerType.income:
        return 'Income transactions';
      case TriggerType.expense:
        return 'Expense transactions';
      case TriggerType.category:
        return categoryName ?? 'Category transactions';
      case TriggerType.anyTransaction:
        return 'All transactions';
    }
  }

  /// Check if the rule is valid and can be saved
  bool get isValid {
    return ruleName.isNotEmpty &&
           goalId > 0 &&
           allocationValue > 0 &&
           (triggerType != TriggerType.category || triggerCategoryId != null) &&
           (maximumAllocationAmount == null || maximumAllocationAmount! > 0) &&
           (minimumTriggerAmount == null || minimumTriggerAmount! >= 0);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (ruleName.isEmpty) {
      errors.add('Rule name is required');
    }
    
    if (goalId <= 0) {
      errors.add('Goal must be selected');
    }
    
    if (allocationValue <= 0) {
      errors.add('Allocation value must be greater than 0');
    }
    
    if (allocationMethod == AllocationMethod.percentage && allocationValue > 1) {
      errors.add('Percentage cannot exceed 100%');
    }
    
    if (triggerType == TriggerType.category && triggerCategoryId == null) {
      errors.add('Category must be selected for category trigger');
    }
    
    if (maximumAllocationAmount != null && maximumAllocationAmount! <= 0) {
      errors.add('Maximum allocation amount must be greater than 0');
    }
    
    if (minimumTriggerAmount != null && minimumTriggerAmount! < 0) {
      errors.add('Minimum trigger amount cannot be negative');
    }
    
    return errors;
  }

  /// Create a copy with computed fields for UI display
  AutoAllocationRule withDisplayInfo({
    String? goalTitle,
    String? categoryName,
  }) {
    return copyWith(
      goalTitle: goalTitle ?? this.goalTitle,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

/// Rule creation/editing form model
@freezed
class AutoAllocationRuleForm with _$AutoAllocationRuleForm {
  const factory AutoAllocationRuleForm({
    String? ruleId,
    @Default('') String ruleName,
    @Default(TriggerType.expense) TriggerType triggerType,
    int? triggerCategoryId,
    int? goalId,
    @Default(AllocationMethod.percentage) AllocationMethod allocationMethod,
    @Default(0.1) double allocationValue, // Default 10%
    double? minimumTriggerAmount,
    double? maximumAllocationAmount,
    @Default(true) bool isActive,
    @Default('') String description,
  }) = _AutoAllocationRuleForm;

  const AutoAllocationRuleForm._();

  factory AutoAllocationRuleForm.fromJson(Map<String, dynamic> json) =>
      _$AutoAllocationRuleFormFromJson(json);

  /// Create form from existing rule
  factory AutoAllocationRuleForm.fromRule(AutoAllocationRule rule) {
    return AutoAllocationRuleForm(
      ruleId: rule.id?.toString(),
      ruleName: rule.ruleName,
      triggerType: rule.triggerType,
      triggerCategoryId: rule.triggerCategoryId,
      goalId: rule.goalId,
      allocationMethod: rule.allocationMethod,
      allocationValue: rule.allocationValue,
      minimumTriggerAmount: rule.minimumTriggerAmount,
      maximumAllocationAmount: rule.maximumAllocationAmount,
      isActive: rule.isActive,
      description: rule.description ?? '',
    );
  }

  /// Convert form to rule model
  AutoAllocationRule toRule() {
    return AutoAllocationRule(
      id: ruleId != null ? int.tryParse(ruleId!) : null,
      goalId: goalId ?? 0,
      ruleName: ruleName,
      triggerType: triggerType,
      triggerCategoryId: triggerCategoryId,
      allocationMethod: allocationMethod,
      allocationValue: allocationValue,
      minimumTriggerAmount: minimumTriggerAmount,
      maximumAllocationAmount: maximumAllocationAmount,
      isActive: isActive,
      description: description.isEmpty ? null : description,
    );
  }

  /// Check if form is valid
  bool get isValid {
    return ruleName.isNotEmpty &&
           goalId != null &&
           goalId! > 0 &&
           allocationValue > 0 &&
           (triggerType != TriggerType.category || triggerCategoryId != null);
  }

  /// Get form validation errors
  List<String> get validationErrors {
    return toRule().validationErrors;
  }
}