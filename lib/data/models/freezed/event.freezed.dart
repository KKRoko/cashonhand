// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  bool get isPositiveCashflow => throw _privateConstructorUsedError;
  bool get isNegativeCashflow => throw _privateConstructorUsedError;
  RepeatOption get repeatOption => throw _privateConstructorUsedError;
  CustomRecurrence? get customRecurrence => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isYearEndSummary => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      String title,
      double? amount,
      bool isPositiveCashflow,
      bool isNegativeCashflow,
      RepeatOption repeatOption,
      CustomRecurrence? customRecurrence,
      DateTime createdAt,
      bool isYearEndSummary,
      DateTime dateTime});

  $CustomRecurrenceCopyWith<$Res>? get customRecurrence;
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = freezed,
    Object? isPositiveCashflow = null,
    Object? isNegativeCashflow = null,
    Object? repeatOption = null,
    Object? customRecurrence = freezed,
    Object? createdAt = null,
    Object? isYearEndSummary = null,
    Object? dateTime = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      isPositiveCashflow: null == isPositiveCashflow
          ? _value.isPositiveCashflow
          : isPositiveCashflow // ignore: cast_nullable_to_non_nullable
              as bool,
      isNegativeCashflow: null == isNegativeCashflow
          ? _value.isNegativeCashflow
          : isNegativeCashflow // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatOption: null == repeatOption
          ? _value.repeatOption
          : repeatOption // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      customRecurrence: freezed == customRecurrence
          ? _value.customRecurrence
          : customRecurrence // ignore: cast_nullable_to_non_nullable
              as CustomRecurrence?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearEndSummary: null == isYearEndSummary
          ? _value.isYearEndSummary
          : isYearEndSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomRecurrenceCopyWith<$Res>? get customRecurrence {
    if (_value.customRecurrence == null) {
      return null;
    }

    return $CustomRecurrenceCopyWith<$Res>(_value.customRecurrence!, (value) {
      return _then(_value.copyWith(customRecurrence: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double? amount,
      bool isPositiveCashflow,
      bool isNegativeCashflow,
      RepeatOption repeatOption,
      CustomRecurrence? customRecurrence,
      DateTime createdAt,
      bool isYearEndSummary,
      DateTime dateTime});

  @override
  $CustomRecurrenceCopyWith<$Res>? get customRecurrence;
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = freezed,
    Object? isPositiveCashflow = null,
    Object? isNegativeCashflow = null,
    Object? repeatOption = null,
    Object? customRecurrence = freezed,
    Object? createdAt = null,
    Object? isYearEndSummary = null,
    Object? dateTime = null,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      isPositiveCashflow: null == isPositiveCashflow
          ? _value.isPositiveCashflow
          : isPositiveCashflow // ignore: cast_nullable_to_non_nullable
              as bool,
      isNegativeCashflow: null == isNegativeCashflow
          ? _value.isNegativeCashflow
          : isNegativeCashflow // ignore: cast_nullable_to_non_nullable
              as bool,
      repeatOption: null == repeatOption
          ? _value.repeatOption
          : repeatOption // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      customRecurrence: freezed == customRecurrence
          ? _value.customRecurrence
          : customRecurrence // ignore: cast_nullable_to_non_nullable
              as CustomRecurrence?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearEndSummary: null == isYearEndSummary
          ? _value.isYearEndSummary
          : isYearEndSummary // ignore: cast_nullable_to_non_nullable
              as bool,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl extends _Event {
  const _$EventImpl(
      {required this.id,
      required this.title,
      this.amount,
      required this.isPositiveCashflow,
      required this.isNegativeCashflow,
      required this.repeatOption,
      this.customRecurrence,
      required this.createdAt,
      this.isYearEndSummary = true,
      required this.dateTime})
      : super._();

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double? amount;
  @override
  final bool isPositiveCashflow;
  @override
  final bool isNegativeCashflow;
  @override
  final RepeatOption repeatOption;
  @override
  final CustomRecurrence? customRecurrence;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isYearEndSummary;
  @override
  final DateTime dateTime;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, amount: $amount, isPositiveCashflow: $isPositiveCashflow, isNegativeCashflow: $isNegativeCashflow, repeatOption: $repeatOption, customRecurrence: $customRecurrence, createdAt: $createdAt, isYearEndSummary: $isYearEndSummary, dateTime: $dateTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.isPositiveCashflow, isPositiveCashflow) ||
                other.isPositiveCashflow == isPositiveCashflow) &&
            (identical(other.isNegativeCashflow, isNegativeCashflow) ||
                other.isNegativeCashflow == isNegativeCashflow) &&
            (identical(other.repeatOption, repeatOption) ||
                other.repeatOption == repeatOption) &&
            (identical(other.customRecurrence, customRecurrence) ||
                other.customRecurrence == customRecurrence) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isYearEndSummary, isYearEndSummary) ||
                other.isYearEndSummary == isYearEndSummary) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      amount,
      isPositiveCashflow,
      isNegativeCashflow,
      repeatOption,
      customRecurrence,
      createdAt,
      isYearEndSummary,
      dateTime);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event extends Event {
  const factory _Event(
      {required final String id,
      required final String title,
      final double? amount,
      required final bool isPositiveCashflow,
      required final bool isNegativeCashflow,
      required final RepeatOption repeatOption,
      final CustomRecurrence? customRecurrence,
      required final DateTime createdAt,
      final bool isYearEndSummary,
      required final DateTime dateTime}) = _$EventImpl;
  const _Event._() : super._();

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double? get amount;
  @override
  bool get isPositiveCashflow;
  @override
  bool get isNegativeCashflow;
  @override
  RepeatOption get repeatOption;
  @override
  CustomRecurrence? get customRecurrence;
  @override
  DateTime get createdAt;
  @override
  bool get isYearEndSummary;
  @override
  DateTime get dateTime;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
