// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_up_calculation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoundUpCalculation _$RoundUpCalculationFromJson(Map<String, dynamic> json) {
  return _RoundUpCalculation.fromJson(json);
}

/// @nodoc
mixin _$RoundUpCalculation {
  double get originalAmount => throw _privateConstructorUsedError;
  double get roundUpAmount => throw _privateConstructorUsedError;
  double get roundedTotal => throw _privateConstructorUsedError;
  RoundUpStrategy get strategyUsed => throw _privateConstructorUsedError;
  bool get isApplicable => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoundUpCalculationCopyWith<RoundUpCalculation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundUpCalculationCopyWith<$Res> {
  factory $RoundUpCalculationCopyWith(
          RoundUpCalculation value, $Res Function(RoundUpCalculation) then) =
      _$RoundUpCalculationCopyWithImpl<$Res, RoundUpCalculation>;
  @useResult
  $Res call(
      {double originalAmount,
      double roundUpAmount,
      double roundedTotal,
      RoundUpStrategy strategyUsed,
      bool isApplicable,
      String reason});
}

/// @nodoc
class _$RoundUpCalculationCopyWithImpl<$Res, $Val extends RoundUpCalculation>
    implements $RoundUpCalculationCopyWith<$Res> {
  _$RoundUpCalculationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalAmount = null,
    Object? roundUpAmount = null,
    Object? roundedTotal = null,
    Object? strategyUsed = null,
    Object? isApplicable = null,
    Object? reason = null,
  }) {
    return _then(_value.copyWith(
      originalAmount: null == originalAmount
          ? _value.originalAmount
          : originalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      roundUpAmount: null == roundUpAmount
          ? _value.roundUpAmount
          : roundUpAmount // ignore: cast_nullable_to_non_nullable
              as double,
      roundedTotal: null == roundedTotal
          ? _value.roundedTotal
          : roundedTotal // ignore: cast_nullable_to_non_nullable
              as double,
      strategyUsed: null == strategyUsed
          ? _value.strategyUsed
          : strategyUsed // ignore: cast_nullable_to_non_nullable
              as RoundUpStrategy,
      isApplicable: null == isApplicable
          ? _value.isApplicable
          : isApplicable // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoundUpCalculationImplCopyWith<$Res>
    implements $RoundUpCalculationCopyWith<$Res> {
  factory _$$RoundUpCalculationImplCopyWith(_$RoundUpCalculationImpl value,
          $Res Function(_$RoundUpCalculationImpl) then) =
      __$$RoundUpCalculationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double originalAmount,
      double roundUpAmount,
      double roundedTotal,
      RoundUpStrategy strategyUsed,
      bool isApplicable,
      String reason});
}

/// @nodoc
class __$$RoundUpCalculationImplCopyWithImpl<$Res>
    extends _$RoundUpCalculationCopyWithImpl<$Res, _$RoundUpCalculationImpl>
    implements _$$RoundUpCalculationImplCopyWith<$Res> {
  __$$RoundUpCalculationImplCopyWithImpl(_$RoundUpCalculationImpl _value,
      $Res Function(_$RoundUpCalculationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? originalAmount = null,
    Object? roundUpAmount = null,
    Object? roundedTotal = null,
    Object? strategyUsed = null,
    Object? isApplicable = null,
    Object? reason = null,
  }) {
    return _then(_$RoundUpCalculationImpl(
      originalAmount: null == originalAmount
          ? _value.originalAmount
          : originalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      roundUpAmount: null == roundUpAmount
          ? _value.roundUpAmount
          : roundUpAmount // ignore: cast_nullable_to_non_nullable
              as double,
      roundedTotal: null == roundedTotal
          ? _value.roundedTotal
          : roundedTotal // ignore: cast_nullable_to_non_nullable
              as double,
      strategyUsed: null == strategyUsed
          ? _value.strategyUsed
          : strategyUsed // ignore: cast_nullable_to_non_nullable
              as RoundUpStrategy,
      isApplicable: null == isApplicable
          ? _value.isApplicable
          : isApplicable // ignore: cast_nullable_to_non_nullable
              as bool,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoundUpCalculationImpl implements _RoundUpCalculation {
  const _$RoundUpCalculationImpl(
      {required this.originalAmount,
      required this.roundUpAmount,
      required this.roundedTotal,
      required this.strategyUsed,
      this.isApplicable = true,
      this.reason = ''});

  factory _$RoundUpCalculationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundUpCalculationImplFromJson(json);

  @override
  final double originalAmount;
  @override
  final double roundUpAmount;
  @override
  final double roundedTotal;
  @override
  final RoundUpStrategy strategyUsed;
  @override
  @JsonKey()
  final bool isApplicable;
  @override
  @JsonKey()
  final String reason;

  @override
  String toString() {
    return 'RoundUpCalculation(originalAmount: $originalAmount, roundUpAmount: $roundUpAmount, roundedTotal: $roundedTotal, strategyUsed: $strategyUsed, isApplicable: $isApplicable, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundUpCalculationImpl &&
            (identical(other.originalAmount, originalAmount) ||
                other.originalAmount == originalAmount) &&
            (identical(other.roundUpAmount, roundUpAmount) ||
                other.roundUpAmount == roundUpAmount) &&
            (identical(other.roundedTotal, roundedTotal) ||
                other.roundedTotal == roundedTotal) &&
            (identical(other.strategyUsed, strategyUsed) ||
                other.strategyUsed == strategyUsed) &&
            (identical(other.isApplicable, isApplicable) ||
                other.isApplicable == isApplicable) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, originalAmount, roundUpAmount,
      roundedTotal, strategyUsed, isApplicable, reason);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundUpCalculationImplCopyWith<_$RoundUpCalculationImpl> get copyWith =>
      __$$RoundUpCalculationImplCopyWithImpl<_$RoundUpCalculationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundUpCalculationImplToJson(
      this,
    );
  }
}

abstract class _RoundUpCalculation implements RoundUpCalculation {
  const factory _RoundUpCalculation(
      {required final double originalAmount,
      required final double roundUpAmount,
      required final double roundedTotal,
      required final RoundUpStrategy strategyUsed,
      final bool isApplicable,
      final String reason}) = _$RoundUpCalculationImpl;

  factory _RoundUpCalculation.fromJson(Map<String, dynamic> json) =
      _$RoundUpCalculationImpl.fromJson;

  @override
  double get originalAmount;
  @override
  double get roundUpAmount;
  @override
  double get roundedTotal;
  @override
  RoundUpStrategy get strategyUsed;
  @override
  bool get isApplicable;
  @override
  String get reason;
  @override
  @JsonKey(ignore: true)
  _$$RoundUpCalculationImplCopyWith<_$RoundUpCalculationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
