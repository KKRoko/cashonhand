// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_base_implementation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Achievement _$AchievementFromJson(Map<String, dynamic> json) {
  return _Achievement.fromJson(json);
}

/// @nodoc
mixin _$Achievement {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  AchievementType get type => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  bool get isUnlocked => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  DateTime? get unlockedAt =>
      throw _privateConstructorUsedError; // Enhanced fields for gamification
  String get emoji => throw _privateConstructorUsedError;
  String get badgeColor => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get tier =>
      throw _privateConstructorUsedError; // 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  List<String> get celebrationMessages => throw _privateConstructorUsedError;
  String? get shareText => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Achievement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementCopyWith<Achievement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementCopyWith<$Res> {
  factory $AchievementCopyWith(
          Achievement value, $Res Function(Achievement) then) =
      _$AchievementCopyWithImpl<$Res, Achievement>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      AchievementType type,
      double targetAmount,
      bool isUnlocked,
      double progress,
      DateTime? unlockedAt,
      String emoji,
      String badgeColor,
      int points,
      int tier,
      List<String> celebrationMessages,
      String? shareText,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AchievementCopyWithImpl<$Res, $Val extends Achievement>
    implements $AchievementCopyWith<$Res> {
  _$AchievementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetAmount = null,
    Object? isUnlocked = null,
    Object? progress = null,
    Object? unlockedAt = freezed,
    Object? emoji = null,
    Object? badgeColor = null,
    Object? points = null,
    Object? tier = null,
    Object? celebrationMessages = null,
    Object? shareText = freezed,
    Object? metadata = freezed,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      badgeColor: null == badgeColor
          ? _value.badgeColor
          : badgeColor // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      celebrationMessages: null == celebrationMessages
          ? _value.celebrationMessages
          : celebrationMessages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shareText: freezed == shareText
          ? _value.shareText
          : shareText // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementImplCopyWith<$Res>
    implements $AchievementCopyWith<$Res> {
  factory _$$AchievementImplCopyWith(
          _$AchievementImpl value, $Res Function(_$AchievementImpl) then) =
      __$$AchievementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      AchievementType type,
      double targetAmount,
      bool isUnlocked,
      double progress,
      DateTime? unlockedAt,
      String emoji,
      String badgeColor,
      int points,
      int tier,
      List<String> celebrationMessages,
      String? shareText,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AchievementImplCopyWithImpl<$Res>
    extends _$AchievementCopyWithImpl<$Res, _$AchievementImpl>
    implements _$$AchievementImplCopyWith<$Res> {
  __$$AchievementImplCopyWithImpl(
      _$AchievementImpl _value, $Res Function(_$AchievementImpl) _then)
      : super(_value, _then);

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? targetAmount = null,
    Object? isUnlocked = null,
    Object? progress = null,
    Object? unlockedAt = freezed,
    Object? emoji = null,
    Object? badgeColor = null,
    Object? points = null,
    Object? tier = null,
    Object? celebrationMessages = null,
    Object? shareText = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AchievementImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as AchievementType,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isUnlocked: null == isUnlocked
          ? _value.isUnlocked
          : isUnlocked // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      unlockedAt: freezed == unlockedAt
          ? _value.unlockedAt
          : unlockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      badgeColor: null == badgeColor
          ? _value.badgeColor
          : badgeColor // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as int,
      celebrationMessages: null == celebrationMessages
          ? _value._celebrationMessages
          : celebrationMessages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shareText: freezed == shareText
          ? _value.shareText
          : shareText // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementImpl extends _Achievement {
  const _$AchievementImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.targetAmount,
      this.isUnlocked = false,
      this.progress = 0.0,
      this.unlockedAt,
      this.emoji = '🏆',
      this.badgeColor = 'gold',
      this.points = 100,
      this.tier = 1,
      final List<String> celebrationMessages = const [],
      this.shareText,
      final Map<String, dynamic>? metadata})
      : _celebrationMessages = celebrationMessages,
        _metadata = metadata,
        super._();

  factory _$AchievementImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final AchievementType type;
  @override
  final double targetAmount;
  @override
  @JsonKey()
  final bool isUnlocked;
  @override
  @JsonKey()
  final double progress;
  @override
  final DateTime? unlockedAt;
// Enhanced fields for gamification
  @override
  @JsonKey()
  final String emoji;
  @override
  @JsonKey()
  final String badgeColor;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int tier;
// 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  final List<String> _celebrationMessages;
// 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  @override
  @JsonKey()
  List<String> get celebrationMessages {
    if (_celebrationMessages is EqualUnmodifiableListView)
      return _celebrationMessages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_celebrationMessages);
  }

  @override
  final String? shareText;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, type: $type, targetAmount: $targetAmount, isUnlocked: $isUnlocked, progress: $progress, unlockedAt: $unlockedAt, emoji: $emoji, badgeColor: $badgeColor, points: $points, tier: $tier, celebrationMessages: $celebrationMessages, shareText: $shareText, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.isUnlocked, isUnlocked) ||
                other.isUnlocked == isUnlocked) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.unlockedAt, unlockedAt) ||
                other.unlockedAt == unlockedAt) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.badgeColor, badgeColor) ||
                other.badgeColor == badgeColor) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            const DeepCollectionEquality()
                .equals(other._celebrationMessages, _celebrationMessages) &&
            (identical(other.shareText, shareText) ||
                other.shareText == shareText) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      type,
      targetAmount,
      isUnlocked,
      progress,
      unlockedAt,
      emoji,
      badgeColor,
      points,
      tier,
      const DeepCollectionEquality().hash(_celebrationMessages),
      shareText,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      __$$AchievementImplCopyWithImpl<_$AchievementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementImplToJson(
      this,
    );
  }
}

abstract class _Achievement extends Achievement {
  const factory _Achievement(
      {required final String id,
      required final String title,
      required final String description,
      required final AchievementType type,
      required final double targetAmount,
      final bool isUnlocked,
      final double progress,
      final DateTime? unlockedAt,
      final String emoji,
      final String badgeColor,
      final int points,
      final int tier,
      final List<String> celebrationMessages,
      final String? shareText,
      final Map<String, dynamic>? metadata}) = _$AchievementImpl;
  const _Achievement._() : super._();

  factory _Achievement.fromJson(Map<String, dynamic> json) =
      _$AchievementImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  AchievementType get type;
  @override
  double get targetAmount;
  @override
  bool get isUnlocked;
  @override
  double get progress;
  @override
  DateTime? get unlockedAt; // Enhanced fields for gamification
  @override
  String get emoji;
  @override
  String get badgeColor;
  @override
  int get points;
  @override
  int get tier; // 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  @override
  List<String> get celebrationMessages;
  @override
  String? get shareText;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Achievement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementImplCopyWith<_$AchievementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
