// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryBudgetImpl _$$CategoryBudgetImplFromJson(Map<String, dynamic> json) =>
    _$CategoryBudgetImpl(
      id: (json['id'] as num).toInt(),
      budgetId: (json['budgetId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
      bucketType: $enumDecode(_$BucketTypeEnumMap, json['bucketType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$$CategoryBudgetImplToJson(
        _$CategoryBudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'budgetId': instance.budgetId,
      'categoryId': instance.categoryId,
      'allocatedAmount': instance.allocatedAmount,
      'bucketType': _$BucketTypeEnumMap[instance.bucketType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'categoryName': instance.categoryName,
    };

const _$BucketTypeEnumMap = {
  BucketType.needs: 'needs',
  BucketType.wants: 'wants',
  BucketType.savings: 'savings',
};
