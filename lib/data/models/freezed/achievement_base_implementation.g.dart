// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_base_implementation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    _$AchievementImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$AchievementTypeEnumMap, json['type']),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'targetAmount': instance.targetAmount,
      'isUnlocked': instance.isUnlocked,
      'progress': instance.progress,
      'unlockedAt': instance.unlockedAt?.toIso8601String(),
    };

const _$AchievementTypeEnumMap = {
  AchievementType.savingMilestone: 'savingMilestone',
  AchievementType.streak: 'streak',
  AchievementType.yearEndTarget: 'yearEndTarget',
  AchievementType.customGoal: 'customGoal',
};
