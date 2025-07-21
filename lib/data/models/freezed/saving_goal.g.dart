// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saving_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingGoalImpl _$$SavingGoalImplFromJson(Map<String, dynamic> json) =>
    _$SavingGoalImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      goalType: $enumDecode(_$GoalTypeEnumMap, json['goalType']),
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadlineDate: json['deadlineDate'] == null
          ? null
          : DateTime.parse(json['deadlineDate'] as String),
      recurringPeriod: $enumDecodeNullable(
          _$RecurringPeriodEnumMap, json['recurringPeriod']),
      recurringTargetAmount:
          (json['recurringTargetAmount'] as num?)?.toDouble(),
      checkpoints: (json['checkpoints'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
    );

Map<String, dynamic> _$$SavingGoalImplToJson(_$SavingGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'goalType': _$GoalTypeEnumMap[instance.goalType]!,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'deadlineDate': instance.deadlineDate?.toIso8601String(),
      'recurringPeriod': _$RecurringPeriodEnumMap[instance.recurringPeriod],
      'recurringTargetAmount': instance.recurringTargetAmount,
      'checkpoints':
          instance.checkpoints?.map((e) => e.toIso8601String()).toList(),
    };

const _$GoalTypeEnumMap = {
  GoalType.simple: 'simple',
  GoalType.deadline: 'deadline',
  GoalType.recurring: 'recurring',
};

const _$RecurringPeriodEnumMap = {
  RecurringPeriod.weekly: 'weekly',
  RecurringPeriod.monthly: 'monthly',
};
