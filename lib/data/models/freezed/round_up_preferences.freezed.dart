// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_up_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoundUpPreferences _$RoundUpPreferencesFromJson(Map<String, dynamic> json) {
  return _RoundUpPreferences.fromJson(json);
}

/// @nodoc
mixin _$RoundUpPreferences {
  bool get isEnabled => throw _privateConstructorUsedError;
  RoundUpStrategy get strategy => throw _privateConstructorUsedError;
  double? get customMultiplier => throw _privateConstructorUsedError;
  int? get defaultGoalId => throw _privateConstructorUsedError;
  double get minimumRoundUp => throw _privateConstructorUsedError;
  double get maximumRoundUp => throw _privateConstructorUsedError;
  List<int> get excludedCategoryIds => throw _privateConstructorUsedError;
  bool get onlyOnExpenses => throw _privateConstructorUsedError;
  bool get autoSelectGoal => throw _privateConstructorUsedError;

  /// Serializes this RoundUpPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoundUpPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundUpPreferencesCopyWith<RoundUpPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundUpPreferencesCopyWith<$Res> {
  factory $RoundUpPreferencesCopyWith(
          RoundUpPreferences value, $Res Function(RoundUpPreferences) then) =
      _$RoundUpPreferencesCopyWithImpl<$Res, RoundUpPreferences>;
  @useResult
  $Res call(
      {bool isEnabled,
      RoundUpStrategy strategy,
      double? customMultiplier,
      int? defaultGoalId,
      double minimumRoundUp,
      double maximumRoundUp,
      List<int> excludedCategoryIds,
      bool onlyOnExpenses,
      bool autoSelectGoal});
}

/// @nodoc
class _$RoundUpPreferencesCopyWithImpl<$Res, $Val extends RoundUpPreferences>
    implements $RoundUpPreferencesCopyWith<$Res> {
  _$RoundUpPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoundUpPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? strategy = null,
    Object? customMultiplier = freezed,
    Object? defaultGoalId = freezed,
    Object? minimumRoundUp = null,
    Object? maximumRoundUp = null,
    Object? excludedCategoryIds = null,
    Object? onlyOnExpenses = null,
    Object? autoSelectGoal = null,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as RoundUpStrategy,
      customMultiplier: freezed == customMultiplier
          ? _value.customMultiplier
          : customMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      defaultGoalId: freezed == defaultGoalId
          ? _value.defaultGoalId
          : defaultGoalId // ignore: cast_nullable_to_non_nullable
              as int?,
      minimumRoundUp: null == minimumRoundUp
          ? _value.minimumRoundUp
          : minimumRoundUp // ignore: cast_nullable_to_non_nullable
              as double,
      maximumRoundUp: null == maximumRoundUp
          ? _value.maximumRoundUp
          : maximumRoundUp // ignore: cast_nullable_to_non_nullable
              as double,
      excludedCategoryIds: null == excludedCategoryIds
          ? _value.excludedCategoryIds
          : excludedCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      onlyOnExpenses: null == onlyOnExpenses
          ? _value.onlyOnExpenses
          : onlyOnExpenses // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSelectGoal: null == autoSelectGoal
          ? _value.autoSelectGoal
          : autoSelectGoal // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoundUpPreferencesImplCopyWith<$Res>
    implements $RoundUpPreferencesCopyWith<$Res> {
  factory _$$RoundUpPreferencesImplCopyWith(_$RoundUpPreferencesImpl value,
          $Res Function(_$RoundUpPreferencesImpl) then) =
      __$$RoundUpPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isEnabled,
      RoundUpStrategy strategy,
      double? customMultiplier,
      int? defaultGoalId,
      double minimumRoundUp,
      double maximumRoundUp,
      List<int> excludedCategoryIds,
      bool onlyOnExpenses,
      bool autoSelectGoal});
}

