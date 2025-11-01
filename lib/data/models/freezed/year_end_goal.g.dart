// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_end_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$YearEndGoalImpl _$$YearEndGoalImplFromJson(Map<String, dynamic> json) =>
    _$YearEndGoalImpl(
      id: (json['id'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      needsPercentage: (json['needsPercentage'] as num).toDouble(),
      wantsPercentage: (json['wantsPercentage'] as num).toDouble(),
      savingsPercentage: (json['savingsPercentage'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$YearEndGoalImplToJson(_$YearEndGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'needsPercentage': instance.needsPercentage,
      'wantsPercentage': instance.wantsPercentage,
      'savingsPercentage': instance.savingsPercentage,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
