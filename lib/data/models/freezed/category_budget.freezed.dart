// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_budget.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CategoryBudget _$CategoryBudgetFromJson(Map<String, dynamic> json) {
  return _CategoryBudget.fromJson(json);
}

/// @nodoc
mixin _$CategoryBudget {
  int get id => throw _privateConstructorUsedError;
  int get budgetId => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  double get allocatedAmount =>
      throw _privateConstructorUsedError; // monthly dollar amount
  BucketType get bucketType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;

  /// Serializes this CategoryBudget to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryBudgetCopyWith<CategoryBudget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryBudgetCopyWith<$Res> {
  factory $CategoryBudgetCopyWith(
          CategoryBudget value, $Res Function(CategoryBudget) then) =
      _$CategoryBudgetCopyWithImpl<$Res, CategoryBudget>;
  @useResult
  $Res call(
      {int id,
      int budgetId,
      int categoryId,
      double allocatedAmount,
      BucketType bucketType,
      DateTime createdAt,
      DateTime updatedAt,
      String? categoryName});
}

/// @nodoc
class _$CategoryBudgetCopyWithImpl<$Res, $Val extends CategoryBudget>
    implements $CategoryBudgetCopyWith<$Res> {
  _$CategoryBudgetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? budgetId = null,
    Object? categoryId = null,
    Object? allocatedAmount = null,
    Object? bucketType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? categoryName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      budgetId: null == budgetId
          ? _value.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      allocatedAmount: null == allocatedAmount
          ? _value.allocatedAmount
          : allocatedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bucketType: null == bucketType
          ? _value.bucketType
          : bucketType // ignore: cast_nullable_to_non_nullable
              as BucketType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryBudgetImplCopyWith<$Res>
    implements $CategoryBudgetCopyWith<$Res> {
  factory _$$CategoryBudgetImplCopyWith(_$CategoryBudgetImpl value,
          $Res Function(_$CategoryBudgetImpl) then) =
      __$$CategoryBudgetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int budgetId,
      int categoryId,
      double allocatedAmount,
      BucketType bucketType,
      DateTime createdAt,
      DateTime updatedAt,
      String? categoryName});
}

/// @nodoc
class __$$CategoryBudgetImplCopyWithImpl<$Res>
    extends _$CategoryBudgetCopyWithImpl<$Res, _$CategoryBudgetImpl>
    implements _$$CategoryBudgetImplCopyWith<$Res> {
  __$$CategoryBudgetImplCopyWithImpl(
      _$CategoryBudgetImpl _value, $Res Function(_$CategoryBudgetImpl) _then)
      : super(_value, _then);

  /// Create a copy of CategoryBudget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? budgetId = null,
    Object? categoryId = null,
    Object? allocatedAmount = null,
    Object? bucketType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? categoryName = freezed,
  }) {
    return _then(_$CategoryBudgetImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      budgetId: null == budgetId
          ? _value.budgetId
          : budgetId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      allocatedAmount: null == allocatedAmount
          ? _value.allocatedAmount
          : allocatedAmount // ignore: cast_nullable_to_non_nullable
              as double,
      bucketType: null == bucketType
          ? _value.bucketType
          : bucketType // ignore: cast_nullable_to_non_nullable
              as BucketType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryBudgetImpl extends _CategoryBudget {
  const _$CategoryBudgetImpl(
      {required this.id,
      required this.budgetId,
      required this.categoryId,
      required this.allocatedAmount,
      required this.bucketType,
      required this.createdAt,
      required this.updatedAt,
      this.categoryName})
      : super._();

  factory _$CategoryBudgetImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryBudgetImplFromJson(json);

  @override
  final int id;
  @override
  final int budgetId;
  @override
  final int categoryId;
  @override
  final double allocatedAmount;
// monthly dollar amount
  @override
  final BucketType bucketType;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? categoryName;

  @override
  String toString() {
    return 'CategoryBudget(id: $id, budgetId: $budgetId, categoryId: $categoryId, allocatedAmount: $allocatedAmount, bucketType: $bucketType, createdAt: $createdAt, updatedAt: $updatedAt, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryBudgetImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.budgetId, budgetId) ||
                other.budgetId == budgetId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.allocatedAmount, allocatedAmount) ||
                other.allocatedAmount == allocatedAmount) &&
            (identical(other.bucketType, bucketType) ||
                other.bucketType == bucketType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, budgetId, categoryId,
      allocatedAmount, bucketType, createdAt, updatedAt, categoryName);

  /// Create a copy of CategoryBudget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryBudgetImplCopyWith<_$CategoryBudgetImpl> get copyWith =>
      __$$CategoryBudgetImplCopyWithImpl<_$CategoryBudgetImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryBudgetImplToJson(
      this,
    );
  }
}

abstract class _CategoryBudget extends CategoryBudget {
  const factory _CategoryBudget(
      {required final int id,
      required final int budgetId,
      required final int categoryId,
      required final double allocatedAmount,
      required final BucketType bucketType,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? categoryName}) = _$CategoryBudgetImpl;
  const _CategoryBudget._() : super._();

  factory _CategoryBudget.fromJson(Map<String, dynamic> json) =
      _$CategoryBudgetImpl.fromJson;

  @override
  int get id;
  @override
  int get budgetId;
  @override
  int get categoryId;
  @override
  double get allocatedAmount; // monthly dollar amount
  @override
  BucketType get bucketType;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get categoryName;

  /// Create a copy of CategoryBudget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryBudgetImplCopyWith<_$CategoryBudgetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
