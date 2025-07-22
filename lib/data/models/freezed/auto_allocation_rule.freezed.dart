// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auto_allocation_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AutoAllocationRule _$AutoAllocationRuleFromJson(Map<String, dynamic> json) {
  return _AutoAllocationRule.fromJson(json);
}

/// @nodoc
mixin _$AutoAllocationRule {
  int? get id => throw _privateConstructorUsedError;
  int get goalId => throw _privateConstructorUsedError;
  String get ruleName => throw _privateConstructorUsedError;
  TriggerType get triggerType => throw _privateConstructorUsedError;
  int? get triggerCategoryId => throw _privateConstructorUsedError;
  AllocationMethod get allocationMethod => throw _privateConstructorUsedError;
  double get allocationValue => throw _privateConstructorUsedError;
  double? get minimumTriggerAmount => throw _privateConstructorUsedError;
  double? get maximumAllocationAmount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Additional computed fields for UI
  String? get goalTitle => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;

  /// Serializes this AutoAllocationRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutoAllocationRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoAllocationRuleCopyWith<AutoAllocationRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoAllocationRuleCopyWith<$Res> {
  factory $AutoAllocationRuleCopyWith(
          AutoAllocationRule value, $Res Function(AutoAllocationRule) then) =
      _$AutoAllocationRuleCopyWithImpl<$Res, AutoAllocationRule>;
  @useResult
  $Res call(
      {int? id,
      int goalId,
      String ruleName,
      TriggerType triggerType,
      int? triggerCategoryId,
      AllocationMethod allocationMethod,
      double allocationValue,
      double? minimumTriggerAmount,
      double? maximumAllocationAmount,
      bool isActive,
      String? description,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? goalTitle,
      String? categoryName});
}

/// @nodoc
class _$AutoAllocationRuleCopyWithImpl<$Res, $Val extends AutoAllocationRule>
    implements $AutoAllocationRuleCopyWith<$Res> {
  _$AutoAllocationRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoAllocationRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? goalId = null,
    Object? ruleName = null,
    Object? triggerType = null,
    Object? triggerCategoryId = freezed,
    Object? allocationMethod = null,
    Object? allocationValue = null,
    Object? minimumTriggerAmount = freezed,
    Object? maximumAllocationAmount = freezed,
    Object? isActive = null,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? goalTitle = freezed,
    Object? categoryName = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      ruleName: null == ruleName
          ? _value.ruleName
          : ruleName // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      triggerCategoryId: freezed == triggerCategoryId
          ? _value.triggerCategoryId
          : triggerCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      allocationMethod: null == allocationMethod
          ? _value.allocationMethod
          : allocationMethod // ignore: cast_nullable_to_non_nullable
              as AllocationMethod,
      allocationValue: null == allocationValue
          ? _value.allocationValue
          : allocationValue // ignore: cast_nullable_to_non_nullable
              as double,
      minimumTriggerAmount: freezed == minimumTriggerAmount
          ? _value.minimumTriggerAmount
          : minimumTriggerAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumAllocationAmount: freezed == maximumAllocationAmount
          ? _value.maximumAllocationAmount
          : maximumAllocationAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalTitle: freezed == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutoAllocationRuleImplCopyWith<$Res>
    implements $AutoAllocationRuleCopyWith<$Res> {
  factory _$$AutoAllocationRuleImplCopyWith(_$AutoAllocationRuleImpl value,
          $Res Function(_$AutoAllocationRuleImpl) then) =
      __$$AutoAllocationRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      int goalId,
      String ruleName,
      TriggerType triggerType,
      int? triggerCategoryId,
      AllocationMethod allocationMethod,
      double allocationValue,
      double? minimumTriggerAmount,
      double? maximumAllocationAmount,
      bool isActive,
      String? description,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? goalTitle,
      String? categoryName});
}

