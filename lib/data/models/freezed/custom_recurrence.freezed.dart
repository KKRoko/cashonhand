// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'custom_recurrence.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CustomRecurrence _$CustomRecurrenceFromJson(Map<String, dynamic> json) {
  return _CustomRecurrence.fromJson(json);
}

/// @nodoc
mixin _$CustomRecurrence {
  RepeatOption get interval => throw _privateConstructorUsedError;
  int get frequency => throw _privateConstructorUsedError;
  List<bool> get selectedDays => throw _privateConstructorUsedError;
  int? get dayOfMonth => throw _privateConstructorUsedError;
  int? get weekOfMonth => throw _privateConstructorUsedError;
  int? get month => throw _privateConstructorUsedError;

  /// Serializes this CustomRecurrence to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CustomRecurrence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomRecurrenceCopyWith<CustomRecurrence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomRecurrenceCopyWith<$Res> {
  factory $CustomRecurrenceCopyWith(
          CustomRecurrence value, $Res Function(CustomRecurrence) then) =
      _$CustomRecurrenceCopyWithImpl<$Res, CustomRecurrence>;
  @useResult
  $Res call(
      {RepeatOption interval,
      int frequency,
      List<bool> selectedDays,
      int? dayOfMonth,
      int? weekOfMonth,
      int? month});
}

/// @nodoc
class _$CustomRecurrenceCopyWithImpl<$Res, $Val extends CustomRecurrence>
    implements $CustomRecurrenceCopyWith<$Res> {
  _$CustomRecurrenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomRecurrence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? frequency = null,
    Object? selectedDays = null,
    Object? dayOfMonth = freezed,
    Object? weekOfMonth = freezed,
    Object? month = freezed,
  }) {
    return _then(_value.copyWith(
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as int,
      selectedDays: null == selectedDays
          ? _value.selectedDays
          : selectedDays // ignore: cast_nullable_to_non_nullable
              as List<bool>,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      weekOfMonth: freezed == weekOfMonth
          ? _value.weekOfMonth
          : weekOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      month: freezed == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CustomRecurrenceImplCopyWith<$Res>
    implements $CustomRecurrenceCopyWith<$Res> {
  factory _$$CustomRecurrenceImplCopyWith(_$CustomRecurrenceImpl value,
          $Res Function(_$CustomRecurrenceImpl) then) =
      __$$CustomRecurrenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RepeatOption interval,
      int frequency,
      List<bool> selectedDays,
      int? dayOfMonth,
      int? weekOfMonth,
      int? month});
}

/// @nodoc
class __$$CustomRecurrenceImplCopyWithImpl<$Res>
    extends _$CustomRecurrenceCopyWithImpl<$Res, _$CustomRecurrenceImpl>
    implements _$$CustomRecurrenceImplCopyWith<$Res> {
  __$$CustomRecurrenceImplCopyWithImpl(_$CustomRecurrenceImpl _value,
      $Res Function(_$CustomRecurrenceImpl) _then)
      : super(_value, _then);

  /// Create a copy of CustomRecurrence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? interval = null,
    Object? frequency = null,
    Object? selectedDays = null,
    Object? dayOfMonth = freezed,
    Object? weekOfMonth = freezed,
    Object? month = freezed,
  }) {
    return _then(_$CustomRecurrenceImpl(
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as RepeatOption,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as int,
      selectedDays: null == selectedDays
          ? _value._selectedDays
          : selectedDays // ignore: cast_nullable_to_non_nullable
              as List<bool>,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      weekOfMonth: freezed == weekOfMonth
          ? _value.weekOfMonth
          : weekOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      month: freezed == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomRecurrenceImpl extends _CustomRecurrence {
  const _$CustomRecurrenceImpl(
      {required this.interval,
      required this.frequency,
      final List<bool> selectedDays = const [
        false,
        false,
        false,
        false,
        false,
        false,
        false
      ],
      this.dayOfMonth,
      this.weekOfMonth,
      this.month})
      : _selectedDays = selectedDays,
        super._();

  factory _$CustomRecurrenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomRecurrenceImplFromJson(json);

  @override
  final RepeatOption interval;
  @override
  final int frequency;
  final List<bool> _selectedDays;
  @override
  @JsonKey()
  List<bool> get selectedDays {
    if (_selectedDays is EqualUnmodifiableListView) return _selectedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedDays);
  }

  @override
  final int? dayOfMonth;
  @override
  final int? weekOfMonth;
  @override
  final int? month;

  @override
  String toString() {
    return 'CustomRecurrence(interval: $interval, frequency: $frequency, selectedDays: $selectedDays, dayOfMonth: $dayOfMonth, weekOfMonth: $weekOfMonth, month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomRecurrenceImpl &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            const DeepCollectionEquality()
                .equals(other._selectedDays, _selectedDays) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.weekOfMonth, weekOfMonth) ||
                other.weekOfMonth == weekOfMonth) &&
            (identical(other.month, month) || other.month == month));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      interval,
      frequency,
      const DeepCollectionEquality().hash(_selectedDays),
      dayOfMonth,
      weekOfMonth,
      month);

  /// Create a copy of CustomRecurrence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomRecurrenceImplCopyWith<_$CustomRecurrenceImpl> get copyWith =>
      __$$CustomRecurrenceImplCopyWithImpl<_$CustomRecurrenceImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomRecurrenceImplToJson(
      this,
    );
  }
}

abstract class _CustomRecurrence extends CustomRecurrence {
  const factory _CustomRecurrence(
      {required final RepeatOption interval,
      required final int frequency,
      final List<bool> selectedDays,
      final int? dayOfMonth,
      final int? weekOfMonth,
      final int? month}) = _$CustomRecurrenceImpl;
  const _CustomRecurrence._() : super._();

  factory _CustomRecurrence.fromJson(Map<String, dynamic> json) =
      _$CustomRecurrenceImpl.fromJson;

  @override
  RepeatOption get interval;
  @override
  int get frequency;
  @override
  List<bool> get selectedDays;
  @override
  int? get dayOfMonth;
  @override
  int? get weekOfMonth;
  @override
  int? get month;

  /// Create a copy of CustomRecurrence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomRecurrenceImplCopyWith<_$CustomRecurrenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
