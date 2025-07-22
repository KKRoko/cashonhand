// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_up_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundUpPreferencesImpl _$$RoundUpPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$RoundUpPreferencesImpl(
      isEnabled: json['isEnabled'] as bool? ?? false,
      strategy:
          $enumDecodeNullable(_$RoundUpStrategyEnumMap, json['strategy']) ??
              RoundUpStrategy.nearestDollar,
      customMultiplier: (json['customMultiplier'] as num?)?.toDouble(),
      defaultGoalId: (json['defaultGoalId'] as num?)?.toInt(),
      minimumRoundUp: (json['minimumRoundUp'] as num?)?.toDouble() ?? 0.01,
      maximumRoundUp: (json['maximumRoundUp'] as num?)?.toDouble() ?? 10.00,
      excludedCategoryIds: (json['excludedCategoryIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      onlyOnExpenses: json['onlyOnExpenses'] as bool? ?? true,
      autoSelectGoal: json['autoSelectGoal'] as bool? ?? true,
    );

Map<String, dynamic> _$$RoundUpPreferencesImplToJson(
        _$RoundUpPreferencesImpl instance) =>
    <String, dynamic>{
      'isEnabled': instance.isEnabled,
      'strategy': _$RoundUpStrategyEnumMap[instance.strategy]!,
      'customMultiplier': instance.customMultiplier,
      'defaultGoalId': instance.defaultGoalId,
      'minimumRoundUp': instance.minimumRoundUp,
      'maximumRoundUp': instance.maximumRoundUp,
      'excludedCategoryIds': instance.excludedCategoryIds,
      'onlyOnExpenses': instance.onlyOnExpenses,
      'autoSelectGoal': instance.autoSelectGoal,
    };

const _$RoundUpStrategyEnumMap = {
  RoundUpStrategy.nearestDollar: 'nearestDollar',
  RoundUpStrategy.nearestFive: 'nearestFive',
  RoundUpStrategy.nearestTen: 'nearestTen',
  RoundUpStrategy.custom: 'custom',
};
