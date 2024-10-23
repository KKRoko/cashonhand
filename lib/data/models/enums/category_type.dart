import 'package:json_annotation/json_annotation.dart';

enum CategoryType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
  @JsonValue('both')
  both
}