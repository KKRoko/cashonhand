// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'year_end_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

YearEndGoal _$YearEndGoalFromJson(Map<String, dynamic> json) {
  return _YearEndGoal.fromJson(json);
}

/// @nodoc
mixin _$YearEndGoal {
  int get id => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError; // e.g., 2025
  double get needsPercentage =>
      throw _privateConstructorUsedError; // annual percentage goal for needs bucket (0.0-1.0)
  double get wantsPercentage =>
      throw _privateConstructorUsedError; // annual percentage goal for wants bucket (0.0-1.0)
  double get savingsPercentage =>
      throw _privateConstructorUsedError; // annual percentage goal for savings bucket (0.0-1.0)
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this YearEndGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of YearEndGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $YearEndGoalCopyWith<YearEndGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearEndGoalCopyWith<$Res> {
  factory $YearEndGoalCopyWith(
          YearEndGoal value, $Res Function(YearEndGoal) then) =
      _$YearEndGoalCopyWithImpl<$Res, YearEndGoal>;
  @useResult
  $Res call(
      {int id,
      int year,
      double needsPercentage,
      double wantsPercentage,
      double savingsPercentage,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$YearEndGoalCopyWithImpl<$Res, $Val extends YearEndGoal>
    implements $YearEndGoalCopyWith<$Res> {
  _$YearEndGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of YearEndGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? needsPercentage = null,
    Object? wantsPercentage = null,
    Object? savingsPercentage = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
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
abstract class _$$YearEndGoalImplCopyWith<$Res>
    implements $YearEndGoalCopyWith<$Res> {
  factory _$$YearEndGoalImplCopyWith(
          _$YearEndGoalImpl value, $Res Function(_$YearEndGoalImpl) then) =
      __$$YearEndGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int year,
      double needsPercentage,
      double wantsPercentage,
      double savingsPercentage,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$YearEndGoalImplCopyWithImpl<$Res>
    extends _$YearEndGoalCopyWithImpl<$Res, _$YearEndGoalImpl>
    implements _$$YearEndGoalImplCopyWith<$Res> {
  __$$YearEndGoalImplCopyWithImpl(
      _$YearEndGoalImpl _value, $Res Function(_$YearEndGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of YearEndGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? needsPercentage = null,
    Object? wantsPercentage = null,
    Object? savingsPercentage = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$YearEndGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
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
class _$YearEndGoalImpl extends _YearEndGoal {
  const _$YearEndGoalImpl(
      {required this.id,
      required this.year,
      required this.needsPercentage,
      required this.wantsPercentage,
      required this.savingsPercentage,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  factory _$YearEndGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$YearEndGoalImplFromJson(json);

  @override
  final int id;
  @override
  final int year;
// e.g., 2025
  @override
  final double needsPercentage;
// annual percentage goal for needs bucket (0.0-1.0)
  @override
  final double wantsPercentage;
// annual percentage goal for wants bucket (0.0-1.0)
  @override
  final double savingsPercentage;
// annual percentage goal for savings bucket (0.0-1.0)
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'YearEndGoal(id: $id, year: $year, needsPercentage: $needsPercentage, wantsPercentage: $wantsPercentage, savingsPercentage: $savingsPercentage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearEndGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.needsPercentage, needsPercentage) ||
                other.needsPercentage == needsPercentage) &&
            (identical(other.wantsPercentage, wantsPercentage) ||
                other.wantsPercentage == wantsPercentage) &&
            (identical(other.savingsPercentage, savingsPercentage) ||
                other.savingsPercentage == savingsPercentage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, year, needsPercentage,
      wantsPercentage, savingsPercentage, createdAt, updatedAt);

  /// Create a copy of YearEndGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$YearEndGoalImplCopyWith<_$YearEndGoalImpl> get copyWith =>
      __$$YearEndGoalImplCopyWithImpl<_$YearEndGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$YearEndGoalImplToJson(
      this,
    );
  }
}

abstract class _YearEndGoal extends YearEndGoal {
  const factory _YearEndGoal(
      {required final int id,
      required final int year,
      required final double needsPercentage,
      required final double wantsPercentage,
      required final double savingsPercentage,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$YearEndGoalImpl;
  const _YearEndGoal._() : super._();

  factory _YearEndGoal.fromJson(Map<String, dynamic> json) =
      _$YearEndGoalImpl.fromJson;

  @override
  int get id;
  @override
  int get year; // e.g., 2025
  @override
  double
      get needsPercentage; // annual percentage goal for needs bucket (0.0-1.0)
  @override
  double
      get wantsPercentage; // annual percentage goal for wants bucket (0.0-1.0)
  @override
  double
      get savingsPercentage; // annual percentage goal for savings bucket (0.0-1.0)
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of YearEndGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$YearEndGoalImplCopyWith<_$YearEndGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
