// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'financial_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FinancialSuggestion _$FinancialSuggestionFromJson(Map<String, dynamic> json) {
  return _FinancialSuggestion.fromJson(json);
}

/// @nodoc
mixin _$FinancialSuggestion {
  String get id => throw _privateConstructorUsedError;
  SuggestionType get type => throw _privateConstructorUsedError;
  SuggestionPriority get priority => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get actionText => throw _privateConstructorUsedError;
  String? get actionRoute => throw _privateConstructorUsedError;
  Map<String, dynamic>? get actionData => throw _privateConstructorUsedError;
  double? get potentialSavings => throw _privateConstructorUsedError;
  int? get relatedGoalId => throw _privateConstructorUsedError;
  int? get relatedCategoryId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get isDismissed => throw _privateConstructorUsedError;
  bool get isActionTaken => throw _privateConstructorUsedError;
  DateTime? get dismissedAt => throw _privateConstructorUsedError;
  DateTime? get actionTakenAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FinancialSuggestionCopyWith<FinancialSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FinancialSuggestionCopyWith<$Res> {
  factory $FinancialSuggestionCopyWith(
          FinancialSuggestion value, $Res Function(FinancialSuggestion) then) =
      _$FinancialSuggestionCopyWithImpl<$Res, FinancialSuggestion>;
  @useResult
  $Res call(
      {String id,
      SuggestionType type,
      SuggestionPriority priority,
      String title,
      String description,
      String? actionText,
      String? actionRoute,
      Map<String, dynamic>? actionData,
      double? potentialSavings,
      int? relatedGoalId,
      int? relatedCategoryId,
      DateTime createdAt,
      DateTime? expiresAt,
      bool isDismissed,
      bool isActionTaken,
      DateTime? dismissedAt,
      DateTime? actionTakenAt});
}

/// @nodoc
class _$FinancialSuggestionCopyWithImpl<$Res, $Val extends FinancialSuggestion>
    implements $FinancialSuggestionCopyWith<$Res> {
  _$FinancialSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? description = null,
    Object? actionText = freezed,
    Object? actionRoute = freezed,
    Object? actionData = freezed,
    Object? potentialSavings = freezed,
    Object? relatedGoalId = freezed,
    Object? relatedCategoryId = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isDismissed = null,
    Object? isActionTaken = null,
    Object? dismissedAt = freezed,
    Object? actionTakenAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SuggestionType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as SuggestionPriority,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionText: freezed == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _value.actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      potentialSavings: freezed == potentialSavings
          ? _value.potentialSavings
          : potentialSavings // ignore: cast_nullable_to_non_nullable
              as double?,
      relatedGoalId: freezed == relatedGoalId
          ? _value.relatedGoalId
          : relatedGoalId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedCategoryId: freezed == relatedCategoryId
          ? _value.relatedCategoryId
          : relatedCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDismissed: null == isDismissed
          ? _value.isDismissed
          : isDismissed // ignore: cast_nullable_to_non_nullable
              as bool,
      isActionTaken: null == isActionTaken
          ? _value.isActionTaken
          : isActionTaken // ignore: cast_nullable_to_non_nullable
              as bool,
      dismissedAt: freezed == dismissedAt
          ? _value.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionTakenAt: freezed == actionTakenAt
          ? _value.actionTakenAt
          : actionTakenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FinancialSuggestionImplCopyWith<$Res>
    implements $FinancialSuggestionCopyWith<$Res> {
  factory _$$FinancialSuggestionImplCopyWith(_$FinancialSuggestionImpl value,
          $Res Function(_$FinancialSuggestionImpl) then) =
      __$$FinancialSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      SuggestionType type,
      SuggestionPriority priority,
      String title,
      String description,
      String? actionText,
      String? actionRoute,
      Map<String, dynamic>? actionData,
      double? potentialSavings,
      int? relatedGoalId,
      int? relatedCategoryId,
      DateTime createdAt,
      DateTime? expiresAt,
      bool isDismissed,
      bool isActionTaken,
      DateTime? dismissedAt,
      DateTime? actionTakenAt});
}