/// @nodoc
class __$$RoundUpPreferencesImplCopyWithImpl<$Res>
    extends _$RoundUpPreferencesCopyWithImpl<$Res, _$RoundUpPreferencesImpl>
    implements _$$RoundUpPreferencesImplCopyWith<$Res> {
  __$$RoundUpPreferencesImplCopyWithImpl(_$RoundUpPreferencesImpl _value,
      $Res Function(_$RoundUpPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoundUpPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? strategy = null,
    Object? customMultiplier = freezed,
    Object? defaultGoalId = freezed,
    Object? minimumRoundUp = null,
    Object? maximumRoundUp = null,
    Object? excludedCategoryIds = null,
    Object? onlyOnExpenses = null,
    Object? autoSelectGoal = null,
  }) {
    return _then(_$RoundUpPreferencesImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      strategy: null == strategy
          ? _value.strategy
          : strategy // ignore: cast_nullable_to_non_nullable
              as RoundUpStrategy,
      customMultiplier: freezed == customMultiplier
          ? _value.customMultiplier
          : customMultiplier // ignore: cast_nullable_to_non_nullable
              as double?,
      defaultGoalId: freezed == defaultGoalId
          ? _value.defaultGoalId
          : defaultGoalId // ignore: cast_nullable_to_non_nullable
              as int?,
      minimumRoundUp: null == minimumRoundUp
          ? _value.minimumRoundUp
          : minimumRoundUp // ignore: cast_nullable_to_non_nullable
              as double,
      maximumRoundUp: null == maximumRoundUp
          ? _value.maximumRoundUp
          : maximumRoundUp // ignore: cast_nullable_to_non_nullable
              as double,
      excludedCategoryIds: null == excludedCategoryIds
          ? _value._excludedCategoryIds
          : excludedCategoryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      onlyOnExpenses: null == onlyOnExpenses
          ? _value.onlyOnExpenses
          : onlyOnExpenses // ignore: cast_nullable_to_non_nullable
              as bool,
      autoSelectGoal: null == autoSelectGoal
          ? _value.autoSelectGoal
          : autoSelectGoal // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoundUpPreferencesImpl implements _RoundUpPreferences {
  const _$RoundUpPreferencesImpl(
      {this.isEnabled = false,
      this.strategy = RoundUpStrategy.nearestDollar,
      this.customMultiplier,
      this.defaultGoalId,
      this.minimumRoundUp = 0.01,
      this.maximumRoundUp = 10.00,
      final List<int> excludedCategoryIds = const [],
      this.onlyOnExpenses = true,
      this.autoSelectGoal = true})
      : _excludedCategoryIds = excludedCategoryIds;

  factory _$RoundUpPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundUpPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final RoundUpStrategy strategy;
  @override
  final double? customMultiplier;
  @override
  final int? defaultGoalId;
  @override
  @JsonKey()
  final double minimumRoundUp;
  @override
  @JsonKey()
  final double maximumRoundUp;
  final List<int> _excludedCategoryIds;
  @override
  @JsonKey()
  List<int> get excludedCategoryIds {
    if (_excludedCategoryIds is EqualUnmodifiableListView)
      return _excludedCategoryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedCategoryIds);
  }

  @override
  @JsonKey()
  final bool onlyOnExpenses;
  @override
  @JsonKey()
  final bool autoSelectGoal;

  @override
  String toString() {
    return 'RoundUpPreferences(isEnabled: $isEnabled, strategy: $strategy, customMultiplier: $customMultiplier, defaultGoalId: $defaultGoalId, minimumRoundUp: $minimumRoundUp, maximumRoundUp: $maximumRoundUp, excludedCategoryIds: $excludedCategoryIds, onlyOnExpenses: $onlyOnExpenses, autoSelectGoal: $autoSelectGoal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundUpPreferencesImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.strategy, strategy) ||
                other.strategy == strategy) &&
            (identical(other.customMultiplier, customMultiplier) ||
                other.customMultiplier == customMultiplier) &&
            (identical(other.defaultGoalId, defaultGoalId) ||
                other.defaultGoalId == defaultGoalId) &&
            (identical(other.minimumRoundUp, minimumRoundUp) ||
                other.minimumRoundUp == minimumRoundUp) &&
            (identical(other.maximumRoundUp, maximumRoundUp) ||
                other.maximumRoundUp == maximumRoundUp) &&
            const DeepCollectionEquality()
                .equals(other._excludedCategoryIds, _excludedCategoryIds) &&
            (identical(other.onlyOnExpenses, onlyOnExpenses) ||
                other.onlyOnExpenses == onlyOnExpenses) &&
            (identical(other.autoSelectGoal, autoSelectGoal) ||
                other.autoSelectGoal == autoSelectGoal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isEnabled,
      strategy,
      customMultiplier,
      defaultGoalId,
      minimumRoundUp,
      maximumRoundUp,
      const DeepCollectionEquality().hash(_excludedCategoryIds),
      onlyOnExpenses,
      autoSelectGoal);

  /// Create a copy of RoundUpPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundUpPreferencesImplCopyWith<_$RoundUpPreferencesImpl> get copyWith =>
      __$$RoundUpPreferencesImplCopyWithImpl<_$RoundUpPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundUpPreferencesImplToJson(
      this,
    );
  }
}

abstract class _RoundUpPreferences implements RoundUpPreferences {
  const factory _RoundUpPreferences(
      {final bool isEnabled,
      final RoundUpStrategy strategy,
      final double? customMultiplier,
      final int? defaultGoalId,
      final double minimumRoundUp,
      final double maximumRoundUp,
      final List<int> excludedCategoryIds,
      final bool onlyOnExpenses,
      final bool autoSelectGoal}) = _$RoundUpPreferencesImpl;

  factory _RoundUpPreferences.fromJson(Map<String, dynamic> json) =
      _$RoundUpPreferencesImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  RoundUpStrategy get strategy;
  @override
  double? get customMultiplier;
  @override
  int? get defaultGoalId;
  @override
  double get minimumRoundUp;
  @override
  double get maximumRoundUp;
  @override
  List<int> get excludedCategoryIds;
  @override
  bool get onlyOnExpenses;
  @override
  bool get autoSelectGoal;

  /// Create a copy of RoundUpPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundUpPreferencesImplCopyWith<_$RoundUpPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
