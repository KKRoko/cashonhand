// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryImpl _$$CategoryImplFromJson(Map<String, dynamic> json) =>
    _$CategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$CategoryTypeEnumMap, json['type']),
      color: json['color'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$CategoryImplToJson(_$CategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$CategoryTypeEnumMap[instance.type]!,
      'color': instance.color,
      'isActive': instance.isActive,
    };

const _$CategoryTypeEnumMap = {
  CategoryType.income: 'income',
  CategoryType.expense: 'expense',
  CategoryType.both: 'both',
};