/// @nodoc
class __$$FinancialSuggestionImplCopyWithImpl<$Res>
    extends _$FinancialSuggestionCopyWithImpl<$Res, _$FinancialSuggestionImpl>
    implements _$$FinancialSuggestionImplCopyWith<$Res> {
  __$$FinancialSuggestionImplCopyWithImpl(_$FinancialSuggestionImpl _value,
      $Res Function(_$FinancialSuggestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? priority = null,
    Object? title = null,
    Object? description = null,
    Object? actionText = freezed,
    Object? actionRoute = freezed,
    Object? actionData = freezed,
    Object? potentialSavings = freezed,
    Object? relatedGoalId = freezed,
    Object? relatedCategoryId = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? isDismissed = null,
    Object? isActionTaken = null,
    Object? dismissedAt = freezed,
    Object? actionTakenAt = freezed,
  }) {
    return _then(_$FinancialSuggestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SuggestionType,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as SuggestionPriority,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      actionText: freezed == actionText
          ? _value.actionText
          : actionText // ignore: cast_nullable_to_non_nullable
              as String?,
      actionRoute: freezed == actionRoute
          ? _value.actionRoute
          : actionRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      actionData: freezed == actionData
          ? _value._actionData
          : actionData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      potentialSavings: freezed == potentialSavings
          ? _value.potentialSavings
          : potentialSavings // ignore: cast_nullable_to_non_nullable
              as double?,
      relatedGoalId: freezed == relatedGoalId
          ? _value.relatedGoalId
          : relatedGoalId // ignore: cast_nullable_to_non_nullable
              as int?,
      relatedCategoryId: freezed == relatedCategoryId
          ? _value.relatedCategoryId
          : relatedCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isDismissed: null == isDismissed
          ? _value.isDismissed
          : isDismissed // ignore: cast_nullable_to_non_nullable
              as bool,
      isActionTaken: null == isActionTaken
          ? _value.isActionTaken
          : isActionTaken // ignore: cast_nullable_to_non_nullable
              as bool,
      dismissedAt: freezed == dismissedAt
          ? _value.dismissedAt
          : dismissedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      actionTakenAt: freezed == actionTakenAt
          ? _value.actionTakenAt
          : actionTakenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FinancialSuggestionImpl extends _FinancialSuggestion {
  const _$FinancialSuggestionImpl(
      {required this.id,
      required this.type,
      required this.priority,
      required this.title,
      required this.description,
      this.actionText,
      this.actionRoute,
      final Map<String, dynamic>? actionData,
      this.potentialSavings,
      this.relatedGoalId,
      this.relatedCategoryId,
      required this.createdAt,
      this.expiresAt,
      this.isDismissed = false,
      this.isActionTaken = false,
      this.dismissedAt,
      this.actionTakenAt})
      : _actionData = actionData,
        super._();

  factory _$FinancialSuggestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FinancialSuggestionImplFromJson(json);

  @override
  final String id;
  @override
  final SuggestionType type;
  @override
  final SuggestionPriority priority;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? actionText;
  @override
  final String? actionRoute;
  final Map<String, dynamic>? _actionData;
  @override
  Map<String, dynamic>? get actionData {
    final value = _actionData;
    if (value == null) return null;
    if (_actionData is EqualUnmodifiableMapView) return _actionData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final double? potentialSavings;
  @override
  final int? relatedGoalId;
  @override
  final int? relatedCategoryId;
  @override
  final DateTime createdAt;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool isDismissed;
  @override
  @JsonKey()
  final bool isActionTaken;
  @override
  final DateTime? dismissedAt;
  @override
  final DateTime? actionTakenAt;

  @override
  String toString() {
    return 'FinancialSuggestion(id: $id, type: $type, priority: $priority, title: $title, description: $description, actionText: $actionText, actionRoute: $actionRoute, actionData: $actionData, potentialSavings: $potentialSavings, relatedGoalId: $relatedGoalId, relatedCategoryId: $relatedCategoryId, createdAt: $createdAt, expiresAt: $expiresAt, isDismissed: $isDismissed, isActionTaken: $isActionTaken, dismissedAt: $dismissedAt, actionTakenAt: $actionTakenAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FinancialSuggestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.actionText, actionText) ||
                other.actionText == actionText) &&
            (identical(other.actionRoute, actionRoute) ||
                other.actionRoute == actionRoute) &&
            const DeepCollectionEquality()
                .equals(other._actionData, _actionData) &&
            (identical(other.potentialSavings, potentialSavings) ||
                other.potentialSavings == potentialSavings) &&
            (identical(other.relatedGoalId, relatedGoalId) ||
                other.relatedGoalId == relatedGoalId) &&
            (identical(other.relatedCategoryId, relatedCategoryId) ||
                other.relatedCategoryId == relatedCategoryId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isDismissed, isDismissed) ||
                other.isDismissed == isDismissed) &&
            (identical(other.isActionTaken, isActionTaken) ||
                other.isActionTaken == isActionTaken) &&
            (identical(other.dismissedAt, dismissedAt) ||
                other.dismissedAt == dismissedAt) &&
            (identical(other.actionTakenAt, actionTakenAt) ||
                other.actionTakenAt == actionTakenAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      priority,
      title,
      description,
      actionText,
      actionRoute,
      const DeepCollectionEquality().hash(_actionData),
      potentialSavings,
      relatedGoalId,
      relatedCategoryId,
      createdAt,
      expiresAt,
      isDismissed,
      isActionTaken,
      dismissedAt,
      actionTakenAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FinancialSuggestionImplCopyWith<_$FinancialSuggestionImpl> get copyWith =>
      __$$FinancialSuggestionImplCopyWithImpl<_$FinancialSuggestionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FinancialSuggestionImplToJson(
      this,
    );
  }
}

abstract class _FinancialSuggestion extends FinancialSuggestion {
  const factory _FinancialSuggestion(
      {required final String id,
      required final SuggestionType type,
      required final SuggestionPriority priority,
      required final String title,
      required final String description,
      final String? actionText,
      final String? actionRoute,
      final Map<String, dynamic>? actionData,
      final double? potentialSavings,
      final int? relatedGoalId,
      final int? relatedCategoryId,
      required final DateTime createdAt,
      final DateTime? expiresAt,
      final bool isDismissed,
      final bool isActionTaken,
      final DateTime? dismissedAt,
      final DateTime? actionTakenAt}) = _$FinancialSuggestionImpl;
  const _FinancialSuggestion._() : super._();

  factory _FinancialSuggestion.fromJson(Map<String, dynamic> json) =
      _$FinancialSuggestionImpl.fromJson;

  @override
  String get id;
  @override
  SuggestionType get type;
  @override
  SuggestionPriority get priority;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get actionText;
  @override
  String? get actionRoute;
  @override
  Map<String, dynamic>? get actionData;
  @override
  double? get potentialSavings;
  @override
  int? get relatedGoalId;
  @override
  int? get relatedCategoryId;
  @override
  DateTime get createdAt;
  @override
  DateTime? get expiresAt;
  @override
  bool get isDismissed;
  @override
  bool get isActionTaken;
  @override
  DateTime? get dismissedAt;
  @override
  DateTime? get actionTakenAt;
  @override
  @JsonKey(ignore: true)
  _$$FinancialSuggestionImplCopyWith<_$FinancialSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SpendingPattern _$SpendingPatternFromJson(Map<String, dynamic> json) {
  return _SpendingPattern.fromJson(json);
}

/// @nodoc
mixin _$SpendingPattern {
  int get categoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  double get averageMonthly => throw _privateConstructorUsedError;
  double get currentMonth => throw _privateConstructorUsedError;
  double get lastMonth => throw _privateConstructorUsedError;
  int get transactionCount => throw _privateConstructorUsedError;
  DateTime get firstTransaction => throw _privateConstructorUsedError;
  DateTime get lastTransaction => throw _privateConstructorUsedError;
  List<double> get monthlyTrends => throw _privateConstructorUsedError;
  double? get peakAmount => throw _privateConstructorUsedError;
  DateTime? get peakDate => throw _privateConstructorUsedError;
  List<String> get frequentMerchants => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpendingPatternCopyWith<SpendingPattern> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingPatternCopyWith<$Res> {
  factory $SpendingPatternCopyWith(
          SpendingPattern value, $Res Function(SpendingPattern) then) =
      _$SpendingPatternCopyWithImpl<$Res, SpendingPattern>;
  @useResult
  $Res call(
      {int categoryId,
      String categoryName,
      double averageMonthly,
      double currentMonth,
      double lastMonth,
      int transactionCount,
      DateTime firstTransaction,
      DateTime lastTransaction,
      List<double> monthlyTrends,
      double? peakAmount,
      DateTime? peakDate,
      List<String> frequentMerchants});
}

/// @nodoc
class _$SpendingPatternCopyWithImpl<$Res, $Val extends SpendingPattern>
    implements $SpendingPatternCopyWith<$Res> {
  _$SpendingPatternCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? averageMonthly = null,
    Object? currentMonth = null,
    Object? lastMonth = null,
    Object? transactionCount = null,
    Object? firstTransaction = null,
    Object? lastTransaction = null,
    Object? monthlyTrends = null,
    Object? peakAmount = freezed,
    Object? peakDate = freezed,
    Object? frequentMerchants = null,
  }) {
    return _then(_value.copyWith(
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      averageMonthly: null == averageMonthly
          ? _value.averageMonthly
          : averageMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      currentMonth: null == currentMonth
          ? _value.currentMonth
          : currentMonth // ignore: cast_nullable_to_non_nullable
              as double,
      lastMonth: null == lastMonth
          ? _value.lastMonth
          : lastMonth // ignore: cast_nullable_to_non_nullable
              as double,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      firstTransaction: null == firstTransaction
          ? _value.firstTransaction
          : firstTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastTransaction: null == lastTransaction
          ? _value.lastTransaction
          : lastTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthlyTrends: null == monthlyTrends
          ? _value.monthlyTrends
          : monthlyTrends // ignore: cast_nullable_to_non_nullable
              as List<double>,
      peakAmount: freezed == peakAmount
          ? _value.peakAmount
          : peakAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      peakDate: freezed == peakDate
          ? _value.peakDate
          : peakDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      frequentMerchants: null == frequentMerchants
          ? _value.frequentMerchants
          : frequentMerchants // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpendingPatternImplCopyWith<$Res>
    implements $SpendingPatternCopyWith<$Res> {
  factory _$$SpendingPatternImplCopyWith(_$SpendingPatternImpl value,
          $Res Function(_$SpendingPatternImpl) then) =
      __$$SpendingPatternImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int categoryId,
      String categoryName,
      double averageMonthly,
      double currentMonth,
      double lastMonth,
      int transactionCount,
      DateTime firstTransaction,
      DateTime lastTransaction,
      List<double> monthlyTrends,
      double? peakAmount,
      DateTime? peakDate,
      List<String> frequentMerchants});
}

/// @nodoc
class __$$SpendingPatternImplCopyWithImpl<$Res>
    extends _$SpendingPatternCopyWithImpl<$Res, _$SpendingPatternImpl>
    implements _$$SpendingPatternImplCopyWith<$Res> {
  __$$SpendingPatternImplCopyWithImpl(
      _$SpendingPatternImpl _value, $Res Function(_$SpendingPatternImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryId = null,
    Object? categoryName = null,
    Object? averageMonthly = null,
    Object? currentMonth = null,
    Object? lastMonth = null,
    Object? transactionCount = null,
    Object? firstTransaction = null,
    Object? lastTransaction = null,
    Object? monthlyTrends = null,
    Object? peakAmount = freezed,
    Object? peakDate = freezed,
    Object? frequentMerchants = null,
  }) {
    return _then(_$SpendingPatternImpl(
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
      averageMonthly: null == averageMonthly
          ? _value.averageMonthly
          : averageMonthly // ignore: cast_nullable_to_non_nullable
              as double,
      currentMonth: null == currentMonth
          ? _value.currentMonth
          : currentMonth // ignore: cast_nullable_to_non_nullable
              as double,
      lastMonth: null == lastMonth
          ? _value.lastMonth
          : lastMonth // ignore: cast_nullable_to_non_nullable
              as double,
      transactionCount: null == transactionCount
          ? _value.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      firstTransaction: null == firstTransaction
          ? _value.firstTransaction
          : firstTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastTransaction: null == lastTransaction
          ? _value.lastTransaction
          : lastTransaction // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthlyTrends: null == monthlyTrends
          ? _value._monthlyTrends
          : monthlyTrends // ignore: cast_nullable_to_non_nullable
              as List<double>,
      peakAmount: freezed == peakAmount
          ? _value.peakAmount
          : peakAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      peakDate: freezed == peakDate
          ? _value.peakDate
          : peakDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      frequentMerchants: null == frequentMerchants
          ? _value._frequentMerchants
          : frequentMerchants // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpendingPatternImpl extends _SpendingPattern {
  const _$SpendingPatternImpl(
      {required this.categoryId,
      required this.categoryName,
      required this.averageMonthly,
      required this.currentMonth,
      required this.lastMonth,
      required this.transactionCount,
      required this.firstTransaction,
      required this.lastTransaction,
      required final List<double> monthlyTrends,
      this.peakAmount,
      this.peakDate,
      final List<String> frequentMerchants = const []})
      : _monthlyTrends = monthlyTrends,
        _frequentMerchants = frequentMerchants,
        super._();

  factory _$SpendingPatternImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpendingPatternImplFromJson(json);

  @override
  final int categoryId;
  @override
  final String categoryName;
  @override
  final double averageMonthly;
  @override
  final double currentMonth;
  @override
  final double lastMonth;
  @override
  final int transactionCount;
  @override
  final DateTime firstTransaction;
  @override
  final DateTime lastTransaction;
  final List<double> _monthlyTrends;
  @override
  List<double> get monthlyTrends {
    if (_monthlyTrends is EqualUnmodifiableListView) return _monthlyTrends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_monthlyTrends);
  }

  @override
  final double? peakAmount;
  @override
  final DateTime? peakDate;
  final List<String> _frequentMerchants;
  @override
  @JsonKey()
  List<String> get frequentMerchants {
    if (_frequentMerchants is EqualUnmodifiableListView)
      return _frequentMerchants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frequentMerchants);
  }

  @override
  String toString() {
    return 'SpendingPattern(categoryId: $categoryId, categoryName: $categoryName, averageMonthly: $averageMonthly, currentMonth: $currentMonth, lastMonth: $lastMonth, transactionCount: $transactionCount, firstTransaction: $firstTransaction, lastTransaction: $lastTransaction, monthlyTrends: $monthlyTrends, peakAmount: $peakAmount, peakDate: $peakDate, frequentMerchants: $frequentMerchants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingPatternImpl &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.averageMonthly, averageMonthly) ||
                other.averageMonthly == averageMonthly) &&
            (identical(other.currentMonth, currentMonth) ||
                other.currentMonth == currentMonth) &&
            (identical(other.lastMonth, lastMonth) ||
                other.lastMonth == lastMonth) &&
            (identical(other.transactionCount, transactionCount) ||
                other.transactionCount == transactionCount) &&
            (identical(other.firstTransaction, firstTransaction) ||
                other.firstTransaction == firstTransaction) &&
            (identical(other.lastTransaction, lastTransaction) ||
                other.lastTransaction == lastTransaction) &&
            const DeepCollectionEquality()
                .equals(other._monthlyTrends, _monthlyTrends) &&
            (identical(other.peakAmount, peakAmount) ||
                other.peakAmount == peakAmount) &&
            (identical(other.peakDate, peakDate) ||
                other.peakDate == peakDate) &&
            const DeepCollectionEquality()
                .equals(other._frequentMerchants, _frequentMerchants));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      categoryId,
      categoryName,
      averageMonthly,
      currentMonth,
      lastMonth,
      transactionCount,
      firstTransaction,
      lastTransaction,
      const DeepCollectionEquality().hash(_monthlyTrends),
      peakAmount,
      peakDate,
      const DeepCollectionEquality().hash(_frequentMerchants));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingPatternImplCopyWith<_$SpendingPatternImpl> get copyWith =>
      __$$SpendingPatternImplCopyWithImpl<_$SpendingPatternImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpendingPatternImplToJson(
      this,
    );
  }
}

abstract class _SpendingPattern extends SpendingPattern {
  const factory _SpendingPattern(
      {required final int categoryId,
      required final String categoryName,
      required final double averageMonthly,
      required final double currentMonth,
      required final double lastMonth,
      required final int transactionCount,
      required final DateTime firstTransaction,
      required final DateTime lastTransaction,
      required final List<double> monthlyTrends,
      final double? peakAmount,
      final DateTime? peakDate,
      final List<String> frequentMerchants}) = _$SpendingPatternImpl;
  const _SpendingPattern._() : super._();

  factory _SpendingPattern.fromJson(Map<String, dynamic> json) =
      _$SpendingPatternImpl.fromJson;

  @override
  int get categoryId;
  @override
  String get categoryName;
  @override
  double get averageMonthly;
  @override
  double get currentMonth;
  @override
  double get lastMonth;
  @override
  int get transactionCount;
  @override
  DateTime get firstTransaction;
  @override
  DateTime get lastTransaction;
  @override
  List<double> get monthlyTrends;
  @override
  double? get peakAmount;
  @override
  DateTime? get peakDate;
  @override
  List<String> get frequentMerchants;
  @override
  @JsonKey(ignore: true)
  _$$SpendingPatternImplCopyWith<_$SpendingPatternImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavingsOpportunity _$SavingsOpportunityFromJson(Map<String, dynamic> json) {
  return _SavingsOpportunity.fromJson(json);
}

/// @nodoc
mixin _$SavingsOpportunity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get potentialMonthlySavings => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError; // 0.0 to 1.0
  SuggestionType get suggestionType => throw _privateConstructorUsedError;
  int? get categoryId => throw _privateConstructorUsedError;
  int? get goalId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get analysisData => throw _privateConstructorUsedError;
  DateTime get detectedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SavingsOpportunityCopyWith<SavingsOpportunity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsOpportunityCopyWith<$Res> {
  factory $SavingsOpportunityCopyWith(
          SavingsOpportunity value, $Res Function(SavingsOpportunity) then) =
      _$SavingsOpportunityCopyWithImpl<$Res, SavingsOpportunity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double potentialMonthlySavings,
      double confidence,
      SuggestionType suggestionType,
      int? categoryId,
      int? goalId,
      Map<String, dynamic>? analysisData,
      DateTime detectedAt});
}

/// @nodoc
class _$SavingsOpportunityCopyWithImpl<$Res, $Val extends SavingsOpportunity>
    implements $SavingsOpportunityCopyWith<$Res> {
  _$SavingsOpportunityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? potentialMonthlySavings = null,
    Object? confidence = null,
    Object? suggestionType = null,
    Object? categoryId = freezed,
    Object? goalId = freezed,
    Object? analysisData = freezed,
    Object? detectedAt = null,
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
      potentialMonthlySavings: null == potentialMonthlySavings
          ? _value.potentialMonthlySavings
          : potentialMonthlySavings // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      suggestionType: null == suggestionType
          ? _value.suggestionType
          : suggestionType // ignore: cast_nullable_to_non_nullable
              as SuggestionType,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: freezed == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int?,
      analysisData: freezed == analysisData
          ? _value.analysisData
          : analysisData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SavingsOpportunityImplCopyWith<$Res>
    implements $SavingsOpportunityCopyWith<$Res> {
  factory _$$SavingsOpportunityImplCopyWith(_$SavingsOpportunityImpl value,
          $Res Function(_$SavingsOpportunityImpl) then) =
      __$$SavingsOpportunityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double potentialMonthlySavings,
      double confidence,
      SuggestionType suggestionType,
      int? categoryId,
      int? goalId,
      Map<String, dynamic>? analysisData,
      DateTime detectedAt});
}

/// @nodoc
class __$$SavingsOpportunityImplCopyWithImpl<$Res>
    extends _$SavingsOpportunityCopyWithImpl<$Res, _$SavingsOpportunityImpl>
    implements _$$SavingsOpportunityImplCopyWith<$Res> {
  __$$SavingsOpportunityImplCopyWithImpl(_$SavingsOpportunityImpl _value,
      $Res Function(_$SavingsOpportunityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? potentialMonthlySavings = null,
    Object? confidence = null,
    Object? suggestionType = null,
    Object? categoryId = freezed,
    Object? goalId = freezed,
    Object? analysisData = freezed,
    Object? detectedAt = null,
  }) {
    return _then(_$SavingsOpportunityImpl(
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
      potentialMonthlySavings: null == potentialMonthlySavings
          ? _value.potentialMonthlySavings
          : potentialMonthlySavings // ignore: cast_nullable_to_non_nullable
              as double,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      suggestionType: null == suggestionType
          ? _value.suggestionType
          : suggestionType // ignore: cast_nullable_to_non_nullable
              as SuggestionType,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      goalId: freezed == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int?,
      analysisData: freezed == analysisData
          ? _value._analysisData
          : analysisData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      detectedAt: null == detectedAt
          ? _value.detectedAt
          : detectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsOpportunityImpl extends _SavingsOpportunity {
  const _$SavingsOpportunityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.potentialMonthlySavings,
      required this.confidence,
      required this.suggestionType,
      this.categoryId,
      this.goalId,
      final Map<String, dynamic>? analysisData,
      required this.detectedAt})
      : _analysisData = analysisData,
        super._();

  factory _$SavingsOpportunityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsOpportunityImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double potentialMonthlySavings;
  @override
  final double confidence;
// 0.0 to 1.0
  @override
  final SuggestionType suggestionType;
  @override
  final int? categoryId;
  @override
  final int? goalId;
  final Map<String, dynamic>? _analysisData;
  @override
  Map<String, dynamic>? get analysisData {
    final value = _analysisData;
    if (value == null) return null;
    if (_analysisData is EqualUnmodifiableMapView) return _analysisData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime detectedAt;

  @override
  String toString() {
    return 'SavingsOpportunity(id: $id, title: $title, description: $description, potentialMonthlySavings: $potentialMonthlySavings, confidence: $confidence, suggestionType: $suggestionType, categoryId: $categoryId, goalId: $goalId, analysisData: $analysisData, detectedAt: $detectedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsOpportunityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(
                    other.potentialMonthlySavings, potentialMonthlySavings) ||
                other.potentialMonthlySavings == potentialMonthlySavings) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.suggestionType, suggestionType) ||
                other.suggestionType == suggestionType) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            const DeepCollectionEquality()
                .equals(other._analysisData, _analysisData) &&
            (identical(other.detectedAt, detectedAt) ||
                other.detectedAt == detectedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      potentialMonthlySavings,
      confidence,
      suggestionType,
      categoryId,
      goalId,
      const DeepCollectionEquality().hash(_analysisData),
      detectedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsOpportunityImplCopyWith<_$SavingsOpportunityImpl> get copyWith =>
      __$$SavingsOpportunityImplCopyWithImpl<_$SavingsOpportunityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsOpportunityImplToJson(
      this,
    );
  }
}

abstract class _SavingsOpportunity extends SavingsOpportunity {
  const factory _SavingsOpportunity(
      {required final String id,
      required final String title,
      required final String description,
      required final double potentialMonthlySavings,
      required final double confidence,
      required final SuggestionType suggestionType,
      final int? categoryId,
      final int? goalId,
      final Map<String, dynamic>? analysisData,
      required final DateTime detectedAt}) = _$SavingsOpportunityImpl;
  const _SavingsOpportunity._() : super._();

  factory _SavingsOpportunity.fromJson(Map<String, dynamic> json) =
      _$SavingsOpportunityImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get potentialMonthlySavings;
  @override
  double get confidence;
  @override // 0.0 to 1.0
  SuggestionType get suggestionType;
  @override
  int? get categoryId;
  @override
  int? get goalId;
  @override
  Map<String, dynamic>? get analysisData;
  @override
  DateTime get detectedAt;
  @override
  @JsonKey(ignore: true)
  _$$SavingsOpportunityImplCopyWith<_$SavingsOpportunityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalInsight _$GoalInsightFromJson(Map<String, dynamic> json) {
  return _GoalInsight.fromJson(json);
}

/// @nodoc
mixin _$GoalInsight {
  int get goalId => throw _privateConstructorUsedError;
  String get goalTitle => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  DateTime get targetDate => throw _privateConstructorUsedError;
  double get monthlyRequired => throw _privateConstructorUsedError;
  double get averageMonthlyContribution => throw _privateConstructorUsedError;
  int get daysRemaining => throw _privateConstructorUsedError;
  bool get isOnTrack => throw _privateConstructorUsedError;
  double? get projectedShortfall => throw _privateConstructorUsedError;
  DateTime? get projectedCompletionDate => throw _privateConstructorUsedError;
  List<String> get recommendations => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GoalInsightCopyWith<GoalInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalInsightCopyWith<$Res> {
  factory $GoalInsightCopyWith(
          GoalInsight value, $Res Function(GoalInsight) then) =
      _$GoalInsightCopyWithImpl<$Res, GoalInsight>;
  @useResult
  $Res call(
      {int goalId,
      String goalTitle,
      double currentAmount,
      double targetAmount,
      DateTime targetDate,
      double monthlyRequired,
      double averageMonthlyContribution,
      int daysRemaining,
      bool isOnTrack,
      double? projectedShortfall,
      DateTime? projectedCompletionDate,
      List<String> recommendations});
}

/// @nodoc
class _$GoalInsightCopyWithImpl<$Res, $Val extends GoalInsight>
    implements $GoalInsightCopyWith<$Res> {
  _$GoalInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? goalTitle = null,
    Object? currentAmount = null,
    Object? targetAmount = null,
    Object? targetDate = null,
    Object? monthlyRequired = null,
    Object? averageMonthlyContribution = null,
    Object? daysRemaining = null,
    Object? isOnTrack = null,
    Object? projectedShortfall = freezed,
    Object? projectedCompletionDate = freezed,
    Object? recommendations = null,
  }) {
    return _then(_value.copyWith(
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      goalTitle: null == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthlyRequired: null == monthlyRequired
          ? _value.monthlyRequired
          : monthlyRequired // ignore: cast_nullable_to_non_nullable
              as double,
      averageMonthlyContribution: null == averageMonthlyContribution
          ? _value.averageMonthlyContribution
          : averageMonthlyContribution // ignore: cast_nullable_to_non_nullable
              as double,
      daysRemaining: null == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      isOnTrack: null == isOnTrack
          ? _value.isOnTrack
          : isOnTrack // ignore: cast_nullable_to_non_nullable
              as bool,
      projectedShortfall: freezed == projectedShortfall
          ? _value.projectedShortfall
          : projectedShortfall // ignore: cast_nullable_to_non_nullable
              as double?,
      projectedCompletionDate: freezed == projectedCompletionDate
          ? _value.projectedCompletionDate
          : projectedCompletionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recommendations: null == recommendations
          ? _value.recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalInsightImplCopyWith<$Res>
    implements $GoalInsightCopyWith<$Res> {
  factory _$$GoalInsightImplCopyWith(
          _$GoalInsightImpl value, $Res Function(_$GoalInsightImpl) then) =
      __$$GoalInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int goalId,
      String goalTitle,
      double currentAmount,
      double targetAmount,
      DateTime targetDate,
      double monthlyRequired,
      double averageMonthlyContribution,
      int daysRemaining,
      bool isOnTrack,
      double? projectedShortfall,
      DateTime? projectedCompletionDate,
      List<String> recommendations});
}

/// @nodoc
class __$$GoalInsightImplCopyWithImpl<$Res>
    extends _$GoalInsightCopyWithImpl<$Res, _$GoalInsightImpl>
    implements _$$GoalInsightImplCopyWith<$Res> {
  __$$GoalInsightImplCopyWithImpl(
      _$GoalInsightImpl _value, $Res Function(_$GoalInsightImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? goalId = null,
    Object? goalTitle = null,
    Object? currentAmount = null,
    Object? targetAmount = null,
    Object? targetDate = null,
    Object? monthlyRequired = null,
    Object? averageMonthlyContribution = null,
    Object? daysRemaining = null,
    Object? isOnTrack = null,
    Object? projectedShortfall = freezed,
    Object? projectedCompletionDate = freezed,
    Object? recommendations = null,
  }) {
    return _then(_$GoalInsightImpl(
      goalId: null == goalId
          ? _value.goalId
          : goalId // ignore: cast_nullable_to_non_nullable
              as int,
      goalTitle: null == goalTitle
          ? _value.goalTitle
          : goalTitle // ignore: cast_nullable_to_non_nullable
              as String,
      currentAmount: null == currentAmount
          ? _value.currentAmount
          : currentAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetAmount: null == targetAmount
          ? _value.targetAmount
          : targetAmount // ignore: cast_nullable_to_non_nullable
              as double,
      targetDate: null == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      monthlyRequired: null == monthlyRequired
          ? _value.monthlyRequired
          : monthlyRequired // ignore: cast_nullable_to_non_nullable
              as double,
      averageMonthlyContribution: null == averageMonthlyContribution
          ? _value.averageMonthlyContribution
          : averageMonthlyContribution // ignore: cast_nullable_to_non_nullable
              as double,
      daysRemaining: null == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      isOnTrack: null == isOnTrack
          ? _value.isOnTrack
          : isOnTrack // ignore: cast_nullable_to_non_nullable
              as bool,
      projectedShortfall: freezed == projectedShortfall
          ? _value.projectedShortfall
          : projectedShortfall // ignore: cast_nullable_to_non_nullable
              as double?,
      projectedCompletionDate: freezed == projectedCompletionDate
          ? _value.projectedCompletionDate
          : projectedCompletionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      recommendations: null == recommendations
          ? _value._recommendations
          : recommendations // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalInsightImpl extends _GoalInsight {
  const _$GoalInsightImpl(
      {required this.goalId,
      required this.goalTitle,
      required this.currentAmount,
      required this.targetAmount,
      required this.targetDate,
      required this.monthlyRequired,
      required this.averageMonthlyContribution,
      required this.daysRemaining,
      required this.isOnTrack,
      this.projectedShortfall,
      this.projectedCompletionDate,
      final List<String> recommendations = const []})
      : _recommendations = recommendations,
        super._();

  factory _$GoalInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalInsightImplFromJson(json);

  @override
  final int goalId;
  @override
  final String goalTitle;
  @override
  final double currentAmount;
  @override
  final double targetAmount;
  @override
  final DateTime targetDate;
  @override
  final double monthlyRequired;
  @override
  final double averageMonthlyContribution;
  @override
  final int daysRemaining;
  @override
  final bool isOnTrack;
  @override
  final double? projectedShortfall;
  @override
  final DateTime? projectedCompletionDate;
  final List<String> _recommendations;
  @override
  @JsonKey()
  List<String> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  @override
  String toString() {
    return 'GoalInsight(goalId: $goalId, goalTitle: $goalTitle, currentAmount: $currentAmount, targetAmount: $targetAmount, targetDate: $targetDate, monthlyRequired: $monthlyRequired, averageMonthlyContribution: $averageMonthlyContribution, daysRemaining: $daysRemaining, isOnTrack: $isOnTrack, projectedShortfall: $projectedShortfall, projectedCompletionDate: $projectedCompletionDate, recommendations: $recommendations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalInsightImpl &&
            (identical(other.goalId, goalId) || other.goalId == goalId) &&
            (identical(other.goalTitle, goalTitle) ||
                other.goalTitle == goalTitle) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.monthlyRequired, monthlyRequired) ||
                other.monthlyRequired == monthlyRequired) &&
            (identical(other.averageMonthlyContribution,
                    averageMonthlyContribution) ||
                other.averageMonthlyContribution ==
                    averageMonthlyContribution) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining) &&
            (identical(other.isOnTrack, isOnTrack) ||
                other.isOnTrack == isOnTrack) &&
            (identical(other.projectedShortfall, projectedShortfall) ||
                other.projectedShortfall == projectedShortfall) &&
            (identical(
                    other.projectedCompletionDate, projectedCompletionDate) ||
                other.projectedCompletionDate == projectedCompletionDate) &&
            const DeepCollectionEquality()
                .equals(other._recommendations, _recommendations));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      goalId,
      goalTitle,
      currentAmount,
      targetAmount,
      targetDate,
      monthlyRequired,
      averageMonthlyContribution,
      daysRemaining,
      isOnTrack,
      projectedShortfall,
      projectedCompletionDate,
      const DeepCollectionEquality().hash(_recommendations));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalInsightImplCopyWith<_$GoalInsightImpl> get copyWith =>
      __$$GoalInsightImplCopyWithImpl<_$GoalInsightImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalInsightImplToJson(
      this,
    );
  }
}

abstract class _GoalInsight extends GoalInsight {
  const factory _GoalInsight(
      {required final int goalId,
      required final String goalTitle,
      required final double currentAmount,
      required final double targetAmount,
      required final DateTime targetDate,
      required final double monthlyRequired,
      required final double averageMonthlyContribution,
      required final int daysRemaining,
      required final bool isOnTrack,
      final double? projectedShortfall,
      final DateTime? projectedCompletionDate,
      final List<String> recommendations}) = _$GoalInsightImpl;
  const _GoalInsight._() : super._();

  factory _GoalInsight.fromJson(Map<String, dynamic> json) =
      _$GoalInsightImpl.fromJson;

  @override
  int get goalId;
  @override
  String get goalTitle;
  @override
  double get currentAmount;
  @override
  double get targetAmount;
  @override
  DateTime get targetDate;
  @override
  double get monthlyRequired;
  @override
  double get averageMonthlyContribution;
  @override
  int get daysRemaining;
  @override
  bool get isOnTrack;
  @override
  double? get projectedShortfall;
  @override
  DateTime? get projectedCompletionDate;
  @override
  List<String> get recommendations;
  @override
  @JsonKey(ignore: true)
  _$$GoalInsightImplCopyWith<_$GoalInsightImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
