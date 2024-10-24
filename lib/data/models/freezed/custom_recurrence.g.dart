// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_recurrence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomRecurrenceImpl _$$CustomRecurrenceImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomRecurrenceImpl(
      interval: $enumDecode(_$RepeatOptionEnumMap, json['interval']),
      frequency: (json['frequency'] as num).toInt(),
      selectedDays: (json['selectedDays'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          const [false, false, false, false, false, false, false],
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
      weekOfMonth: (json['weekOfMonth'] as num?)?.toInt(),
      month: (json['month'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CustomRecurrenceImplToJson(
        _$CustomRecurrenceImpl instance) =>
    <String, dynamic>{
      'interval': _$RepeatOptionEnumMap[instance.interval]!,
      'frequency': instance.frequency,
      'selectedDays': instance.selectedDays,
      'dayOfMonth': instance.dayOfMonth,
      'weekOfMonth': instance.weekOfMonth,
      'month': instance.month,
    };

const _$RepeatOptionEnumMap = {
  RepeatOption.today: 'today',
  RepeatOption.daily: 'daily',
  RepeatOption.weekly: 'weekly',
  RepeatOption.monthly: 'monthly',
  RepeatOption.custom: 'custom',
};
