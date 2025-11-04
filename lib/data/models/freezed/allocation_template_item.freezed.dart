// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_template_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AllocationTemplateItem _$AllocationTemplateItemFromJson(
    Map<String, dynamic> json) {
  return _AllocationTemplateItem.fromJson(json);
}

/// @nodoc
mixin _$AllocationTemplateItem {
  int get id => throw _privateConstructorUsedError;
  int get templateId => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  double get allocatedAmount => throw _privateConstructorUsedError;
  BucketType get bucketType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AllocationTemplateItemCopyWith<AllocationTemplateItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllocationTemplateItemCopyWith<$Res> {
  factory $AllocationTemplateItemCopyWith(AllocationTemplateItem value,
          $Res Function(AllocationTemplateItem) then) =
      _$AllocationTemplateItemCopyWithImpl<$Res, AllocationTemplateItem>;
  @useResult
  $Res call(
      {int id,
      int templateId,
      int categoryId,
      double allocatedAmount,
      BucketType bucketType,
      DateTime createdAt,
      DateTime updatedAt,
      String? categoryName});
}

/// @nodoc
class _$AllocationTemplateItemCopyWithImpl<$Res,
        $Val extends AllocationTemplateItem>
    implements $AllocationTemplateItemCopyWith<$Res> {
  _$AllocationTemplateItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
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
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AllocationTemplateItemImplCopyWith<$Res>
    implements $AllocationTemplateItemCopyWith<$Res> {
  factory _$$AllocationTemplateItemImplCopyWith(
          _$AllocationTemplateItemImpl value,
          $Res Function(_$AllocationTemplateItemImpl) then) =
      __$$AllocationTemplateItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int templateId,
      int categoryId,
      double allocatedAmount,
      BucketType bucketType,
      DateTime createdAt,
      DateTime updatedAt,
      String? categoryName});
}

/// @nodoc
class __$$AllocationTemplateItemImplCopyWithImpl<$Res>
    extends _$AllocationTemplateItemCopyWithImpl<$Res,
        _$AllocationTemplateItemImpl>
    implements _$$AllocationTemplateItemImplCopyWith<$Res> {
  __$$AllocationTemplateItemImplCopyWithImpl(
      _$AllocationTemplateItemImpl _value,
      $Res Function(_$AllocationTemplateItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? templateId = null,
    Object? categoryId = null,
    Object? allocatedAmount = null,
    Object? bucketType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? categoryName = freezed,
  }) {
    return _then(_$AllocationTemplateItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      templateId: null == templateId
          ? _value.templateId
          : templateId // ignore: cast_nullable_to_non_nullable
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
class _$AllocationTemplateItemImpl extends _AllocationTemplateItem {
  const _$AllocationTemplateItemImpl(
      {required this.id,
      required this.templateId,
      required this.categoryId,
      required this.allocatedAmount,
      required this.bucketType,
      required this.createdAt,
      required this.updatedAt,
      this.categoryName})
      : super._();

  factory _$AllocationTemplateItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllocationTemplateItemImplFromJson(json);

  @override
  final int id;
  @override
  final int templateId;
  @override
  final int categoryId;
  @override
  final double allocatedAmount;
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
    return 'AllocationTemplateItem(id: $id, templateId: $templateId, categoryId: $categoryId, allocatedAmount: $allocatedAmount, bucketType: $bucketType, createdAt: $createdAt, updatedAt: $updatedAt, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllocationTemplateItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.templateId, templateId) ||
                other.templateId == templateId) &&
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

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, templateId, categoryId,
      allocatedAmount, bucketType, createdAt, updatedAt, categoryName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AllocationTemplateItemImplCopyWith<_$AllocationTemplateItemImpl>
      get copyWith => __$$AllocationTemplateItemImplCopyWithImpl<
          _$AllocationTemplateItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllocationTemplateItemImplToJson(
      this,
    );
  }
}

abstract class _AllocationTemplateItem extends AllocationTemplateItem {
  const factory _AllocationTemplateItem(
      {required final int id,
      required final int templateId,
      required final int categoryId,
      required final double allocatedAmount,
      required final BucketType bucketType,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? categoryName}) = _$AllocationTemplateItemImpl;
  const _AllocationTemplateItem._() : super._();

  factory _AllocationTemplateItem.fromJson(Map<String, dynamic> json) =
      _$AllocationTemplateItemImpl.fromJson;

  @override
  int get id;
  @override
  int get templateId;
  @override
  int get categoryId;
  @override
  double get allocatedAmount;
  @override
  BucketType get bucketType;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get categoryName;
  @override
  @JsonKey(ignore: true)
  _$$AllocationTemplateItemImplCopyWith<_$AllocationTemplateItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}
