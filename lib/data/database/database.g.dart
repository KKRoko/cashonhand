// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<CategoryType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<CategoryType>($CategoriesTable.$convertertype);
  static const VerificationMeta _parentCategoryIdMeta =
      const VerificationMeta('parentCategoryId');
  @override
  late final GeneratedColumn<int> parentCategoryId = GeneratedColumn<int>(
      'parent_category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, parentCategoryId, icon, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('parent_category_id')) {
      context.handle(
          _parentCategoryIdMeta,
          parentCategoryId.isAcceptableOrUnknown(
              data['parent_category_id']!, _parentCategoryIdMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $CategoriesTable.$convertertype.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      parentCategoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_category_id']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<CategoryType, String> $convertertype =
      const CategoryTypeConverter();
}

class CategoryTableData extends DataClass
    implements Insertable<CategoryTableData> {
  final int id;
  final String name;
  final CategoryType type;
  final int? parentCategoryId;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryTableData(
      {required this.id,
      required this.name,
      required this.type,
      this.parentCategoryId,
      this.icon,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] =
          Variable<String>($CategoriesTable.$convertertype.toSql(type));
    }
    if (!nullToAbsent || parentCategoryId != null) {
      map['parent_category_id'] = Variable<int>(parentCategoryId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      parentCategoryId: parentCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentCategoryId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<CategoryType>(json['type']),
      parentCategoryId: serializer.fromJson<int?>(json['parentCategoryId']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<CategoryType>(type),
      'parentCategoryId': serializer.toJson<int?>(parentCategoryId),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryTableData copyWith(
          {int? id,
          String? name,
          CategoryType? type,
          Value<int?> parentCategoryId = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        parentCategoryId: parentCategoryId.present
            ? parentCategoryId.value
            : this.parentCategoryId,
        icon: icon.present ? icon.value : this.icon,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoryTableData copyWithCompanion(CategoriesCompanion data) {
    return CategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      parentCategoryId: data.parentCategoryId.present
          ? data.parentCategoryId.value
          : this.parentCategoryId,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, type, parentCategoryId, icon, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.parentCategoryId == this.parentCategoryId &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<CategoryType> type;
  final Value<int?> parentCategoryId;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.parentCategoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required CategoryType type,
    this.parentCategoryId = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        type = Value(type);
  static Insertable<CategoryTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? parentCategoryId,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<CategoryType>? type,
      Value<int?>? parentCategoryId,
      Value<String?>? icon,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($CategoriesTable.$convertertype.toSql(type.value));
    }
    if (parentCategoryId.present) {
      map['parent_category_id'] = Variable<int>(parentCategoryId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('parentCategoryId: $parentCategoryId, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, EventTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _originalEventIdMeta =
      const VerificationMeta('originalEventId');
  @override
  late final GeneratedColumn<int> originalEventId = GeneratedColumn<int>(
      'original_event_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _repeatOptionMeta =
      const VerificationMeta('repeatOption');
  @override
  late final GeneratedColumnWithTypeConverter<RepeatOption, String>
      repeatOption = GeneratedColumn<String>(
              'repeat_option', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<RepeatOption>($EventsTable.$converterrepeatOption);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customRecurrenceMeta =
      const VerificationMeta('customRecurrence');
  @override
  late final GeneratedColumnWithTypeConverter<CustomRecurrence?, String>
      customRecurrence = GeneratedColumn<String>(
              'custom_recurrence', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<CustomRecurrence?>(
              $EventsTable.$convertercustomRecurrencen);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        originalEventId,
        title,
        categoryId,
        amount,
        date,
        repeatOption,
        isRecurring,
        notes,
        customRecurrence,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<EventTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('original_event_id')) {
      context.handle(
          _originalEventIdMeta,
          originalEventId.isAcceptableOrUnknown(
              data['original_event_id']!, _originalEventIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    context.handle(_repeatOptionMeta, const VerificationResult.success());
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    context.handle(_customRecurrenceMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      originalEventId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}original_event_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      repeatOption: $EventsTable.$converterrepeatOption.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat_option'])!),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      customRecurrence: $EventsTable.$convertercustomRecurrencen.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}custom_recurrence'])),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }

  static TypeConverter<RepeatOption, String> $converterrepeatOption =
      const RepeatOptionConverter();
  static TypeConverter<CustomRecurrence, String> $convertercustomRecurrence =
      const CustomRecurrenceConverter();
  static TypeConverter<CustomRecurrence?, String?> $convertercustomRecurrencen =
      NullAwareTypeConverter.wrap($convertercustomRecurrence);
}

class EventTableData extends DataClass implements Insertable<EventTableData> {
  final int id;
  final int? originalEventId;
  final String title;
  final int categoryId;
  final double amount;
  final DateTime date;
  final RepeatOption repeatOption;
  final bool isRecurring;
  final String? notes;
  final CustomRecurrence? customRecurrence;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EventTableData(
      {required this.id,
      this.originalEventId,
      required this.title,
      required this.categoryId,
      required this.amount,
      required this.date,
      required this.repeatOption,
      required this.isRecurring,
      this.notes,
      this.customRecurrence,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || originalEventId != null) {
      map['original_event_id'] = Variable<int>(originalEventId);
    }
    map['title'] = Variable<String>(title);
    map['category_id'] = Variable<int>(categoryId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    {
      map['repeat_option'] = Variable<String>(
          $EventsTable.$converterrepeatOption.toSql(repeatOption));
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || customRecurrence != null) {
      map['custom_recurrence'] = Variable<String>(
          $EventsTable.$convertercustomRecurrencen.toSql(customRecurrence));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      originalEventId: originalEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(originalEventId),
      title: Value(title),
      categoryId: Value(categoryId),
      amount: Value(amount),
      date: Value(date),
      repeatOption: Value(repeatOption),
      isRecurring: Value(isRecurring),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      customRecurrence: customRecurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(customRecurrence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EventTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTableData(
      id: serializer.fromJson<int>(json['id']),
      originalEventId: serializer.fromJson<int?>(json['originalEventId']),
      title: serializer.fromJson<String>(json['title']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      repeatOption: serializer.fromJson<RepeatOption>(json['repeatOption']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      notes: serializer.fromJson<String?>(json['notes']),
      customRecurrence:
          serializer.fromJson<CustomRecurrence?>(json['customRecurrence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'originalEventId': serializer.toJson<int?>(originalEventId),
      'title': serializer.toJson<String>(title),
      'categoryId': serializer.toJson<int>(categoryId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'repeatOption': serializer.toJson<RepeatOption>(repeatOption),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'notes': serializer.toJson<String?>(notes),
      'customRecurrence':
          serializer.toJson<CustomRecurrence?>(customRecurrence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EventTableData copyWith(
          {int? id,
          Value<int?> originalEventId = const Value.absent(),
          String? title,
          int? categoryId,
          double? amount,
          DateTime? date,
          RepeatOption? repeatOption,
          bool? isRecurring,
          Value<String?> notes = const Value.absent(),
          Value<CustomRecurrence?> customRecurrence = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EventTableData(
        id: id ?? this.id,
        originalEventId: originalEventId.present
            ? originalEventId.value
            : this.originalEventId,
        title: title ?? this.title,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        repeatOption: repeatOption ?? this.repeatOption,
        isRecurring: isRecurring ?? this.isRecurring,
        notes: notes.present ? notes.value : this.notes,
        customRecurrence: customRecurrence.present
            ? customRecurrence.value
            : this.customRecurrence,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  EventTableData copyWithCompanion(EventsCompanion data) {
    return EventTableData(
      id: data.id.present ? data.id.value : this.id,
      originalEventId: data.originalEventId.present
          ? data.originalEventId.value
          : this.originalEventId,
      title: data.title.present ? data.title.value : this.title,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      repeatOption: data.repeatOption.present
          ? data.repeatOption.value
          : this.repeatOption,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      notes: data.notes.present ? data.notes.value : this.notes,
      customRecurrence: data.customRecurrence.present
          ? data.customRecurrence.value
          : this.customRecurrence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTableData(')
          ..write('id: $id, ')
          ..write('originalEventId: $originalEventId, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('repeatOption: $repeatOption, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes, ')
          ..write('customRecurrence: $customRecurrence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      originalEventId,
      title,
      categoryId,
      amount,
      date,
      repeatOption,
      isRecurring,
      notes,
      customRecurrence,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTableData &&
          other.id == this.id &&
          other.originalEventId == this.originalEventId &&
          other.title == this.title &&
          other.categoryId == this.categoryId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.repeatOption == this.repeatOption &&
          other.isRecurring == this.isRecurring &&
          other.notes == this.notes &&
          other.customRecurrence == this.customRecurrence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EventsCompanion extends UpdateCompanion<EventTableData> {
  final Value<int> id;
  final Value<int?> originalEventId;
  final Value<String> title;
  final Value<int> categoryId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<RepeatOption> repeatOption;
  final Value<bool> isRecurring;
  final Value<String?> notes;
  final Value<CustomRecurrence?> customRecurrence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.originalEventId = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.repeatOption = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.customRecurrence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EventsCompanion.insert({
    this.id = const Value.absent(),
    this.originalEventId = const Value.absent(),
    required String title,
    required int categoryId,
    required double amount,
    required DateTime date,
    required RepeatOption repeatOption,
    this.isRecurring = const Value.absent(),
    this.notes = const Value.absent(),
    this.customRecurrence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        categoryId = Value(categoryId),
        amount = Value(amount),
        date = Value(date),
        repeatOption = Value(repeatOption);
  static Insertable<EventTableData> custom({
    Expression<int>? id,
    Expression<int>? originalEventId,
    Expression<String>? title,
    Expression<int>? categoryId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? repeatOption,
    Expression<bool>? isRecurring,
    Expression<String>? notes,
    Expression<String>? customRecurrence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (originalEventId != null) 'original_event_id': originalEventId,
      if (title != null) 'title': title,
      if (categoryId != null) 'category_id': categoryId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (repeatOption != null) 'repeat_option': repeatOption,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (notes != null) 'notes': notes,
      if (customRecurrence != null) 'custom_recurrence': customRecurrence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EventsCompanion copyWith(
      {Value<int>? id,
      Value<int?>? originalEventId,
      Value<String>? title,
      Value<int>? categoryId,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<RepeatOption>? repeatOption,
      Value<bool>? isRecurring,
      Value<String?>? notes,
      Value<CustomRecurrence?>? customRecurrence,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return EventsCompanion(
      id: id ?? this.id,
      originalEventId: originalEventId ?? this.originalEventId,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      repeatOption: repeatOption ?? this.repeatOption,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
      customRecurrence: customRecurrence ?? this.customRecurrence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (originalEventId.present) {
      map['original_event_id'] = Variable<int>(originalEventId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (repeatOption.present) {
      map['repeat_option'] = Variable<String>(
          $EventsTable.$converterrepeatOption.toSql(repeatOption.value));
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (customRecurrence.present) {
      map['custom_recurrence'] = Variable<String>($EventsTable
          .$convertercustomRecurrencen
          .toSql(customRecurrence.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('originalEventId: $originalEventId, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('repeatOption: $repeatOption, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('notes: $notes, ')
          ..write('customRecurrence: $customRecurrence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SavingGoalsTableTable extends SavingGoalsTable
    with TableInfo<$SavingGoalsTableTable, SavingGoalTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _goalTypeMeta =
      const VerificationMeta('goalType');
  @override
  late final GeneratedColumnWithTypeConverter<GoalType, String> goalType =
      GeneratedColumn<String>('goal_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<GoalType>($SavingGoalsTableTable.$convertergoalType);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deadlineDateMeta =
      const VerificationMeta('deadlineDate');
  @override
  late final GeneratedColumn<DateTime> deadlineDate = GeneratedColumn<DateTime>(
      'deadline_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _recurringPeriodMeta =
      const VerificationMeta('recurringPeriod');
  @override
  late final GeneratedColumnWithTypeConverter<RecurringPeriod?, String>
      recurringPeriod = GeneratedColumn<String>(
              'recurring_period', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<RecurringPeriod?>(
              $SavingGoalsTableTable.$converterrecurringPeriodn);
  static const VerificationMeta _recurringTargetAmountMeta =
      const VerificationMeta('recurringTargetAmount');
  @override
  late final GeneratedColumn<double> recurringTargetAmount =
      GeneratedColumn<double>('recurring_target_amount', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _checkpointsMeta =
      const VerificationMeta('checkpoints');
  @override
  late final GeneratedColumn<String> checkpoints = GeneratedColumn<String>(
      'checkpoints', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        targetAmount,
        currentAmount,
        goalType,
        isCompleted,
        createdAt,
        updatedAt,
        deadlineDate,
        recurringPeriod,
        recurringTargetAmount,
        checkpoints
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_goals_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<SavingGoalTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    context.handle(_goalTypeMeta, const VerificationResult.success());
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deadline_date')) {
      context.handle(
          _deadlineDateMeta,
          deadlineDate.isAcceptableOrUnknown(
              data['deadline_date']!, _deadlineDateMeta));
    }
    context.handle(_recurringPeriodMeta, const VerificationResult.success());
    if (data.containsKey('recurring_target_amount')) {
      context.handle(
          _recurringTargetAmountMeta,
          recurringTargetAmount.isAcceptableOrUnknown(
              data['recurring_target_amount']!, _recurringTargetAmountMeta));
    }
    if (data.containsKey('checkpoints')) {
      context.handle(
          _checkpointsMeta,
          checkpoints.isAcceptableOrUnknown(
              data['checkpoints']!, _checkpointsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingGoalTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingGoalTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      goalType: $SavingGoalsTableTable.$convertergoalType.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}goal_type'])!),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deadlineDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline_date']),
      recurringPeriod: $SavingGoalsTableTable.$converterrecurringPeriodn
          .fromSql(attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}recurring_period'])),
      recurringTargetAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}recurring_target_amount']),
      checkpoints: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checkpoints']),
    );
  }

  @override
  $SavingGoalsTableTable createAlias(String alias) {
    return $SavingGoalsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<GoalType, String> $convertergoalType =
      const GoalTypeConverter();
  static TypeConverter<RecurringPeriod, String> $converterrecurringPeriod =
      const RecurringPeriodConverter();
  static TypeConverter<RecurringPeriod?, String?> $converterrecurringPeriodn =
      NullAwareTypeConverter.wrap($converterrecurringPeriod);
}

class SavingGoalTableData extends DataClass
    implements Insertable<SavingGoalTableData> {
  final int id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final GoalType goalType;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deadlineDate;
  final RecurringPeriod? recurringPeriod;
  final double? recurringTargetAmount;
  final String? checkpoints;
  const SavingGoalTableData(
      {required this.id,
      required this.title,
      required this.description,
      required this.targetAmount,
      required this.currentAmount,
      required this.goalType,
      required this.isCompleted,
      required this.createdAt,
      required this.updatedAt,
      this.deadlineDate,
      this.recurringPeriod,
      this.recurringTargetAmount,
      this.checkpoints});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target_amount'] = Variable<double>(targetAmount);
    map['current_amount'] = Variable<double>(currentAmount);
    {
      map['goal_type'] = Variable<String>(
          $SavingGoalsTableTable.$convertergoalType.toSql(goalType));
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deadlineDate != null) {
      map['deadline_date'] = Variable<DateTime>(deadlineDate);
    }
    if (!nullToAbsent || recurringPeriod != null) {
      map['recurring_period'] = Variable<String>($SavingGoalsTableTable
          .$converterrecurringPeriodn
          .toSql(recurringPeriod));
    }
    if (!nullToAbsent || recurringTargetAmount != null) {
      map['recurring_target_amount'] = Variable<double>(recurringTargetAmount);
    }
    if (!nullToAbsent || checkpoints != null) {
      map['checkpoints'] = Variable<String>(checkpoints);
    }
    return map;
  }

  SavingGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return SavingGoalsTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      goalType: Value(goalType),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deadlineDate: deadlineDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineDate),
      recurringPeriod: recurringPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringPeriod),
      recurringTargetAmount: recurringTargetAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringTargetAmount),
      checkpoints: checkpoints == null && nullToAbsent
          ? const Value.absent()
          : Value(checkpoints),
    );
  }

  factory SavingGoalTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingGoalTableData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      goalType: serializer.fromJson<GoalType>(json['goalType']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deadlineDate: serializer.fromJson<DateTime?>(json['deadlineDate']),
      recurringPeriod:
          serializer.fromJson<RecurringPeriod?>(json['recurringPeriod']),
      recurringTargetAmount:
          serializer.fromJson<double?>(json['recurringTargetAmount']),
      checkpoints: serializer.fromJson<String?>(json['checkpoints']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'goalType': serializer.toJson<GoalType>(goalType),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deadlineDate': serializer.toJson<DateTime?>(deadlineDate),
      'recurringPeriod': serializer.toJson<RecurringPeriod?>(recurringPeriod),
      'recurringTargetAmount':
          serializer.toJson<double?>(recurringTargetAmount),
      'checkpoints': serializer.toJson<String?>(checkpoints),
    };
  }

  SavingGoalTableData copyWith(
          {int? id,
          String? title,
          String? description,
          double? targetAmount,
          double? currentAmount,
          GoalType? goalType,
          bool? isCompleted,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deadlineDate = const Value.absent(),
          Value<RecurringPeriod?> recurringPeriod = const Value.absent(),
          Value<double?> recurringTargetAmount = const Value.absent(),
          Value<String?> checkpoints = const Value.absent()}) =>
      SavingGoalTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        goalType: goalType ?? this.goalType,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deadlineDate:
            deadlineDate.present ? deadlineDate.value : this.deadlineDate,
        recurringPeriod: recurringPeriod.present
            ? recurringPeriod.value
            : this.recurringPeriod,
        recurringTargetAmount: recurringTargetAmount.present
            ? recurringTargetAmount.value
            : this.recurringTargetAmount,
        checkpoints: checkpoints.present ? checkpoints.value : this.checkpoints,
      );
  SavingGoalTableData copyWithCompanion(SavingGoalsTableCompanion data) {
    return SavingGoalTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deadlineDate: data.deadlineDate.present
          ? data.deadlineDate.value
          : this.deadlineDate,
      recurringPeriod: data.recurringPeriod.present
          ? data.recurringPeriod.value
          : this.recurringPeriod,
      recurringTargetAmount: data.recurringTargetAmount.present
          ? data.recurringTargetAmount.value
          : this.recurringTargetAmount,
      checkpoints:
          data.checkpoints.present ? data.checkpoints.value : this.checkpoints,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('goalType: $goalType, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('recurringPeriod: $recurringPeriod, ')
          ..write('recurringTargetAmount: $recurringTargetAmount, ')
          ..write('checkpoints: $checkpoints')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      targetAmount,
      currentAmount,
      goalType,
      isCompleted,
      createdAt,
      updatedAt,
      deadlineDate,
      recurringPeriod,
      recurringTargetAmount,
      checkpoints);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingGoalTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.goalType == this.goalType &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deadlineDate == this.deadlineDate &&
          other.recurringPeriod == this.recurringPeriod &&
          other.recurringTargetAmount == this.recurringTargetAmount &&
          other.checkpoints == this.checkpoints);
}

class SavingGoalsTableCompanion extends UpdateCompanion<SavingGoalTableData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<double> targetAmount;
  final Value<double> currentAmount;
  final Value<GoalType> goalType;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deadlineDate;
  final Value<RecurringPeriod?> recurringPeriod;
  final Value<double?> recurringTargetAmount;
  final Value<String?> checkpoints;
  const SavingGoalsTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.goalType = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deadlineDate = const Value.absent(),
    this.recurringPeriod = const Value.absent(),
    this.recurringTargetAmount = const Value.absent(),
    this.checkpoints = const Value.absent(),
  });
  SavingGoalsTableCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String description,
    required double targetAmount,
    this.currentAmount = const Value.absent(),
    required GoalType goalType,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deadlineDate = const Value.absent(),
    this.recurringPeriod = const Value.absent(),
    this.recurringTargetAmount = const Value.absent(),
    this.checkpoints = const Value.absent(),
  })  : title = Value(title),
        description = Value(description),
        targetAmount = Value(targetAmount),
        goalType = Value(goalType);
  static Insertable<SavingGoalTableData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? targetAmount,
    Expression<double>? currentAmount,
    Expression<String>? goalType,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deadlineDate,
    Expression<String>? recurringPeriod,
    Expression<double>? recurringTargetAmount,
    Expression<String>? checkpoints,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (goalType != null) 'goal_type': goalType,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deadlineDate != null) 'deadline_date': deadlineDate,
      if (recurringPeriod != null) 'recurring_period': recurringPeriod,
      if (recurringTargetAmount != null)
        'recurring_target_amount': recurringTargetAmount,
      if (checkpoints != null) 'checkpoints': checkpoints,
    });
  }

  SavingGoalsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? description,
      Value<double>? targetAmount,
      Value<double>? currentAmount,
      Value<GoalType>? goalType,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deadlineDate,
      Value<RecurringPeriod?>? recurringPeriod,
      Value<double?>? recurringTargetAmount,
      Value<String?>? checkpoints}) {
    return SavingGoalsTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      goalType: goalType ?? this.goalType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      recurringPeriod: recurringPeriod ?? this.recurringPeriod,
      recurringTargetAmount:
          recurringTargetAmount ?? this.recurringTargetAmount,
      checkpoints: checkpoints ?? this.checkpoints,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(
          $SavingGoalsTableTable.$convertergoalType.toSql(goalType.value));
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deadlineDate.present) {
      map['deadline_date'] = Variable<DateTime>(deadlineDate.value);
    }
    if (recurringPeriod.present) {
      map['recurring_period'] = Variable<String>($SavingGoalsTableTable
          .$converterrecurringPeriodn
          .toSql(recurringPeriod.value));
    }
    if (recurringTargetAmount.present) {
      map['recurring_target_amount'] =
          Variable<double>(recurringTargetAmount.value);
    }
    if (checkpoints.present) {
      map['checkpoints'] = Variable<String>(checkpoints.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('goalType: $goalType, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deadlineDate: $deadlineDate, ')
          ..write('recurringPeriod: $recurringPeriod, ')
          ..write('recurringTargetAmount: $recurringTargetAmount, ')
          ..write('checkpoints: $checkpoints')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumnWithTypeConverter<AchievementType, String> type =
      GeneratedColumn<String>('type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AchievementType>($AchievementsTable.$convertertype);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isUnlockedMeta =
      const VerificationMeta('isUnlocked');
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
      'is_unlocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_unlocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        type,
        targetAmount,
        isUnlocked,
        progress,
        unlockedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
      Insertable<AchievementTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    context.handle(_typeMeta, const VerificationResult.success());
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
          _isUnlockedMeta,
          isUnlocked.isAcceptableOrUnknown(
              data['is_unlocked']!, _isUnlockedMeta));
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AchievementTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      type: $AchievementsTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!),
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      isUnlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_unlocked'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }

  static TypeConverter<AchievementType, String> $convertertype =
      const AchievementTypeConverter();
}

class AchievementTableData extends DataClass
    implements Insertable<AchievementTableData> {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final double targetAmount;
  final bool isUnlocked;
  final double progress;
  final DateTime? unlockedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AchievementTableData(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      required this.targetAmount,
      required this.isUnlocked,
      required this.progress,
      this.unlockedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    {
      map['type'] =
          Variable<String>($AchievementsTable.$convertertype.toSql(type));
    }
    map['target_amount'] = Variable<double>(targetAmount);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      type: Value(type),
      targetAmount: Value(targetAmount),
      isUnlocked: Value(isUnlocked),
      progress: Value(progress),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AchievementTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      type: serializer.fromJson<AchievementType>(json['type']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      progress: serializer.fromJson<double>(json['progress']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'type': serializer.toJson<AchievementType>(type),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'progress': serializer.toJson<double>(progress),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AchievementTableData copyWith(
          {String? id,
          String? title,
          String? description,
          AchievementType? type,
          double? targetAmount,
          bool? isUnlocked,
          double? progress,
          Value<DateTime?> unlockedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AchievementTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        targetAmount: targetAmount ?? this.targetAmount,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        progress: progress ?? this.progress,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AchievementTableData copyWithCompanion(AchievementsCompanion data) {
    return AchievementTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      isUnlocked:
          data.isUnlocked.present ? data.isUnlocked.value : this.isUnlocked,
      progress: data.progress.present ? data.progress.value : this.progress,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('progress: $progress, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, type, targetAmount,
      isUnlocked, progress, unlockedAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.type == this.type &&
          other.targetAmount == this.targetAmount &&
          other.isUnlocked == this.isUnlocked &&
          other.progress == this.progress &&
          other.unlockedAt == this.unlockedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AchievementsCompanion extends UpdateCompanion<AchievementTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<AchievementType> type;
  final Value<double> targetAmount;
  final Value<bool> isUnlocked;
  final Value<double> progress;
  final Value<DateTime?> unlockedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.progress = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required AchievementType type,
    required double targetAmount,
    this.isUnlocked = const Value.absent(),
    this.progress = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        type = Value(type),
        targetAmount = Value(targetAmount);
  static Insertable<AchievementTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? type,
    Expression<double>? targetAmount,
    Expression<bool>? isUnlocked,
    Expression<double>? progress,
    Expression<DateTime>? unlockedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (progress != null) 'progress': progress,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<AchievementType>? type,
      Value<double>? targetAmount,
      Value<bool>? isUnlocked,
      Value<double>? progress,
      Value<DateTime?>? unlockedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] =
          Variable<String>($AchievementsTable.$convertertype.toSql(type.value));
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('progress: $progress, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalAllocationsTable extends GoalAllocations
    with TableInfo<$GoalAllocationsTable, GoalAllocationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<int> eventId = GeneratedColumn<int>(
      'event_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES events (id) ON DELETE CASCADE'));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES saving_goals_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _allocationAmountMeta =
      const VerificationMeta('allocationAmount');
  @override
  late final GeneratedColumn<double> allocationAmount = GeneratedColumn<double>(
      'allocation_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _allocationTypeMeta =
      const VerificationMeta('allocationType');
  @override
  late final GeneratedColumnWithTypeConverter<AllocationType, String>
      allocationType = GeneratedColumn<String>(
              'allocation_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AllocationType>(
              $GoalAllocationsTable.$converterallocationType);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        goalId,
        allocationAmount,
        allocationType,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_allocations';
  @override
  VerificationContext validateIntegrity(
      Insertable<GoalAllocationTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('allocation_amount')) {
      context.handle(
          _allocationAmountMeta,
          allocationAmount.isAcceptableOrUnknown(
              data['allocation_amount']!, _allocationAmountMeta));
    } else if (isInserting) {
      context.missing(_allocationAmountMeta);
    }
    context.handle(_allocationTypeMeta, const VerificationResult.success());
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalAllocationTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalAllocationTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}event_id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
      allocationAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocation_amount'])!,
      allocationType: $GoalAllocationsTable.$converterallocationType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}allocation_type'])!),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $GoalAllocationsTable createAlias(String alias) {
    return $GoalAllocationsTable(attachedDatabase, alias);
  }

  static TypeConverter<AllocationType, String> $converterallocationType =
      const AllocationTypeConverter();
}

class GoalAllocationTableData extends DataClass
    implements Insertable<GoalAllocationTableData> {
  final int id;
  final int eventId;
  final int goalId;
  final double allocationAmount;
  final AllocationType allocationType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const GoalAllocationTableData(
      {required this.id,
      required this.eventId,
      required this.goalId,
      required this.allocationAmount,
      required this.allocationType,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<int>(eventId);
    map['goal_id'] = Variable<int>(goalId);
    map['allocation_amount'] = Variable<double>(allocationAmount);
    {
      map['allocation_type'] = Variable<String>(
          $GoalAllocationsTable.$converterallocationType.toSql(allocationType));
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GoalAllocationsCompanion toCompanion(bool nullToAbsent) {
    return GoalAllocationsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      goalId: Value(goalId),
      allocationAmount: Value(allocationAmount),
      allocationType: Value(allocationType),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory GoalAllocationTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalAllocationTableData(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<int>(json['eventId']),
      goalId: serializer.fromJson<int>(json['goalId']),
      allocationAmount: serializer.fromJson<double>(json['allocationAmount']),
      allocationType:
          serializer.fromJson<AllocationType>(json['allocationType']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<int>(eventId),
      'goalId': serializer.toJson<int>(goalId),
      'allocationAmount': serializer.toJson<double>(allocationAmount),
      'allocationType': serializer.toJson<AllocationType>(allocationType),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GoalAllocationTableData copyWith(
          {int? id,
          int? eventId,
          int? goalId,
          double? allocationAmount,
          AllocationType? allocationType,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      GoalAllocationTableData(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        goalId: goalId ?? this.goalId,
        allocationAmount: allocationAmount ?? this.allocationAmount,
        allocationType: allocationType ?? this.allocationType,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GoalAllocationTableData copyWithCompanion(GoalAllocationsCompanion data) {
    return GoalAllocationTableData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      allocationAmount: data.allocationAmount.present
          ? data.allocationAmount.value
          : this.allocationAmount,
      allocationType: data.allocationType.present
          ? data.allocationType.value
          : this.allocationType,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalAllocationTableData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('goalId: $goalId, ')
          ..write('allocationAmount: $allocationAmount, ')
          ..write('allocationType: $allocationType, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, goalId, allocationAmount,
      allocationType, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalAllocationTableData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.goalId == this.goalId &&
          other.allocationAmount == this.allocationAmount &&
          other.allocationType == this.allocationType &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GoalAllocationsCompanion
    extends UpdateCompanion<GoalAllocationTableData> {
  final Value<int> id;
  final Value<int> eventId;
  final Value<int> goalId;
  final Value<double> allocationAmount;
  final Value<AllocationType> allocationType;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const GoalAllocationsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.allocationAmount = const Value.absent(),
    this.allocationType = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  GoalAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int eventId,
    required int goalId,
    required double allocationAmount,
    required AllocationType allocationType,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : eventId = Value(eventId),
        goalId = Value(goalId),
        allocationAmount = Value(allocationAmount),
        allocationType = Value(allocationType);
  static Insertable<GoalAllocationTableData> custom({
    Expression<int>? id,
    Expression<int>? eventId,
    Expression<int>? goalId,
    Expression<double>? allocationAmount,
    Expression<String>? allocationType,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (goalId != null) 'goal_id': goalId,
      if (allocationAmount != null) 'allocation_amount': allocationAmount,
      if (allocationType != null) 'allocation_type': allocationType,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  GoalAllocationsCompanion copyWith(
      {Value<int>? id,
      Value<int>? eventId,
      Value<int>? goalId,
      Value<double>? allocationAmount,
      Value<AllocationType>? allocationType,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return GoalAllocationsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      goalId: goalId ?? this.goalId,
      allocationAmount: allocationAmount ?? this.allocationAmount,
      allocationType: allocationType ?? this.allocationType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<int>(eventId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (allocationAmount.present) {
      map['allocation_amount'] = Variable<double>(allocationAmount.value);
    }
    if (allocationType.present) {
      map['allocation_type'] = Variable<String>($GoalAllocationsTable
          .$converterallocationType
          .toSql(allocationType.value));
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('goalId: $goalId, ')
          ..write('allocationAmount: $allocationAmount, ')
          ..write('allocationType: $allocationType, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AutoAllocationRulesTable extends AutoAllocationRules
    with TableInfo<$AutoAllocationRulesTable, AutoAllocationRuleTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutoAllocationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES saving_goals_table (id) ON DELETE CASCADE'));
  static const VerificationMeta _ruleNameMeta =
      const VerificationMeta('ruleName');
  @override
  late final GeneratedColumn<String> ruleName = GeneratedColumn<String>(
      'rule_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _triggerTypeMeta =
      const VerificationMeta('triggerType');
  @override
  late final GeneratedColumnWithTypeConverter<TriggerType, String> triggerType =
      GeneratedColumn<String>('trigger_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<TriggerType>(
              $AutoAllocationRulesTable.$convertertriggerType);
  static const VerificationMeta _triggerCategoryIdMeta =
      const VerificationMeta('triggerCategoryId');
  @override
  late final GeneratedColumn<int> triggerCategoryId = GeneratedColumn<int>(
      'trigger_category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _allocationMethodMeta =
      const VerificationMeta('allocationMethod');
  @override
  late final GeneratedColumnWithTypeConverter<AllocationMethod, String>
      allocationMethod = GeneratedColumn<String>(
              'allocation_method', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<AllocationMethod>(
              $AutoAllocationRulesTable.$converterallocationMethod);
  static const VerificationMeta _allocationValueMeta =
      const VerificationMeta('allocationValue');
  @override
  late final GeneratedColumn<double> allocationValue = GeneratedColumn<double>(
      'allocation_value', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _minimumTriggerAmountMeta =
      const VerificationMeta('minimumTriggerAmount');
  @override
  late final GeneratedColumn<double> minimumTriggerAmount =
      GeneratedColumn<double>('minimum_trigger_amount', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _maximumAllocationAmountMeta =
      const VerificationMeta('maximumAllocationAmount');
  @override
  late final GeneratedColumn<double> maximumAllocationAmount =
      GeneratedColumn<double>('maximum_allocation_amount', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
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
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auto_allocation_rules';
  @override
  VerificationContext validateIntegrity(
      Insertable<AutoAllocationRuleTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('rule_name')) {
      context.handle(_ruleNameMeta,
          ruleName.isAcceptableOrUnknown(data['rule_name']!, _ruleNameMeta));
    } else if (isInserting) {
      context.missing(_ruleNameMeta);
    }
    context.handle(_triggerTypeMeta, const VerificationResult.success());
    if (data.containsKey('trigger_category_id')) {
      context.handle(
          _triggerCategoryIdMeta,
          triggerCategoryId.isAcceptableOrUnknown(
              data['trigger_category_id']!, _triggerCategoryIdMeta));
    }
    context.handle(_allocationMethodMeta, const VerificationResult.success());
    if (data.containsKey('allocation_value')) {
      context.handle(
          _allocationValueMeta,
          allocationValue.isAcceptableOrUnknown(
              data['allocation_value']!, _allocationValueMeta));
    } else if (isInserting) {
      context.missing(_allocationValueMeta);
    }
    if (data.containsKey('minimum_trigger_amount')) {
      context.handle(
          _minimumTriggerAmountMeta,
          minimumTriggerAmount.isAcceptableOrUnknown(
              data['minimum_trigger_amount']!, _minimumTriggerAmountMeta));
    }
    if (data.containsKey('maximum_allocation_amount')) {
      context.handle(
          _maximumAllocationAmountMeta,
          maximumAllocationAmount.isAcceptableOrUnknown(
              data['maximum_allocation_amount']!,
              _maximumAllocationAmountMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutoAllocationRuleTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutoAllocationRuleTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goal_id'])!,
      ruleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_name'])!,
      triggerType: $AutoAllocationRulesTable.$convertertriggerType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}trigger_type'])!),
      triggerCategoryId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}trigger_category_id']),
      allocationMethod: $AutoAllocationRulesTable.$converterallocationMethod
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}allocation_method'])!),
      allocationValue: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocation_value'])!,
      minimumTriggerAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}minimum_trigger_amount']),
      maximumAllocationAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}maximum_allocation_amount']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AutoAllocationRulesTable createAlias(String alias) {
    return $AutoAllocationRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<TriggerType, String> $convertertriggerType =
      const TriggerTypeConverter();
  static TypeConverter<AllocationMethod, String> $converterallocationMethod =
      const AllocationMethodConverter();
}

class AutoAllocationRuleTableData extends DataClass
    implements Insertable<AutoAllocationRuleTableData> {
  final int id;
  final int goalId;
  final String ruleName;
  final TriggerType triggerType;
  final int? triggerCategoryId;
  final AllocationMethod allocationMethod;
  final double allocationValue;
  final double? minimumTriggerAmount;
  final double? maximumAllocationAmount;
  final bool isActive;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AutoAllocationRuleTableData(
      {required this.id,
      required this.goalId,
      required this.ruleName,
      required this.triggerType,
      this.triggerCategoryId,
      required this.allocationMethod,
      required this.allocationValue,
      this.minimumTriggerAmount,
      this.maximumAllocationAmount,
      required this.isActive,
      this.description,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['goal_id'] = Variable<int>(goalId);
    map['rule_name'] = Variable<String>(ruleName);
    {
      map['trigger_type'] = Variable<String>(
          $AutoAllocationRulesTable.$convertertriggerType.toSql(triggerType));
    }
    if (!nullToAbsent || triggerCategoryId != null) {
      map['trigger_category_id'] = Variable<int>(triggerCategoryId);
    }
    {
      map['allocation_method'] = Variable<String>($AutoAllocationRulesTable
          .$converterallocationMethod
          .toSql(allocationMethod));
    }
    map['allocation_value'] = Variable<double>(allocationValue);
    if (!nullToAbsent || minimumTriggerAmount != null) {
      map['minimum_trigger_amount'] = Variable<double>(minimumTriggerAmount);
    }
    if (!nullToAbsent || maximumAllocationAmount != null) {
      map['maximum_allocation_amount'] =
          Variable<double>(maximumAllocationAmount);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AutoAllocationRulesCompanion toCompanion(bool nullToAbsent) {
    return AutoAllocationRulesCompanion(
      id: Value(id),
      goalId: Value(goalId),
      ruleName: Value(ruleName),
      triggerType: Value(triggerType),
      triggerCategoryId: triggerCategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(triggerCategoryId),
      allocationMethod: Value(allocationMethod),
      allocationValue: Value(allocationValue),
      minimumTriggerAmount: minimumTriggerAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumTriggerAmount),
      maximumAllocationAmount: maximumAllocationAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumAllocationAmount),
      isActive: Value(isActive),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AutoAllocationRuleTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutoAllocationRuleTableData(
      id: serializer.fromJson<int>(json['id']),
      goalId: serializer.fromJson<int>(json['goalId']),
      ruleName: serializer.fromJson<String>(json['ruleName']),
      triggerType: serializer.fromJson<TriggerType>(json['triggerType']),
      triggerCategoryId: serializer.fromJson<int?>(json['triggerCategoryId']),
      allocationMethod:
          serializer.fromJson<AllocationMethod>(json['allocationMethod']),
      allocationValue: serializer.fromJson<double>(json['allocationValue']),
      minimumTriggerAmount:
          serializer.fromJson<double?>(json['minimumTriggerAmount']),
      maximumAllocationAmount:
          serializer.fromJson<double?>(json['maximumAllocationAmount']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'goalId': serializer.toJson<int>(goalId),
      'ruleName': serializer.toJson<String>(ruleName),
      'triggerType': serializer.toJson<TriggerType>(triggerType),
      'triggerCategoryId': serializer.toJson<int?>(triggerCategoryId),
      'allocationMethod': serializer.toJson<AllocationMethod>(allocationMethod),
      'allocationValue': serializer.toJson<double>(allocationValue),
      'minimumTriggerAmount': serializer.toJson<double?>(minimumTriggerAmount),
      'maximumAllocationAmount':
          serializer.toJson<double?>(maximumAllocationAmount),
      'isActive': serializer.toJson<bool>(isActive),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AutoAllocationRuleTableData copyWith(
          {int? id,
          int? goalId,
          String? ruleName,
          TriggerType? triggerType,
          Value<int?> triggerCategoryId = const Value.absent(),
          AllocationMethod? allocationMethod,
          double? allocationValue,
          Value<double?> minimumTriggerAmount = const Value.absent(),
          Value<double?> maximumAllocationAmount = const Value.absent(),
          bool? isActive,
          Value<String?> description = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      AutoAllocationRuleTableData(
        id: id ?? this.id,
        goalId: goalId ?? this.goalId,
        ruleName: ruleName ?? this.ruleName,
        triggerType: triggerType ?? this.triggerType,
        triggerCategoryId: triggerCategoryId.present
            ? triggerCategoryId.value
            : this.triggerCategoryId,
        allocationMethod: allocationMethod ?? this.allocationMethod,
        allocationValue: allocationValue ?? this.allocationValue,
        minimumTriggerAmount: minimumTriggerAmount.present
            ? minimumTriggerAmount.value
            : this.minimumTriggerAmount,
        maximumAllocationAmount: maximumAllocationAmount.present
            ? maximumAllocationAmount.value
            : this.maximumAllocationAmount,
        isActive: isActive ?? this.isActive,
        description: description.present ? description.value : this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AutoAllocationRuleTableData copyWithCompanion(
      AutoAllocationRulesCompanion data) {
    return AutoAllocationRuleTableData(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      ruleName: data.ruleName.present ? data.ruleName.value : this.ruleName,
      triggerType:
          data.triggerType.present ? data.triggerType.value : this.triggerType,
      triggerCategoryId: data.triggerCategoryId.present
          ? data.triggerCategoryId.value
          : this.triggerCategoryId,
      allocationMethod: data.allocationMethod.present
          ? data.allocationMethod.value
          : this.allocationMethod,
      allocationValue: data.allocationValue.present
          ? data.allocationValue.value
          : this.allocationValue,
      minimumTriggerAmount: data.minimumTriggerAmount.present
          ? data.minimumTriggerAmount.value
          : this.minimumTriggerAmount,
      maximumAllocationAmount: data.maximumAllocationAmount.present
          ? data.maximumAllocationAmount.value
          : this.maximumAllocationAmount,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutoAllocationRuleTableData(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('ruleName: $ruleName, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerCategoryId: $triggerCategoryId, ')
          ..write('allocationMethod: $allocationMethod, ')
          ..write('allocationValue: $allocationValue, ')
          ..write('minimumTriggerAmount: $minimumTriggerAmount, ')
          ..write('maximumAllocationAmount: $maximumAllocationAmount, ')
          ..write('isActive: $isActive, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutoAllocationRuleTableData &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.ruleName == this.ruleName &&
          other.triggerType == this.triggerType &&
          other.triggerCategoryId == this.triggerCategoryId &&
          other.allocationMethod == this.allocationMethod &&
          other.allocationValue == this.allocationValue &&
          other.minimumTriggerAmount == this.minimumTriggerAmount &&
          other.maximumAllocationAmount == this.maximumAllocationAmount &&
          other.isActive == this.isActive &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AutoAllocationRulesCompanion
    extends UpdateCompanion<AutoAllocationRuleTableData> {
  final Value<int> id;
  final Value<int> goalId;
  final Value<String> ruleName;
  final Value<TriggerType> triggerType;
  final Value<int?> triggerCategoryId;
  final Value<AllocationMethod> allocationMethod;
  final Value<double> allocationValue;
  final Value<double?> minimumTriggerAmount;
  final Value<double?> maximumAllocationAmount;
  final Value<bool> isActive;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AutoAllocationRulesCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.ruleName = const Value.absent(),
    this.triggerType = const Value.absent(),
    this.triggerCategoryId = const Value.absent(),
    this.allocationMethod = const Value.absent(),
    this.allocationValue = const Value.absent(),
    this.minimumTriggerAmount = const Value.absent(),
    this.maximumAllocationAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AutoAllocationRulesCompanion.insert({
    this.id = const Value.absent(),
    required int goalId,
    required String ruleName,
    required TriggerType triggerType,
    this.triggerCategoryId = const Value.absent(),
    required AllocationMethod allocationMethod,
    required double allocationValue,
    this.minimumTriggerAmount = const Value.absent(),
    this.maximumAllocationAmount = const Value.absent(),
    this.isActive = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : goalId = Value(goalId),
        ruleName = Value(ruleName),
        triggerType = Value(triggerType),
        allocationMethod = Value(allocationMethod),
        allocationValue = Value(allocationValue);
  static Insertable<AutoAllocationRuleTableData> custom({
    Expression<int>? id,
    Expression<int>? goalId,
    Expression<String>? ruleName,
    Expression<String>? triggerType,
    Expression<int>? triggerCategoryId,
    Expression<String>? allocationMethod,
    Expression<double>? allocationValue,
    Expression<double>? minimumTriggerAmount,
    Expression<double>? maximumAllocationAmount,
    Expression<bool>? isActive,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (ruleName != null) 'rule_name': ruleName,
      if (triggerType != null) 'trigger_type': triggerType,
      if (triggerCategoryId != null) 'trigger_category_id': triggerCategoryId,
      if (allocationMethod != null) 'allocation_method': allocationMethod,
      if (allocationValue != null) 'allocation_value': allocationValue,
      if (minimumTriggerAmount != null)
        'minimum_trigger_amount': minimumTriggerAmount,
      if (maximumAllocationAmount != null)
        'maximum_allocation_amount': maximumAllocationAmount,
      if (isActive != null) 'is_active': isActive,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AutoAllocationRulesCompanion copyWith(
      {Value<int>? id,
      Value<int>? goalId,
      Value<String>? ruleName,
      Value<TriggerType>? triggerType,
      Value<int?>? triggerCategoryId,
      Value<AllocationMethod>? allocationMethod,
      Value<double>? allocationValue,
      Value<double?>? minimumTriggerAmount,
      Value<double?>? maximumAllocationAmount,
      Value<bool>? isActive,
      Value<String?>? description,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return AutoAllocationRulesCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      ruleName: ruleName ?? this.ruleName,
      triggerType: triggerType ?? this.triggerType,
      triggerCategoryId: triggerCategoryId ?? this.triggerCategoryId,
      allocationMethod: allocationMethod ?? this.allocationMethod,
      allocationValue: allocationValue ?? this.allocationValue,
      minimumTriggerAmount: minimumTriggerAmount ?? this.minimumTriggerAmount,
      maximumAllocationAmount:
          maximumAllocationAmount ?? this.maximumAllocationAmount,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (ruleName.present) {
      map['rule_name'] = Variable<String>(ruleName.value);
    }
    if (triggerType.present) {
      map['trigger_type'] = Variable<String>($AutoAllocationRulesTable
          .$convertertriggerType
          .toSql(triggerType.value));
    }
    if (triggerCategoryId.present) {
      map['trigger_category_id'] = Variable<int>(triggerCategoryId.value);
    }
    if (allocationMethod.present) {
      map['allocation_method'] = Variable<String>($AutoAllocationRulesTable
          .$converterallocationMethod
          .toSql(allocationMethod.value));
    }
    if (allocationValue.present) {
      map['allocation_value'] = Variable<double>(allocationValue.value);
    }
    if (minimumTriggerAmount.present) {
      map['minimum_trigger_amount'] =
          Variable<double>(minimumTriggerAmount.value);
    }
    if (maximumAllocationAmount.present) {
      map['maximum_allocation_amount'] =
          Variable<double>(maximumAllocationAmount.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutoAllocationRulesCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('ruleName: $ruleName, ')
          ..write('triggerType: $triggerType, ')
          ..write('triggerCategoryId: $triggerCategoryId, ')
          ..write('allocationMethod: $allocationMethod, ')
          ..write('allocationValue: $allocationValue, ')
          ..write('minimumTriggerAmount: $minimumTriggerAmount, ')
          ..write('maximumAllocationAmount: $maximumAllocationAmount, ')
          ..write('isActive: $isActive, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets
    with TableInfo<$BudgetsTable, BudgetTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _monthlyIncomeMeta =
      const VerificationMeta('monthlyIncome');
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
      'monthly_income', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cycleStartDayMeta =
      const VerificationMeta('cycleStartDay');
  @override
  late final GeneratedColumn<int> cycleStartDay = GeneratedColumn<int>(
      'cycle_start_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _needsPercentageMeta =
      const VerificationMeta('needsPercentage');
  @override
  late final GeneratedColumn<double> needsPercentage = GeneratedColumn<double>(
      'needs_percentage', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.50));
  static const VerificationMeta _wantsPercentageMeta =
      const VerificationMeta('wantsPercentage');
  @override
  late final GeneratedColumn<double> wantsPercentage = GeneratedColumn<double>(
      'wants_percentage', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.30));
  static const VerificationMeta _savingsPercentageMeta =
      const VerificationMeta('savingsPercentage');
  @override
  late final GeneratedColumn<double> savingsPercentage =
      GeneratedColumn<double>('savings_percentage', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.20));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        monthlyIncome,
        cycleStartDay,
        needsPercentage,
        wantsPercentage,
        savingsPercentage,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
          _monthlyIncomeMeta,
          monthlyIncome.isAcceptableOrUnknown(
              data['monthly_income']!, _monthlyIncomeMeta));
    } else if (isInserting) {
      context.missing(_monthlyIncomeMeta);
    }
    if (data.containsKey('cycle_start_day')) {
      context.handle(
          _cycleStartDayMeta,
          cycleStartDay.isAcceptableOrUnknown(
              data['cycle_start_day']!, _cycleStartDayMeta));
    }
    if (data.containsKey('needs_percentage')) {
      context.handle(
          _needsPercentageMeta,
          needsPercentage.isAcceptableOrUnknown(
              data['needs_percentage']!, _needsPercentageMeta));
    }
    if (data.containsKey('wants_percentage')) {
      context.handle(
          _wantsPercentageMeta,
          wantsPercentage.isAcceptableOrUnknown(
              data['wants_percentage']!, _wantsPercentageMeta));
    }
    if (data.containsKey('savings_percentage')) {
      context.handle(
          _savingsPercentageMeta,
          savingsPercentage.isAcceptableOrUnknown(
              data['savings_percentage']!, _savingsPercentageMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      monthlyIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_income'])!,
      cycleStartDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_start_day'])!,
      needsPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}needs_percentage'])!,
      wantsPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}wants_percentage'])!,
      savingsPercentage: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}savings_percentage'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetTableData extends DataClass implements Insertable<BudgetTableData> {
  final int id;
  final double monthlyIncome;
  final int cycleStartDay;
  final double needsPercentage;
  final double wantsPercentage;
  final double savingsPercentage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BudgetTableData(
      {required this.id,
      required this.monthlyIncome,
      required this.cycleStartDay,
      required this.needsPercentage,
      required this.wantsPercentage,
      required this.savingsPercentage,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    map['cycle_start_day'] = Variable<int>(cycleStartDay);
    map['needs_percentage'] = Variable<double>(needsPercentage);
    map['wants_percentage'] = Variable<double>(wantsPercentage);
    map['savings_percentage'] = Variable<double>(savingsPercentage);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      monthlyIncome: Value(monthlyIncome),
      cycleStartDay: Value(cycleStartDay),
      needsPercentage: Value(needsPercentage),
      wantsPercentage: Value(wantsPercentage),
      savingsPercentage: Value(savingsPercentage),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BudgetTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetTableData(
      id: serializer.fromJson<int>(json['id']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
      cycleStartDay: serializer.fromJson<int>(json['cycleStartDay']),
      needsPercentage: serializer.fromJson<double>(json['needsPercentage']),
      wantsPercentage: serializer.fromJson<double>(json['wantsPercentage']),
      savingsPercentage: serializer.fromJson<double>(json['savingsPercentage']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
      'cycleStartDay': serializer.toJson<int>(cycleStartDay),
      'needsPercentage': serializer.toJson<double>(needsPercentage),
      'wantsPercentage': serializer.toJson<double>(wantsPercentage),
      'savingsPercentage': serializer.toJson<double>(savingsPercentage),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BudgetTableData copyWith(
          {int? id,
          double? monthlyIncome,
          int? cycleStartDay,
          double? needsPercentage,
          double? wantsPercentage,
          double? savingsPercentage,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      BudgetTableData(
        id: id ?? this.id,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        cycleStartDay: cycleStartDay ?? this.cycleStartDay,
        needsPercentage: needsPercentage ?? this.needsPercentage,
        wantsPercentage: wantsPercentage ?? this.wantsPercentage,
        savingsPercentage: savingsPercentage ?? this.savingsPercentage,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BudgetTableData copyWithCompanion(BudgetsCompanion data) {
    return BudgetTableData(
      id: data.id.present ? data.id.value : this.id,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
      cycleStartDay: data.cycleStartDay.present
          ? data.cycleStartDay.value
          : this.cycleStartDay,
      needsPercentage: data.needsPercentage.present
          ? data.needsPercentage.value
          : this.needsPercentage,
      wantsPercentage: data.wantsPercentage.present
          ? data.wantsPercentage.value
          : this.wantsPercentage,
      savingsPercentage: data.savingsPercentage.present
          ? data.savingsPercentage.value
          : this.savingsPercentage,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTableData(')
          ..write('id: $id, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('cycleStartDay: $cycleStartDay, ')
          ..write('needsPercentage: $needsPercentage, ')
          ..write('wantsPercentage: $wantsPercentage, ')
          ..write('savingsPercentage: $savingsPercentage, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      monthlyIncome,
      cycleStartDay,
      needsPercentage,
      wantsPercentage,
      savingsPercentage,
      isActive,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetTableData &&
          other.id == this.id &&
          other.monthlyIncome == this.monthlyIncome &&
          other.cycleStartDay == this.cycleStartDay &&
          other.needsPercentage == this.needsPercentage &&
          other.wantsPercentage == this.wantsPercentage &&
          other.savingsPercentage == this.savingsPercentage &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<BudgetTableData> {
  final Value<int> id;
  final Value<double> monthlyIncome;
  final Value<int> cycleStartDay;
  final Value<double> needsPercentage;
  final Value<double> wantsPercentage;
  final Value<double> savingsPercentage;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.cycleStartDay = const Value.absent(),
    this.needsPercentage = const Value.absent(),
    this.wantsPercentage = const Value.absent(),
    this.savingsPercentage = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BudgetsCompanion.insert({
    this.id = const Value.absent(),
    required double monthlyIncome,
    this.cycleStartDay = const Value.absent(),
    this.needsPercentage = const Value.absent(),
    this.wantsPercentage = const Value.absent(),
    this.savingsPercentage = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : monthlyIncome = Value(monthlyIncome);
  static Insertable<BudgetTableData> custom({
    Expression<int>? id,
    Expression<double>? monthlyIncome,
    Expression<int>? cycleStartDay,
    Expression<double>? needsPercentage,
    Expression<double>? wantsPercentage,
    Expression<double>? savingsPercentage,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (cycleStartDay != null) 'cycle_start_day': cycleStartDay,
      if (needsPercentage != null) 'needs_percentage': needsPercentage,
      if (wantsPercentage != null) 'wants_percentage': wantsPercentage,
      if (savingsPercentage != null) 'savings_percentage': savingsPercentage,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BudgetsCompanion copyWith(
      {Value<int>? id,
      Value<double>? monthlyIncome,
      Value<int>? cycleStartDay,
      Value<double>? needsPercentage,
      Value<double>? wantsPercentage,
      Value<double>? savingsPercentage,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      cycleStartDay: cycleStartDay ?? this.cycleStartDay,
      needsPercentage: needsPercentage ?? this.needsPercentage,
      wantsPercentage: wantsPercentage ?? this.wantsPercentage,
      savingsPercentage: savingsPercentage ?? this.savingsPercentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    if (cycleStartDay.present) {
      map['cycle_start_day'] = Variable<int>(cycleStartDay.value);
    }
    if (needsPercentage.present) {
      map['needs_percentage'] = Variable<double>(needsPercentage.value);
    }
    if (wantsPercentage.present) {
      map['wants_percentage'] = Variable<double>(wantsPercentage.value);
    }
    if (savingsPercentage.present) {
      map['savings_percentage'] = Variable<double>(savingsPercentage.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('cycleStartDay: $cycleStartDay, ')
          ..write('needsPercentage: $needsPercentage, ')
          ..write('wantsPercentage: $wantsPercentage, ')
          ..write('savingsPercentage: $savingsPercentage, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, CategoryBudgetTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _budgetIdMeta =
      const VerificationMeta('budgetId');
  @override
  late final GeneratedColumn<int> budgetId = GeneratedColumn<int>(
      'budget_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES budgets (id) ON DELETE CASCADE'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (id) ON DELETE CASCADE'));
  static const VerificationMeta _allocatedAmountMeta =
      const VerificationMeta('allocatedAmount');
  @override
  late final GeneratedColumn<double> allocatedAmount = GeneratedColumn<double>(
      'allocated_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bucketTypeMeta =
      const VerificationMeta('bucketType');
  @override
  late final GeneratedColumnWithTypeConverter<BucketType, String> bucketType =
      GeneratedColumn<String>('bucket_type', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<BucketType>(
              $CategoryBudgetsTable.$converterbucketType);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        budgetId,
        categoryId,
        allocatedAmount,
        bucketType,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(
      Insertable<CategoryBudgetTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('budget_id')) {
      context.handle(_budgetIdMeta,
          budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta));
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('allocated_amount')) {
      context.handle(
          _allocatedAmountMeta,
          allocatedAmount.isAcceptableOrUnknown(
              data['allocated_amount']!, _allocatedAmountMeta));
    } else if (isInserting) {
      context.missing(_allocatedAmountMeta);
    }
    context.handle(_bucketTypeMeta, const VerificationResult.success());
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryBudgetTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudgetTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      budgetId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}budget_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      allocatedAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_amount'])!,
      bucketType: $CategoryBudgetsTable.$converterbucketType.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}bucket_type'])!),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }

  static TypeConverter<BucketType, String> $converterbucketType =
      const BucketTypeConverter();
}

class CategoryBudgetTableData extends DataClass
    implements Insertable<CategoryBudgetTableData> {
  final int id;
  final int budgetId;
  final int categoryId;
  final double allocatedAmount;
  final BucketType bucketType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryBudgetTableData(
      {required this.id,
      required this.budgetId,
      required this.categoryId,
      required this.allocatedAmount,
      required this.bucketType,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['budget_id'] = Variable<int>(budgetId);
    map['category_id'] = Variable<int>(categoryId);
    map['allocated_amount'] = Variable<double>(allocatedAmount);
    {
      map['bucket_type'] = Variable<String>(
          $CategoryBudgetsTable.$converterbucketType.toSql(bucketType));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      id: Value(id),
      budgetId: Value(budgetId),
      categoryId: Value(categoryId),
      allocatedAmount: Value(allocatedAmount),
      bucketType: Value(bucketType),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryBudgetTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudgetTableData(
      id: serializer.fromJson<int>(json['id']),
      budgetId: serializer.fromJson<int>(json['budgetId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      allocatedAmount: serializer.fromJson<double>(json['allocatedAmount']),
      bucketType: serializer.fromJson<BucketType>(json['bucketType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'budgetId': serializer.toJson<int>(budgetId),
      'categoryId': serializer.toJson<int>(categoryId),
      'allocatedAmount': serializer.toJson<double>(allocatedAmount),
      'bucketType': serializer.toJson<BucketType>(bucketType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryBudgetTableData copyWith(
          {int? id,
          int? budgetId,
          int? categoryId,
          double? allocatedAmount,
          BucketType? bucketType,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryBudgetTableData(
        id: id ?? this.id,
        budgetId: budgetId ?? this.budgetId,
        categoryId: categoryId ?? this.categoryId,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        bucketType: bucketType ?? this.bucketType,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoryBudgetTableData copyWithCompanion(CategoryBudgetsCompanion data) {
    return CategoryBudgetTableData(
      id: data.id.present ? data.id.value : this.id,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      allocatedAmount: data.allocatedAmount.present
          ? data.allocatedAmount.value
          : this.allocatedAmount,
      bucketType:
          data.bucketType.present ? data.bucketType.value : this.bucketType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetTableData(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('bucketType: $bucketType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, budgetId, categoryId, allocatedAmount,
      bucketType, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudgetTableData &&
          other.id == this.id &&
          other.budgetId == this.budgetId &&
          other.categoryId == this.categoryId &&
          other.allocatedAmount == this.allocatedAmount &&
          other.bucketType == this.bucketType &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoryBudgetsCompanion
    extends UpdateCompanion<CategoryBudgetTableData> {
  final Value<int> id;
  final Value<int> budgetId;
  final Value<int> categoryId;
  final Value<double> allocatedAmount;
  final Value<BucketType> bucketType;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoryBudgetsCompanion({
    this.id = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.allocatedAmount = const Value.absent(),
    this.bucketType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required int budgetId,
    required int categoryId,
    required double allocatedAmount,
    required BucketType bucketType,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : budgetId = Value(budgetId),
        categoryId = Value(categoryId),
        allocatedAmount = Value(allocatedAmount),
        bucketType = Value(bucketType);
  static Insertable<CategoryBudgetTableData> custom({
    Expression<int>? id,
    Expression<int>? budgetId,
    Expression<int>? categoryId,
    Expression<double>? allocatedAmount,
    Expression<String>? bucketType,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (budgetId != null) 'budget_id': budgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (allocatedAmount != null) 'allocated_amount': allocatedAmount,
      if (bucketType != null) 'bucket_type': bucketType,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoryBudgetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? budgetId,
      Value<int>? categoryId,
      Value<double>? allocatedAmount,
      Value<BucketType>? bucketType,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CategoryBudgetsCompanion(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      bucketType: bucketType ?? this.bucketType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<int>(budgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (allocatedAmount.present) {
      map['allocated_amount'] = Variable<double>(allocatedAmount.value);
    }
    if (bucketType.present) {
      map['bucket_type'] = Variable<String>(
          $CategoryBudgetsTable.$converterbucketType.toSql(bucketType.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('allocatedAmount: $allocatedAmount, ')
          ..write('bucketType: $bucketType, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $SavingGoalsTableTable savingGoalsTable =
      $SavingGoalsTableTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $GoalAllocationsTable goalAllocations =
      $GoalAllocationsTable(this);
  late final $AutoAllocationRulesTable autoAllocationRules =
      $AutoAllocationRulesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $CategoryBudgetsTable categoryBudgets =
      $CategoryBudgetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        events,
        savingGoalsTable,
        achievements,
        goalAllocations,
        autoAllocationRules,
        budgets,
        categoryBudgets
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('events',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('goal_allocations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('saving_goals_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('goal_allocations', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('saving_goals_table',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('auto_allocation_rules', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('budgets',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('category_budgets', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('categories',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('category_budgets', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required CategoryType type,
  Value<int?> parentCategoryId,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<CategoryType> type,
  Value<int?> parentCategoryId,
  Value<String?> icon,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$Database, $CategoriesTable, CategoryTableData> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentCategoryIdTable(_$Database db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.categories.parentCategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get parentCategoryId {
    if ($_item.parentCategoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.parentCategoryId!));
    final item = $_typedResult.readTableOrNull(_parentCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EventsTable, List<EventTableData>>
      _eventsRefsTable(_$Database db) =>
          MultiTypedResultKey.fromTable(db.events,
              aliasName:
                  $_aliasNameGenerator(db.categories.id, db.events.categoryId));

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AutoAllocationRulesTable,
      List<AutoAllocationRuleTableData>> _autoAllocationRulesRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.autoAllocationRules,
          aliasName: $_aliasNameGenerator(
              db.categories.id, db.autoAllocationRules.triggerCategoryId));

  $$AutoAllocationRulesTableProcessedTableManager get autoAllocationRulesRefs {
    final manager =
        $$AutoAllocationRulesTableTableManager($_db, $_db.autoAllocationRules)
            .filter((f) => f.triggerCategoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_autoAllocationRulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CategoryBudgetsTable,
      List<CategoryBudgetTableData>> _categoryBudgetsRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.categoryBudgets,
          aliasName: $_aliasNameGenerator(
              db.categories.id, db.categoryBudgets.categoryId));

  $$CategoryBudgetsTableProcessedTableManager get categoryBudgetsRefs {
    final manager =
        $$CategoryBudgetsTableTableManager($_db, $_db.categoryBudgets)
            .filter((f) => f.categoryId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_categoryBudgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$Database, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CategoryType, CategoryType, String> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get parentCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> eventsRefs(
      Expression<bool> Function($$EventsTableFilterComposer f) f) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> autoAllocationRulesRefs(
      Expression<bool> Function($$AutoAllocationRulesTableFilterComposer f) f) {
    final $$AutoAllocationRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.autoAllocationRules,
        getReferencedColumn: (t) => t.triggerCategoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AutoAllocationRulesTableFilterComposer(
              $db: $db,
              $table: $db.autoAllocationRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> categoryBudgetsRefs(
      Expression<bool> Function($$CategoryBudgetsTableFilterComposer f) f) {
    final $$CategoryBudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryBudgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryBudgetsTableFilterComposer(
              $db: $db,
              $table: $db.categoryBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$Database, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get parentCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$Database, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> eventsRefs<T extends Object>(
      Expression<T> Function($$EventsTableAnnotationComposer a) f) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> autoAllocationRulesRefs<T extends Object>(
      Expression<T> Function($$AutoAllocationRulesTableAnnotationComposer a)
          f) {
    final $$AutoAllocationRulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.autoAllocationRules,
            getReferencedColumn: (t) => t.triggerCategoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AutoAllocationRulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.autoAllocationRules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> categoryBudgetsRefs<T extends Object>(
      Expression<T> Function($$CategoryBudgetsTableAnnotationComposer a) f) {
    final $$CategoryBudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryBudgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryBudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.categoryBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$Database,
    $CategoriesTable,
    CategoryTableData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryTableData, $$CategoriesTableReferences),
    CategoryTableData,
    PrefetchHooks Function(
        {bool parentCategoryId,
        bool eventsRefs,
        bool autoAllocationRulesRefs,
        bool categoryBudgetsRefs})> {
  $$CategoriesTableTableManager(_$Database db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<CategoryType> type = const Value.absent(),
            Value<int?> parentCategoryId = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            type: type,
            parentCategoryId: parentCategoryId,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required CategoryType type,
            Value<int?> parentCategoryId = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            parentCategoryId: parentCategoryId,
            icon: icon,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {parentCategoryId = false,
              eventsRefs = false,
              autoAllocationRulesRefs = false,
              categoryBudgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (eventsRefs) db.events,
                if (autoAllocationRulesRefs) db.autoAllocationRules,
                if (categoryBudgetsRefs) db.categoryBudgets
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (parentCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentCategoryId,
                    referencedTable:
                        $$CategoriesTableReferences._parentCategoryIdTable(db),
                    referencedColumn: $$CategoriesTableReferences
                        ._parentCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._eventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .eventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (autoAllocationRulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._autoAllocationRulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .autoAllocationRulesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.triggerCategoryId == item.id),
                        typedResults: items),
                  if (categoryBudgetsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._categoryBudgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .categoryBudgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $CategoriesTable,
    CategoryTableData,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryTableData, $$CategoriesTableReferences),
    CategoryTableData,
    PrefetchHooks Function(
        {bool parentCategoryId,
        bool eventsRefs,
        bool autoAllocationRulesRefs,
        bool categoryBudgetsRefs})>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<int?> originalEventId,
  required String title,
  required int categoryId,
  required double amount,
  required DateTime date,
  required RepeatOption repeatOption,
  Value<bool> isRecurring,
  Value<String?> notes,
  Value<CustomRecurrence?> customRecurrence,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<int> id,
  Value<int?> originalEventId,
  Value<String> title,
  Value<int> categoryId,
  Value<double> amount,
  Value<DateTime> date,
  Value<RepeatOption> repeatOption,
  Value<bool> isRecurring,
  Value<String?> notes,
  Value<CustomRecurrence?> customRecurrence,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$EventsTableReferences
    extends BaseReferences<_$Database, $EventsTable, EventTableData> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$Database db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.events.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$GoalAllocationsTable,
      List<GoalAllocationTableData>> _goalAllocationsRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.goalAllocations,
          aliasName:
              $_aliasNameGenerator(db.events.id, db.goalAllocations.eventId));

  $$GoalAllocationsTableProcessedTableManager get goalAllocationsRefs {
    final manager =
        $$GoalAllocationsTableTableManager($_db, $_db.goalAllocations)
            .filter((f) => f.eventId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_goalAllocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EventsTableFilterComposer extends Composer<_$Database, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get originalEventId => $composableBuilder(
      column: $table.originalEventId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RepeatOption, RepeatOption, String>
      get repeatOption => $composableBuilder(
          column: $table.repeatOption,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<CustomRecurrence?, CustomRecurrence, String>
      get customRecurrence => $composableBuilder(
          column: $table.customRecurrence,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> goalAllocationsRefs(
      Expression<bool> Function($$GoalAllocationsTableFilterComposer f) f) {
    final $$GoalAllocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalAllocations,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalAllocationsTableFilterComposer(
              $db: $db,
              $table: $db.goalAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableOrderingComposer extends Composer<_$Database, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get originalEventId => $composableBuilder(
      column: $table.originalEventId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeatOption => $composableBuilder(
      column: $table.repeatOption,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customRecurrence => $composableBuilder(
      column: $table.customRecurrence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$Database, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get originalEventId => $composableBuilder(
      column: $table.originalEventId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RepeatOption, String> get repeatOption =>
      $composableBuilder(
          column: $table.repeatOption, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CustomRecurrence?, String>
      get customRecurrence => $composableBuilder(
          column: $table.customRecurrence, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> goalAllocationsRefs<T extends Object>(
      Expression<T> Function($$GoalAllocationsTableAnnotationComposer a) f) {
    final $$GoalAllocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalAllocations,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalAllocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.goalAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableTableManager extends RootTableManager<
    _$Database,
    $EventsTable,
    EventTableData,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventTableData, $$EventsTableReferences),
    EventTableData,
    PrefetchHooks Function({bool categoryId, bool goalAllocationsRefs})> {
  $$EventsTableTableManager(_$Database db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> originalEventId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<RepeatOption> repeatOption = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<CustomRecurrence?> customRecurrence = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            originalEventId: originalEventId,
            title: title,
            categoryId: categoryId,
            amount: amount,
            date: date,
            repeatOption: repeatOption,
            isRecurring: isRecurring,
            notes: notes,
            customRecurrence: customRecurrence,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> originalEventId = const Value.absent(),
            required String title,
            required int categoryId,
            required double amount,
            required DateTime date,
            required RepeatOption repeatOption,
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<CustomRecurrence?> customRecurrence = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            originalEventId: originalEventId,
            title: title,
            categoryId: categoryId,
            amount: amount,
            date: date,
            repeatOption: repeatOption,
            isRecurring: isRecurring,
            notes: notes,
            customRecurrence: customRecurrence,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EventsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {categoryId = false, goalAllocationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (goalAllocationsRefs) db.goalAllocations
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$EventsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$EventsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (goalAllocationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$EventsTableReferences
                            ._goalAllocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EventsTableReferences(db, table, p0)
                                .goalAllocationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.eventId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $EventsTable,
    EventTableData,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (EventTableData, $$EventsTableReferences),
    EventTableData,
    PrefetchHooks Function({bool categoryId, bool goalAllocationsRefs})>;
typedef $$SavingGoalsTableTableCreateCompanionBuilder
    = SavingGoalsTableCompanion Function({
  Value<int> id,
  required String title,
  required String description,
  required double targetAmount,
  Value<double> currentAmount,
  required GoalType goalType,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deadlineDate,
  Value<RecurringPeriod?> recurringPeriod,
  Value<double?> recurringTargetAmount,
  Value<String?> checkpoints,
});
typedef $$SavingGoalsTableTableUpdateCompanionBuilder
    = SavingGoalsTableCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> description,
  Value<double> targetAmount,
  Value<double> currentAmount,
  Value<GoalType> goalType,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deadlineDate,
  Value<RecurringPeriod?> recurringPeriod,
  Value<double?> recurringTargetAmount,
  Value<String?> checkpoints,
});

final class $$SavingGoalsTableTableReferences extends BaseReferences<_$Database,
    $SavingGoalsTableTable, SavingGoalTableData> {
  $$SavingGoalsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GoalAllocationsTable,
      List<GoalAllocationTableData>> _goalAllocationsRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.goalAllocations,
          aliasName: $_aliasNameGenerator(
              db.savingGoalsTable.id, db.goalAllocations.goalId));

  $$GoalAllocationsTableProcessedTableManager get goalAllocationsRefs {
    final manager =
        $$GoalAllocationsTableTableManager($_db, $_db.goalAllocations)
            .filter((f) => f.goalId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_goalAllocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AutoAllocationRulesTable,
      List<AutoAllocationRuleTableData>> _autoAllocationRulesRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.autoAllocationRules,
          aliasName: $_aliasNameGenerator(
              db.savingGoalsTable.id, db.autoAllocationRules.goalId));

  $$AutoAllocationRulesTableProcessedTableManager get autoAllocationRulesRefs {
    final manager =
        $$AutoAllocationRulesTableTableManager($_db, $_db.autoAllocationRules)
            .filter((f) => f.goalId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_autoAllocationRulesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SavingGoalsTableTableFilterComposer
    extends Composer<_$Database, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<GoalType, GoalType, String> get goalType =>
      $composableBuilder(
          column: $table.goalType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadlineDate => $composableBuilder(
      column: $table.deadlineDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<RecurringPeriod?, RecurringPeriod, String>
      get recurringPeriod => $composableBuilder(
          column: $table.recurringPeriod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get recurringTargetAmount => $composableBuilder(
      column: $table.recurringTargetAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checkpoints => $composableBuilder(
      column: $table.checkpoints, builder: (column) => ColumnFilters(column));

  Expression<bool> goalAllocationsRefs(
      Expression<bool> Function($$GoalAllocationsTableFilterComposer f) f) {
    final $$GoalAllocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalAllocations,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalAllocationsTableFilterComposer(
              $db: $db,
              $table: $db.goalAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> autoAllocationRulesRefs(
      Expression<bool> Function($$AutoAllocationRulesTableFilterComposer f) f) {
    final $$AutoAllocationRulesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.autoAllocationRules,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AutoAllocationRulesTableFilterComposer(
              $db: $db,
              $table: $db.autoAllocationRules,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SavingGoalsTableTableOrderingComposer
    extends Composer<_$Database, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get goalType => $composableBuilder(
      column: $table.goalType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadlineDate => $composableBuilder(
      column: $table.deadlineDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringPeriod => $composableBuilder(
      column: $table.recurringPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get recurringTargetAmount => $composableBuilder(
      column: $table.recurringTargetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checkpoints => $composableBuilder(
      column: $table.checkpoints, builder: (column) => ColumnOrderings(column));
}

class $$SavingGoalsTableTableAnnotationComposer
    extends Composer<_$Database, $SavingGoalsTableTable> {
  $$SavingGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalType, String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineDate => $composableBuilder(
      column: $table.deadlineDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurringPeriod?, String>
      get recurringPeriod => $composableBuilder(
          column: $table.recurringPeriod, builder: (column) => column);

  GeneratedColumn<double> get recurringTargetAmount => $composableBuilder(
      column: $table.recurringTargetAmount, builder: (column) => column);

  GeneratedColumn<String> get checkpoints => $composableBuilder(
      column: $table.checkpoints, builder: (column) => column);

  Expression<T> goalAllocationsRefs<T extends Object>(
      Expression<T> Function($$GoalAllocationsTableAnnotationComposer a) f) {
    final $$GoalAllocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.goalAllocations,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GoalAllocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.goalAllocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> autoAllocationRulesRefs<T extends Object>(
      Expression<T> Function($$AutoAllocationRulesTableAnnotationComposer a)
          f) {
    final $$AutoAllocationRulesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.autoAllocationRules,
            getReferencedColumn: (t) => t.goalId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$AutoAllocationRulesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.autoAllocationRules,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SavingGoalsTableTableTableManager extends RootTableManager<
    _$Database,
    $SavingGoalsTableTable,
    SavingGoalTableData,
    $$SavingGoalsTableTableFilterComposer,
    $$SavingGoalsTableTableOrderingComposer,
    $$SavingGoalsTableTableAnnotationComposer,
    $$SavingGoalsTableTableCreateCompanionBuilder,
    $$SavingGoalsTableTableUpdateCompanionBuilder,
    (SavingGoalTableData, $$SavingGoalsTableTableReferences),
    SavingGoalTableData,
    PrefetchHooks Function(
        {bool goalAllocationsRefs, bool autoAllocationRulesRefs})> {
  $$SavingGoalsTableTableTableManager(
      _$Database db, $SavingGoalsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingGoalsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<GoalType> goalType = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deadlineDate = const Value.absent(),
            Value<RecurringPeriod?> recurringPeriod = const Value.absent(),
            Value<double?> recurringTargetAmount = const Value.absent(),
            Value<String?> checkpoints = const Value.absent(),
          }) =>
              SavingGoalsTableCompanion(
            id: id,
            title: title,
            description: description,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            goalType: goalType,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deadlineDate: deadlineDate,
            recurringPeriod: recurringPeriod,
            recurringTargetAmount: recurringTargetAmount,
            checkpoints: checkpoints,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String description,
            required double targetAmount,
            Value<double> currentAmount = const Value.absent(),
            required GoalType goalType,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deadlineDate = const Value.absent(),
            Value<RecurringPeriod?> recurringPeriod = const Value.absent(),
            Value<double?> recurringTargetAmount = const Value.absent(),
            Value<String?> checkpoints = const Value.absent(),
          }) =>
              SavingGoalsTableCompanion.insert(
            id: id,
            title: title,
            description: description,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            goalType: goalType,
            isCompleted: isCompleted,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deadlineDate: deadlineDate,
            recurringPeriod: recurringPeriod,
            recurringTargetAmount: recurringTargetAmount,
            checkpoints: checkpoints,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SavingGoalsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {goalAllocationsRefs = false, autoAllocationRulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (goalAllocationsRefs) db.goalAllocations,
                if (autoAllocationRulesRefs) db.autoAllocationRules
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (goalAllocationsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SavingGoalsTableTableReferences
                            ._goalAllocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SavingGoalsTableTableReferences(db, table, p0)
                                .goalAllocationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items),
                  if (autoAllocationRulesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SavingGoalsTableTableReferences
                            ._autoAllocationRulesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SavingGoalsTableTableReferences(db, table, p0)
                                .autoAllocationRulesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SavingGoalsTableTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $SavingGoalsTableTable,
    SavingGoalTableData,
    $$SavingGoalsTableTableFilterComposer,
    $$SavingGoalsTableTableOrderingComposer,
    $$SavingGoalsTableTableAnnotationComposer,
    $$SavingGoalsTableTableCreateCompanionBuilder,
    $$SavingGoalsTableTableUpdateCompanionBuilder,
    (SavingGoalTableData, $$SavingGoalsTableTableReferences),
    SavingGoalTableData,
    PrefetchHooks Function(
        {bool goalAllocationsRefs, bool autoAllocationRulesRefs})>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  required String title,
  required String description,
  required AchievementType type,
  required double targetAmount,
  Value<bool> isUnlocked,
  Value<double> progress,
  Value<DateTime?> unlockedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<AchievementType> type,
  Value<double> targetAmount,
  Value<bool> isUnlocked,
  Value<double> progress,
  Value<DateTime?> unlockedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$Database, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AchievementType, AchievementType, String>
      get type => $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$Database, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progress => $composableBuilder(
      column: $table.progress, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$Database, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AchievementType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$Database,
    $AchievementsTable,
    AchievementTableData,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementTableData,
      BaseReferences<_$Database, $AchievementsTable, AchievementTableData>
    ),
    AchievementTableData,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$Database db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<AchievementType> type = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<bool> isUnlocked = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            title: title,
            description: description,
            type: type,
            targetAmount: targetAmount,
            isUnlocked: isUnlocked,
            progress: progress,
            unlockedAt: unlockedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required AchievementType type,
            required double targetAmount,
            Value<bool> isUnlocked = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            title: title,
            description: description,
            type: type,
            targetAmount: targetAmount,
            isUnlocked: isUnlocked,
            progress: progress,
            unlockedAt: unlockedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $AchievementsTable,
    AchievementTableData,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      AchievementTableData,
      BaseReferences<_$Database, $AchievementsTable, AchievementTableData>
    ),
    AchievementTableData,
    PrefetchHooks Function()>;
typedef $$GoalAllocationsTableCreateCompanionBuilder = GoalAllocationsCompanion
    Function({
  Value<int> id,
  required int eventId,
  required int goalId,
  required double allocationAmount,
  required AllocationType allocationType,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$GoalAllocationsTableUpdateCompanionBuilder = GoalAllocationsCompanion
    Function({
  Value<int> id,
  Value<int> eventId,
  Value<int> goalId,
  Value<double> allocationAmount,
  Value<AllocationType> allocationType,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$GoalAllocationsTableReferences extends BaseReferences<_$Database,
    $GoalAllocationsTable, GoalAllocationTableData> {
  $$GoalAllocationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$Database db) => db.events.createAlias(
      $_aliasNameGenerator(db.goalAllocations.eventId, db.events.id));

  $$EventsTableProcessedTableManager? get eventId {
    if ($_item.eventId == null) return null;
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.id($_item.eventId!));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SavingGoalsTableTable _goalIdTable(_$Database db) =>
      db.savingGoalsTable.createAlias($_aliasNameGenerator(
          db.goalAllocations.goalId, db.savingGoalsTable.id));

  $$SavingGoalsTableTableProcessedTableManager? get goalId {
    if ($_item.goalId == null) return null;
    final manager =
        $$SavingGoalsTableTableTableManager($_db, $_db.savingGoalsTable)
            .filter((f) => f.id($_item.goalId!));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GoalAllocationsTableFilterComposer
    extends Composer<_$Database, $GoalAllocationsTable> {
  $$GoalAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get allocationAmount => $composableBuilder(
      column: $table.allocationAmount,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<AllocationType, AllocationType, String>
      get allocationType => $composableBuilder(
          column: $table.allocationType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavingGoalsTableTableFilterComposer get goalId {
    final $$SavingGoalsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableFilterComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalAllocationsTableOrderingComposer
    extends Composer<_$Database, $GoalAllocationsTable> {
  $$GoalAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocationAmount => $composableBuilder(
      column: $table.allocationAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allocationType => $composableBuilder(
      column: $table.allocationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableOrderingComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavingGoalsTableTableOrderingComposer get goalId {
    final $$SavingGoalsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableOrderingComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalAllocationsTableAnnotationComposer
    extends Composer<_$Database, $GoalAllocationsTable> {
  $$GoalAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get allocationAmount => $composableBuilder(
      column: $table.allocationAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AllocationType, String> get allocationType =>
      $composableBuilder(
          column: $table.allocationType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SavingGoalsTableTableAnnotationComposer get goalId {
    final $$SavingGoalsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GoalAllocationsTableTableManager extends RootTableManager<
    _$Database,
    $GoalAllocationsTable,
    GoalAllocationTableData,
    $$GoalAllocationsTableFilterComposer,
    $$GoalAllocationsTableOrderingComposer,
    $$GoalAllocationsTableAnnotationComposer,
    $$GoalAllocationsTableCreateCompanionBuilder,
    $$GoalAllocationsTableUpdateCompanionBuilder,
    (GoalAllocationTableData, $$GoalAllocationsTableReferences),
    GoalAllocationTableData,
    PrefetchHooks Function({bool eventId, bool goalId})> {
  $$GoalAllocationsTableTableManager(_$Database db, $GoalAllocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalAllocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> eventId = const Value.absent(),
            Value<int> goalId = const Value.absent(),
            Value<double> allocationAmount = const Value.absent(),
            Value<AllocationType> allocationType = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GoalAllocationsCompanion(
            id: id,
            eventId: eventId,
            goalId: goalId,
            allocationAmount: allocationAmount,
            allocationType: allocationType,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int eventId,
            required int goalId,
            required double allocationAmount,
            required AllocationType allocationType,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              GoalAllocationsCompanion.insert(
            id: id,
            eventId: eventId,
            goalId: goalId,
            allocationAmount: allocationAmount,
            allocationType: allocationType,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GoalAllocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({eventId = false, goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (eventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eventId,
                    referencedTable:
                        $$GoalAllocationsTableReferences._eventIdTable(db),
                    referencedColumn:
                        $$GoalAllocationsTableReferences._eventIdTable(db).id,
                  ) as T;
                }
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable:
                        $$GoalAllocationsTableReferences._goalIdTable(db),
                    referencedColumn:
                        $$GoalAllocationsTableReferences._goalIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GoalAllocationsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $GoalAllocationsTable,
    GoalAllocationTableData,
    $$GoalAllocationsTableFilterComposer,
    $$GoalAllocationsTableOrderingComposer,
    $$GoalAllocationsTableAnnotationComposer,
    $$GoalAllocationsTableCreateCompanionBuilder,
    $$GoalAllocationsTableUpdateCompanionBuilder,
    (GoalAllocationTableData, $$GoalAllocationsTableReferences),
    GoalAllocationTableData,
    PrefetchHooks Function({bool eventId, bool goalId})>;
typedef $$AutoAllocationRulesTableCreateCompanionBuilder
    = AutoAllocationRulesCompanion Function({
  Value<int> id,
  required int goalId,
  required String ruleName,
  required TriggerType triggerType,
  Value<int?> triggerCategoryId,
  required AllocationMethod allocationMethod,
  required double allocationValue,
  Value<double?> minimumTriggerAmount,
  Value<double?> maximumAllocationAmount,
  Value<bool> isActive,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$AutoAllocationRulesTableUpdateCompanionBuilder
    = AutoAllocationRulesCompanion Function({
  Value<int> id,
  Value<int> goalId,
  Value<String> ruleName,
  Value<TriggerType> triggerType,
  Value<int?> triggerCategoryId,
  Value<AllocationMethod> allocationMethod,
  Value<double> allocationValue,
  Value<double?> minimumTriggerAmount,
  Value<double?> maximumAllocationAmount,
  Value<bool> isActive,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$AutoAllocationRulesTableReferences extends BaseReferences<
    _$Database, $AutoAllocationRulesTable, AutoAllocationRuleTableData> {
  $$AutoAllocationRulesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SavingGoalsTableTable _goalIdTable(_$Database db) =>
      db.savingGoalsTable.createAlias($_aliasNameGenerator(
          db.autoAllocationRules.goalId, db.savingGoalsTable.id));

  $$SavingGoalsTableTableProcessedTableManager? get goalId {
    if ($_item.goalId == null) return null;
    final manager =
        $$SavingGoalsTableTableTableManager($_db, $_db.savingGoalsTable)
            .filter((f) => f.id($_item.goalId!));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _triggerCategoryIdTable(_$Database db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.autoAllocationRules.triggerCategoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get triggerCategoryId {
    if ($_item.triggerCategoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.triggerCategoryId!));
    final item = $_typedResult.readTableOrNull(_triggerCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AutoAllocationRulesTableFilterComposer
    extends Composer<_$Database, $AutoAllocationRulesTable> {
  $$AutoAllocationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleName => $composableBuilder(
      column: $table.ruleName, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TriggerType, TriggerType, String>
      get triggerType => $composableBuilder(
          column: $table.triggerType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<AllocationMethod, AllocationMethod, String>
      get allocationMethod => $composableBuilder(
          column: $table.allocationMethod,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get allocationValue => $composableBuilder(
      column: $table.allocationValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minimumTriggerAmount => $composableBuilder(
      column: $table.minimumTriggerAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maximumAllocationAmount => $composableBuilder(
      column: $table.maximumAllocationAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$SavingGoalsTableTableFilterComposer get goalId {
    final $$SavingGoalsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableFilterComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get triggerCategoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.triggerCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AutoAllocationRulesTableOrderingComposer
    extends Composer<_$Database, $AutoAllocationRulesTable> {
  $$AutoAllocationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleName => $composableBuilder(
      column: $table.ruleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerType => $composableBuilder(
      column: $table.triggerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allocationMethod => $composableBuilder(
      column: $table.allocationMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocationValue => $composableBuilder(
      column: $table.allocationValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minimumTriggerAmount => $composableBuilder(
      column: $table.minimumTriggerAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maximumAllocationAmount => $composableBuilder(
      column: $table.maximumAllocationAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$SavingGoalsTableTableOrderingComposer get goalId {
    final $$SavingGoalsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableOrderingComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get triggerCategoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.triggerCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AutoAllocationRulesTableAnnotationComposer
    extends Composer<_$Database, $AutoAllocationRulesTable> {
  $$AutoAllocationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleName =>
      $composableBuilder(column: $table.ruleName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TriggerType, String> get triggerType =>
      $composableBuilder(
          column: $table.triggerType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AllocationMethod, String>
      get allocationMethod => $composableBuilder(
          column: $table.allocationMethod, builder: (column) => column);

  GeneratedColumn<double> get allocationValue => $composableBuilder(
      column: $table.allocationValue, builder: (column) => column);

  GeneratedColumn<double> get minimumTriggerAmount => $composableBuilder(
      column: $table.minimumTriggerAmount, builder: (column) => column);

  GeneratedColumn<double> get maximumAllocationAmount => $composableBuilder(
      column: $table.maximumAllocationAmount, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SavingGoalsTableTableAnnotationComposer get goalId {
    final $$SavingGoalsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoalsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.savingGoalsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get triggerCategoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.triggerCategoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AutoAllocationRulesTableTableManager extends RootTableManager<
    _$Database,
    $AutoAllocationRulesTable,
    AutoAllocationRuleTableData,
    $$AutoAllocationRulesTableFilterComposer,
    $$AutoAllocationRulesTableOrderingComposer,
    $$AutoAllocationRulesTableAnnotationComposer,
    $$AutoAllocationRulesTableCreateCompanionBuilder,
    $$AutoAllocationRulesTableUpdateCompanionBuilder,
    (AutoAllocationRuleTableData, $$AutoAllocationRulesTableReferences),
    AutoAllocationRuleTableData,
    PrefetchHooks Function({bool goalId, bool triggerCategoryId})> {
  $$AutoAllocationRulesTableTableManager(
      _$Database db, $AutoAllocationRulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutoAllocationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AutoAllocationRulesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AutoAllocationRulesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> goalId = const Value.absent(),
            Value<String> ruleName = const Value.absent(),
            Value<TriggerType> triggerType = const Value.absent(),
            Value<int?> triggerCategoryId = const Value.absent(),
            Value<AllocationMethod> allocationMethod = const Value.absent(),
            Value<double> allocationValue = const Value.absent(),
            Value<double?> minimumTriggerAmount = const Value.absent(),
            Value<double?> maximumAllocationAmount = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AutoAllocationRulesCompanion(
            id: id,
            goalId: goalId,
            ruleName: ruleName,
            triggerType: triggerType,
            triggerCategoryId: triggerCategoryId,
            allocationMethod: allocationMethod,
            allocationValue: allocationValue,
            minimumTriggerAmount: minimumTriggerAmount,
            maximumAllocationAmount: maximumAllocationAmount,
            isActive: isActive,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int goalId,
            required String ruleName,
            required TriggerType triggerType,
            Value<int?> triggerCategoryId = const Value.absent(),
            required AllocationMethod allocationMethod,
            required double allocationValue,
            Value<double?> minimumTriggerAmount = const Value.absent(),
            Value<double?> maximumAllocationAmount = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              AutoAllocationRulesCompanion.insert(
            id: id,
            goalId: goalId,
            ruleName: ruleName,
            triggerType: triggerType,
            triggerCategoryId: triggerCategoryId,
            allocationMethod: allocationMethod,
            allocationValue: allocationValue,
            minimumTriggerAmount: minimumTriggerAmount,
            maximumAllocationAmount: maximumAllocationAmount,
            isActive: isActive,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AutoAllocationRulesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({goalId = false, triggerCategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable:
                        $$AutoAllocationRulesTableReferences._goalIdTable(db),
                    referencedColumn: $$AutoAllocationRulesTableReferences
                        ._goalIdTable(db)
                        .id,
                  ) as T;
                }
                if (triggerCategoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.triggerCategoryId,
                    referencedTable: $$AutoAllocationRulesTableReferences
                        ._triggerCategoryIdTable(db),
                    referencedColumn: $$AutoAllocationRulesTableReferences
                        ._triggerCategoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AutoAllocationRulesTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $AutoAllocationRulesTable,
    AutoAllocationRuleTableData,
    $$AutoAllocationRulesTableFilterComposer,
    $$AutoAllocationRulesTableOrderingComposer,
    $$AutoAllocationRulesTableAnnotationComposer,
    $$AutoAllocationRulesTableCreateCompanionBuilder,
    $$AutoAllocationRulesTableUpdateCompanionBuilder,
    (AutoAllocationRuleTableData, $$AutoAllocationRulesTableReferences),
    AutoAllocationRuleTableData,
    PrefetchHooks Function({bool goalId, bool triggerCategoryId})>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  required double monthlyIncome,
  Value<int> cycleStartDay,
  Value<double> needsPercentage,
  Value<double> wantsPercentage,
  Value<double> savingsPercentage,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<int> id,
  Value<double> monthlyIncome,
  Value<int> cycleStartDay,
  Value<double> needsPercentage,
  Value<double> wantsPercentage,
  Value<double> savingsPercentage,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$Database, $BudgetsTable, BudgetTableData> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoryBudgetsTable,
      List<CategoryBudgetTableData>> _categoryBudgetsRefsTable(
          _$Database db) =>
      MultiTypedResultKey.fromTable(db.categoryBudgets,
          aliasName:
              $_aliasNameGenerator(db.budgets.id, db.categoryBudgets.budgetId));

  $$CategoryBudgetsTableProcessedTableManager get categoryBudgetsRefs {
    final manager =
        $$CategoryBudgetsTableTableManager($_db, $_db.categoryBudgets)
            .filter((f) => f.budgetId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_categoryBudgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BudgetsTableFilterComposer extends Composer<_$Database, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get needsPercentage => $composableBuilder(
      column: $table.needsPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get wantsPercentage => $composableBuilder(
      column: $table.wantsPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get savingsPercentage => $composableBuilder(
      column: $table.savingsPercentage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> categoryBudgetsRefs(
      Expression<bool> Function($$CategoryBudgetsTableFilterComposer f) f) {
    final $$CategoryBudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryBudgets,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryBudgetsTableFilterComposer(
              $db: $db,
              $table: $db.categoryBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$Database, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get needsPercentage => $composableBuilder(
      column: $table.needsPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get wantsPercentage => $composableBuilder(
      column: $table.wantsPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get savingsPercentage => $composableBuilder(
      column: $table.savingsPercentage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$Database, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
      column: $table.monthlyIncome, builder: (column) => column);

  GeneratedColumn<int> get cycleStartDay => $composableBuilder(
      column: $table.cycleStartDay, builder: (column) => column);

  GeneratedColumn<double> get needsPercentage => $composableBuilder(
      column: $table.needsPercentage, builder: (column) => column);

  GeneratedColumn<double> get wantsPercentage => $composableBuilder(
      column: $table.wantsPercentage, builder: (column) => column);

  GeneratedColumn<double> get savingsPercentage => $composableBuilder(
      column: $table.savingsPercentage, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> categoryBudgetsRefs<T extends Object>(
      Expression<T> Function($$CategoryBudgetsTableAnnotationComposer a) f) {
    final $$CategoryBudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryBudgets,
        getReferencedColumn: (t) => t.budgetId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryBudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.categoryBudgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$Database,
    $BudgetsTable,
    BudgetTableData,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetTableData, $$BudgetsTableReferences),
    BudgetTableData,
    PrefetchHooks Function({bool categoryBudgetsRefs})> {
  $$BudgetsTableTableManager(_$Database db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> monthlyIncome = const Value.absent(),
            Value<int> cycleStartDay = const Value.absent(),
            Value<double> needsPercentage = const Value.absent(),
            Value<double> wantsPercentage = const Value.absent(),
            Value<double> savingsPercentage = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            monthlyIncome: monthlyIncome,
            cycleStartDay: cycleStartDay,
            needsPercentage: needsPercentage,
            wantsPercentage: wantsPercentage,
            savingsPercentage: savingsPercentage,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double monthlyIncome,
            Value<int> cycleStartDay = const Value.absent(),
            Value<double> needsPercentage = const Value.absent(),
            Value<double> wantsPercentage = const Value.absent(),
            Value<double> savingsPercentage = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            monthlyIncome: monthlyIncome,
            cycleStartDay: cycleStartDay,
            needsPercentage: needsPercentage,
            wantsPercentage: wantsPercentage,
            savingsPercentage: savingsPercentage,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BudgetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryBudgetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (categoryBudgetsRefs) db.categoryBudgets
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoryBudgetsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$BudgetsTableReferences
                            ._categoryBudgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BudgetsTableReferences(db, table, p0)
                                .categoryBudgetsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.budgetId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $BudgetsTable,
    BudgetTableData,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetTableData, $$BudgetsTableReferences),
    BudgetTableData,
    PrefetchHooks Function({bool categoryBudgetsRefs})>;
typedef $$CategoryBudgetsTableCreateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  Value<int> id,
  required int budgetId,
  required int categoryId,
  required double allocatedAmount,
  required BucketType bucketType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CategoryBudgetsTableUpdateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  Value<int> id,
  Value<int> budgetId,
  Value<int> categoryId,
  Value<double> allocatedAmount,
  Value<BucketType> bucketType,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$CategoryBudgetsTableReferences extends BaseReferences<_$Database,
    $CategoryBudgetsTable, CategoryBudgetTableData> {
  $$CategoryBudgetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BudgetsTable _budgetIdTable(_$Database db) => db.budgets.createAlias(
      $_aliasNameGenerator(db.categoryBudgets.budgetId, db.budgets.id));

  $$BudgetsTableProcessedTableManager? get budgetId {
    if ($_item.budgetId == null) return null;
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.id($_item.budgetId!));
    final item = $_typedResult.readTableOrNull(_budgetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$Database db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.categoryBudgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$Database, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BucketType, BucketType, String>
      get bucketType => $composableBuilder(
          column: $table.bucketType,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$BudgetsTableFilterComposer get budgetId {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$Database, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucketType => $composableBuilder(
      column: $table.bucketType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$BudgetsTableOrderingComposer get budgetId {
    final $$BudgetsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableOrderingComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$Database, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get allocatedAmount => $composableBuilder(
      column: $table.allocatedAmount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BucketType, String> get bucketType =>
      $composableBuilder(
          column: $table.bucketType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BudgetsTableAnnotationComposer get budgetId {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.budgetId,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryBudgetsTableTableManager extends RootTableManager<
    _$Database,
    $CategoryBudgetsTable,
    CategoryBudgetTableData,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (CategoryBudgetTableData, $$CategoryBudgetsTableReferences),
    CategoryBudgetTableData,
    PrefetchHooks Function({bool budgetId, bool categoryId})> {
  $$CategoryBudgetsTableTableManager(_$Database db, $CategoryBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> budgetId = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<double> allocatedAmount = const Value.absent(),
            Value<BucketType> bucketType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion(
            id: id,
            budgetId: budgetId,
            categoryId: categoryId,
            allocatedAmount: allocatedAmount,
            bucketType: bucketType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int budgetId,
            required int categoryId,
            required double allocatedAmount,
            required BucketType bucketType,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion.insert(
            id: id,
            budgetId: budgetId,
            categoryId: categoryId,
            allocatedAmount: allocatedAmount,
            bucketType: bucketType,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryBudgetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({budgetId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (budgetId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.budgetId,
                    referencedTable:
                        $$CategoryBudgetsTableReferences._budgetIdTable(db),
                    referencedColumn:
                        $$CategoryBudgetsTableReferences._budgetIdTable(db).id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$CategoryBudgetsTableReferences._categoryIdTable(db),
                    referencedColumn: $$CategoryBudgetsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CategoryBudgetsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $CategoryBudgetsTable,
    CategoryBudgetTableData,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (CategoryBudgetTableData, $$CategoryBudgetsTableReferences),
    CategoryBudgetTableData,
    PrefetchHooks Function({bool budgetId, bool categoryId})>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$SavingGoalsTableTableTableManager get savingGoalsTable =>
      $$SavingGoalsTableTableTableManager(_db, _db.savingGoalsTable);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$GoalAllocationsTableTableManager get goalAllocations =>
      $$GoalAllocationsTableTableManager(_db, _db.goalAllocations);
  $$AutoAllocationRulesTableTableManager get autoAllocationRules =>
      $$AutoAllocationRulesTableTableManager(_db, _db.autoAllocationRules);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
}
