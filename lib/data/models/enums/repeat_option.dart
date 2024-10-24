import 'package:json_annotation/json_annotation.dart';

enum RepeatOption {
  @JsonValue('today')
  today,
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('custom')
  custom
}