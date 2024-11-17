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
  int? get id => throw _privateConstructorUsedError;
  int? get originalEventId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  RepeatOption get repeatOption => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  CustomRecurrence? get customRecurrence => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isYearEndSummary => throw _privateConstructorUsedError;

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
      {int? id,
      int? originalEventId,
      String title,
      int categoryId,
      double amount,
      DateTime dateTime,
      RepeatOption repeatOption,
      bool isRecurring,
      String? notes,
      CustomRecurrence? customRecurrence,
      DateTime createdAt,
      DateTime updatedAt,
      bool isYearEndSummary});

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
    Object? id = freezed,
    Object? originalEventId = freezed,
    Object? title = null,
    Object? categoryId = null,
    Object? amount = null,
    Object? dateTime = null,
    Object? repeatOption = null,
    Object? isRecurring = null,
    Object? notes = freezed,
    Object? customRecurrence = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isYearEndSummary = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      originalEventId: freezed == originalEventId
          ? _value.originalEventId
          : originalEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      repeatOption: null == repeatOption
          ? _value.repeatOption
          : repeatOption // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      customRecurrence: freezed == customRecurrence
          ? _value.customRecurrence
          : customRecurrence // ignore: cast_nullable_to_non_nullable
              as CustomRecurrence?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearEndSummary: null == isYearEndSummary
          ? _value.isYearEndSummary
          : isYearEndSummary // ignore: cast_nullable_to_non_nullable
              as bool,
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
      {int? id,
      int? originalEventId,
      String title,
      int categoryId,
      double amount,
      DateTime dateTime,
      RepeatOption repeatOption,
      bool isRecurring,
      String? notes,
      CustomRecurrence? customRecurrence,
      DateTime createdAt,
      DateTime updatedAt,
      bool isYearEndSummary});

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
    Object? id = freezed,
    Object? originalEventId = freezed,
    Object? title = null,
    Object? categoryId = null,
    Object? amount = null,
    Object? dateTime = null,
    Object? repeatOption = null,
    Object? isRecurring = null,
    Object? notes = freezed,
    Object? customRecurrence = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isYearEndSummary = null,
  }) {
    return _then(_$EventImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      originalEventId: freezed == originalEventId
          ? _value.originalEventId
          : originalEventId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      repeatOption: null == repeatOption
          ? _value.repeatOption
          : repeatOption // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      customRecurrence: freezed == customRecurrence
          ? _value.customRecurrence
          : customRecurrence // ignore: cast_nullable_to_non_nullable
              as CustomRecurrence?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isYearEndSummary: null == isYearEndSummary
          ? _value.isYearEndSummary
          : isYearEndSummary // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl extends _Event {
  const _$EventImpl(
      {this.id,
      this.originalEventId,
      required this.title,
      required this.categoryId,
      required this.amount,
      required this.dateTime,
      required this.repeatOption,
      required this.isRecurring,
      this.notes,
      this.customRecurrence,
      required this.createdAt,
      required this.updatedAt,
      required this.isYearEndSummary})
      : super._();

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final int? id;
  @override
  final int? originalEventId;
  @override
  final String title;
  @override
  final int categoryId;
  @override
  final double amount;
  @override
  final DateTime dateTime;
  @override
  final RepeatOption repeatOption;
  @override
  final bool isRecurring;
  @override
  final String? notes;
  @override
  final CustomRecurrence? customRecurrence;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final bool isYearEndSummary;

  @override
  String toString() {
    return 'Event(id: $id, originalEventId: $originalEventId, title: $title, categoryId: $categoryId, amount: $amount, dateTime: $dateTime, repeatOption: $repeatOption, isRecurring: $isRecurring, notes: $notes, customRecurrence: $customRecurrence, createdAt: $createdAt, updatedAt: $updatedAt, isYearEndSummary: $isYearEndSummary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.originalEventId, originalEventId) ||
                other.originalEventId == originalEventId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.repeatOption, repeatOption) ||
                other.repeatOption == repeatOption) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.customRecurrence, customRecurrence) ||
                other.customRecurrence == customRecurrence) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isYearEndSummary, isYearEndSummary) ||
                other.isYearEndSummary == isYearEndSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      originalEventId,
      title,
      categoryId,
      amount,
      dateTime,
      repeatOption,
      isRecurring,
      notes,
      customRecurrence,
      createdAt,
      updatedAt,
      isYearEndSummary);

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
      {final int? id,
      final int? originalEventId,
      required final String title,
      required final int categoryId,
      required final double amount,
      required final DateTime dateTime,
      required final RepeatOption repeatOption,
      required final bool isRecurring,
      final String? notes,
      final CustomRecurrence? customRecurrence,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final bool isYearEndSummary}) = _$EventImpl;
  const _Event._() : super._();

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  int? get id;
  @override
  int? get originalEventId;
  @override
  String get title;
  @override
  int get categoryId;
  @override
  double get amount;
  @override
  DateTime get dateTime;
  @override
  RepeatOption get repeatOption;
  @override
  bool get isRecurring;
  @override
  String? get notes;
  @override
  CustomRecurrence? get customRecurrence;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  bool get isYearEndSummary;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
