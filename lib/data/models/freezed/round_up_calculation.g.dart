// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_up_calculation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundUpCalculationImpl _$$RoundUpCalculationImplFromJson(
        Map<String, dynamic> json) =>
    _$RoundUpCalculationImpl(
      originalAmount: (json['originalAmount'] as num).toDouble(),
      roundUpAmount: (json['roundUpAmount'] as num).toDouble(),
      roundedTotal: (json['roundedTotal'] as num).toDouble(),
      strategyUsed: $enumDecode(_$RoundUpStrategyEnumMap, json['strategyUsed']),
      isApplicable: json['isApplicable'] as bool? ?? true,
      reason: json['reason'] as String? ?? '',
    );

Map<String, dynamic> _$$RoundUpCalculationImplToJson(
        _$RoundUpCalculationImpl instance) =>
    <String, dynamic>{
      'originalAmount': instance.originalAmount,
      'roundUpAmount': instance.roundUpAmount,
      'roundedTotal': instance.roundedTotal,
      'strategyUsed': _$RoundUpStrategyEnumMap[instance.strategyUsed]!,
      'isApplicable': instance.isApplicable,
      'reason': instance.reason,
    };

const _$RoundUpStrategyEnumMap = {
  RoundUpStrategy.nearestDollar: 'nearestDollar',
  RoundUpStrategy.nearestFive: 'nearestFive',
  RoundUpStrategy.nearestTen: 'nearestTen',
  RoundUpStrategy.custom: 'custom',
};
