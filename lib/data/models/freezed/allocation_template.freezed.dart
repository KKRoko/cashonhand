// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allocation_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AllocationTemplate _$AllocationTemplateFromJson(Map<String, dynamic> json) {
  return _AllocationTemplate.fromJson(json);
}

/// @nodoc
mixin _$AllocationTemplate {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AllocationTemplateCopyWith<AllocationTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllocationTemplateCopyWith<$Res> {
  factory $AllocationTemplateCopyWith(
          AllocationTemplate value, $Res Function(AllocationTemplate) then) =
      _$AllocationTemplateCopyWithImpl<$Res, AllocationTemplate>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      double totalAmount,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$AllocationTemplateCopyWithImpl<$Res, $Val extends AllocationTemplate>
    implements $AllocationTemplateCopyWith<$Res> {
  _$AllocationTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AllocationTemplateImplCopyWith<$Res>
    implements $AllocationTemplateCopyWith<$Res> {
  factory _$$AllocationTemplateImplCopyWith(_$AllocationTemplateImpl value,
          $Res Function(_$AllocationTemplateImpl) then) =
      __$$AllocationTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? description,
      double totalAmount,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$AllocationTemplateImplCopyWithImpl<$Res>
    extends _$AllocationTemplateCopyWithImpl<$Res, _$AllocationTemplateImpl>
    implements _$$AllocationTemplateImplCopyWith<$Res> {
  __$$AllocationTemplateImplCopyWithImpl(_$AllocationTemplateImpl _value,
      $Res Function(_$AllocationTemplateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? totalAmount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$AllocationTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AllocationTemplateImpl extends _AllocationTemplate {
  const _$AllocationTemplateImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.totalAmount,
      required this.createdAt,
      required this.updatedAt})
      : super._();

  factory _$AllocationTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllocationTemplateImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final double totalAmount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'AllocationTemplate(id: $id, name: $name, description: $description, totalAmount: $totalAmount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllocationTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, description, totalAmount, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AllocationTemplateImplCopyWith<_$AllocationTemplateImpl> get copyWith =>
      __$$AllocationTemplateImplCopyWithImpl<_$AllocationTemplateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllocationTemplateImplToJson(
      this,
    );
  }
}

abstract class _AllocationTemplate extends AllocationTemplate {
  const factory _AllocationTemplate(
      {required final int id,
      required final String name,
      final String? description,
      required final double totalAmount,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$AllocationTemplateImpl;
  const _AllocationTemplate._() : super._();

  factory _AllocationTemplate.fromJson(Map<String, dynamic> json) =
      _$AllocationTemplateImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  double get totalAmount;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AllocationTemplateImplCopyWith<_$AllocationTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
