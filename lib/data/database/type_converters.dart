// lib/data/database/type_converters.dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../models/freezed/custom_recurrence.dart';
import '../models/enums/repeat_option.dart';
import '../models/enums/category_type.dart';

class CustomRecurrenceConverter extends TypeConverter<CustomRecurrence, String> {
  const CustomRecurrenceConverter();

  @override
  CustomRecurrence fromSql(String fromDb) {
    return CustomRecurrence.fromJson(json.decode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(CustomRecurrence value) {
    return json.encode(value.toJson());
  }
}

class RepeatOptionConverter extends TypeConverter<RepeatOption, String> {
  const RepeatOptionConverter();

  @override
  RepeatOption fromSql(String fromDb) {
    return RepeatOption.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(RepeatOption value) {
    return value.toString().split('.').last;
  }
}

class CategoryTypeConverter extends TypeConverter<CategoryType, String> {
  const CategoryTypeConverter();

  @override
  CategoryType fromSql(String fromDb) {
    return CategoryType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(CategoryType value) {
    return value.toString().split('.').last;
  }
}