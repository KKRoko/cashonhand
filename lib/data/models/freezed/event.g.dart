// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: (json['id'] as num?)?.toInt(),
      originalEventId: (json['originalEventId'] as num?)?.toInt(),
      title: json['title'] as String,
      categoryId: (json['categoryId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      repeatOption: $enumDecode(_$RepeatOptionEnumMap, json['repeatOption']),
      isRecurring: json['isRecurring'] as bool,
      notes: json['notes'] as String?,
      customRecurrence: json['customRecurrence'] == null
          ? null
          : CustomRecurrence.fromJson(
              json['customRecurrence'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isYearEndSummary: json['isYearEndSummary'] as bool,
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalEventId': instance.originalEventId,
      'title': instance.title,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'dateTime': instance.dateTime.toIso8601String(),
      'repeatOption': _$RepeatOptionEnumMap[instance.repeatOption]!,
      'isRecurring': instance.isRecurring,
      'notes': instance.notes,
      'customRecurrence': instance.customRecurrence?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isYearEndSummary': instance.isYearEndSummary,
    };

const _$RepeatOptionEnumMap = {
  RepeatOption.today: 'today',
  RepeatOption.daily: 'daily',
  RepeatOption.weekly: 'weekly',
  RepeatOption.monthly: 'monthly',
  RepeatOption.custom: 'custom',
};
