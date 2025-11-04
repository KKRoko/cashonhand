// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saving_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SavingGoal _$SavingGoalFromJson(Map<String, dynamic> json) {
  return _SavingGoal.fromJson(json);
}

/// @nodoc
mixin _$SavingGoal {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  GoalType get goalType => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get deadlineDate => throw _privateConstructorUsedError;
  RecurringPeriod? get recurringPeriod => throw _privateConstructorUsedError;
  double? get recurringTargetAmount => throw _privateConstructorUsedError;
  List<DateTime>? get checkpoints => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavingGoalCopyWith<SavingGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingGoalCopyWith<$Res> {
  factory $SavingGoalCopyWith(
          SavingGoal value, $Res Function(SavingGoal) then) =
      _$SavingGoalCopyWithImpl<$Res, SavingGoal>;
  @useResult
  $Res call(
      {int id,
      String title,
      String description,
      double targetAmount,
      double currentAmount,
      GoalType goalType,
      bool isCompleted,
      DateTime createdAt,
      DateTime? deadlineDate,
      RecurringPeriod? recurringPeriod,
      double? recurringTargetAmount,
      List<DateTime>? checkpoints});
}

/// @nodoc
class _$SavingGoalCopyWithImpl<$Res, $Val extends SavingGoal>
    implements $SavingGoalCopyWith<$Res> {
  _$SavingGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? goalType = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? deadlineDate = freezed,
    Object? recurringPeriod = freezed,
    Object? recurringTargetAmount = freezed,
    Object? checkpoints = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as GoalType,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deadlineDate: freezed == deadlineDate
          ? _value.deadlineDate
          : deadlineDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recurringPeriod: freezed == recurringPeriod
          ? _value.recurringPeriod
          : recurringPeriod // ignore: cast_nullable_to_non_nullable
              as RecurringPeriod?,
      recurringTargetAmount: freezed == recurringTargetAmount
          ? _value.recurringTargetAmount
          : recurringTargetAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      checkpoints: freezed == checkpoints
          ? _value.checkpoints
          : checkpoints // ignore: cast_nullable_to_non_nullable
              as List<DateTime>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavingGoalImplCopyWith<$Res>
    implements $SavingGoalCopyWith<$Res> {
  factory _$$SavingGoalImplCopyWith(
          _$SavingGoalImpl value, $Res Function(_$SavingGoalImpl) then) =
      __$$SavingGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String description,
      double targetAmount,
      double currentAmount,
      GoalType goalType,
      bool isCompleted,
      DateTime createdAt,
      DateTime? deadlineDate,
      RecurringPeriod? recurringPeriod,
      double? recurringTargetAmount,
      List<DateTime>? checkpoints});
}

/// @nodoc
class __$$SavingGoalImplCopyWithImpl<$Res>
    extends _$SavingGoalCopyWithImpl<$Res, _$SavingGoalImpl>
    implements _$$SavingGoalImplCopyWith<$Res> {
  __$$SavingGoalImplCopyWithImpl(
      _$SavingGoalImpl _value, $Res Function(_$SavingGoalImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? goalType = null,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? deadlineDate = freezed,
    Object? recurringPeriod = freezed,
    Object? recurringTargetAmount = freezed,
    Object? checkpoints = freezed,
  }) {
    return _then(_$SavingGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      goalType: null == goalType
          ? _value.goalType
          : goalType // ignore: cast_nullable_to_non_nullable
              as GoalType,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deadlineDate: freezed == deadlineDate
          ? _value.deadlineDate
          : deadlineDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recurringPeriod: freezed == recurringPeriod
          ? _value.recurringPeriod
          : recurringPeriod // ignore: cast_nullable_to_non_nullable
              as RecurringPeriod?,
      recurringTargetAmount: freezed == recurringTargetAmount
          ? _value.recurringTargetAmount
          : recurringTargetAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      checkpoints: freezed == checkpoints
          ? _value._checkpoints
          : checkpoints // ignore: cast_nullable_to_non_nullable
              as List<DateTime>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingGoalImpl extends _SavingGoal {
  const _$SavingGoalImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.targetAmount,
      required this.currentAmount,
      required this.goalType,
      required this.isCompleted,
      required this.createdAt,
      this.deadlineDate,
      this.recurringPeriod,
      this.recurringTargetAmount,
      final List<DateTime>? checkpoints})
      : _checkpoints = checkpoints,
        super._();

  factory _$SavingGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingGoalImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final GoalType goalType;
  @override
  final bool isCompleted;
  @override
  final DateTime createdAt;
  @override
  final DateTime? deadlineDate;
  @override
  final RecurringPeriod? recurringPeriod;
  @override
  final double? recurringTargetAmount;
  final List<DateTime>? _checkpoints;
  @override
  List<DateTime>? get checkpoints {
    final value = _checkpoints;
    if (value == null) return null;
    if (_checkpoints is EqualUnmodifiableListView) return _checkpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SavingGoal(id: $id, title: $title, description: $description, targetAmount: $targetAmount, currentAmount: $currentAmount, goalType: $goalType, isCompleted: $isCompleted, createdAt: $createdAt, deadlineDate: $deadlineDate, recurringPeriod: $recurringPeriod, recurringTargetAmount: $recurringTargetAmount, checkpoints: $checkpoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.goalType, goalType) ||
                other.goalType == goalType) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.deadlineDate, deadlineDate) ||
                other.deadlineDate == deadlineDate) &&
            (identical(other.recurringPeriod, recurringPeriod) ||
                other.recurringPeriod == recurringPeriod) &&
            (identical(other.recurringTargetAmount, recurringTargetAmount) ||
                other.recurringTargetAmount == recurringTargetAmount) &&
            const DeepCollectionEquality()
                .equals(other._checkpoints, _checkpoints));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      targetAmount,
      currentAmount,
      goalType,
      isCompleted,
      createdAt,
      deadlineDate,
      recurringPeriod,
      recurringTargetAmount,
      const DeepCollectionEquality().hash(_checkpoints));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingGoalImplCopyWith<_$SavingGoalImpl> get copyWith =>
      __$$SavingGoalImplCopyWithImpl<_$SavingGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingGoalImplToJson(
      this,
    );
  }
}

abstract class _SavingGoal extends SavingGoal {
  const factory _SavingGoal(
      {required final int id,
      required final String title,
      required final String description,
      required final double targetAmount,
      required final double currentAmount,
      required final GoalType goalType,
      required final bool isCompleted,
      required final DateTime createdAt,
      final DateTime? deadlineDate,
      final RecurringPeriod? recurringPeriod,
      final double? recurringTargetAmount,
      final List<DateTime>? checkpoints}) = _$SavingGoalImpl;
  const _SavingGoal._() : super._();

  factory _SavingGoal.fromJson(Map<String, dynamic> json) =
      _$SavingGoalImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  GoalType get goalType;
  @override
  bool get isCompleted;
  @override
  DateTime get createdAt;
  @override
  DateTime? get deadlineDate;
  @override
  RecurringPeriod? get recurringPeriod;
  @override
  double? get recurringTargetAmount;
  @override
  List<DateTime>? get checkpoints;
  @override
  @JsonKey(ignore: true)
  _$$SavingGoalImplCopyWith<_$SavingGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
