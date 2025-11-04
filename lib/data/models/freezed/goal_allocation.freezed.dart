// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goal_allocation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GoalAllocation _$GoalAllocationFromJson(Map<String, dynamic> json) {
  return _GoalAllocation.fromJson(json);
}

/// @nodoc
mixin _$GoalAllocation {
  int? get id => throw _privateConstructorUsedError;
  int get eventId => throw _privateConstructorUsedError;
  int get goalId => throw _privateConstructorUsedError;
  double get allocationAmount => throw _privateConstructorUsedError;
  AllocationType get allocationType => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Additional fields for UI/display purposes
  String get goalTitle => throw _privateConstructorUsedError;
  String get eventTitle => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GoalAllocationCopyWith<GoalAllocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalAllocationCopyWith<$Res> {
  factory $GoalAllocationCopyWith(
          GoalAllocation value, $Res Function(GoalAllocation) then) =
      _$GoalAllocationCopyWithImpl<$Res, GoalAllocation>;
  @useResult
  $Res call(
      {int? id,
      int eventId,
      int goalId,
      double allocationAmount,
      AllocationType allocationType,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      String goalTitle,
      String eventTitle});
}

/// @nodoc
class _$GoalAllocationCopyWithImpl<$Res, $Val extends GoalAllocation>
    implements $GoalAllocationCopyWith<$Res> {
  _$GoalAllocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? eventId = null,
    Object? goalId = null,
    Object? allocationAmount = null,
    Object? allocationType = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? goalTitle = null,
    Object? eventTitle = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      allocationAmount: null == allocationAmount
          ? _value.allocationAmount
          : allocationAmount // ignore: cast_nullable_to_non_nullable
              as double,
      allocationType: null == allocationType
          ? _value.allocationType
          : allocationType // ignore: cast_nullable_to_non_nullable
              as AllocationType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalTitle: null == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalAllocationImplCopyWith<$Res>
    implements $GoalAllocationCopyWith<$Res> {
  factory _$$GoalAllocationImplCopyWith(_$GoalAllocationImpl value,
          $Res Function(_$GoalAllocationImpl) then) =
      __$$GoalAllocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int eventId,
      int goalId,
      double allocationAmount,
      AllocationType allocationType,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt,
      String goalTitle,
      String eventTitle});
}

/// @nodoc
class __$$GoalAllocationImplCopyWithImpl<$Res>
    extends _$GoalAllocationCopyWithImpl<$Res, _$GoalAllocationImpl>
    implements _$$GoalAllocationImplCopyWith<$Res> {
  __$$GoalAllocationImplCopyWithImpl(
      _$GoalAllocationImpl _value, $Res Function(_$GoalAllocationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? eventId = null,
    Object? goalId = null,
    Object? allocationAmount = null,
    Object? allocationType = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? goalTitle = null,
    Object? eventTitle = null,
  }) {
    return _then(_$GoalAllocationImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as int,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      allocationAmount: null == allocationAmount
          ? _value.allocationAmount
          : allocationAmount // ignore: cast_nullable_to_non_nullable
              as double,
      allocationType: null == allocationType
          ? _value.allocationType
          : allocationType // ignore: cast_nullable_to_non_nullable
              as AllocationType,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalTitle: null == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalAllocationImpl implements _GoalAllocation {
  const _$GoalAllocationImpl(
      {required this.id,
      required this.eventId,
      required this.goalId,
      required this.allocationAmount,
      required this.allocationType,
      this.notes,
      this.createdAt,
      this.updatedAt,
      this.goalTitle = '',
      this.eventTitle = ''});

  factory _$GoalAllocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalAllocationImplFromJson(json);

  @override
  final int? id;
  @override
  final int eventId;
  @override
  final int goalId;
  @override
  final double allocationAmount;
  @override
  final AllocationType allocationType;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Additional fields for UI/display purposes
  @override
  @JsonKey()
  final String goalTitle;
  @override
  @JsonKey()
  final String eventTitle;

  @override
  String toString() {
    return 'GoalAllocation(id: $id, eventId: $eventId, goalId: $goalId, allocationAmount: $allocationAmount, allocationType: $allocationType, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, goalTitle: $goalTitle, eventTitle: $eventTitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalAllocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.allocationAmount, allocationAmount) ||
                other.allocationAmount == allocationAmount) &&
            (identical(other.allocationType, allocationType) ||
                other.allocationType == allocationType) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.goalTitle, goalTitle) ||
                other.goalTitle == goalTitle) &&
            (identical(other.eventTitle, eventTitle) ||
                other.eventTitle == eventTitle));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      goalId,
      allocationAmount,
      allocationType,
      notes,
      createdAt,
      updatedAt,
      goalTitle,
      eventTitle);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalAllocationImplCopyWith<_$GoalAllocationImpl> get copyWith =>
      __$$GoalAllocationImplCopyWithImpl<_$GoalAllocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalAllocationImplToJson(
      this,
    );
  }
}

abstract class _GoalAllocation implements GoalAllocation {
  const factory _GoalAllocation(
      {required final int? id,
      required final int eventId,
      required final int goalId,
      required final double allocationAmount,
      required final AllocationType allocationType,
      final String? notes,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String goalTitle,
      final String eventTitle}) = _$GoalAllocationImpl;

  factory _GoalAllocation.fromJson(Map<String, dynamic> json) =
      _$GoalAllocationImpl.fromJson;

  @override
  int? get id;
  @override
  int get eventId;
  @override
  int get goalId;
  @override
  double get allocationAmount;
  @override
  AllocationType get allocationType;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override // Additional fields for UI/display purposes
  String get goalTitle;
  @override
  String get eventTitle;
  @override
  @JsonKey(ignore: true)
  _$$GoalAllocationImplCopyWith<_$GoalAllocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