/// @nodoc
class __$$AutoAllocationRuleImplCopyWithImpl<$Res>
    extends _$AutoAllocationRuleCopyWithImpl<$Res, _$AutoAllocationRuleImpl>
    implements _$$AutoAllocationRuleImplCopyWith<$Res> {
  __$$AutoAllocationRuleImplCopyWithImpl(_$AutoAllocationRuleImpl _value,
      $Res Function(_$AutoAllocationRuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutoAllocationRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? goalId = null,
    Object? ruleName = null,
    Object? triggerType = null,
    Object? triggerCategoryId = freezed,
    Object? allocationMethod = null,
    Object? allocationValue = null,
    Object? minimumTriggerAmount = freezed,
    Object? maximumAllocationAmount = freezed,
    Object? isActive = null,
    Object? description = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? goalTitle = freezed,
    Object? categoryName = freezed,
  }) {
    return _then(_$AutoAllocationRuleImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      ruleName: null == ruleName
          ? _value.ruleName
          : ruleName // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      triggerCategoryId: freezed == triggerCategoryId
          ? _value.triggerCategoryId
          : triggerCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      allocationMethod: null == allocationMethod
          ? _value.allocationMethod
          : allocationMethod // ignore: cast_nullable_to_non_nullable
              as AllocationMethod,
      allocationValue: null == allocationValue
          ? _value.allocationValue
          : allocationValue // ignore: cast_nullable_to_non_nullable
              as double,
      minimumTriggerAmount: freezed == minimumTriggerAmount
          ? _value.minimumTriggerAmount
          : minimumTriggerAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumAllocationAmount: freezed == maximumAllocationAmount
          ? _value.maximumAllocationAmount
          : maximumAllocationAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalTitle: freezed == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutoAllocationRuleImpl extends _AutoAllocationRule {
  const _$AutoAllocationRuleImpl(
      {this.id,
      required this.goalId,
      required this.ruleName,
      required this.triggerType,
      this.triggerCategoryId,
      required this.allocationMethod,
      required this.allocationValue,
      this.minimumTriggerAmount,
      this.maximumAllocationAmount,
      this.isActive = true,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.goalTitle,
      this.categoryName})
      : super._();

  factory _$AutoAllocationRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutoAllocationRuleImplFromJson(json);

  @override
  final int? id;
  @override
  final int goalId;
  @override
  final String ruleName;
  @override
  final TriggerType triggerType;
  @override
  final int? triggerCategoryId;
  @override
  final AllocationMethod allocationMethod;
  @override
  final double allocationValue;
  @override
  final double? minimumTriggerAmount;
  @override
  final double? maximumAllocationAmount;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? description;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
// Additional computed fields for UI
  @override
  final String? goalTitle;
  @override
  final String? categoryName;

  @override
  String toString() {
    return 'AutoAllocationRule(id: $id, goalId: $goalId, ruleName: $ruleName, triggerType: $triggerType, triggerCategoryId: $triggerCategoryId, allocationMethod: $allocationMethod, allocationValue: $allocationValue, minimumTriggerAmount: $minimumTriggerAmount, maximumAllocationAmount: $maximumAllocationAmount, isActive: $isActive, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, goalTitle: $goalTitle, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoAllocationRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.ruleName, ruleName) ||
                other.ruleName == ruleName) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.triggerCategoryId, triggerCategoryId) ||
                other.triggerCategoryId == triggerCategoryId) &&
            (identical(other.allocationMethod, allocationMethod) ||
                other.allocationMethod == allocationMethod) &&
            (identical(other.allocationValue, allocationValue) ||
                other.allocationValue == allocationValue) &&
            (identical(other.minimumTriggerAmount, minimumTriggerAmount) ||
                other.minimumTriggerAmount == minimumTriggerAmount) &&
            (identical(
                    other.maximumAllocationAmount, maximumAllocationAmount) ||
                other.maximumAllocationAmount == maximumAllocationAmount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.goalTitle, goalTitle) ||
                other.goalTitle == goalTitle) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      goalId,
      ruleName,
      triggerType,
      triggerCategoryId,
      allocationMethod,
      allocationValue,
      minimumTriggerAmount,
      maximumAllocationAmount,
      isActive,
      description,
      createdAt,
      updatedAt,
      goalTitle,
      categoryName);

  /// Create a copy of AutoAllocationRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoAllocationRuleImplCopyWith<_$AutoAllocationRuleImpl> get copyWith =>
      __$$AutoAllocationRuleImplCopyWithImpl<_$AutoAllocationRuleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutoAllocationRuleImplToJson(
      this,
    );
  }
}

