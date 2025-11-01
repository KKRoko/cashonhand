// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_template_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllocationTemplateItemImpl _$$AllocationTemplateItemImplFromJson(
        Map<String, dynamic> json) =>
    _$AllocationTemplateItemImpl(
      id: (json['id'] as num).toInt(),
      templateId: (json['templateId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      allocatedAmount: (json['allocatedAmount'] as num).toDouble(),
      bucketType: $enumDecode(_$BucketTypeEnumMap, json['bucketType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      categoryName: json['categoryName'] as String?,
    );

Map<String, dynamic> _$$AllocationTemplateItemImplToJson(
        _$AllocationTemplateItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'templateId': instance.templateId,
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
