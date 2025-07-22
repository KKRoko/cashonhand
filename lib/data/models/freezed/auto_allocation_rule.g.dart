// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_allocation_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AutoAllocationRuleImpl _$$AutoAllocationRuleImplFromJson(
        Map<String, dynamic> json) =>
    _$AutoAllocationRuleImpl(
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
      goalTitle: json['goalTitle'] as String?,
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$$AutoAllocationRuleImplToJson(
        _$AutoAllocationRuleImpl instance) =>
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

_$AutoAllocationRuleFormImpl _$$AutoAllocationRuleFormImplFromJson(
        Map<String, dynamic> json) =>
    _$AutoAllocationRuleFormImpl(
      ruleId: json['ruleId'] as String?,
      ruleName: json['ruleName'] as String? ?? '',
      triggerType:
          $enumDecodeNullable(_$TriggerTypeEnumMap, json['triggerType']) ??
              TriggerType.expense,
      triggerCategoryId: (json['triggerCategoryId'] as num?)?.toInt(),
      goalId: (json['goalId'] as num?)?.toInt(),
      allocationMethod: $enumDecodeNullable(
              _$AllocationMethodEnumMap, json['allocationMethod']) ??
          AllocationMethod.percentage,
      allocationValue: (json['allocationValue'] as num?)?.toDouble() ?? 0.1,
      minimumTriggerAmount: (json['minimumTriggerAmount'] as num?)?.toDouble(),
      maximumAllocationAmount:
          (json['maximumAllocationAmount'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$$AutoAllocationRuleFormImplToJson(
        _$AutoAllocationRuleFormImpl instance) =>
    <String, dynamic>{
      'ruleId': instance.ruleId,
      'ruleName': instance.ruleName,
      'triggerType': _$TriggerTypeEnumMap[instance.triggerType]!,
      'triggerCategoryId': instance.triggerCategoryId,
      'goalId': instance.goalId,
      'allocationMethod': _$AllocationMethodEnumMap[instance.allocationMethod]!,
      'allocationValue': instance.allocationValue,
      'minimumTriggerAmount': instance.minimumTriggerAmount,
      'maximumAllocationAmount': instance.maximumAllocationAmount,
      'isActive': instance.isActive,
      'description': instance.description,
    };