abstract class _AutoAllocationRule extends AutoAllocationRule {
  const factory _AutoAllocationRule(
      {final int? id,
      required final int goalId,
      required final String ruleName,
      required final TriggerType triggerType,
      final int? triggerCategoryId,
      required final AllocationMethod allocationMethod,
      required final double allocationValue,
      final double? minimumTriggerAmount,
      final double? maximumAllocationAmount,
      final bool isActive,
      final String? description,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? goalTitle,
      final String? categoryName}) = _$AutoAllocationRuleImpl;
  const _AutoAllocationRule._() : super._();

  factory _AutoAllocationRule.fromJson(Map<String, dynamic> json) =
      _$AutoAllocationRuleImpl.fromJson;

  @override
  int? get id;
  @override
  int get goalId;
  @override
  String get ruleName;
  @override
  TriggerType get triggerType;
  @override
  int? get triggerCategoryId;
  @override
  AllocationMethod get allocationMethod;
  @override
  double get allocationValue;
  @override
  double? get minimumTriggerAmount;
  @override
  double? get maximumAllocationAmount;
  @override
  bool get isActive;
  @override
  String? get description;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt; // Additional computed fields for UI
  @override
  String? get goalTitle;
  @override
  String? get categoryName;

  /// Create a copy of AutoAllocationRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoAllocationRuleImplCopyWith<_$AutoAllocationRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutoAllocationRuleForm _$AutoAllocationRuleFormFromJson(
    Map<String, dynamic> json) {
  return _AutoAllocationRuleForm.fromJson(json);
}

