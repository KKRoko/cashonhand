// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllocationRuleImpl _$$AllocationRuleImplFromJson(Map<String, dynamic> json) =>
    _$AllocationRuleImpl(
      id: (json['id'] as num?)?.toInt(),
      goalId: (json['goalId'] as num).toInt(),
      ruleName: json['ruleName'] as String,
      triggerType: $enumDecode(_$TriggerTypeEnumMap, json['triggerType']),
      triggerCategoryId: (json['triggerCategoryId'] as num?)?.toInt(),
      allocationMethod:
          $enumDecode(_$AllocationMethodEnumMap, json['allocationMethod']),
      allocationValue: (json['allocationValue'] as num).toDouble(),
      minimumTriggerAmount: (json['minimumTriggerAmount'] as num?)?.toDouble(),
      maximumAllocationAmount:
          (json['maximumAllocationAmount'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      goalTitle: json['goalTitle'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
    );

Map<String, dynamic> _$$AllocationRuleImplToJson(
        _$AllocationRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'ruleName': instance.ruleName,
      'triggerType': _$TriggerTypeEnumMap[instance.triggerType]!,
      'triggerCategoryId': instance.triggerCategoryId,
      'allocationMethod': _$AllocationMethodEnumMap[instance.allocationMethod]!,
      'allocationValue': instance.allocationValue,
      'minimumTriggerAmount': instance.minimumTriggerAmount,
      'maximumAllocationAmount': instance.maximumAllocationAmount,
      'isActive': instance.isActive,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'goalTitle': instance.goalTitle,
      'categoryName': instance.categoryName,
    };

const _$TriggerTypeEnumMap = {
  TriggerType.income: 'income',
  TriggerType.expense: 'expense',
  TriggerType.category: 'category',
  TriggerType.anyTransaction: 'any_transaction',
};

const _$AllocationMethodEnumMap = {
  AllocationMethod.percentage: 'percentage',
  AllocationMethod.fixedAmount: 'fixed_amount',
  AllocationMethod.roundUp: 'round_up',
};
