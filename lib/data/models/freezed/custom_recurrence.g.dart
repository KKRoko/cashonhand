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
          const [],
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
      repeatAtEndOfMonth: json['repeatAtEndOfMonth'] as bool? ?? false,
      useLastDayOfMonth: json['useLastDayOfMonth'] as bool? ?? false,
      originalDate: json['originalDate'] == null
          ? null
          : DateTime.parse(json['originalDate'] as String),
    );

Map<String, dynamic> _$$CustomRecurrenceImplToJson(
        _$CustomRecurrenceImpl instance) =>
    <String, dynamic>{
      'interval': _$RepeatOptionEnumMap[instance.interval]!,
      'frequency': instance.frequency,
      'selectedDays': instance.selectedDays,
      'dayOfMonth': instance.dayOfMonth,
      'repeatAtEndOfMonth': instance.repeatAtEndOfMonth,
      'useLastDayOfMonth': instance.useLastDayOfMonth,
      'originalDate': instance.originalDate?.toIso8601String(),
    };

const _$RepeatOptionEnumMap = {
  RepeatOption.today: 'today',
  RepeatOption.daily: 'daily',
  RepeatOption.weekly: 'weekly',
  RepeatOption.monthly: 'monthly',
  RepeatOption.custom: 'custom',
};
