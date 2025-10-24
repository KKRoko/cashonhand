// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetImpl _$$BudgetImplFromJson(Map<String, dynamic> json) => _$BudgetImpl(
      id: (json['id'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      cycleStartDay: (json['cycleStartDay'] as num).toInt(),
      needsPercentage: (json['needsPercentage'] as num).toDouble(),
      wantsPercentage: (json['wantsPercentage'] as num).toDouble(),
      savingsPercentage: (json['savingsPercentage'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BudgetImplToJson(_$BudgetImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'month': instance.month,
      'year': instance.year,
      'monthlyIncome': instance.monthlyIncome,
      'cycleStartDay': instance.cycleStartDay,
      'needsPercentage': instance.needsPercentage,
      'wantsPercentage': instance.wantsPercentage,
      'savingsPercentage': instance.savingsPercentage,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
