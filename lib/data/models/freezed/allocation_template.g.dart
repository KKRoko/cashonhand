// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allocation_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllocationTemplateImpl _$$AllocationTemplateImplFromJson(
        Map<String, dynamic> json) =>
    _$AllocationTemplateImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AllocationTemplateImplToJson(
        _$AllocationTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'totalAmount': instance.totalAmount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
