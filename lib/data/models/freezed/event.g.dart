// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      isPositiveCashflow: json['isPositiveCashflow'] as bool,
      isNegativeCashflow: json['isNegativeCashflow'] as bool,
      repeatOption: $enumDecode(_$RepeatOptionEnumMap, json['repeatOption']),
      customRecurrence: json['customRecurrence'] == null
          ? null
          : CustomRecurrence.fromJson(
              json['customRecurrence'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isYearEndSummary: json['isYearEndSummary'] as bool? ?? true,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'isPositiveCashflow': instance.isPositiveCashflow,
      'isNegativeCashflow': instance.isNegativeCashflow,
      'repeatOption': _$RepeatOptionEnumMap[instance.repeatOption]!,
      'customRecurrence': instance.customRecurrence?.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
      'isYearEndSummary': instance.isYearEndSummary,
      'dateTime': instance.dateTime.toIso8601String(),
    };

const _$RepeatOptionEnumMap = {
  RepeatOption.today: 'today',
  RepeatOption.daily: 'daily',
  RepeatOption.weekly: 'weekly',
  RepeatOption.monthly: 'monthly',
  RepeatOption.yearly: 'yearly',
  RepeatOption.custom: 'custom',
};