/// @nodoc
mixin _$AutoAllocationRuleForm {
  String? get ruleId => throw _privateConstructorUsedError;
  String get ruleName => throw _privateConstructorUsedError;
  TriggerType get triggerType => throw _privateConstructorUsedError;
  int? get triggerCategoryId => throw _privateConstructorUsedError;
  int? get goalId => throw _privateConstructorUsedError;
  AllocationMethod get allocationMethod => throw _privateConstructorUsedError;
  double get allocationValue =>
      throw _privateConstructorUsedError; // Default 10%
  double? get minimumTriggerAmount => throw _privateConstructorUsedError;
  double? get maximumAllocationAmount => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this AutoAllocationRuleForm to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutoAllocationRuleForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoAllocationRuleFormCopyWith<AutoAllocationRuleForm> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoAllocationRuleFormCopyWith<$Res> {
  factory $AutoAllocationRuleFormCopyWith(AutoAllocationRuleForm value,
          $Res Function(AutoAllocationRuleForm) then) =
      _$AutoAllocationRuleFormCopyWithImpl<$Res, AutoAllocationRuleForm>;
  @useResult
  $Res call(
      {String? ruleId,
      String ruleName,
      TriggerType triggerType,
      int? triggerCategoryId,
      int? goalId,
      AllocationMethod allocationMethod,
      double allocationValue,
      double? minimumTriggerAmount,
      double? maximumAllocationAmount,
      bool isActive,
      String description});
}

/// @nodoc
class _$AutoAllocationRuleFormCopyWithImpl<$Res,
        $Val extends AutoAllocationRuleForm>
    implements $AutoAllocationRuleFormCopyWith<$Res> {
  _$AutoAllocationRuleFormCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoAllocationRuleForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = freezed,
    Object? ruleName = null,
    Object? triggerType = null,
    Object? triggerCategoryId = freezed,
    Object? goalId = freezed,
    Object? allocationMethod = null,
    Object? allocationValue = null,
    Object? minimumTriggerAmount = freezed,
    Object? maximumAllocationAmount = freezed,
    Object? isActive = null,
    Object? description = null,
  }) {
    return _then(_value.copyWith(
      ruleId: freezed == ruleId
          ? _value.ruleId
          : ruleId // ignore: cast_nullable_to_non_nullable
              as String?,
      ruleName: null == ruleName
          ? _value.ruleName
          : ruleName // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      triggerCategoryId: freezed == triggerCategoryId
          ? _value.triggerCategoryId
          : triggerCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: freezed == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int?,
      allocationMethod: null == allocationMethod
          ? _value.allocationMethod
          : allocationMethod // ignore: cast_nullable_to_non_nullable
              as AllocationMethod,
      allocationValue: null == allocationValue
          ? _value.allocationValue
          : allocationValue // ignore: cast_nullable_to_non_nullable
              as double,
      minimumTriggerAmount: freezed == minimumTriggerAmount
          ? _value.minimumTriggerAmount
          : minimumTriggerAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumAllocationAmount: freezed == maximumAllocationAmount
          ? _value.maximumAllocationAmount
          : maximumAllocationAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutoAllocationRuleFormImplCopyWith<$Res>
    implements $AutoAllocationRuleFormCopyWith<$Res> {
  factory _$$AutoAllocationRuleFormImplCopyWith(
          _$AutoAllocationRuleFormImpl value,
          $Res Function(_$AutoAllocationRuleFormImpl) then) =
      __$$AutoAllocationRuleFormImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? ruleId,
      String ruleName,
      TriggerType triggerType,
      int? triggerCategoryId,
      int? goalId,
      AllocationMethod allocationMethod,
      double allocationValue,
      double? minimumTriggerAmount,
      double? maximumAllocationAmount,
      bool isActive,
      String description});
}

/// @nodoc
class __$$AutoAllocationRuleFormImplCopyWithImpl<$Res>
    extends _$AutoAllocationRuleFormCopyWithImpl<$Res,
        _$AutoAllocationRuleFormImpl>
    implements _$$AutoAllocationRuleFormImplCopyWith<$Res> {
  __$$AutoAllocationRuleFormImplCopyWithImpl(
      _$AutoAllocationRuleFormImpl _value,
      $Res Function(_$AutoAllocationRuleFormImpl) _then)
      : super(_value, _then);

  /// Create a copy of AutoAllocationRuleForm
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ruleId = freezed,
    Object? ruleName = null,
    Object? triggerType = null,
    Object? triggerCategoryId = freezed,
    Object? goalId = freezed,
    Object? allocationMethod = null,
    Object? allocationValue = null,
    Object? minimumTriggerAmount = freezed,
    Object? maximumAllocationAmount = freezed,
    Object? isActive = null,
    Object? description = null,
  }) {
    return _then(_$AutoAllocationRuleFormImpl(
      ruleId: freezed == ruleId
          ? _value.ruleId
          : ruleId // ignore: cast_nullable_to_non_nullable
              as String?,
      ruleName: null == ruleName
          ? _value.ruleName
          : ruleName // ignore: cast_nullable_to_non_nullable
              as String,
      triggerType: null == triggerType
          ? _value.triggerType
          : triggerType // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      triggerCategoryId: freezed == triggerCategoryId
          ? _value.triggerCategoryId
          : triggerCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: freezed == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int?,
      allocationMethod: null == allocationMethod
          ? _value.allocationMethod
          : allocationMethod // ignore: cast_nullable_to_non_nullable
              as AllocationMethod,
      allocationValue: null == allocationValue
          ? _value.allocationValue
          : allocationValue // ignore: cast_nullable_to_non_nullable
              as double,
      minimumTriggerAmount: freezed == minimumTriggerAmount
          ? _value.minimumTriggerAmount
          : minimumTriggerAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      maximumAllocationAmount: freezed == maximumAllocationAmount
          ? _value.maximumAllocationAmount
          : maximumAllocationAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutoAllocationRuleFormImpl extends _AutoAllocationRuleForm {
  const _$AutoAllocationRuleFormImpl(
      {this.ruleId,
      this.ruleName = '',
      this.triggerType = TriggerType.expense,
      this.triggerCategoryId,
      this.goalId,
      this.allocationMethod = AllocationMethod.percentage,
      this.allocationValue = 0.1,
      this.minimumTriggerAmount,
      this.maximumAllocationAmount,
      this.isActive = true,
      this.description = ''})
      : super._();

  factory _$AutoAllocationRuleFormImpl.fromJson(Map<String, dynamic> json) =>
      _$$AutoAllocationRuleFormImplFromJson(json);

  @override
  final String? ruleId;
  @override
  @JsonKey()
  final String ruleName;
  @override
  @JsonKey()
  final TriggerType triggerType;
  @override
  final int? triggerCategoryId;
  @override
  final int? goalId;
  @override
  @JsonKey()
  final AllocationMethod allocationMethod;
  @override
  @JsonKey()
  final double allocationValue;
// Default 10%
  @override
  final double? minimumTriggerAmount;
  @override
  final double? maximumAllocationAmount;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'AutoAllocationRuleForm(ruleId: $ruleId, ruleName: $ruleName, triggerType: $triggerType, triggerCategoryId: $triggerCategoryId, goalId: $goalId, allocationMethod: $allocationMethod, allocationValue: $allocationValue, minimumTriggerAmount: $minimumTriggerAmount, maximumAllocationAmount: $maximumAllocationAmount, isActive: $isActive, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoAllocationRuleFormImpl &&
            (identical(other.ruleId, ruleId) || other.ruleId == ruleId) &&
            (identical(other.ruleName, ruleName) ||
                other.ruleName == ruleName) &&
            (identical(other.triggerType, triggerType) ||
                other.triggerType == triggerType) &&
            (identical(other.triggerCategoryId, triggerCategoryId) ||
                other.triggerCategoryId == triggerCategoryId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.allocationMethod, allocationMethod) ||
                other.allocationMethod == allocationMethod) &&
            (identical(other.allocationValue, allocationValue) ||
                other.allocationValue == allocationValue) &&
            (identical(other.minimumTriggerAmount, minimumTriggerAmount) ||
                other.minimumTriggerAmount == minimumTriggerAmount) &&
            (identical(
                    other.maximumAllocationAmount, maximumAllocationAmount) ||
                other.maximumAllocationAmount == maximumAllocationAmount) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      ruleId,
      ruleName,
      triggerType,
      triggerCategoryId,
      goalId,
      allocationMethod,
      allocationValue,
      minimumTriggerAmount,
      maximumAllocationAmount,
      isActive,
      description);

  /// Create a copy of AutoAllocationRuleForm
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoAllocationRuleFormImplCopyWith<_$AutoAllocationRuleFormImpl>
      get copyWith => __$$AutoAllocationRuleFormImplCopyWithImpl<
          _$AutoAllocationRuleFormImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutoAllocationRuleFormImplToJson(
      this,
    );
  }
}

