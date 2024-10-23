import 'package:json_annotation/json_annotation.dart';

enum DeleteOption {
  @JsonValue('thisDay')
  thisDay,
  @JsonValue('allTime')
  allTime,
  @JsonValue('futureOnly')
  futureOnly,
  @JsonValue('pastOnly')
  pastOnly,
}