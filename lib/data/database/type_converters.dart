// lib/data/database/type_converters.dart
import 'package:drift/drift.dart';
import '../models/enums/goal_type.dart';
import '../models/enums/recurring_period.dart';
import '../models/freezed/achievement_base_implementation.dart';
import '../models/freezed/custom_recurrence.dart';
import '../models/enums/repeat_option.dart';
import '../models/enums/category_type.dart';
import '../models/enums/allocation_type.dart';
import '../models/enums/trigger_type.dart';
import '../models/enums/allocation_method.dart';
import '../models/enums/bucket_type.dart';
import '../../utils/money.dart';
import 'dart:convert';

class CustomRecurrenceConverter
    extends TypeConverter<CustomRecurrence, String> {
  const CustomRecurrenceConverter();

  @override
  CustomRecurrence fromSql(String fromDb) {
    final Map<String, dynamic> json = jsonDecode(fromDb);
    return CustomRecurrence.fromJson(json);
  }

  @override
  String toSql(CustomRecurrence value) {
    return jsonEncode(value.toJson());
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

class GoalTypeConverter extends TypeConverter<GoalType, String> {
  const GoalTypeConverter();

  @override
  GoalType fromSql(String fromDb) {
    return GoalType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(GoalType value) {
    return value.toString().split('.').last;
  }
}

class RecurringPeriodConverter extends TypeConverter<RecurringPeriod, String> {
  const RecurringPeriodConverter();

  @override
  RecurringPeriod fromSql(String fromDb) {
    return RecurringPeriod.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(RecurringPeriod value) {
    return value.toString().split('.').last;
  }
}

class AchievementTypeConverter extends TypeConverter<AchievementType, String> {
  const AchievementTypeConverter();

  @override
  AchievementType fromSql(String fromDb) {
    return AchievementType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(AchievementType value) {
    return value.toString().split('.').last;
  }
}

class AllocationTypeConverter extends TypeConverter<AllocationType, String> {
  const AllocationTypeConverter();

  @override
  AllocationType fromSql(String fromDb) {
    return AllocationType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(AllocationType value) {
    return value.toString().split('.').last;
  }
}

class TriggerTypeConverter extends TypeConverter<TriggerType, String> {
  const TriggerTypeConverter();

  @override
  TriggerType fromSql(String fromDb) {
    return TriggerType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(TriggerType value) {
    return value.toString().split('.').last;
  }
}

class AllocationMethodConverter extends TypeConverter<AllocationMethod, String> {
  const AllocationMethodConverter();

  @override
  AllocationMethod fromSql(String fromDb) {
    return AllocationMethod.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(AllocationMethod value) {
    return value.toString().split('.').last;
  }
}

class BucketTypeConverter extends TypeConverter<BucketType, String> {
  const BucketTypeConverter();

  @override
  BucketType fromSql(String fromDb) {
    return BucketType.values.firstWhere(
      (e) => e.toString().split('.').last == fromDb,
    );
  }

  @override
  String toSql(BucketType value) {
    return value.toString().split('.').last;
  }
}

/// Converter for Money type - stores as double in database for compatibility
/// but provides precise decimal arithmetic in the application
class MoneyConverter extends TypeConverter<Money, double> {
  const MoneyConverter();

  @override
  Money fromSql(double fromDb) {
    return Money.fromDouble(fromDb);
  }

  @override
  double toSql(Money value) {
    return value.toDouble;
  }
}