abstract class _AutoAllocationRuleForm extends AutoAllocationRuleForm {
  const factory _AutoAllocationRuleForm(
      {final String? ruleId,
      final String ruleName,
      final TriggerType triggerType,
      final int? triggerCategoryId,
      final int? goalId,
      final AllocationMethod allocationMethod,
      final double allocationValue,
      final double? minimumTriggerAmount,
      final double? maximumAllocationAmount,
      final bool isActive,
      final String description}) = _$AutoAllocationRuleFormImpl;
  const _AutoAllocationRuleForm._() : super._();

  factory _AutoAllocationRuleForm.fromJson(Map<String, dynamic> json) =
      _$AutoAllocationRuleFormImpl.fromJson;

  @override
  String? get ruleId;
  @override
  String get ruleName;
  @override
  TriggerType get triggerType;
  @override
  int? get triggerCategoryId;
  @override
  int? get goalId;
  @override
  AllocationMethod get allocationMethod;
  @override
  double get allocationValue; // Default 10%
  @override
  double? get minimumTriggerAmount;
  @override
  double? get maximumAllocationAmount;
  @override
  bool get isActive;
  @override
  String get description;

  /// Create a copy of AutoAllocationRuleForm
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoAllocationRuleFormImplCopyWith<_$AutoAllocationRuleFormImpl>
      get copyWith => throw _privateConstructorUsedError;
}
