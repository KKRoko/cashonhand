// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Budget _$BudgetFromJson(Map<String, dynamic> json) {
  return _Budget.fromJson(json);
}

/// @nodoc
mixin _$Budget {
  int get id => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError; // 1-12
  int get year => throw _privateConstructorUsedError; // e.g., 2025
  double get monthlyIncome => throw _privateConstructorUsedError;
  int get cycleStartDay => throw _privateConstructorUsedError; // 1-31
  double get needsPercentage =>
      throw _privateConstructorUsedError; // 0.0-1.0 (e.g., 0.50 = 50%)
  double get wantsPercentage => throw _privateConstructorUsedError;
  double get savingsPercentage => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Budget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BudgetCopyWith<Budget> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetCopyWith<$Res> {
  factory $BudgetCopyWith(Budget value, $Res Function(Budget) then) =
      _$BudgetCopyWithImpl<$Res, Budget>;
  @useResult
  $Res call(
      {int id,
      int month,
      int year,
      double monthlyIncome,
      int cycleStartDay,
      double needsPercentage,
      double wantsPercentage,
      double savingsPercentage,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$BudgetCopyWithImpl<$Res, $Val extends Budget>
    implements $BudgetCopyWith<$Res> {
  _$BudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? year = null,
    Object? monthlyIncome = null,
    Object? cycleStartDay = null,
    Object? needsPercentage = null,
    Object? wantsPercentage = null,
    Object? savingsPercentage = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as double,
      cycleStartDay: null == cycleStartDay
          ? _value.cycleStartDay
          : cycleStartDay // ignore: cast_nullable_to_non_nullable
              as int,
      needsPercentage: null == needsPercentage
          ? _value.needsPercentage
          : needsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      wantsPercentage: null == wantsPercentage
          ? _value.wantsPercentage
          : wantsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      savingsPercentage: null == savingsPercentage
          ? _value.savingsPercentage
          : savingsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetImplCopyWith<$Res> implements $BudgetCopyWith<$Res> {
  factory _$$BudgetImplCopyWith(
          _$BudgetImpl value, $Res Function(_$BudgetImpl) then) =
      __$$BudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int month,
      int year,
      double monthlyIncome,
      int cycleStartDay,
      double needsPercentage,
      double wantsPercentage,
      double savingsPercentage,
      bool isActive,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$BudgetImplCopyWithImpl<$Res>
    extends _$BudgetCopyWithImpl<$Res, _$BudgetImpl>
    implements _$$BudgetImplCopyWith<$Res> {
  __$$BudgetImplCopyWithImpl(
      _$BudgetImpl _value, $Res Function(_$BudgetImpl) _then)
      : super(_value, _then);

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? year = null,
    Object? monthlyIncome = null,
    Object? cycleStartDay = null,
    Object? needsPercentage = null,
    Object? wantsPercentage = null,
    Object? savingsPercentage = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$BudgetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      monthlyIncome: null == monthlyIncome
          ? _value.monthlyIncome
          : monthlyIncome // ignore: cast_nullable_to_non_nullable
              as double,
      cycleStartDay: null == cycleStartDay
          ? _value.cycleStartDay
          : cycleStartDay // ignore: cast_nullable_to_non_nullable
              as int,
      needsPercentage: null == needsPercentage
          ? _value.needsPercentage
          : needsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      wantsPercentage: null == wantsPercentage
          ? _value.wantsPercentage
          : wantsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      savingsPercentage: null == savingsPercentage
          ? _value.savingsPercentage
          : savingsPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetImpl extends _Budget {
  const _$BudgetImpl(
      {required this.id,
      required this.month,
      required this.year,
      required this.monthlyIncome,
      required this.cycleStartDay,
      required this.needsPercentage,
      required this.wantsPercentage,
      required this.savingsPercentage,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  factory _$BudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetImplFromJson(json);

  @override
  final int id;
  @override
  final int month;
// 1-12
  @override
  final int year;
// e.g., 2025
  @override
  final double monthlyIncome;
  @override
  final int cycleStartDay;
// 1-31
  @override
  final double needsPercentage;
// 0.0-1.0 (e.g., 0.50 = 50%)
  @override
  final double wantsPercentage;
  @override
  final double savingsPercentage;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Budget(id: $id, month: $month, year: $year, monthlyIncome: $monthlyIncome, cycleStartDay: $cycleStartDay, needsPercentage: $needsPercentage, wantsPercentage: $wantsPercentage, savingsPercentage: $savingsPercentage, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.monthlyIncome, monthlyIncome) ||
                other.monthlyIncome == monthlyIncome) &&
            (identical(other.cycleStartDay, cycleStartDay) ||
                other.cycleStartDay == cycleStartDay) &&
            (identical(other.needsPercentage, needsPercentage) ||
                other.needsPercentage == needsPercentage) &&
            (identical(other.wantsPercentage, wantsPercentage) ||
                other.wantsPercentage == wantsPercentage) &&
            (identical(other.savingsPercentage, savingsPercentage) ||
                other.savingsPercentage == savingsPercentage) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      month,
      year,
      monthlyIncome,
      cycleStartDay,
      needsPercentage,
      wantsPercentage,
      savingsPercentage,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      __$$BudgetImplCopyWithImpl<_$BudgetImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetImplToJson(
      this,
    );
  }
}

abstract class _Budget extends Budget {
  const factory _Budget(
      {required final int id,
      required final int month,
      required final int year,
      required final double monthlyIncome,
      required final int cycleStartDay,
      required final double needsPercentage,
      required final double wantsPercentage,
      required final double savingsPercentage,
      required final bool isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$BudgetImpl;
  const _Budget._() : super._();

  factory _Budget.fromJson(Map<String, dynamic> json) = _$BudgetImpl.fromJson;

  @override
  int get id;
  @override
  int get month; // 1-12
  @override
  int get year; // e.g., 2025
  @override
  double get monthlyIncome;
  @override
  int get cycleStartDay; // 1-31
  @override
  double get needsPercentage; // 0.0-1.0 (e.g., 0.50 = 50%)
  @override
  double get wantsPercentage;
  @override
  double get savingsPercentage;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Budget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BudgetImplCopyWith<_$BudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
