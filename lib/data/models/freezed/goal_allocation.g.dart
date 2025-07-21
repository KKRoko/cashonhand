// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_allocation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoalAllocationImpl _$$GoalAllocationImplFromJson(Map<String, dynamic> json) =>
    _$GoalAllocationImpl(
      id: (json['id'] as num?)?.toInt(),
      eventId: (json['eventId'] as num).toInt(),
      goalId: (json['goalId'] as num).toInt(),
      allocationAmount: (json['allocationAmount'] as num).toDouble(),
      allocationType:
          $enumDecode(_$AllocationTypeEnumMap, json['allocationType']),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      goalTitle: json['goalTitle'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? '',
    );

Map<String, dynamic> _$$GoalAllocationImplToJson(
        _$GoalAllocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'goalId': instance.goalId,
      'allocationAmount': instance.allocationAmount,
      'allocationType': _$AllocationTypeEnumMap[instance.allocationType]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'goalTitle': instance.goalTitle,
      'eventTitle': instance.eventTitle,
    };

const _$AllocationTypeEnumMap = {
  AllocationType.manual: 'manual',
  AllocationType.auto: 'auto',
  AllocationType.roundUp: 'round_up',
};
