// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formalityMeta = const VerificationMeta(
    'formality',
  );
  @override
  late final GeneratedColumn<int> formality = GeneratedColumn<int>(
    'formality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _warmthMeta = const VerificationMeta('warmth');
  @override
  late final GeneratedColumn<int> warmth = GeneratedColumn<int>(
    'warmth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    slot,
    formality,
    warmth,
    isBuiltIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('formality')) {
      context.handle(
        _formalityMeta,
        formality.isAcceptableOrUnknown(data['formality']!, _formalityMeta),
      );
    }
    if (data.containsKey('warmth')) {
      context.handle(
        _warmthMeta,
        warmth.isAcceptableOrUnknown(data['warmth']!, _warmthMeta),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      formality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}formality'],
      )!,
      warmth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warmth'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;

  /// Nombre del valor de `Slot`. Obligatorio.
  final String slot;
  final int formality;
  final int warmth;
  final bool isBuiltIn;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.slot,
    required this.formality,
    required this.warmth,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['slot'] = Variable<String>(slot);
    map['formality'] = Variable<int>(formality);
    map['warmth'] = Variable<int>(warmth);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      slot: Value(slot),
      formality: Value(formality),
      warmth: Value(warmth),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      slot: serializer.fromJson<String>(json['slot']),
      formality: serializer.fromJson<int>(json['formality']),
      warmth: serializer.fromJson<int>(json['warmth']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'slot': serializer.toJson<String>(slot),
      'formality': serializer.toJson<int>(formality),
      'warmth': serializer.toJson<int>(warmth),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? name,
    String? slot,
    int? formality,
    int? warmth,
    bool? isBuiltIn,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    slot: slot ?? this.slot,
    formality: formality ?? this.formality,
    warmth: warmth ?? this.warmth,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      slot: data.slot.present ? data.slot.value : this.slot,
      formality: data.formality.present ? data.formality.value : this.formality,
      warmth: data.warmth.present ? data.warmth.value : this.warmth,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slot: $slot, ')
          ..write('formality: $formality, ')
          ..write('warmth: $warmth, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, slot, formality, warmth, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.slot == this.slot &&
          other.formality == this.formality &&
          other.warmth == this.warmth &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> slot;
  final Value<int> formality;
  final Value<int> warmth;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.slot = const Value.absent(),
    this.formality = const Value.absent(),
    this.warmth = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String slot,
    this.formality = const Value.absent(),
    this.warmth = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       slot = Value(slot);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? slot,
    Expression<int>? formality,
    Expression<int>? warmth,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (slot != null) 'slot': slot,
      if (formality != null) 'formality': formality,
      if (warmth != null) 'warmth': warmth,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? slot,
    Value<int>? formality,
    Value<int>? warmth,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      formality: formality ?? this.formality,
      warmth: warmth ?? this.warmth,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (formality.present) {
      map['formality'] = Variable<int>(formality.value);
    }
    if (warmth.present) {
      map['warmth'] = Variable<int>(warmth.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slot: $slot, ')
          ..write('formality: $formality, ')
          ..write('warmth: $warmth, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $OccasionsTable extends Occasions
    with TableInfo<$OccasionsTable, OccasionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccasionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _formalityMeta = const VerificationMeta(
    'formality',
  );
  @override
  late final GeneratedColumn<int> formality = GeneratedColumn<int>(
    'formality',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    formality,
    isBuiltIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occasions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccasionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('formality')) {
      context.handle(
        _formalityMeta,
        formality.isAcceptableOrUnknown(data['formality']!, _formalityMeta),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OccasionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccasionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      formality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}formality'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $OccasionsTable createAlias(String alias) {
    return $OccasionsTable(attachedDatabase, alias);
  }
}

class OccasionRow extends DataClass implements Insertable<OccasionRow> {
  final int id;
  final String name;
  final int formality;
  final bool isBuiltIn;
  final int sortOrder;
  const OccasionRow({
    required this.id,
    required this.name,
    required this.formality,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['formality'] = Variable<int>(formality);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  OccasionsCompanion toCompanion(bool nullToAbsent) {
    return OccasionsCompanion(
      id: Value(id),
      name: Value(name),
      formality: Value(formality),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory OccasionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccasionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      formality: serializer.fromJson<int>(json['formality']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'formality': serializer.toJson<int>(formality),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  OccasionRow copyWith({
    int? id,
    String? name,
    int? formality,
    bool? isBuiltIn,
    int? sortOrder,
  }) => OccasionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    formality: formality ?? this.formality,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  OccasionRow copyWithCompanion(OccasionsCompanion data) {
    return OccasionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      formality: data.formality.present ? data.formality.value : this.formality,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccasionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('formality: $formality, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, formality, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccasionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.formality == this.formality &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class OccasionsCompanion extends UpdateCompanion<OccasionRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> formality;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  const OccasionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.formality = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  OccasionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.formality = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<OccasionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? formality,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (formality != null) 'formality': formality,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  OccasionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? formality,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
  }) {
    return OccasionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      formality: formality ?? this.formality,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (formality.present) {
      map['formality'] = Variable<int>(formality.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccasionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('formality: $formality, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MoodsTable extends Moods with TableInfo<$MoodsTable, MoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isBuiltIn, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'moods';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $MoodsTable createAlias(String alias) {
    return $MoodsTable(attachedDatabase, alias);
  }
}

class MoodRow extends DataClass implements Insertable<MoodRow> {
  final int id;
  final String name;
  final bool isBuiltIn;
  final int sortOrder;
  const MoodRow({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MoodsCompanion toCompanion(bool nullToAbsent) {
    return MoodsCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory MoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MoodRow copyWith({int? id, String? name, bool? isBuiltIn, int? sortOrder}) =>
      MoodRow(
        id: id ?? this.id,
        name: name ?? this.name,
        isBuiltIn: isBuiltIn ?? this.isBuiltIn,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  MoodRow copyWithCompanion(MoodsCompanion data) {
    return MoodRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class MoodsCompanion extends UpdateCompanion<MoodRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  const MoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  MoodsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MoodRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  MoodsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
  }) {
    return MoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $WashGroupsTable extends WashGroups
    with TableInfo<$WashGroupsTable, WashGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WashGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isBuiltIn, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wash_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<WashGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WashGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WashGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $WashGroupsTable createAlias(String alias) {
    return $WashGroupsTable(attachedDatabase, alias);
  }
}

class WashGroupRow extends DataClass implements Insertable<WashGroupRow> {
  final int id;
  final String name;
  final bool isBuiltIn;
  final int sortOrder;
  const WashGroupRow({
    required this.id,
    required this.name,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WashGroupsCompanion toCompanion(bool nullToAbsent) {
    return WashGroupsCompanion(
      id: Value(id),
      name: Value(name),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory WashGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WashGroupRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WashGroupRow copyWith({
    int? id,
    String? name,
    bool? isBuiltIn,
    int? sortOrder,
  }) => WashGroupRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  WashGroupRow copyWithCompanion(WashGroupsCompanion data) {
    return WashGroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WashGroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WashGroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class WashGroupsCompanion extends UpdateCompanion<WashGroupRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  const WashGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WashGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WashGroupRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WashGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
  }) {
    return WashGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WashGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;
  final String name;
  const TagRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TagRow copyWith({int? id, String? name}) =>
      TagRow(id: id ?? this.id, name: name ?? this.name);
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $GarmentsTable extends Garments
    with TableInfo<$GarmentsTable, GarmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbPathMeta = const VerificationMeta(
    'thumbPath',
  );
  @override
  late final GeneratedColumn<String> thumbPath = GeneratedColumn<String>(
    'thumb_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalPathMeta = const VerificationMeta(
    'originalPath',
  );
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
    'original_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _dominantColorArgbMeta = const VerificationMeta(
    'dominantColorArgb',
  );
  @override
  late final GeneratedColumn<int> dominantColorArgb = GeneratedColumn<int>(
    'dominant_color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorFamilyMeta = const VerificationMeta(
    'colorFamily',
  );
  @override
  late final GeneratedColumn<String> colorFamily = GeneratedColumn<String>(
    'color_family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paletteJsonMeta = const VerificationMeta(
    'paletteJson',
  );
  @override
  late final GeneratedColumn<String> paletteJson = GeneratedColumn<String>(
    'palette_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _washGroupIdMeta = const VerificationMeta(
    'washGroupId',
  );
  @override
  late final GeneratedColumn<int> washGroupId = GeneratedColumn<int>(
    'wash_group_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wash_groups (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wearCountMeta = const VerificationMeta(
    'wearCount',
  );
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
    'wear_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWornAtMeta = const VerificationMeta(
    'lastWornAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWornAt = GeneratedColumn<DateTime>(
    'last_worn_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _washCountMeta = const VerificationMeta(
    'washCount',
  );
  @override
  late final GeneratedColumn<int> washCount = GeneratedColumn<int>(
    'wash_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWashedAtMeta = const VerificationMeta(
    'lastWashedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWashedAt = GeneratedColumn<DateTime>(
    'last_washed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wearsSinceWashMeta = const VerificationMeta(
    'wearsSinceWash',
  );
  @override
  late final GeneratedColumn<int> wearsSinceWash = GeneratedColumn<int>(
    'wears_since_wash',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    imagePath,
    thumbPath,
    originalPath,
    categoryId,
    dominantColorArgb,
    colorFamily,
    paletteJson,
    name,
    brand,
    notes,
    washGroupId,
    isFavorite,
    isArchived,
    wearCount,
    lastWornAt,
    washCount,
    lastWashedAt,
    wearsSinceWash,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garments';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('thumb_path')) {
      context.handle(
        _thumbPathMeta,
        thumbPath.isAcceptableOrUnknown(data['thumb_path']!, _thumbPathMeta),
      );
    } else if (isInserting) {
      context.missing(_thumbPathMeta);
    }
    if (data.containsKey('original_path')) {
      context.handle(
        _originalPathMeta,
        originalPath.isAcceptableOrUnknown(
          data['original_path']!,
          _originalPathMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('dominant_color_argb')) {
      context.handle(
        _dominantColorArgbMeta,
        dominantColorArgb.isAcceptableOrUnknown(
          data['dominant_color_argb']!,
          _dominantColorArgbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dominantColorArgbMeta);
    }
    if (data.containsKey('color_family')) {
      context.handle(
        _colorFamilyMeta,
        colorFamily.isAcceptableOrUnknown(
          data['color_family']!,
          _colorFamilyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_colorFamilyMeta);
    }
    if (data.containsKey('palette_json')) {
      context.handle(
        _paletteJsonMeta,
        paletteJson.isAcceptableOrUnknown(
          data['palette_json']!,
          _paletteJsonMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('wash_group_id')) {
      context.handle(
        _washGroupIdMeta,
        washGroupId.isAcceptableOrUnknown(
          data['wash_group_id']!,
          _washGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('wear_count')) {
      context.handle(
        _wearCountMeta,
        wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta),
      );
    }
    if (data.containsKey('last_worn_at')) {
      context.handle(
        _lastWornAtMeta,
        lastWornAt.isAcceptableOrUnknown(
          data['last_worn_at']!,
          _lastWornAtMeta,
        ),
      );
    }
    if (data.containsKey('wash_count')) {
      context.handle(
        _washCountMeta,
        washCount.isAcceptableOrUnknown(data['wash_count']!, _washCountMeta),
      );
    }
    if (data.containsKey('last_washed_at')) {
      context.handle(
        _lastWashedAtMeta,
        lastWashedAt.isAcceptableOrUnknown(
          data['last_washed_at']!,
          _lastWashedAtMeta,
        ),
      );
    }
    if (data.containsKey('wears_since_wash')) {
      context.handle(
        _wearsSinceWashMeta,
        wearsSinceWash.isAcceptableOrUnknown(
          data['wears_since_wash']!,
          _wearsSinceWashMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GarmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      thumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumb_path'],
      )!,
      originalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_path'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      dominantColorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dominant_color_argb'],
      )!,
      colorFamily: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_family'],
      )!,
      paletteJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}palette_json'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      washGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wash_group_id'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      wearCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wear_count'],
      )!,
      lastWornAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_worn_at'],
      ),
      washCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wash_count'],
      )!,
      lastWashedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_washed_at'],
      ),
      wearsSinceWash: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wears_since_wash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GarmentsTable createAlias(String alias) {
    return $GarmentsTable(attachedDatabase, alias);
  }
}

class GarmentRow extends DataClass implements Insertable<GarmentRow> {
  final int id;

  /// Rutas RELATIVAS al directorio de documentos de la app. En Android la
  /// ruta absoluta del sandbox cambia entre reinstalaciones y
  /// actualizaciones, así que guardar la absoluta rompería las imágenes.
  final String imagePath;
  final String thumbPath;

  /// La foto sin recortar, por si se quiere rehacer el recorte.
  final String? originalPath;

  /// Sin `onDelete: cascade` a propósito: borrar una categoría no debe
  /// borrar la ropa. El repositorio reasigna las prendas a "Sin clasificar".
  final int categoryId;
  final int dominantColorArgb;

  /// Familia cromática derivada del ARGB y persistida.
  ///
  /// Es dato derivado, que normalmente no se guarda. Aquí sí, porque es la
  /// única forma de que el filtro por color se resuelva en SQL como todos
  /// los demás en vez de traer el armario entero y descartar en memoria.
  final String colorFamily;

  /// Paleta secundaria como JSON de enteros ARGB. Es informativa y no se
  /// filtra por ella, así que un blob JSON basta.
  final String paletteJson;
  final String? name;
  final String? brand;
  final String? notes;

  /// Sin cascade: borrar un grupo de lavado no puede borrar ropa. Las
  /// prendas se quedan sin clasificar y ya.
  final int? washGroupId;
  final bool isFavorite;
  final bool isArchived;
  final int wearCount;
  final DateTime? lastWornAt;

  /// Lavadas acumuladas: la métrica de desgaste que de verdad importa.
  final int washCount;
  final DateTime? lastWashedAt;

  /// Usos desde la última lavada. Se pone a cero al lavar.
  final int wearsSinceWash;
  final DateTime createdAt;
  const GarmentRow({
    required this.id,
    required this.imagePath,
    required this.thumbPath,
    this.originalPath,
    required this.categoryId,
    required this.dominantColorArgb,
    required this.colorFamily,
    required this.paletteJson,
    this.name,
    this.brand,
    this.notes,
    this.washGroupId,
    required this.isFavorite,
    required this.isArchived,
    required this.wearCount,
    this.lastWornAt,
    required this.washCount,
    this.lastWashedAt,
    required this.wearsSinceWash,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['image_path'] = Variable<String>(imagePath);
    map['thumb_path'] = Variable<String>(thumbPath);
    if (!nullToAbsent || originalPath != null) {
      map['original_path'] = Variable<String>(originalPath);
    }
    map['category_id'] = Variable<int>(categoryId);
    map['dominant_color_argb'] = Variable<int>(dominantColorArgb);
    map['color_family'] = Variable<String>(colorFamily);
    map['palette_json'] = Variable<String>(paletteJson);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || washGroupId != null) {
      map['wash_group_id'] = Variable<int>(washGroupId);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || lastWornAt != null) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt);
    }
    map['wash_count'] = Variable<int>(washCount);
    if (!nullToAbsent || lastWashedAt != null) {
      map['last_washed_at'] = Variable<DateTime>(lastWashedAt);
    }
    map['wears_since_wash'] = Variable<int>(wearsSinceWash);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GarmentsCompanion toCompanion(bool nullToAbsent) {
    return GarmentsCompanion(
      id: Value(id),
      imagePath: Value(imagePath),
      thumbPath: Value(thumbPath),
      originalPath: originalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(originalPath),
      categoryId: Value(categoryId),
      dominantColorArgb: Value(dominantColorArgb),
      colorFamily: Value(colorFamily),
      paletteJson: Value(paletteJson),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      washGroupId: washGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(washGroupId),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      wearCount: Value(wearCount),
      lastWornAt: lastWornAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWornAt),
      washCount: Value(washCount),
      lastWashedAt: lastWashedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWashedAt),
      wearsSinceWash: Value(wearsSinceWash),
      createdAt: Value(createdAt),
    );
  }

  factory GarmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentRow(
      id: serializer.fromJson<int>(json['id']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      thumbPath: serializer.fromJson<String>(json['thumbPath']),
      originalPath: serializer.fromJson<String?>(json['originalPath']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      dominantColorArgb: serializer.fromJson<int>(json['dominantColorArgb']),
      colorFamily: serializer.fromJson<String>(json['colorFamily']),
      paletteJson: serializer.fromJson<String>(json['paletteJson']),
      name: serializer.fromJson<String?>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      notes: serializer.fromJson<String?>(json['notes']),
      washGroupId: serializer.fromJson<int?>(json['washGroupId']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      lastWornAt: serializer.fromJson<DateTime?>(json['lastWornAt']),
      washCount: serializer.fromJson<int>(json['washCount']),
      lastWashedAt: serializer.fromJson<DateTime?>(json['lastWashedAt']),
      wearsSinceWash: serializer.fromJson<int>(json['wearsSinceWash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'imagePath': serializer.toJson<String>(imagePath),
      'thumbPath': serializer.toJson<String>(thumbPath),
      'originalPath': serializer.toJson<String?>(originalPath),
      'categoryId': serializer.toJson<int>(categoryId),
      'dominantColorArgb': serializer.toJson<int>(dominantColorArgb),
      'colorFamily': serializer.toJson<String>(colorFamily),
      'paletteJson': serializer.toJson<String>(paletteJson),
      'name': serializer.toJson<String?>(name),
      'brand': serializer.toJson<String?>(brand),
      'notes': serializer.toJson<String?>(notes),
      'washGroupId': serializer.toJson<int?>(washGroupId),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'wearCount': serializer.toJson<int>(wearCount),
      'lastWornAt': serializer.toJson<DateTime?>(lastWornAt),
      'washCount': serializer.toJson<int>(washCount),
      'lastWashedAt': serializer.toJson<DateTime?>(lastWashedAt),
      'wearsSinceWash': serializer.toJson<int>(wearsSinceWash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GarmentRow copyWith({
    int? id,
    String? imagePath,
    String? thumbPath,
    Value<String?> originalPath = const Value.absent(),
    int? categoryId,
    int? dominantColorArgb,
    String? colorFamily,
    String? paletteJson,
    Value<String?> name = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> washGroupId = const Value.absent(),
    bool? isFavorite,
    bool? isArchived,
    int? wearCount,
    Value<DateTime?> lastWornAt = const Value.absent(),
    int? washCount,
    Value<DateTime?> lastWashedAt = const Value.absent(),
    int? wearsSinceWash,
    DateTime? createdAt,
  }) => GarmentRow(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    thumbPath: thumbPath ?? this.thumbPath,
    originalPath: originalPath.present ? originalPath.value : this.originalPath,
    categoryId: categoryId ?? this.categoryId,
    dominantColorArgb: dominantColorArgb ?? this.dominantColorArgb,
    colorFamily: colorFamily ?? this.colorFamily,
    paletteJson: paletteJson ?? this.paletteJson,
    name: name.present ? name.value : this.name,
    brand: brand.present ? brand.value : this.brand,
    notes: notes.present ? notes.value : this.notes,
    washGroupId: washGroupId.present ? washGroupId.value : this.washGroupId,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    wearCount: wearCount ?? this.wearCount,
    lastWornAt: lastWornAt.present ? lastWornAt.value : this.lastWornAt,
    washCount: washCount ?? this.washCount,
    lastWashedAt: lastWashedAt.present ? lastWashedAt.value : this.lastWashedAt,
    wearsSinceWash: wearsSinceWash ?? this.wearsSinceWash,
    createdAt: createdAt ?? this.createdAt,
  );
  GarmentRow copyWithCompanion(GarmentsCompanion data) {
    return GarmentRow(
      id: data.id.present ? data.id.value : this.id,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      thumbPath: data.thumbPath.present ? data.thumbPath.value : this.thumbPath,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      dominantColorArgb: data.dominantColorArgb.present
          ? data.dominantColorArgb.value
          : this.dominantColorArgb,
      colorFamily: data.colorFamily.present
          ? data.colorFamily.value
          : this.colorFamily,
      paletteJson: data.paletteJson.present
          ? data.paletteJson.value
          : this.paletteJson,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      notes: data.notes.present ? data.notes.value : this.notes,
      washGroupId: data.washGroupId.present
          ? data.washGroupId.value
          : this.washGroupId,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      lastWornAt: data.lastWornAt.present
          ? data.lastWornAt.value
          : this.lastWornAt,
      washCount: data.washCount.present ? data.washCount.value : this.washCount,
      lastWashedAt: data.lastWashedAt.present
          ? data.lastWashedAt.value
          : this.lastWashedAt,
      wearsSinceWash: data.wearsSinceWash.present
          ? data.wearsSinceWash.value
          : this.wearsSinceWash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentRow(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('originalPath: $originalPath, ')
          ..write('categoryId: $categoryId, ')
          ..write('dominantColorArgb: $dominantColorArgb, ')
          ..write('colorFamily: $colorFamily, ')
          ..write('paletteJson: $paletteJson, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('notes: $notes, ')
          ..write('washGroupId: $washGroupId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('washCount: $washCount, ')
          ..write('lastWashedAt: $lastWashedAt, ')
          ..write('wearsSinceWash: $wearsSinceWash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    imagePath,
    thumbPath,
    originalPath,
    categoryId,
    dominantColorArgb,
    colorFamily,
    paletteJson,
    name,
    brand,
    notes,
    washGroupId,
    isFavorite,
    isArchived,
    wearCount,
    lastWornAt,
    washCount,
    lastWashedAt,
    wearsSinceWash,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentRow &&
          other.id == this.id &&
          other.imagePath == this.imagePath &&
          other.thumbPath == this.thumbPath &&
          other.originalPath == this.originalPath &&
          other.categoryId == this.categoryId &&
          other.dominantColorArgb == this.dominantColorArgb &&
          other.colorFamily == this.colorFamily &&
          other.paletteJson == this.paletteJson &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.notes == this.notes &&
          other.washGroupId == this.washGroupId &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.wearCount == this.wearCount &&
          other.lastWornAt == this.lastWornAt &&
          other.washCount == this.washCount &&
          other.lastWashedAt == this.lastWashedAt &&
          other.wearsSinceWash == this.wearsSinceWash &&
          other.createdAt == this.createdAt);
}

class GarmentsCompanion extends UpdateCompanion<GarmentRow> {
  final Value<int> id;
  final Value<String> imagePath;
  final Value<String> thumbPath;
  final Value<String?> originalPath;
  final Value<int> categoryId;
  final Value<int> dominantColorArgb;
  final Value<String> colorFamily;
  final Value<String> paletteJson;
  final Value<String?> name;
  final Value<String?> brand;
  final Value<String?> notes;
  final Value<int?> washGroupId;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<int> wearCount;
  final Value<DateTime?> lastWornAt;
  final Value<int> washCount;
  final Value<DateTime?> lastWashedAt;
  final Value<int> wearsSinceWash;
  final Value<DateTime> createdAt;
  const GarmentsCompanion({
    this.id = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.thumbPath = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dominantColorArgb = const Value.absent(),
    this.colorFamily = const Value.absent(),
    this.paletteJson = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.notes = const Value.absent(),
    this.washGroupId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    this.washCount = const Value.absent(),
    this.lastWashedAt = const Value.absent(),
    this.wearsSinceWash = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GarmentsCompanion.insert({
    this.id = const Value.absent(),
    required String imagePath,
    required String thumbPath,
    this.originalPath = const Value.absent(),
    required int categoryId,
    required int dominantColorArgb,
    required String colorFamily,
    this.paletteJson = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.notes = const Value.absent(),
    this.washGroupId = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    this.washCount = const Value.absent(),
    this.lastWashedAt = const Value.absent(),
    this.wearsSinceWash = const Value.absent(),
    required DateTime createdAt,
  }) : imagePath = Value(imagePath),
       thumbPath = Value(thumbPath),
       categoryId = Value(categoryId),
       dominantColorArgb = Value(dominantColorArgb),
       colorFamily = Value(colorFamily),
       createdAt = Value(createdAt);
  static Insertable<GarmentRow> custom({
    Expression<int>? id,
    Expression<String>? imagePath,
    Expression<String>? thumbPath,
    Expression<String>? originalPath,
    Expression<int>? categoryId,
    Expression<int>? dominantColorArgb,
    Expression<String>? colorFamily,
    Expression<String>? paletteJson,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? notes,
    Expression<int>? washGroupId,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<int>? wearCount,
    Expression<DateTime>? lastWornAt,
    Expression<int>? washCount,
    Expression<DateTime>? lastWashedAt,
    Expression<int>? wearsSinceWash,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (imagePath != null) 'image_path': imagePath,
      if (thumbPath != null) 'thumb_path': thumbPath,
      if (originalPath != null) 'original_path': originalPath,
      if (categoryId != null) 'category_id': categoryId,
      if (dominantColorArgb != null) 'dominant_color_argb': dominantColorArgb,
      if (colorFamily != null) 'color_family': colorFamily,
      if (paletteJson != null) 'palette_json': paletteJson,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (notes != null) 'notes': notes,
      if (washGroupId != null) 'wash_group_id': washGroupId,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (wearCount != null) 'wear_count': wearCount,
      if (lastWornAt != null) 'last_worn_at': lastWornAt,
      if (washCount != null) 'wash_count': washCount,
      if (lastWashedAt != null) 'last_washed_at': lastWashedAt,
      if (wearsSinceWash != null) 'wears_since_wash': wearsSinceWash,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GarmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? imagePath,
    Value<String>? thumbPath,
    Value<String?>? originalPath,
    Value<int>? categoryId,
    Value<int>? dominantColorArgb,
    Value<String>? colorFamily,
    Value<String>? paletteJson,
    Value<String?>? name,
    Value<String?>? brand,
    Value<String?>? notes,
    Value<int?>? washGroupId,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<int>? wearCount,
    Value<DateTime?>? lastWornAt,
    Value<int>? washCount,
    Value<DateTime?>? lastWashedAt,
    Value<int>? wearsSinceWash,
    Value<DateTime>? createdAt,
  }) {
    return GarmentsCompanion(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      originalPath: originalPath ?? this.originalPath,
      categoryId: categoryId ?? this.categoryId,
      dominantColorArgb: dominantColorArgb ?? this.dominantColorArgb,
      colorFamily: colorFamily ?? this.colorFamily,
      paletteJson: paletteJson ?? this.paletteJson,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      washGroupId: washGroupId ?? this.washGroupId,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      washCount: washCount ?? this.washCount,
      lastWashedAt: lastWashedAt ?? this.lastWashedAt,
      wearsSinceWash: wearsSinceWash ?? this.wearsSinceWash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (thumbPath.present) {
      map['thumb_path'] = Variable<String>(thumbPath.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (dominantColorArgb.present) {
      map['dominant_color_argb'] = Variable<int>(dominantColorArgb.value);
    }
    if (colorFamily.present) {
      map['color_family'] = Variable<String>(colorFamily.value);
    }
    if (paletteJson.present) {
      map['palette_json'] = Variable<String>(paletteJson.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (washGroupId.present) {
      map['wash_group_id'] = Variable<int>(washGroupId.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (wearCount.present) {
      map['wear_count'] = Variable<int>(wearCount.value);
    }
    if (lastWornAt.present) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt.value);
    }
    if (washCount.present) {
      map['wash_count'] = Variable<int>(washCount.value);
    }
    if (lastWashedAt.present) {
      map['last_washed_at'] = Variable<DateTime>(lastWashedAt.value);
    }
    if (wearsSinceWash.present) {
      map['wears_since_wash'] = Variable<int>(wearsSinceWash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentsCompanion(')
          ..write('id: $id, ')
          ..write('imagePath: $imagePath, ')
          ..write('thumbPath: $thumbPath, ')
          ..write('originalPath: $originalPath, ')
          ..write('categoryId: $categoryId, ')
          ..write('dominantColorArgb: $dominantColorArgb, ')
          ..write('colorFamily: $colorFamily, ')
          ..write('paletteJson: $paletteJson, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('notes: $notes, ')
          ..write('washGroupId: $washGroupId, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('washCount: $washCount, ')
          ..write('lastWashedAt: $lastWashedAt, ')
          ..write('wearsSinceWash: $wearsSinceWash, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GarmentTagsTable extends GarmentTags
    with TableInfo<$GarmentTagsTable, GarmentTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [garmentId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garment_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {garmentId, tagId};
  @override
  GarmentTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentTag(
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $GarmentTagsTable createAlias(String alias) {
    return $GarmentTagsTable(attachedDatabase, alias);
  }
}

class GarmentTag extends DataClass implements Insertable<GarmentTag> {
  final int garmentId;
  final int tagId;
  const GarmentTag({required this.garmentId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['garment_id'] = Variable<int>(garmentId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  GarmentTagsCompanion toCompanion(bool nullToAbsent) {
    return GarmentTagsCompanion(
      garmentId: Value(garmentId),
      tagId: Value(tagId),
    );
  }

  factory GarmentTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentTag(
      garmentId: serializer.fromJson<int>(json['garmentId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'garmentId': serializer.toJson<int>(garmentId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  GarmentTag copyWith({int? garmentId, int? tagId}) => GarmentTag(
    garmentId: garmentId ?? this.garmentId,
    tagId: tagId ?? this.tagId,
  );
  GarmentTag copyWithCompanion(GarmentTagsCompanion data) {
    return GarmentTag(
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentTag(')
          ..write('garmentId: $garmentId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(garmentId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentTag &&
          other.garmentId == this.garmentId &&
          other.tagId == this.tagId);
}

class GarmentTagsCompanion extends UpdateCompanion<GarmentTag> {
  final Value<int> garmentId;
  final Value<int> tagId;
  final Value<int> rowid;
  const GarmentTagsCompanion({
    this.garmentId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GarmentTagsCompanion.insert({
    required int garmentId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : garmentId = Value(garmentId),
       tagId = Value(tagId);
  static Insertable<GarmentTag> custom({
    Expression<int>? garmentId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (garmentId != null) 'garment_id': garmentId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GarmentTagsCompanion copyWith({
    Value<int>? garmentId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return GarmentTagsCompanion(
      garmentId: garmentId ?? this.garmentId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentTagsCompanion(')
          ..write('garmentId: $garmentId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GarmentSeasonsTable extends GarmentSeasons
    with TableInfo<$GarmentSeasonsTable, GarmentSeason> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentSeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [garmentId, season];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garment_seasons';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentSeason> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {garmentId, season};
  @override
  GarmentSeason map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentSeason(
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
    );
  }

  @override
  $GarmentSeasonsTable createAlias(String alias) {
    return $GarmentSeasonsTable(attachedDatabase, alias);
  }
}

class GarmentSeason extends DataClass implements Insertable<GarmentSeason> {
  final int garmentId;
  final String season;
  const GarmentSeason({required this.garmentId, required this.season});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['garment_id'] = Variable<int>(garmentId);
    map['season'] = Variable<String>(season);
    return map;
  }

  GarmentSeasonsCompanion toCompanion(bool nullToAbsent) {
    return GarmentSeasonsCompanion(
      garmentId: Value(garmentId),
      season: Value(season),
    );
  }

  factory GarmentSeason.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentSeason(
      garmentId: serializer.fromJson<int>(json['garmentId']),
      season: serializer.fromJson<String>(json['season']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'garmentId': serializer.toJson<int>(garmentId),
      'season': serializer.toJson<String>(season),
    };
  }

  GarmentSeason copyWith({int? garmentId, String? season}) => GarmentSeason(
    garmentId: garmentId ?? this.garmentId,
    season: season ?? this.season,
  );
  GarmentSeason copyWithCompanion(GarmentSeasonsCompanion data) {
    return GarmentSeason(
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
      season: data.season.present ? data.season.value : this.season,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentSeason(')
          ..write('garmentId: $garmentId, ')
          ..write('season: $season')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(garmentId, season);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentSeason &&
          other.garmentId == this.garmentId &&
          other.season == this.season);
}

class GarmentSeasonsCompanion extends UpdateCompanion<GarmentSeason> {
  final Value<int> garmentId;
  final Value<String> season;
  final Value<int> rowid;
  const GarmentSeasonsCompanion({
    this.garmentId = const Value.absent(),
    this.season = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GarmentSeasonsCompanion.insert({
    required int garmentId,
    required String season,
    this.rowid = const Value.absent(),
  }) : garmentId = Value(garmentId),
       season = Value(season);
  static Insertable<GarmentSeason> custom({
    Expression<int>? garmentId,
    Expression<String>? season,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (garmentId != null) 'garment_id': garmentId,
      if (season != null) 'season': season,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GarmentSeasonsCompanion copyWith({
    Value<int>? garmentId,
    Value<String>? season,
    Value<int>? rowid,
  }) {
    return GarmentSeasonsCompanion(
      garmentId: garmentId ?? this.garmentId,
      season: season ?? this.season,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentSeasonsCompanion(')
          ..write('garmentId: $garmentId, ')
          ..write('season: $season, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GarmentOccasionsTable extends GarmentOccasions
    with TableInfo<$GarmentOccasionsTable, GarmentOccasion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentOccasionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occasionIdMeta = const VerificationMeta(
    'occasionId',
  );
  @override
  late final GeneratedColumn<int> occasionId = GeneratedColumn<int>(
    'occasion_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES occasions (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [garmentId, occasionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garment_occasions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentOccasion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    if (data.containsKey('occasion_id')) {
      context.handle(
        _occasionIdMeta,
        occasionId.isAcceptableOrUnknown(data['occasion_id']!, _occasionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_occasionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {garmentId, occasionId};
  @override
  GarmentOccasion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentOccasion(
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
      occasionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occasion_id'],
      )!,
    );
  }

  @override
  $GarmentOccasionsTable createAlias(String alias) {
    return $GarmentOccasionsTable(attachedDatabase, alias);
  }
}

class GarmentOccasion extends DataClass implements Insertable<GarmentOccasion> {
  final int garmentId;
  final int occasionId;
  const GarmentOccasion({required this.garmentId, required this.occasionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['garment_id'] = Variable<int>(garmentId);
    map['occasion_id'] = Variable<int>(occasionId);
    return map;
  }

  GarmentOccasionsCompanion toCompanion(bool nullToAbsent) {
    return GarmentOccasionsCompanion(
      garmentId: Value(garmentId),
      occasionId: Value(occasionId),
    );
  }

  factory GarmentOccasion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentOccasion(
      garmentId: serializer.fromJson<int>(json['garmentId']),
      occasionId: serializer.fromJson<int>(json['occasionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'garmentId': serializer.toJson<int>(garmentId),
      'occasionId': serializer.toJson<int>(occasionId),
    };
  }

  GarmentOccasion copyWith({int? garmentId, int? occasionId}) =>
      GarmentOccasion(
        garmentId: garmentId ?? this.garmentId,
        occasionId: occasionId ?? this.occasionId,
      );
  GarmentOccasion copyWithCompanion(GarmentOccasionsCompanion data) {
    return GarmentOccasion(
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
      occasionId: data.occasionId.present
          ? data.occasionId.value
          : this.occasionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentOccasion(')
          ..write('garmentId: $garmentId, ')
          ..write('occasionId: $occasionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(garmentId, occasionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentOccasion &&
          other.garmentId == this.garmentId &&
          other.occasionId == this.occasionId);
}

class GarmentOccasionsCompanion extends UpdateCompanion<GarmentOccasion> {
  final Value<int> garmentId;
  final Value<int> occasionId;
  final Value<int> rowid;
  const GarmentOccasionsCompanion({
    this.garmentId = const Value.absent(),
    this.occasionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GarmentOccasionsCompanion.insert({
    required int garmentId,
    required int occasionId,
    this.rowid = const Value.absent(),
  }) : garmentId = Value(garmentId),
       occasionId = Value(occasionId);
  static Insertable<GarmentOccasion> custom({
    Expression<int>? garmentId,
    Expression<int>? occasionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (garmentId != null) 'garment_id': garmentId,
      if (occasionId != null) 'occasion_id': occasionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GarmentOccasionsCompanion copyWith({
    Value<int>? garmentId,
    Value<int>? occasionId,
    Value<int>? rowid,
  }) {
    return GarmentOccasionsCompanion(
      garmentId: garmentId ?? this.garmentId,
      occasionId: occasionId ?? this.occasionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (occasionId.present) {
      map['occasion_id'] = Variable<int>(occasionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentOccasionsCompanion(')
          ..write('garmentId: $garmentId, ')
          ..write('occasionId: $occasionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GarmentMoodsTable extends GarmentMoods
    with TableInfo<$GarmentMoodsTable, GarmentMood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GarmentMoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moodIdMeta = const VerificationMeta('moodId');
  @override
  late final GeneratedColumn<int> moodId = GeneratedColumn<int>(
    'mood_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES moods (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [garmentId, moodId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'garment_moods';
  @override
  VerificationContext validateIntegrity(
    Insertable<GarmentMood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    if (data.containsKey('mood_id')) {
      context.handle(
        _moodIdMeta,
        moodId.isAcceptableOrUnknown(data['mood_id']!, _moodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moodIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {garmentId, moodId};
  @override
  GarmentMood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GarmentMood(
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
      moodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_id'],
      )!,
    );
  }

  @override
  $GarmentMoodsTable createAlias(String alias) {
    return $GarmentMoodsTable(attachedDatabase, alias);
  }
}

class GarmentMood extends DataClass implements Insertable<GarmentMood> {
  final int garmentId;
  final int moodId;
  const GarmentMood({required this.garmentId, required this.moodId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['garment_id'] = Variable<int>(garmentId);
    map['mood_id'] = Variable<int>(moodId);
    return map;
  }

  GarmentMoodsCompanion toCompanion(bool nullToAbsent) {
    return GarmentMoodsCompanion(
      garmentId: Value(garmentId),
      moodId: Value(moodId),
    );
  }

  factory GarmentMood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GarmentMood(
      garmentId: serializer.fromJson<int>(json['garmentId']),
      moodId: serializer.fromJson<int>(json['moodId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'garmentId': serializer.toJson<int>(garmentId),
      'moodId': serializer.toJson<int>(moodId),
    };
  }

  GarmentMood copyWith({int? garmentId, int? moodId}) => GarmentMood(
    garmentId: garmentId ?? this.garmentId,
    moodId: moodId ?? this.moodId,
  );
  GarmentMood copyWithCompanion(GarmentMoodsCompanion data) {
    return GarmentMood(
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
      moodId: data.moodId.present ? data.moodId.value : this.moodId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GarmentMood(')
          ..write('garmentId: $garmentId, ')
          ..write('moodId: $moodId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(garmentId, moodId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GarmentMood &&
          other.garmentId == this.garmentId &&
          other.moodId == this.moodId);
}

class GarmentMoodsCompanion extends UpdateCompanion<GarmentMood> {
  final Value<int> garmentId;
  final Value<int> moodId;
  final Value<int> rowid;
  const GarmentMoodsCompanion({
    this.garmentId = const Value.absent(),
    this.moodId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GarmentMoodsCompanion.insert({
    required int garmentId,
    required int moodId,
    this.rowid = const Value.absent(),
  }) : garmentId = Value(garmentId),
       moodId = Value(moodId);
  static Insertable<GarmentMood> custom({
    Expression<int>? garmentId,
    Expression<int>? moodId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (garmentId != null) 'garment_id': garmentId,
      if (moodId != null) 'mood_id': moodId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GarmentMoodsCompanion copyWith({
    Value<int>? garmentId,
    Value<int>? moodId,
    Value<int>? rowid,
  }) {
    return GarmentMoodsCompanion(
      garmentId: garmentId ?? this.garmentId,
      moodId: moodId ?? this.moodId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (moodId.present) {
      map['mood_id'] = Variable<int>(moodId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GarmentMoodsCompanion(')
          ..write('garmentId: $garmentId, ')
          ..write('moodId: $moodId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitsTable extends Outfits with TableInfo<$OutfitsTable, OutfitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occasionIdMeta = const VerificationMeta(
    'occasionId',
  );
  @override
  late final GeneratedColumn<int> occasionId = GeneratedColumn<int>(
    'occasion_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES occasions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _moodIdMeta = const VerificationMeta('moodId');
  @override
  late final GeneratedColumn<int> moodId = GeneratedColumn<int>(
    'mood_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES moods (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wearCountMeta = const VerificationMeta(
    'wearCount',
  );
  @override
  late final GeneratedColumn<int> wearCount = GeneratedColumn<int>(
    'wear_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastWornAtMeta = const VerificationMeta(
    'lastWornAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastWornAt = GeneratedColumn<DateTime>(
    'last_worn_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    occasionId,
    moodId,
    notes,
    isFavorite,
    wearCount,
    lastWornAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfits';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutfitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('occasion_id')) {
      context.handle(
        _occasionIdMeta,
        occasionId.isAcceptableOrUnknown(data['occasion_id']!, _occasionIdMeta),
      );
    }
    if (data.containsKey('mood_id')) {
      context.handle(
        _moodIdMeta,
        moodId.isAcceptableOrUnknown(data['mood_id']!, _moodIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('wear_count')) {
      context.handle(
        _wearCountMeta,
        wearCount.isAcceptableOrUnknown(data['wear_count']!, _wearCountMeta),
      );
    }
    if (data.containsKey('last_worn_at')) {
      context.handle(
        _lastWornAtMeta,
        lastWornAt.isAcceptableOrUnknown(
          data['last_worn_at']!,
          _lastWornAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutfitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      occasionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occasion_id'],
      ),
      moodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mood_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      wearCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wear_count'],
      )!,
      lastWornAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_worn_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutfitsTable createAlias(String alias) {
    return $OutfitsTable(attachedDatabase, alias);
  }
}

class OutfitRow extends DataClass implements Insertable<OutfitRow> {
  final int id;
  final String? name;
  final int? occasionId;
  final int? moodId;
  final String? notes;
  final bool isFavorite;
  final int wearCount;
  final DateTime? lastWornAt;
  final DateTime createdAt;
  const OutfitRow({
    required this.id,
    this.name,
    this.occasionId,
    this.moodId,
    this.notes,
    required this.isFavorite,
    required this.wearCount,
    this.lastWornAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || occasionId != null) {
      map['occasion_id'] = Variable<int>(occasionId);
    }
    if (!nullToAbsent || moodId != null) {
      map['mood_id'] = Variable<int>(moodId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['wear_count'] = Variable<int>(wearCount);
    if (!nullToAbsent || lastWornAt != null) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutfitsCompanion toCompanion(bool nullToAbsent) {
    return OutfitsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      occasionId: occasionId == null && nullToAbsent
          ? const Value.absent()
          : Value(occasionId),
      moodId: moodId == null && nullToAbsent
          ? const Value.absent()
          : Value(moodId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isFavorite: Value(isFavorite),
      wearCount: Value(wearCount),
      lastWornAt: lastWornAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWornAt),
      createdAt: Value(createdAt),
    );
  }

  factory OutfitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      occasionId: serializer.fromJson<int?>(json['occasionId']),
      moodId: serializer.fromJson<int?>(json['moodId']),
      notes: serializer.fromJson<String?>(json['notes']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      wearCount: serializer.fromJson<int>(json['wearCount']),
      lastWornAt: serializer.fromJson<DateTime?>(json['lastWornAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'occasionId': serializer.toJson<int?>(occasionId),
      'moodId': serializer.toJson<int?>(moodId),
      'notes': serializer.toJson<String?>(notes),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'wearCount': serializer.toJson<int>(wearCount),
      'lastWornAt': serializer.toJson<DateTime?>(lastWornAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutfitRow copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    Value<int?> occasionId = const Value.absent(),
    Value<int?> moodId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isFavorite,
    int? wearCount,
    Value<DateTime?> lastWornAt = const Value.absent(),
    DateTime? createdAt,
  }) => OutfitRow(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    occasionId: occasionId.present ? occasionId.value : this.occasionId,
    moodId: moodId.present ? moodId.value : this.moodId,
    notes: notes.present ? notes.value : this.notes,
    isFavorite: isFavorite ?? this.isFavorite,
    wearCount: wearCount ?? this.wearCount,
    lastWornAt: lastWornAt.present ? lastWornAt.value : this.lastWornAt,
    createdAt: createdAt ?? this.createdAt,
  );
  OutfitRow copyWithCompanion(OutfitsCompanion data) {
    return OutfitRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      occasionId: data.occasionId.present
          ? data.occasionId.value
          : this.occasionId,
      moodId: data.moodId.present ? data.moodId.value : this.moodId,
      notes: data.notes.present ? data.notes.value : this.notes,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      wearCount: data.wearCount.present ? data.wearCount.value : this.wearCount,
      lastWornAt: data.lastWornAt.present
          ? data.lastWornAt.value
          : this.lastWornAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('occasionId: $occasionId, ')
          ..write('moodId: $moodId, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    occasionId,
    moodId,
    notes,
    isFavorite,
    wearCount,
    lastWornAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.occasionId == this.occasionId &&
          other.moodId == this.moodId &&
          other.notes == this.notes &&
          other.isFavorite == this.isFavorite &&
          other.wearCount == this.wearCount &&
          other.lastWornAt == this.lastWornAt &&
          other.createdAt == this.createdAt);
}

class OutfitsCompanion extends UpdateCompanion<OutfitRow> {
  final Value<int> id;
  final Value<String?> name;
  final Value<int?> occasionId;
  final Value<int?> moodId;
  final Value<String?> notes;
  final Value<bool> isFavorite;
  final Value<int> wearCount;
  final Value<DateTime?> lastWornAt;
  final Value<DateTime> createdAt;
  const OutfitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.occasionId = const Value.absent(),
    this.moodId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutfitsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.occasionId = const Value.absent(),
    this.moodId = const Value.absent(),
    this.notes = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.wearCount = const Value.absent(),
    this.lastWornAt = const Value.absent(),
    required DateTime createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<OutfitRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? occasionId,
    Expression<int>? moodId,
    Expression<String>? notes,
    Expression<bool>? isFavorite,
    Expression<int>? wearCount,
    Expression<DateTime>? lastWornAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (occasionId != null) 'occasion_id': occasionId,
      if (moodId != null) 'mood_id': moodId,
      if (notes != null) 'notes': notes,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (wearCount != null) 'wear_count': wearCount,
      if (lastWornAt != null) 'last_worn_at': lastWornAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutfitsCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<int?>? occasionId,
    Value<int?>? moodId,
    Value<String?>? notes,
    Value<bool>? isFavorite,
    Value<int>? wearCount,
    Value<DateTime?>? lastWornAt,
    Value<DateTime>? createdAt,
  }) {
    return OutfitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      occasionId: occasionId ?? this.occasionId,
      moodId: moodId ?? this.moodId,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      createdAt: createdAt ?? this.createdAt,
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
    if (occasionId.present) {
      map['occasion_id'] = Variable<int>(occasionId.value);
    }
    if (moodId.present) {
      map['mood_id'] = Variable<int>(moodId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (wearCount.present) {
      map['wear_count'] = Variable<int>(wearCount.value);
    }
    if (lastWornAt.present) {
      map['last_worn_at'] = Variable<DateTime>(lastWornAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('occasionId: $occasionId, ')
          ..write('moodId: $moodId, ')
          ..write('notes: $notes, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('wearCount: $wearCount, ')
          ..write('lastWornAt: $lastWornAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OutfitItemsTable extends OutfitItems
    with TableInfo<$OutfitItemsTable, OutfitItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _outfitIdMeta = const VerificationMeta(
    'outfitId',
  );
  @override
  late final GeneratedColumn<int> outfitId = GeneratedColumn<int>(
    'outfit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES outfits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [outfitId, garmentId, slot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutfitItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('outfit_id')) {
      context.handle(
        _outfitIdMeta,
        outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_outfitIdMeta);
    }
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {outfitId, garmentId};
  @override
  OutfitItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutfitItem(
      outfitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outfit_id'],
      )!,
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
    );
  }

  @override
  $OutfitItemsTable createAlias(String alias) {
    return $OutfitItemsTable(attachedDatabase, alias);
  }
}

class OutfitItem extends DataClass implements Insertable<OutfitItem> {
  final int outfitId;
  final int garmentId;

  /// Ranura congelada en el momento de guardar: si más adelante se
  /// recategoriza la prenda, el outfit guardado conserva su composición.
  final String slot;
  const OutfitItem({
    required this.outfitId,
    required this.garmentId,
    required this.slot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['outfit_id'] = Variable<int>(outfitId);
    map['garment_id'] = Variable<int>(garmentId);
    map['slot'] = Variable<String>(slot);
    return map;
  }

  OutfitItemsCompanion toCompanion(bool nullToAbsent) {
    return OutfitItemsCompanion(
      outfitId: Value(outfitId),
      garmentId: Value(garmentId),
      slot: Value(slot),
    );
  }

  factory OutfitItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutfitItem(
      outfitId: serializer.fromJson<int>(json['outfitId']),
      garmentId: serializer.fromJson<int>(json['garmentId']),
      slot: serializer.fromJson<String>(json['slot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'outfitId': serializer.toJson<int>(outfitId),
      'garmentId': serializer.toJson<int>(garmentId),
      'slot': serializer.toJson<String>(slot),
    };
  }

  OutfitItem copyWith({int? outfitId, int? garmentId, String? slot}) =>
      OutfitItem(
        outfitId: outfitId ?? this.outfitId,
        garmentId: garmentId ?? this.garmentId,
        slot: slot ?? this.slot,
      );
  OutfitItem copyWithCompanion(OutfitItemsCompanion data) {
    return OutfitItem(
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
      slot: data.slot.present ? data.slot.value : this.slot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItem(')
          ..write('outfitId: $outfitId, ')
          ..write('garmentId: $garmentId, ')
          ..write('slot: $slot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(outfitId, garmentId, slot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutfitItem &&
          other.outfitId == this.outfitId &&
          other.garmentId == this.garmentId &&
          other.slot == this.slot);
}

class OutfitItemsCompanion extends UpdateCompanion<OutfitItem> {
  final Value<int> outfitId;
  final Value<int> garmentId;
  final Value<String> slot;
  final Value<int> rowid;
  const OutfitItemsCompanion({
    this.outfitId = const Value.absent(),
    this.garmentId = const Value.absent(),
    this.slot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutfitItemsCompanion.insert({
    required int outfitId,
    required int garmentId,
    required String slot,
    this.rowid = const Value.absent(),
  }) : outfitId = Value(outfitId),
       garmentId = Value(garmentId),
       slot = Value(slot);
  static Insertable<OutfitItem> custom({
    Expression<int>? outfitId,
    Expression<int>? garmentId,
    Expression<String>? slot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (outfitId != null) 'outfit_id': outfitId,
      if (garmentId != null) 'garment_id': garmentId,
      if (slot != null) 'slot': slot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutfitItemsCompanion copyWith({
    Value<int>? outfitId,
    Value<int>? garmentId,
    Value<String>? slot,
    Value<int>? rowid,
  }) {
    return OutfitItemsCompanion(
      outfitId: outfitId ?? this.outfitId,
      garmentId: garmentId ?? this.garmentId,
      slot: slot ?? this.slot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (outfitId.present) {
      map['outfit_id'] = Variable<int>(outfitId.value);
    }
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitItemsCompanion(')
          ..write('outfitId: $outfitId, ')
          ..write('garmentId: $garmentId, ')
          ..write('slot: $slot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutfitPlansTable extends OutfitPlans
    with TableInfo<$OutfitPlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutfitPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _outfitIdMeta = const VerificationMeta(
    'outfitId',
  );
  @override
  late final GeneratedColumn<int> outfitId = GeneratedColumn<int>(
    'outfit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES outfits (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasWornMeta = const VerificationMeta(
    'wasWorn',
  );
  @override
  late final GeneratedColumn<bool> wasWorn = GeneratedColumn<bool>(
    'was_worn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_worn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    outfitId,
    notes,
    wasWorn,
    photoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outfit_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('outfit_id')) {
      context.handle(
        _outfitIdMeta,
        outfitId.isAcceptableOrUnknown(data['outfit_id']!, _outfitIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('was_worn')) {
      context.handle(
        _wasWornMeta,
        wasWorn.isAcceptableOrUnknown(data['was_worn']!, _wasWornMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      outfitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outfit_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      wasWorn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_worn'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutfitPlansTable createAlias(String alias) {
    return $OutfitPlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final int id;

  /// Dia planificado, normalizado a medianoche. NO es unico: un dia admite
  /// varias opciones, y al llegar el dia se marca cual se llevo de verdad.
  /// Planificar es barajar alternativas, no comprometerse a una.
  final DateTime day;
  final int? outfitId;
  final String? notes;

  /// Se marca cuando el usuario confirma que se lo puso de verdad. Sin esto
  /// no habria forma de distinguir "lo tenia planeado" de "me lo puse".
  final bool wasWorn;

  /// Foto del look puesto (del espejo), relativa como las de las prendas.
  /// Convierte el calendario en un diario de lo que se llevo.
  final String? photoPath;
  final DateTime createdAt;
  const PlanRow({
    required this.id,
    required this.day,
    this.outfitId,
    this.notes,
    required this.wasWorn,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<DateTime>(day);
    if (!nullToAbsent || outfitId != null) {
      map['outfit_id'] = Variable<int>(outfitId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['was_worn'] = Variable<bool>(wasWorn);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutfitPlansCompanion toCompanion(bool nullToAbsent) {
    return OutfitPlansCompanion(
      id: Value(id),
      day: Value(day),
      outfitId: outfitId == null && nullToAbsent
          ? const Value.absent()
          : Value(outfitId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      wasWorn: Value(wasWorn),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      outfitId: serializer.fromJson<int?>(json['outfitId']),
      notes: serializer.fromJson<String?>(json['notes']),
      wasWorn: serializer.fromJson<bool>(json['wasWorn']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<DateTime>(day),
      'outfitId': serializer.toJson<int?>(outfitId),
      'notes': serializer.toJson<String?>(notes),
      'wasWorn': serializer.toJson<bool>(wasWorn),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlanRow copyWith({
    int? id,
    DateTime? day,
    Value<int?> outfitId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? wasWorn,
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
  }) => PlanRow(
    id: id ?? this.id,
    day: day ?? this.day,
    outfitId: outfitId.present ? outfitId.value : this.outfitId,
    notes: notes.present ? notes.value : this.notes,
    wasWorn: wasWorn ?? this.wasWorn,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  PlanRow copyWithCompanion(OutfitPlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      outfitId: data.outfitId.present ? data.outfitId.value : this.outfitId,
      notes: data.notes.present ? data.notes.value : this.notes,
      wasWorn: data.wasWorn.present ? data.wasWorn.value : this.wasWorn,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('outfitId: $outfitId, ')
          ..write('notes: $notes, ')
          ..write('wasWorn: $wasWorn, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, day, outfitId, notes, wasWorn, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.outfitId == this.outfitId &&
          other.notes == this.notes &&
          other.wasWorn == this.wasWorn &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class OutfitPlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<int> id;
  final Value<DateTime> day;
  final Value<int?> outfitId;
  final Value<String?> notes;
  final Value<bool> wasWorn;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  const OutfitPlansCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.outfitId = const Value.absent(),
    this.notes = const Value.absent(),
    this.wasWorn = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutfitPlansCompanion.insert({
    this.id = const Value.absent(),
    required DateTime day,
    this.outfitId = const Value.absent(),
    this.notes = const Value.absent(),
    this.wasWorn = const Value.absent(),
    this.photoPath = const Value.absent(),
    required DateTime createdAt,
  }) : day = Value(day),
       createdAt = Value(createdAt);
  static Insertable<PlanRow> custom({
    Expression<int>? id,
    Expression<DateTime>? day,
    Expression<int>? outfitId,
    Expression<String>? notes,
    Expression<bool>? wasWorn,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (outfitId != null) 'outfit_id': outfitId,
      if (notes != null) 'notes': notes,
      if (wasWorn != null) 'was_worn': wasWorn,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutfitPlansCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? day,
    Value<int?>? outfitId,
    Value<String?>? notes,
    Value<bool>? wasWorn,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
  }) {
    return OutfitPlansCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      outfitId: outfitId ?? this.outfitId,
      notes: notes ?? this.notes,
      wasWorn: wasWorn ?? this.wasWorn,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (outfitId.present) {
      map['outfit_id'] = Variable<int>(outfitId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (wasWorn.present) {
      map['was_worn'] = Variable<bool>(wasWorn.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutfitPlansCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('outfitId: $outfitId, ')
          ..write('notes: $notes, ')
          ..write('wasWorn: $wasWorn, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlanItemsTable extends PlanItems
    with TableInfo<$PlanItemsTable, PlanItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES outfit_plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [planId, garmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planId, garmentId};
  @override
  PlanItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanItem(
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
    );
  }

  @override
  $PlanItemsTable createAlias(String alias) {
    return $PlanItemsTable(attachedDatabase, alias);
  }
}

class PlanItem extends DataClass implements Insertable<PlanItem> {
  final int planId;
  final int garmentId;
  const PlanItem({required this.planId, required this.garmentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_id'] = Variable<int>(planId);
    map['garment_id'] = Variable<int>(garmentId);
    return map;
  }

  PlanItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanItemsCompanion(
      planId: Value(planId),
      garmentId: Value(garmentId),
    );
  }

  factory PlanItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanItem(
      planId: serializer.fromJson<int>(json['planId']),
      garmentId: serializer.fromJson<int>(json['garmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planId': serializer.toJson<int>(planId),
      'garmentId': serializer.toJson<int>(garmentId),
    };
  }

  PlanItem copyWith({int? planId, int? garmentId}) => PlanItem(
    planId: planId ?? this.planId,
    garmentId: garmentId ?? this.garmentId,
  );
  PlanItem copyWithCompanion(PlanItemsCompanion data) {
    return PlanItem(
      planId: data.planId.present ? data.planId.value : this.planId,
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanItem(')
          ..write('planId: $planId, ')
          ..write('garmentId: $garmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(planId, garmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanItem &&
          other.planId == this.planId &&
          other.garmentId == this.garmentId);
}

class PlanItemsCompanion extends UpdateCompanion<PlanItem> {
  final Value<int> planId;
  final Value<int> garmentId;
  final Value<int> rowid;
  const PlanItemsCompanion({
    this.planId = const Value.absent(),
    this.garmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanItemsCompanion.insert({
    required int planId,
    required int garmentId,
    this.rowid = const Value.absent(),
  }) : planId = Value(planId),
       garmentId = Value(garmentId);
  static Insertable<PlanItem> custom({
    Expression<int>? planId,
    Expression<int>? garmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planId != null) 'plan_id': planId,
      if (garmentId != null) 'garment_id': garmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanItemsCompanion copyWith({
    Value<int>? planId,
    Value<int>? garmentId,
    Value<int>? rowid,
  }) {
    return PlanItemsCompanion(
      planId: planId ?? this.planId,
      garmentId: garmentId ?? this.garmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemsCompanion(')
          ..write('planId: $planId, ')
          ..write('garmentId: $garmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LaundryDaysTable extends LaundryDays
    with TableInfo<$LaundryDaysTable, LaundryDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaundryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _washedAtMeta = const VerificationMeta(
    'washedAt',
  );
  @override
  late final GeneratedColumn<DateTime> washedAt = GeneratedColumn<DateTime>(
    'washed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, day, washedAt, notes, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laundry_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<LaundryDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('washed_at')) {
      context.handle(
        _washedAtMeta,
        washedAt.isAcceptableOrUnknown(data['washed_at']!, _washedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_washedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LaundryDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LaundryDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      washedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}washed_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LaundryDaysTable createAlias(String alias) {
    return $LaundryDaysTable(attachedDatabase, alias);
  }
}

class LaundryDayRow extends DataClass implements Insertable<LaundryDayRow> {
  final int id;

  /// Dia normalizado a medianoche. Es la clave: un dia, una lavada.
  final DateTime day;

  /// Momento real de la lavada, con hora.
  ///
  /// Separado de [day] porque comparar contra medianoche daba un falso
  /// positivo en el caso mas comun: te pones algo por la manana, lo lavas
  /// esa tarde, y la prenda seguia saliendo como sucia porque su hora de
  /// uso era posterior a las 00:00 del dia de lavado.
  ///
  /// No lleva default a proposito: siempre se escribe explicitamente. La
  /// migracion que anadio esta columna recrea la tabla en vez de usar
  /// ALTER ADD COLUMN, porque SQLite no acepta anadir una columna NOT NULL
  /// sin default ni con un default no constante.
  final DateTime washedAt;
  final String? notes;
  final DateTime createdAt;
  const LaundryDayRow({
    required this.id,
    required this.day,
    required this.washedAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<DateTime>(day);
    map['washed_at'] = Variable<DateTime>(washedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LaundryDaysCompanion toCompanion(bool nullToAbsent) {
    return LaundryDaysCompanion(
      id: Value(id),
      day: Value(day),
      washedAt: Value(washedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory LaundryDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LaundryDayRow(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<DateTime>(json['day']),
      washedAt: serializer.fromJson<DateTime>(json['washedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<DateTime>(day),
      'washedAt': serializer.toJson<DateTime>(washedAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LaundryDayRow copyWith({
    int? id,
    DateTime? day,
    DateTime? washedAt,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => LaundryDayRow(
    id: id ?? this.id,
    day: day ?? this.day,
    washedAt: washedAt ?? this.washedAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  LaundryDayRow copyWithCompanion(LaundryDaysCompanion data) {
    return LaundryDayRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      washedAt: data.washedAt.present ? data.washedAt.value : this.washedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LaundryDayRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('washedAt: $washedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, washedAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LaundryDayRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.washedAt == this.washedAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class LaundryDaysCompanion extends UpdateCompanion<LaundryDayRow> {
  final Value<int> id;
  final Value<DateTime> day;
  final Value<DateTime> washedAt;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  const LaundryDaysCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.washedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LaundryDaysCompanion.insert({
    this.id = const Value.absent(),
    required DateTime day,
    required DateTime washedAt,
    this.notes = const Value.absent(),
    required DateTime createdAt,
  }) : day = Value(day),
       washedAt = Value(washedAt),
       createdAt = Value(createdAt);
  static Insertable<LaundryDayRow> custom({
    Expression<int>? id,
    Expression<DateTime>? day,
    Expression<DateTime>? washedAt,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (washedAt != null) 'washed_at': washedAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LaundryDaysCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? day,
    Value<DateTime>? washedAt,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
  }) {
    return LaundryDaysCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      washedAt: washedAt ?? this.washedAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (washedAt.present) {
      map['washed_at'] = Variable<DateTime>(washedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaundryDaysCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('washedAt: $washedAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LaundryItemsTable extends LaundryItems
    with TableInfo<$LaundryItemsTable, LaundryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LaundryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _laundryDayIdMeta = const VerificationMeta(
    'laundryDayId',
  );
  @override
  late final GeneratedColumn<int> laundryDayId = GeneratedColumn<int>(
    'laundry_day_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES laundry_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _garmentIdMeta = const VerificationMeta(
    'garmentId',
  );
  @override
  late final GeneratedColumn<int> garmentId = GeneratedColumn<int>(
    'garment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES garments (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [laundryDayId, garmentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'laundry_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LaundryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('laundry_day_id')) {
      context.handle(
        _laundryDayIdMeta,
        laundryDayId.isAcceptableOrUnknown(
          data['laundry_day_id']!,
          _laundryDayIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_laundryDayIdMeta);
    }
    if (data.containsKey('garment_id')) {
      context.handle(
        _garmentIdMeta,
        garmentId.isAcceptableOrUnknown(data['garment_id']!, _garmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_garmentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {laundryDayId, garmentId};
  @override
  LaundryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LaundryItem(
      laundryDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}laundry_day_id'],
      )!,
      garmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}garment_id'],
      )!,
    );
  }

  @override
  $LaundryItemsTable createAlias(String alias) {
    return $LaundryItemsTable(attachedDatabase, alias);
  }
}

class LaundryItem extends DataClass implements Insertable<LaundryItem> {
  final int laundryDayId;
  final int garmentId;
  const LaundryItem({required this.laundryDayId, required this.garmentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['laundry_day_id'] = Variable<int>(laundryDayId);
    map['garment_id'] = Variable<int>(garmentId);
    return map;
  }

  LaundryItemsCompanion toCompanion(bool nullToAbsent) {
    return LaundryItemsCompanion(
      laundryDayId: Value(laundryDayId),
      garmentId: Value(garmentId),
    );
  }

  factory LaundryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LaundryItem(
      laundryDayId: serializer.fromJson<int>(json['laundryDayId']),
      garmentId: serializer.fromJson<int>(json['garmentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'laundryDayId': serializer.toJson<int>(laundryDayId),
      'garmentId': serializer.toJson<int>(garmentId),
    };
  }

  LaundryItem copyWith({int? laundryDayId, int? garmentId}) => LaundryItem(
    laundryDayId: laundryDayId ?? this.laundryDayId,
    garmentId: garmentId ?? this.garmentId,
  );
  LaundryItem copyWithCompanion(LaundryItemsCompanion data) {
    return LaundryItem(
      laundryDayId: data.laundryDayId.present
          ? data.laundryDayId.value
          : this.laundryDayId,
      garmentId: data.garmentId.present ? data.garmentId.value : this.garmentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LaundryItem(')
          ..write('laundryDayId: $laundryDayId, ')
          ..write('garmentId: $garmentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(laundryDayId, garmentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LaundryItem &&
          other.laundryDayId == this.laundryDayId &&
          other.garmentId == this.garmentId);
}

class LaundryItemsCompanion extends UpdateCompanion<LaundryItem> {
  final Value<int> laundryDayId;
  final Value<int> garmentId;
  final Value<int> rowid;
  const LaundryItemsCompanion({
    this.laundryDayId = const Value.absent(),
    this.garmentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LaundryItemsCompanion.insert({
    required int laundryDayId,
    required int garmentId,
    this.rowid = const Value.absent(),
  }) : laundryDayId = Value(laundryDayId),
       garmentId = Value(garmentId);
  static Insertable<LaundryItem> custom({
    Expression<int>? laundryDayId,
    Expression<int>? garmentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (laundryDayId != null) 'laundry_day_id': laundryDayId,
      if (garmentId != null) 'garment_id': garmentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LaundryItemsCompanion copyWith({
    Value<int>? laundryDayId,
    Value<int>? garmentId,
    Value<int>? rowid,
  }) {
    return LaundryItemsCompanion(
      laundryDayId: laundryDayId ?? this.laundryDayId,
      garmentId: garmentId ?? this.garmentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (laundryDayId.present) {
      map['laundry_day_id'] = Variable<int>(laundryDayId.value);
    }
    if (garmentId.present) {
      map['garment_id'] = Variable<int>(garmentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LaundryItemsCompanion(')
          ..write('laundryDayId: $laundryDayId, ')
          ..write('garmentId: $garmentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $OccasionsTable occasions = $OccasionsTable(this);
  late final $MoodsTable moods = $MoodsTable(this);
  late final $WashGroupsTable washGroups = $WashGroupsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $GarmentsTable garments = $GarmentsTable(this);
  late final $GarmentTagsTable garmentTags = $GarmentTagsTable(this);
  late final $GarmentSeasonsTable garmentSeasons = $GarmentSeasonsTable(this);
  late final $GarmentOccasionsTable garmentOccasions = $GarmentOccasionsTable(
    this,
  );
  late final $GarmentMoodsTable garmentMoods = $GarmentMoodsTable(this);
  late final $OutfitsTable outfits = $OutfitsTable(this);
  late final $OutfitItemsTable outfitItems = $OutfitItemsTable(this);
  late final $OutfitPlansTable outfitPlans = $OutfitPlansTable(this);
  late final $PlanItemsTable planItems = $PlanItemsTable(this);
  late final $LaundryDaysTable laundryDays = $LaundryDaysTable(this);
  late final $LaundryItemsTable laundryItems = $LaundryItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    occasions,
    moods,
    washGroups,
    tags,
    garments,
    garmentTags,
    garmentSeasons,
    garmentOccasions,
    garmentMoods,
    outfits,
    outfitItems,
    outfitPlans,
    planItems,
    laundryDays,
    laundryItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wash_groups',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garments', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_seasons', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_occasions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occasions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_occasions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_moods', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'moods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('garment_moods', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'occasions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'moods',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfits', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'outfits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'outfits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outfit_plans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'outfit_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plan_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'laundry_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('laundry_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'garments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('laundry_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String slot,
      Value<int> formality,
      Value<int> warmth,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> slot,
      Value<int> formality,
      Value<int> warmth,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GarmentsTable, List<GarmentRow>>
  _garmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garments,
    aliasName: 'categories__id__garments__category_id',
  );

  $$GarmentsTableProcessedTableManager get garmentsRefs {
    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warmth => $composableBuilder(
    column: $table.warmth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> garmentsRefs(
    Expression<bool> Function($$GarmentsTableFilterComposer f) f,
  ) {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warmth => $composableBuilder(
    column: $table.warmth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
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

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<int> get formality =>
      $composableBuilder(column: $table.formality, builder: (column) => column);

  GeneratedColumn<int> get warmth =>
      $composableBuilder(column: $table.warmth, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> garmentsRefs<T extends Object>(
    Expression<T> Function($$GarmentsTableAnnotationComposer a) f,
  ) {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool garmentsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<int> formality = const Value.absent(),
                Value<int> warmth = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                slot: slot,
                formality: formality,
                warmth: warmth,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String slot,
                Value<int> formality = const Value.absent(),
                Value<int> warmth = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                slot: slot,
                formality: formality,
                warmth: warmth,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (garmentsRefs) db.garments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (garmentsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      GarmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._garmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).garmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool garmentsRefs})
    >;
typedef $$OccasionsTableCreateCompanionBuilder =
    OccasionsCompanion Function({
      Value<int> id,
      required String name,
      Value<int> formality,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });
typedef $$OccasionsTableUpdateCompanionBuilder =
    OccasionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> formality,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });

final class $$OccasionsTableReferences
    extends BaseReferences<_$AppDatabase, $OccasionsTable, OccasionRow> {
  $$OccasionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GarmentOccasionsTable, List<GarmentOccasion>>
  _garmentOccasionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentOccasions,
    aliasName: 'occasions__id__garment_occasions__occasion_id',
  );

  $$GarmentOccasionsTableProcessedTableManager get garmentOccasionsRefs {
    final manager = $$GarmentOccasionsTableTableManager(
      $_db,
      $_db.garmentOccasions,
    ).filter((f) => f.occasionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _garmentOccasionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutfitsTable, List<OutfitRow>> _outfitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.outfits,
    aliasName: 'occasions__id__outfits__occasion_id',
  );

  $$OutfitsTableProcessedTableManager get outfitsRefs {
    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.occasionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OccasionsTableFilterComposer
    extends Composer<_$AppDatabase, $OccasionsTable> {
  $$OccasionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> garmentOccasionsRefs(
    Expression<bool> Function($$GarmentOccasionsTableFilterComposer f) f,
  ) {
    final $$GarmentOccasionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentOccasions,
      getReferencedColumn: (t) => t.occasionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentOccasionsTableFilterComposer(
            $db: $db,
            $table: $db.garmentOccasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outfitsRefs(
    Expression<bool> Function($$OutfitsTableFilterComposer f) f,
  ) {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.occasionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccasionsTableOrderingComposer
    extends Composer<_$AppDatabase, $OccasionsTable> {
  $$OccasionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get formality => $composableBuilder(
    column: $table.formality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OccasionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccasionsTable> {
  $$OccasionsTableAnnotationComposer({
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

  GeneratedColumn<int> get formality =>
      $composableBuilder(column: $table.formality, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> garmentOccasionsRefs<T extends Object>(
    Expression<T> Function($$GarmentOccasionsTableAnnotationComposer a) f,
  ) {
    final $$GarmentOccasionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentOccasions,
      getReferencedColumn: (t) => t.occasionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentOccasionsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentOccasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outfitsRefs<T extends Object>(
    Expression<T> Function($$OutfitsTableAnnotationComposer a) f,
  ) {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.occasionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OccasionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccasionsTable,
          OccasionRow,
          $$OccasionsTableFilterComposer,
          $$OccasionsTableOrderingComposer,
          $$OccasionsTableAnnotationComposer,
          $$OccasionsTableCreateCompanionBuilder,
          $$OccasionsTableUpdateCompanionBuilder,
          (OccasionRow, $$OccasionsTableReferences),
          OccasionRow,
          PrefetchHooks Function({bool garmentOccasionsRefs, bool outfitsRefs})
        > {
  $$OccasionsTableTableManager(_$AppDatabase db, $OccasionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccasionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccasionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccasionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> formality = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => OccasionsCompanion(
                id: id,
                name: name,
                formality: formality,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> formality = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => OccasionsCompanion.insert(
                id: id,
                name: name,
                formality: formality,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OccasionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({garmentOccasionsRefs = false, outfitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (garmentOccasionsRefs) db.garmentOccasions,
                    if (outfitsRefs) db.outfits,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (garmentOccasionsRefs)
                        await $_getPrefetchedData<
                          OccasionRow,
                          $OccasionsTable,
                          GarmentOccasion
                        >(
                          currentTable: table,
                          referencedTable: $$OccasionsTableReferences
                              ._garmentOccasionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OccasionsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentOccasionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occasionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outfitsRefs)
                        await $_getPrefetchedData<
                          OccasionRow,
                          $OccasionsTable,
                          OutfitRow
                        >(
                          currentTable: table,
                          referencedTable: $$OccasionsTableReferences
                              ._outfitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OccasionsTableReferences(
                                db,
                                table,
                                p0,
                              ).outfitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occasionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OccasionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccasionsTable,
      OccasionRow,
      $$OccasionsTableFilterComposer,
      $$OccasionsTableOrderingComposer,
      $$OccasionsTableAnnotationComposer,
      $$OccasionsTableCreateCompanionBuilder,
      $$OccasionsTableUpdateCompanionBuilder,
      (OccasionRow, $$OccasionsTableReferences),
      OccasionRow,
      PrefetchHooks Function({bool garmentOccasionsRefs, bool outfitsRefs})
    >;
typedef $$MoodsTableCreateCompanionBuilder =
    MoodsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });
typedef $$MoodsTableUpdateCompanionBuilder =
    MoodsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });

final class $$MoodsTableReferences
    extends BaseReferences<_$AppDatabase, $MoodsTable, MoodRow> {
  $$MoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GarmentMoodsTable, List<GarmentMood>>
  _garmentMoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentMoods,
    aliasName: 'moods__id__garment_moods__mood_id',
  );

  $$GarmentMoodsTableProcessedTableManager get garmentMoodsRefs {
    final manager = $$GarmentMoodsTableTableManager(
      $_db,
      $_db.garmentMoods,
    ).filter((f) => f.moodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentMoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutfitsTable, List<OutfitRow>> _outfitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.outfits,
    aliasName: 'moods__id__outfits__mood_id',
  );

  $$OutfitsTableProcessedTableManager get outfitsRefs {
    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.moodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MoodsTableFilterComposer extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> garmentMoodsRefs(
    Expression<bool> Function($$GarmentMoodsTableFilterComposer f) f,
  ) {
    final $$GarmentMoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentMoods,
      getReferencedColumn: (t) => t.moodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentMoodsTableFilterComposer(
            $db: $db,
            $table: $db.garmentMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outfitsRefs(
    Expression<bool> Function($$OutfitsTableFilterComposer f) f,
  ) {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.moodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoodsTable> {
  $$MoodsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> garmentMoodsRefs<T extends Object>(
    Expression<T> Function($$GarmentMoodsTableAnnotationComposer a) f,
  ) {
    final $$GarmentMoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentMoods,
      getReferencedColumn: (t) => t.moodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentMoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outfitsRefs<T extends Object>(
    Expression<T> Function($$OutfitsTableAnnotationComposer a) f,
  ) {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.moodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoodsTable,
          MoodRow,
          $$MoodsTableFilterComposer,
          $$MoodsTableOrderingComposer,
          $$MoodsTableAnnotationComposer,
          $$MoodsTableCreateCompanionBuilder,
          $$MoodsTableUpdateCompanionBuilder,
          (MoodRow, $$MoodsTableReferences),
          MoodRow,
          PrefetchHooks Function({bool garmentMoodsRefs, bool outfitsRefs})
        > {
  $$MoodsTableTableManager(_$AppDatabase db, $MoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MoodsCompanion(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => MoodsCompanion.insert(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MoodsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({garmentMoodsRefs = false, outfitsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (garmentMoodsRefs) db.garmentMoods,
                    if (outfitsRefs) db.outfits,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (garmentMoodsRefs)
                        await $_getPrefetchedData<
                          MoodRow,
                          $MoodsTable,
                          GarmentMood
                        >(
                          currentTable: table,
                          referencedTable: $$MoodsTableReferences
                              ._garmentMoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoodsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentMoodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.moodId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outfitsRefs)
                        await $_getPrefetchedData<
                          MoodRow,
                          $MoodsTable,
                          OutfitRow
                        >(
                          currentTable: table,
                          referencedTable: $$MoodsTableReferences
                              ._outfitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MoodsTableReferences(db, table, p0).outfitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.moodId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoodsTable,
      MoodRow,
      $$MoodsTableFilterComposer,
      $$MoodsTableOrderingComposer,
      $$MoodsTableAnnotationComposer,
      $$MoodsTableCreateCompanionBuilder,
      $$MoodsTableUpdateCompanionBuilder,
      (MoodRow, $$MoodsTableReferences),
      MoodRow,
      PrefetchHooks Function({bool garmentMoodsRefs, bool outfitsRefs})
    >;
typedef $$WashGroupsTableCreateCompanionBuilder =
    WashGroupsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });
typedef $$WashGroupsTableUpdateCompanionBuilder =
    WashGroupsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });

final class $$WashGroupsTableReferences
    extends BaseReferences<_$AppDatabase, $WashGroupsTable, WashGroupRow> {
  $$WashGroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GarmentsTable, List<GarmentRow>>
  _garmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garments,
    aliasName: 'wash_groups__id__garments__wash_group_id',
  );

  $$GarmentsTableProcessedTableManager get garmentsRefs {
    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.washGroupId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WashGroupsTableFilterComposer
    extends Composer<_$AppDatabase, $WashGroupsTable> {
  $$WashGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> garmentsRefs(
    Expression<bool> Function($$GarmentsTableFilterComposer f) f,
  ) {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.washGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WashGroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $WashGroupsTable> {
  $$WashGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WashGroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WashGroupsTable> {
  $$WashGroupsTableAnnotationComposer({
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

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> garmentsRefs<T extends Object>(
    Expression<T> Function($$GarmentsTableAnnotationComposer a) f,
  ) {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.washGroupId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WashGroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WashGroupsTable,
          WashGroupRow,
          $$WashGroupsTableFilterComposer,
          $$WashGroupsTableOrderingComposer,
          $$WashGroupsTableAnnotationComposer,
          $$WashGroupsTableCreateCompanionBuilder,
          $$WashGroupsTableUpdateCompanionBuilder,
          (WashGroupRow, $$WashGroupsTableReferences),
          WashGroupRow,
          PrefetchHooks Function({bool garmentsRefs})
        > {
  $$WashGroupsTableTableManager(_$AppDatabase db, $WashGroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WashGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WashGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WashGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WashGroupsCompanion(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => WashGroupsCompanion.insert(
                id: id,
                name: name,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WashGroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (garmentsRefs) db.garments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (garmentsRefs)
                    await $_getPrefetchedData<
                      WashGroupRow,
                      $WashGroupsTable,
                      GarmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$WashGroupsTableReferences
                          ._garmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WashGroupsTableReferences(
                            db,
                            table,
                            p0,
                          ).garmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.washGroupId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WashGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WashGroupsTable,
      WashGroupRow,
      $$WashGroupsTableFilterComposer,
      $$WashGroupsTableOrderingComposer,
      $$WashGroupsTableAnnotationComposer,
      $$WashGroupsTableCreateCompanionBuilder,
      $$WashGroupsTableUpdateCompanionBuilder,
      (WashGroupRow, $$WashGroupsTableReferences),
      WashGroupRow,
      PrefetchHooks Function({bool garmentsRefs})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({Value<int> id, required String name});
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({Value<int> id, Value<String> name});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GarmentTagsTable, List<GarmentTag>>
  _garmentTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentTags,
    aliasName: 'tags__id__garment_tags__tag_id',
  );

  $$GarmentTagsTableProcessedTableManager get garmentTagsRefs {
    final manager = $$GarmentTagsTableTableManager(
      $_db,
      $_db.garmentTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> garmentTagsRefs(
    Expression<bool> Function($$GarmentTagsTableFilterComposer f) f,
  ) {
    final $$GarmentTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentTagsTableFilterComposer(
            $db: $db,
            $table: $db.garmentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
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

  Expression<T> garmentTagsRefs<T extends Object>(
    Expression<T> Function($$GarmentTagsTableAnnotationComposer a) f,
  ) {
    final $$GarmentTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool garmentTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({garmentTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (garmentTagsRefs) db.garmentTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (garmentTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, GarmentTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._garmentTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).garmentTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool garmentTagsRefs})
    >;
typedef $$GarmentsTableCreateCompanionBuilder =
    GarmentsCompanion Function({
      Value<int> id,
      required String imagePath,
      required String thumbPath,
      Value<String?> originalPath,
      required int categoryId,
      required int dominantColorArgb,
      required String colorFamily,
      Value<String> paletteJson,
      Value<String?> name,
      Value<String?> brand,
      Value<String?> notes,
      Value<int?> washGroupId,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> wearCount,
      Value<DateTime?> lastWornAt,
      Value<int> washCount,
      Value<DateTime?> lastWashedAt,
      Value<int> wearsSinceWash,
      required DateTime createdAt,
    });
typedef $$GarmentsTableUpdateCompanionBuilder =
    GarmentsCompanion Function({
      Value<int> id,
      Value<String> imagePath,
      Value<String> thumbPath,
      Value<String?> originalPath,
      Value<int> categoryId,
      Value<int> dominantColorArgb,
      Value<String> colorFamily,
      Value<String> paletteJson,
      Value<String?> name,
      Value<String?> brand,
      Value<String?> notes,
      Value<int?> washGroupId,
      Value<bool> isFavorite,
      Value<bool> isArchived,
      Value<int> wearCount,
      Value<DateTime?> lastWornAt,
      Value<int> washCount,
      Value<DateTime?> lastWashedAt,
      Value<int> wearsSinceWash,
      Value<DateTime> createdAt,
    });

final class $$GarmentsTableReferences
    extends BaseReferences<_$AppDatabase, $GarmentsTable, GarmentRow> {
  $$GarmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('garments__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WashGroupsTable _washGroupIdTable(_$AppDatabase db) =>
      db.washGroups.createAlias('garments__wash_group_id__wash_groups__id');

  $$WashGroupsTableProcessedTableManager? get washGroupId {
    final $_column = $_itemColumn<int>('wash_group_id');
    if ($_column == null) return null;
    final manager = $$WashGroupsTableTableManager(
      $_db,
      $_db.washGroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_washGroupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GarmentTagsTable, List<GarmentTag>>
  _garmentTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentTags,
    aliasName: 'garments__id__garment_tags__garment_id',
  );

  $$GarmentTagsTableProcessedTableManager get garmentTagsRefs {
    final manager = $$GarmentTagsTableTableManager(
      $_db,
      $_db.garmentTags,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GarmentSeasonsTable, List<GarmentSeason>>
  _garmentSeasonsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentSeasons,
    aliasName: 'garments__id__garment_seasons__garment_id',
  );

  $$GarmentSeasonsTableProcessedTableManager get garmentSeasonsRefs {
    final manager = $$GarmentSeasonsTableTableManager(
      $_db,
      $_db.garmentSeasons,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentSeasonsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GarmentOccasionsTable, List<GarmentOccasion>>
  _garmentOccasionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentOccasions,
    aliasName: 'garments__id__garment_occasions__garment_id',
  );

  $$GarmentOccasionsTableProcessedTableManager get garmentOccasionsRefs {
    final manager = $$GarmentOccasionsTableTableManager(
      $_db,
      $_db.garmentOccasions,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _garmentOccasionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GarmentMoodsTable, List<GarmentMood>>
  _garmentMoodsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.garmentMoods,
    aliasName: 'garments__id__garment_moods__garment_id',
  );

  $$GarmentMoodsTableProcessedTableManager get garmentMoodsRefs {
    final manager = $$GarmentMoodsTableTableManager(
      $_db,
      $_db.garmentMoods,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_garmentMoodsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: 'garments__id__outfit_items__garment_id',
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItem>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: 'garments__id__plan_items__garment_id',
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LaundryItemsTable, List<LaundryItem>>
  _laundryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.laundryItems,
    aliasName: 'garments__id__laundry_items__garment_id',
  );

  $$LaundryItemsTableProcessedTableManager get laundryItemsRefs {
    final manager = $$LaundryItemsTableTableManager(
      $_db,
      $_db.laundryItems,
    ).filter((f) => f.garmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_laundryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GarmentsTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentsTable> {
  $$GarmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dominantColorArgb => $composableBuilder(
    column: $table.dominantColorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorFamily => $composableBuilder(
    column: $table.colorFamily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paletteJson => $composableBuilder(
    column: $table.paletteJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get washCount => $composableBuilder(
    column: $table.washCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWashedAt => $composableBuilder(
    column: $table.lastWashedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wearsSinceWash => $composableBuilder(
    column: $table.wearsSinceWash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WashGroupsTableFilterComposer get washGroupId {
    final $$WashGroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.washGroupId,
      referencedTable: $db.washGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WashGroupsTableFilterComposer(
            $db: $db,
            $table: $db.washGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> garmentTagsRefs(
    Expression<bool> Function($$GarmentTagsTableFilterComposer f) f,
  ) {
    final $$GarmentTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentTags,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentTagsTableFilterComposer(
            $db: $db,
            $table: $db.garmentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> garmentSeasonsRefs(
    Expression<bool> Function($$GarmentSeasonsTableFilterComposer f) f,
  ) {
    final $$GarmentSeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentSeasons,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentSeasonsTableFilterComposer(
            $db: $db,
            $table: $db.garmentSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> garmentOccasionsRefs(
    Expression<bool> Function($$GarmentOccasionsTableFilterComposer f) f,
  ) {
    final $$GarmentOccasionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentOccasions,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentOccasionsTableFilterComposer(
            $db: $db,
            $table: $db.garmentOccasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> garmentMoodsRefs(
    Expression<bool> Function($$GarmentMoodsTableFilterComposer f) f,
  ) {
    final $$GarmentMoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentMoods,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentMoodsTableFilterComposer(
            $db: $db,
            $table: $db.garmentMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> laundryItemsRefs(
    Expression<bool> Function($$LaundryItemsTableFilterComposer f) f,
  ) {
    final $$LaundryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laundryItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryItemsTableFilterComposer(
            $db: $db,
            $table: $db.laundryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GarmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentsTable> {
  $$GarmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbPath => $composableBuilder(
    column: $table.thumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dominantColorArgb => $composableBuilder(
    column: $table.dominantColorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorFamily => $composableBuilder(
    column: $table.colorFamily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paletteJson => $composableBuilder(
    column: $table.paletteJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get washCount => $composableBuilder(
    column: $table.washCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWashedAt => $composableBuilder(
    column: $table.lastWashedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wearsSinceWash => $composableBuilder(
    column: $table.wearsSinceWash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WashGroupsTableOrderingComposer get washGroupId {
    final $$WashGroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.washGroupId,
      referencedTable: $db.washGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WashGroupsTableOrderingComposer(
            $db: $db,
            $table: $db.washGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentsTable> {
  $$GarmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get thumbPath =>
      $composableBuilder(column: $table.thumbPath, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
    column: $table.originalPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dominantColorArgb => $composableBuilder(
    column: $table.dominantColorArgb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorFamily => $composableBuilder(
    column: $table.colorFamily,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paletteJson => $composableBuilder(
    column: $table.paletteJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wearCount =>
      $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get washCount =>
      $composableBuilder(column: $table.washCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWashedAt => $composableBuilder(
    column: $table.lastWashedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wearsSinceWash => $composableBuilder(
    column: $table.wearsSinceWash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WashGroupsTableAnnotationComposer get washGroupId {
    final $$WashGroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.washGroupId,
      referencedTable: $db.washGroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WashGroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.washGroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> garmentTagsRefs<T extends Object>(
    Expression<T> Function($$GarmentTagsTableAnnotationComposer a) f,
  ) {
    final $$GarmentTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentTags,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> garmentSeasonsRefs<T extends Object>(
    Expression<T> Function($$GarmentSeasonsTableAnnotationComposer a) f,
  ) {
    final $$GarmentSeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentSeasons,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentSeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> garmentOccasionsRefs<T extends Object>(
    Expression<T> Function($$GarmentOccasionsTableAnnotationComposer a) f,
  ) {
    final $$GarmentOccasionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentOccasions,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentOccasionsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentOccasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> garmentMoodsRefs<T extends Object>(
    Expression<T> Function($$GarmentMoodsTableAnnotationComposer a) f,
  ) {
    final $$GarmentMoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.garmentMoods,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentMoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.garmentMoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> laundryItemsRefs<T extends Object>(
    Expression<T> Function($$LaundryItemsTableAnnotationComposer a) f,
  ) {
    final $$LaundryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laundryItems,
      getReferencedColumn: (t) => t.garmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.laundryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GarmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentsTable,
          GarmentRow,
          $$GarmentsTableFilterComposer,
          $$GarmentsTableOrderingComposer,
          $$GarmentsTableAnnotationComposer,
          $$GarmentsTableCreateCompanionBuilder,
          $$GarmentsTableUpdateCompanionBuilder,
          (GarmentRow, $$GarmentsTableReferences),
          GarmentRow,
          PrefetchHooks Function({
            bool categoryId,
            bool washGroupId,
            bool garmentTagsRefs,
            bool garmentSeasonsRefs,
            bool garmentOccasionsRefs,
            bool garmentMoodsRefs,
            bool outfitItemsRefs,
            bool planItemsRefs,
            bool laundryItemsRefs,
          })
        > {
  $$GarmentsTableTableManager(_$AppDatabase db, $GarmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> thumbPath = const Value.absent(),
                Value<String?> originalPath = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> dominantColorArgb = const Value.absent(),
                Value<String> colorFamily = const Value.absent(),
                Value<String> paletteJson = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> washGroupId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWornAt = const Value.absent(),
                Value<int> washCount = const Value.absent(),
                Value<DateTime?> lastWashedAt = const Value.absent(),
                Value<int> wearsSinceWash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GarmentsCompanion(
                id: id,
                imagePath: imagePath,
                thumbPath: thumbPath,
                originalPath: originalPath,
                categoryId: categoryId,
                dominantColorArgb: dominantColorArgb,
                colorFamily: colorFamily,
                paletteJson: paletteJson,
                name: name,
                brand: brand,
                notes: notes,
                washGroupId: washGroupId,
                isFavorite: isFavorite,
                isArchived: isArchived,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                washCount: washCount,
                lastWashedAt: lastWashedAt,
                wearsSinceWash: wearsSinceWash,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String imagePath,
                required String thumbPath,
                Value<String?> originalPath = const Value.absent(),
                required int categoryId,
                required int dominantColorArgb,
                required String colorFamily,
                Value<String> paletteJson = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> washGroupId = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWornAt = const Value.absent(),
                Value<int> washCount = const Value.absent(),
                Value<DateTime?> lastWashedAt = const Value.absent(),
                Value<int> wearsSinceWash = const Value.absent(),
                required DateTime createdAt,
              }) => GarmentsCompanion.insert(
                id: id,
                imagePath: imagePath,
                thumbPath: thumbPath,
                originalPath: originalPath,
                categoryId: categoryId,
                dominantColorArgb: dominantColorArgb,
                colorFamily: colorFamily,
                paletteJson: paletteJson,
                name: name,
                brand: brand,
                notes: notes,
                washGroupId: washGroupId,
                isFavorite: isFavorite,
                isArchived: isArchived,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                washCount: washCount,
                lastWashedAt: lastWashedAt,
                wearsSinceWash: wearsSinceWash,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GarmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                washGroupId = false,
                garmentTagsRefs = false,
                garmentSeasonsRefs = false,
                garmentOccasionsRefs = false,
                garmentMoodsRefs = false,
                outfitItemsRefs = false,
                planItemsRefs = false,
                laundryItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (garmentTagsRefs) db.garmentTags,
                    if (garmentSeasonsRefs) db.garmentSeasons,
                    if (garmentOccasionsRefs) db.garmentOccasions,
                    if (garmentMoodsRefs) db.garmentMoods,
                    if (outfitItemsRefs) db.outfitItems,
                    if (planItemsRefs) db.planItems,
                    if (laundryItemsRefs) db.laundryItems,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$GarmentsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$GarmentsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (washGroupId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.washGroupId,
                                    referencedTable: $$GarmentsTableReferences
                                        ._washGroupIdTable(db),
                                    referencedColumn: $$GarmentsTableReferences
                                        ._washGroupIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (garmentTagsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          GarmentTag
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._garmentTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (garmentSeasonsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          GarmentSeason
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._garmentSeasonsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentSeasonsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (garmentOccasionsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          GarmentOccasion
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._garmentOccasionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentOccasionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (garmentMoodsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          GarmentMood
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._garmentMoodsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).garmentMoodsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outfitItemsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          OutfitItem
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._outfitItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).outfitItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planItemsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          PlanItem
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._planItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).planItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (laundryItemsRefs)
                        await $_getPrefetchedData<
                          GarmentRow,
                          $GarmentsTable,
                          LaundryItem
                        >(
                          currentTable: table,
                          referencedTable: $$GarmentsTableReferences
                              ._laundryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GarmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).laundryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.garmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GarmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentsTable,
      GarmentRow,
      $$GarmentsTableFilterComposer,
      $$GarmentsTableOrderingComposer,
      $$GarmentsTableAnnotationComposer,
      $$GarmentsTableCreateCompanionBuilder,
      $$GarmentsTableUpdateCompanionBuilder,
      (GarmentRow, $$GarmentsTableReferences),
      GarmentRow,
      PrefetchHooks Function({
        bool categoryId,
        bool washGroupId,
        bool garmentTagsRefs,
        bool garmentSeasonsRefs,
        bool garmentOccasionsRefs,
        bool garmentMoodsRefs,
        bool outfitItemsRefs,
        bool planItemsRefs,
        bool laundryItemsRefs,
      })
    >;
typedef $$GarmentTagsTableCreateCompanionBuilder =
    GarmentTagsCompanion Function({
      required int garmentId,
      required int tagId,
      Value<int> rowid,
    });
typedef $$GarmentTagsTableUpdateCompanionBuilder =
    GarmentTagsCompanion Function({
      Value<int> garmentId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$GarmentTagsTableReferences
    extends BaseReferences<_$AppDatabase, $GarmentTagsTable, GarmentTag> {
  $$GarmentTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('garment_tags__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('garment_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GarmentTagsTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentTagsTable> {
  $$GarmentTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentTagsTable> {
  $$GarmentTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentTagsTable> {
  $$GarmentTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentTagsTable,
          GarmentTag,
          $$GarmentTagsTableFilterComposer,
          $$GarmentTagsTableOrderingComposer,
          $$GarmentTagsTableAnnotationComposer,
          $$GarmentTagsTableCreateCompanionBuilder,
          $$GarmentTagsTableUpdateCompanionBuilder,
          (GarmentTag, $$GarmentTagsTableReferences),
          GarmentTag,
          PrefetchHooks Function({bool garmentId, bool tagId})
        > {
  $$GarmentTagsTableTableManager(_$AppDatabase db, $GarmentTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> garmentId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentTagsCompanion(
                garmentId: garmentId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int garmentId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => GarmentTagsCompanion.insert(
                garmentId: garmentId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GarmentTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$GarmentTagsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn: $$GarmentTagsTableReferences
                                    ._garmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$GarmentTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$GarmentTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GarmentTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentTagsTable,
      GarmentTag,
      $$GarmentTagsTableFilterComposer,
      $$GarmentTagsTableOrderingComposer,
      $$GarmentTagsTableAnnotationComposer,
      $$GarmentTagsTableCreateCompanionBuilder,
      $$GarmentTagsTableUpdateCompanionBuilder,
      (GarmentTag, $$GarmentTagsTableReferences),
      GarmentTag,
      PrefetchHooks Function({bool garmentId, bool tagId})
    >;
typedef $$GarmentSeasonsTableCreateCompanionBuilder =
    GarmentSeasonsCompanion Function({
      required int garmentId,
      required String season,
      Value<int> rowid,
    });
typedef $$GarmentSeasonsTableUpdateCompanionBuilder =
    GarmentSeasonsCompanion Function({
      Value<int> garmentId,
      Value<String> season,
      Value<int> rowid,
    });

final class $$GarmentSeasonsTableReferences
    extends BaseReferences<_$AppDatabase, $GarmentSeasonsTable, GarmentSeason> {
  $$GarmentSeasonsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('garment_seasons__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GarmentSeasonsTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentSeasonsTable> {
  $$GarmentSeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentSeasonsTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentSeasonsTable> {
  $$GarmentSeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentSeasonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentSeasonsTable> {
  $$GarmentSeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentSeasonsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentSeasonsTable,
          GarmentSeason,
          $$GarmentSeasonsTableFilterComposer,
          $$GarmentSeasonsTableOrderingComposer,
          $$GarmentSeasonsTableAnnotationComposer,
          $$GarmentSeasonsTableCreateCompanionBuilder,
          $$GarmentSeasonsTableUpdateCompanionBuilder,
          (GarmentSeason, $$GarmentSeasonsTableReferences),
          GarmentSeason,
          PrefetchHooks Function({bool garmentId})
        > {
  $$GarmentSeasonsTableTableManager(
    _$AppDatabase db,
    $GarmentSeasonsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentSeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentSeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentSeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> garmentId = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentSeasonsCompanion(
                garmentId: garmentId,
                season: season,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int garmentId,
                required String season,
                Value<int> rowid = const Value.absent(),
              }) => GarmentSeasonsCompanion.insert(
                garmentId: garmentId,
                season: season,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GarmentSeasonsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$GarmentSeasonsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn:
                                    $$GarmentSeasonsTableReferences
                                        ._garmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GarmentSeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentSeasonsTable,
      GarmentSeason,
      $$GarmentSeasonsTableFilterComposer,
      $$GarmentSeasonsTableOrderingComposer,
      $$GarmentSeasonsTableAnnotationComposer,
      $$GarmentSeasonsTableCreateCompanionBuilder,
      $$GarmentSeasonsTableUpdateCompanionBuilder,
      (GarmentSeason, $$GarmentSeasonsTableReferences),
      GarmentSeason,
      PrefetchHooks Function({bool garmentId})
    >;
typedef $$GarmentOccasionsTableCreateCompanionBuilder =
    GarmentOccasionsCompanion Function({
      required int garmentId,
      required int occasionId,
      Value<int> rowid,
    });
typedef $$GarmentOccasionsTableUpdateCompanionBuilder =
    GarmentOccasionsCompanion Function({
      Value<int> garmentId,
      Value<int> occasionId,
      Value<int> rowid,
    });

final class $$GarmentOccasionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $GarmentOccasionsTable, GarmentOccasion> {
  $$GarmentOccasionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('garment_occasions__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OccasionsTable _occasionIdTable(_$AppDatabase db) =>
      db.occasions.createAlias('garment_occasions__occasion_id__occasions__id');

  $$OccasionsTableProcessedTableManager get occasionId {
    final $_column = $_itemColumn<int>('occasion_id')!;

    final manager = $$OccasionsTableTableManager(
      $_db,
      $_db.occasions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occasionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GarmentOccasionsTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentOccasionsTable> {
  $$GarmentOccasionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccasionsTableFilterComposer get occasionId {
    final $$OccasionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableFilterComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentOccasionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentOccasionsTable> {
  $$GarmentOccasionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccasionsTableOrderingComposer get occasionId {
    final $$OccasionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableOrderingComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentOccasionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentOccasionsTable> {
  $$GarmentOccasionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OccasionsTableAnnotationComposer get occasionId {
    final $$OccasionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableAnnotationComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentOccasionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentOccasionsTable,
          GarmentOccasion,
          $$GarmentOccasionsTableFilterComposer,
          $$GarmentOccasionsTableOrderingComposer,
          $$GarmentOccasionsTableAnnotationComposer,
          $$GarmentOccasionsTableCreateCompanionBuilder,
          $$GarmentOccasionsTableUpdateCompanionBuilder,
          (GarmentOccasion, $$GarmentOccasionsTableReferences),
          GarmentOccasion,
          PrefetchHooks Function({bool garmentId, bool occasionId})
        > {
  $$GarmentOccasionsTableTableManager(
    _$AppDatabase db,
    $GarmentOccasionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentOccasionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentOccasionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentOccasionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> garmentId = const Value.absent(),
                Value<int> occasionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentOccasionsCompanion(
                garmentId: garmentId,
                occasionId: occasionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int garmentId,
                required int occasionId,
                Value<int> rowid = const Value.absent(),
              }) => GarmentOccasionsCompanion.insert(
                garmentId: garmentId,
                occasionId: occasionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GarmentOccasionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentId = false, occasionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable:
                                    $$GarmentOccasionsTableReferences
                                        ._garmentIdTable(db),
                                referencedColumn:
                                    $$GarmentOccasionsTableReferences
                                        ._garmentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (occasionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.occasionId,
                                referencedTable:
                                    $$GarmentOccasionsTableReferences
                                        ._occasionIdTable(db),
                                referencedColumn:
                                    $$GarmentOccasionsTableReferences
                                        ._occasionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GarmentOccasionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentOccasionsTable,
      GarmentOccasion,
      $$GarmentOccasionsTableFilterComposer,
      $$GarmentOccasionsTableOrderingComposer,
      $$GarmentOccasionsTableAnnotationComposer,
      $$GarmentOccasionsTableCreateCompanionBuilder,
      $$GarmentOccasionsTableUpdateCompanionBuilder,
      (GarmentOccasion, $$GarmentOccasionsTableReferences),
      GarmentOccasion,
      PrefetchHooks Function({bool garmentId, bool occasionId})
    >;
typedef $$GarmentMoodsTableCreateCompanionBuilder =
    GarmentMoodsCompanion Function({
      required int garmentId,
      required int moodId,
      Value<int> rowid,
    });
typedef $$GarmentMoodsTableUpdateCompanionBuilder =
    GarmentMoodsCompanion Function({
      Value<int> garmentId,
      Value<int> moodId,
      Value<int> rowid,
    });

final class $$GarmentMoodsTableReferences
    extends BaseReferences<_$AppDatabase, $GarmentMoodsTable, GarmentMood> {
  $$GarmentMoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('garment_moods__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoodsTable _moodIdTable(_$AppDatabase db) =>
      db.moods.createAlias('garment_moods__mood_id__moods__id');

  $$MoodsTableProcessedTableManager get moodId {
    final $_column = $_itemColumn<int>('mood_id')!;

    final manager = $$MoodsTableTableManager(
      $_db,
      $_db.moods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GarmentMoodsTableFilterComposer
    extends Composer<_$AppDatabase, $GarmentMoodsTable> {
  $$GarmentMoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableFilterComposer get moodId {
    final $$MoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableFilterComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentMoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $GarmentMoodsTable> {
  $$GarmentMoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableOrderingComposer get moodId {
    final $$MoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableOrderingComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentMoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GarmentMoodsTable> {
  $$GarmentMoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableAnnotationComposer get moodId {
    final $$MoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GarmentMoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GarmentMoodsTable,
          GarmentMood,
          $$GarmentMoodsTableFilterComposer,
          $$GarmentMoodsTableOrderingComposer,
          $$GarmentMoodsTableAnnotationComposer,
          $$GarmentMoodsTableCreateCompanionBuilder,
          $$GarmentMoodsTableUpdateCompanionBuilder,
          (GarmentMood, $$GarmentMoodsTableReferences),
          GarmentMood,
          PrefetchHooks Function({bool garmentId, bool moodId})
        > {
  $$GarmentMoodsTableTableManager(_$AppDatabase db, $GarmentMoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GarmentMoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GarmentMoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GarmentMoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> garmentId = const Value.absent(),
                Value<int> moodId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GarmentMoodsCompanion(
                garmentId: garmentId,
                moodId: moodId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int garmentId,
                required int moodId,
                Value<int> rowid = const Value.absent(),
              }) => GarmentMoodsCompanion.insert(
                garmentId: garmentId,
                moodId: moodId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GarmentMoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({garmentId = false, moodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$GarmentMoodsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn: $$GarmentMoodsTableReferences
                                    ._garmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (moodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.moodId,
                                referencedTable: $$GarmentMoodsTableReferences
                                    ._moodIdTable(db),
                                referencedColumn: $$GarmentMoodsTableReferences
                                    ._moodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GarmentMoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GarmentMoodsTable,
      GarmentMood,
      $$GarmentMoodsTableFilterComposer,
      $$GarmentMoodsTableOrderingComposer,
      $$GarmentMoodsTableAnnotationComposer,
      $$GarmentMoodsTableCreateCompanionBuilder,
      $$GarmentMoodsTableUpdateCompanionBuilder,
      (GarmentMood, $$GarmentMoodsTableReferences),
      GarmentMood,
      PrefetchHooks Function({bool garmentId, bool moodId})
    >;
typedef $$OutfitsTableCreateCompanionBuilder =
    OutfitsCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<int?> occasionId,
      Value<int?> moodId,
      Value<String?> notes,
      Value<bool> isFavorite,
      Value<int> wearCount,
      Value<DateTime?> lastWornAt,
      required DateTime createdAt,
    });
typedef $$OutfitsTableUpdateCompanionBuilder =
    OutfitsCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<int?> occasionId,
      Value<int?> moodId,
      Value<String?> notes,
      Value<bool> isFavorite,
      Value<int> wearCount,
      Value<DateTime?> lastWornAt,
      Value<DateTime> createdAt,
    });

final class $$OutfitsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitsTable, OutfitRow> {
  $$OutfitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OccasionsTable _occasionIdTable(_$AppDatabase db) =>
      db.occasions.createAlias('outfits__occasion_id__occasions__id');

  $$OccasionsTableProcessedTableManager? get occasionId {
    final $_column = $_itemColumn<int>('occasion_id');
    if ($_column == null) return null;
    final manager = $$OccasionsTableTableManager(
      $_db,
      $_db.occasions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occasionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MoodsTable _moodIdTable(_$AppDatabase db) =>
      db.moods.createAlias('outfits__mood_id__moods__id');

  $$MoodsTableProcessedTableManager? get moodId {
    final $_column = $_itemColumn<int>('mood_id');
    if ($_column == null) return null;
    final manager = $$MoodsTableTableManager(
      $_db,
      $_db.moods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_moodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OutfitItemsTable, List<OutfitItem>>
  _outfitItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitItems,
    aliasName: 'outfits__id__outfit_items__outfit_id',
  );

  $$OutfitItemsTableProcessedTableManager get outfitItemsRefs {
    final manager = $$OutfitItemsTableTableManager(
      $_db,
      $_db.outfitItems,
    ).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutfitPlansTable, List<PlanRow>>
  _outfitPlansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outfitPlans,
    aliasName: 'outfits__id__outfit_plans__outfit_id',
  );

  $$OutfitPlansTableProcessedTableManager get outfitPlansRefs {
    final manager = $$OutfitPlansTableTableManager(
      $_db,
      $_db.outfitPlans,
    ).filter((f) => f.outfitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outfitPlansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OutfitsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OccasionsTableFilterComposer get occasionId {
    final $$OccasionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableFilterComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableFilterComposer get moodId {
    final $$MoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableFilterComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> outfitItemsRefs(
    Expression<bool> Function($$OutfitItemsTableFilterComposer f) f,
  ) {
    final $$OutfitItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableFilterComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outfitPlansRefs(
    Expression<bool> Function($$OutfitPlansTableFilterComposer f) f,
  ) {
    final $$OutfitPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitPlans,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitPlansTableFilterComposer(
            $db: $db,
            $table: $db.outfitPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wearCount => $composableBuilder(
    column: $table.wearCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OccasionsTableOrderingComposer get occasionId {
    final $$OccasionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableOrderingComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableOrderingComposer get moodId {
    final $$MoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableOrderingComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitsTable> {
  $$OutfitsTableAnnotationComposer({
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

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wearCount =>
      $composableBuilder(column: $table.wearCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastWornAt => $composableBuilder(
    column: $table.lastWornAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OccasionsTableAnnotationComposer get occasionId {
    final $$OccasionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occasionId,
      referencedTable: $db.occasions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OccasionsTableAnnotationComposer(
            $db: $db,
            $table: $db.occasions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MoodsTableAnnotationComposer get moodId {
    final $$MoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.moodId,
      referencedTable: $db.moods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.moods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> outfitItemsRefs<T extends Object>(
    Expression<T> Function($$OutfitItemsTableAnnotationComposer a) f,
  ) {
    final $$OutfitItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitItems,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outfitPlansRefs<T extends Object>(
    Expression<T> Function($$OutfitPlansTableAnnotationComposer a) f,
  ) {
    final $$OutfitPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outfitPlans,
      getReferencedColumn: (t) => t.outfitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitsTable,
          OutfitRow,
          $$OutfitsTableFilterComposer,
          $$OutfitsTableOrderingComposer,
          $$OutfitsTableAnnotationComposer,
          $$OutfitsTableCreateCompanionBuilder,
          $$OutfitsTableUpdateCompanionBuilder,
          (OutfitRow, $$OutfitsTableReferences),
          OutfitRow,
          PrefetchHooks Function({
            bool occasionId,
            bool moodId,
            bool outfitItemsRefs,
            bool outfitPlansRefs,
          })
        > {
  $$OutfitsTableTableManager(_$AppDatabase db, $OutfitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> occasionId = const Value.absent(),
                Value<int?> moodId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWornAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutfitsCompanion(
                id: id,
                name: name,
                occasionId: occasionId,
                moodId: moodId,
                notes: notes,
                isFavorite: isFavorite,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<int?> occasionId = const Value.absent(),
                Value<int?> moodId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> wearCount = const Value.absent(),
                Value<DateTime?> lastWornAt = const Value.absent(),
                required DateTime createdAt,
              }) => OutfitsCompanion.insert(
                id: id,
                name: name,
                occasionId: occasionId,
                moodId: moodId,
                notes: notes,
                isFavorite: isFavorite,
                wearCount: wearCount,
                lastWornAt: lastWornAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutfitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                occasionId = false,
                moodId = false,
                outfitItemsRefs = false,
                outfitPlansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (outfitItemsRefs) db.outfitItems,
                    if (outfitPlansRefs) db.outfitPlans,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (occasionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.occasionId,
                                    referencedTable: $$OutfitsTableReferences
                                        ._occasionIdTable(db),
                                    referencedColumn: $$OutfitsTableReferences
                                        ._occasionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (moodId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.moodId,
                                    referencedTable: $$OutfitsTableReferences
                                        ._moodIdTable(db),
                                    referencedColumn: $$OutfitsTableReferences
                                        ._moodIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (outfitItemsRefs)
                        await $_getPrefetchedData<
                          OutfitRow,
                          $OutfitsTable,
                          OutfitItem
                        >(
                          currentTable: table,
                          referencedTable: $$OutfitsTableReferences
                              ._outfitItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OutfitsTableReferences(
                                db,
                                table,
                                p0,
                              ).outfitItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.outfitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (outfitPlansRefs)
                        await $_getPrefetchedData<
                          OutfitRow,
                          $OutfitsTable,
                          PlanRow
                        >(
                          currentTable: table,
                          referencedTable: $$OutfitsTableReferences
                              ._outfitPlansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OutfitsTableReferences(
                                db,
                                table,
                                p0,
                              ).outfitPlansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.outfitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OutfitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitsTable,
      OutfitRow,
      $$OutfitsTableFilterComposer,
      $$OutfitsTableOrderingComposer,
      $$OutfitsTableAnnotationComposer,
      $$OutfitsTableCreateCompanionBuilder,
      $$OutfitsTableUpdateCompanionBuilder,
      (OutfitRow, $$OutfitsTableReferences),
      OutfitRow,
      PrefetchHooks Function({
        bool occasionId,
        bool moodId,
        bool outfitItemsRefs,
        bool outfitPlansRefs,
      })
    >;
typedef $$OutfitItemsTableCreateCompanionBuilder =
    OutfitItemsCompanion Function({
      required int outfitId,
      required int garmentId,
      required String slot,
      Value<int> rowid,
    });
typedef $$OutfitItemsTableUpdateCompanionBuilder =
    OutfitItemsCompanion Function({
      Value<int> outfitId,
      Value<int> garmentId,
      Value<String> slot,
      Value<int> rowid,
    });

final class $$OutfitItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitItemsTable, OutfitItem> {
  $$OutfitItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) =>
      db.outfits.createAlias('outfit_items__outfit_id__outfits__id');

  $$OutfitsTableProcessedTableManager get outfitId {
    final $_column = $_itemColumn<int>('outfit_id')!;

    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('outfit_items__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OutfitItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableOrderingComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitItemsTable> {
  $$OutfitItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitItemsTable,
          OutfitItem,
          $$OutfitItemsTableFilterComposer,
          $$OutfitItemsTableOrderingComposer,
          $$OutfitItemsTableAnnotationComposer,
          $$OutfitItemsTableCreateCompanionBuilder,
          $$OutfitItemsTableUpdateCompanionBuilder,
          (OutfitItem, $$OutfitItemsTableReferences),
          OutfitItem,
          PrefetchHooks Function({bool outfitId, bool garmentId})
        > {
  $$OutfitItemsTableTableManager(_$AppDatabase db, $OutfitItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> outfitId = const Value.absent(),
                Value<int> garmentId = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion(
                outfitId: outfitId,
                garmentId: garmentId,
                slot: slot,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int outfitId,
                required int garmentId,
                required String slot,
                Value<int> rowid = const Value.absent(),
              }) => OutfitItemsCompanion.insert(
                outfitId: outfitId,
                garmentId: garmentId,
                slot: slot,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutfitItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitId = false, garmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (outfitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.outfitId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._outfitIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$OutfitItemsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn: $$OutfitItemsTableReferences
                                    ._garmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OutfitItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitItemsTable,
      OutfitItem,
      $$OutfitItemsTableFilterComposer,
      $$OutfitItemsTableOrderingComposer,
      $$OutfitItemsTableAnnotationComposer,
      $$OutfitItemsTableCreateCompanionBuilder,
      $$OutfitItemsTableUpdateCompanionBuilder,
      (OutfitItem, $$OutfitItemsTableReferences),
      OutfitItem,
      PrefetchHooks Function({bool outfitId, bool garmentId})
    >;
typedef $$OutfitPlansTableCreateCompanionBuilder =
    OutfitPlansCompanion Function({
      Value<int> id,
      required DateTime day,
      Value<int?> outfitId,
      Value<String?> notes,
      Value<bool> wasWorn,
      Value<String?> photoPath,
      required DateTime createdAt,
    });
typedef $$OutfitPlansTableUpdateCompanionBuilder =
    OutfitPlansCompanion Function({
      Value<int> id,
      Value<DateTime> day,
      Value<int?> outfitId,
      Value<String?> notes,
      Value<bool> wasWorn,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });

final class $$OutfitPlansTableReferences
    extends BaseReferences<_$AppDatabase, $OutfitPlansTable, PlanRow> {
  $$OutfitPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitsTable _outfitIdTable(_$AppDatabase db) =>
      db.outfits.createAlias('outfit_plans__outfit_id__outfits__id');

  $$OutfitsTableProcessedTableManager? get outfitId {
    final $_column = $_itemColumn<int>('outfit_id');
    if ($_column == null) return null;
    final manager = $$OutfitsTableTableManager(
      $_db,
      $_db.outfits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_outfitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanItemsTable, List<PlanItem>>
  _planItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planItems,
    aliasName: 'outfit_plans__id__plan_items__plan_id',
  );

  $$PlanItemsTableProcessedTableManager get planItemsRefs {
    final manager = $$PlanItemsTableTableManager(
      $_db,
      $_db.planItems,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OutfitPlansTableFilterComposer
    extends Composer<_$AppDatabase, $OutfitPlansTable> {
  $$OutfitPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasWorn => $composableBuilder(
    column: $table.wasWorn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OutfitsTableFilterComposer get outfitId {
    final $$OutfitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableFilterComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planItemsRefs(
    Expression<bool> Function($$PlanItemsTableFilterComposer f) f,
  ) {
    final $$PlanItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableFilterComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $OutfitPlansTable> {
  $$OutfitPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasWorn => $composableBuilder(
    column: $table.wasWorn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OutfitsTableOrderingComposer get outfitId {
    final $$OutfitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableOrderingComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutfitPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutfitPlansTable> {
  $$OutfitPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get wasWorn =>
      $composableBuilder(column: $table.wasWorn, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OutfitsTableAnnotationComposer get outfitId {
    final $$OutfitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.outfitId,
      referencedTable: $db.outfits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitsTableAnnotationComposer(
            $db: $db,
            $table: $db.outfits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planItemsRefs<T extends Object>(
    Expression<T> Function($$PlanItemsTableAnnotationComposer a) f,
  ) {
    final $$PlanItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planItems,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.planItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OutfitPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutfitPlansTable,
          PlanRow,
          $$OutfitPlansTableFilterComposer,
          $$OutfitPlansTableOrderingComposer,
          $$OutfitPlansTableAnnotationComposer,
          $$OutfitPlansTableCreateCompanionBuilder,
          $$OutfitPlansTableUpdateCompanionBuilder,
          (PlanRow, $$OutfitPlansTableReferences),
          PlanRow,
          PrefetchHooks Function({bool outfitId, bool planItemsRefs})
        > {
  $$OutfitPlansTableTableManager(_$AppDatabase db, $OutfitPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutfitPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutfitPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutfitPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<int?> outfitId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> wasWorn = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutfitPlansCompanion(
                id: id,
                day: day,
                outfitId: outfitId,
                notes: notes,
                wasWorn: wasWorn,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime day,
                Value<int?> outfitId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> wasWorn = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                required DateTime createdAt,
              }) => OutfitPlansCompanion.insert(
                id: id,
                day: day,
                outfitId: outfitId,
                notes: notes,
                wasWorn: wasWorn,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OutfitPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({outfitId = false, planItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (planItemsRefs) db.planItems],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (outfitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.outfitId,
                                referencedTable: $$OutfitPlansTableReferences
                                    ._outfitIdTable(db),
                                referencedColumn: $$OutfitPlansTableReferences
                                    ._outfitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planItemsRefs)
                    await $_getPrefetchedData<
                      PlanRow,
                      $OutfitPlansTable,
                      PlanItem
                    >(
                      currentTable: table,
                      referencedTable: $$OutfitPlansTableReferences
                          ._planItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$OutfitPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).planItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OutfitPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutfitPlansTable,
      PlanRow,
      $$OutfitPlansTableFilterComposer,
      $$OutfitPlansTableOrderingComposer,
      $$OutfitPlansTableAnnotationComposer,
      $$OutfitPlansTableCreateCompanionBuilder,
      $$OutfitPlansTableUpdateCompanionBuilder,
      (PlanRow, $$OutfitPlansTableReferences),
      PlanRow,
      PrefetchHooks Function({bool outfitId, bool planItemsRefs})
    >;
typedef $$PlanItemsTableCreateCompanionBuilder =
    PlanItemsCompanion Function({
      required int planId,
      required int garmentId,
      Value<int> rowid,
    });
typedef $$PlanItemsTableUpdateCompanionBuilder =
    PlanItemsCompanion Function({
      Value<int> planId,
      Value<int> garmentId,
      Value<int> rowid,
    });

final class $$PlanItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItem> {
  $$PlanItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OutfitPlansTable _planIdTable(_$AppDatabase db) =>
      db.outfitPlans.createAlias('plan_items__plan_id__outfit_plans__id');

  $$OutfitPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$OutfitPlansTableTableManager(
      $_db,
      $_db.outfitPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('plan_items__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OutfitPlansTableFilterComposer get planId {
    final $$OutfitPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.outfitPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitPlansTableFilterComposer(
            $db: $db,
            $table: $db.outfitPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OutfitPlansTableOrderingComposer get planId {
    final $$OutfitPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.outfitPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitPlansTableOrderingComposer(
            $db: $db,
            $table: $db.outfitPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OutfitPlansTableAnnotationComposer get planId {
    final $$OutfitPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.outfitPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutfitPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.outfitPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanItemsTable,
          PlanItem,
          $$PlanItemsTableFilterComposer,
          $$PlanItemsTableOrderingComposer,
          $$PlanItemsTableAnnotationComposer,
          $$PlanItemsTableCreateCompanionBuilder,
          $$PlanItemsTableUpdateCompanionBuilder,
          (PlanItem, $$PlanItemsTableReferences),
          PlanItem,
          PrefetchHooks Function({bool planId, bool garmentId})
        > {
  $$PlanItemsTableTableManager(_$AppDatabase db, $PlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> planId = const Value.absent(),
                Value<int> garmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion(
                planId: planId,
                garmentId: garmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int planId,
                required int garmentId,
                Value<int> rowid = const Value.absent(),
              }) => PlanItemsCompanion.insert(
                planId: planId,
                garmentId: garmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlanItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planId = false, garmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (planId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.planId,
                                referencedTable: $$PlanItemsTableReferences
                                    ._planIdTable(db),
                                referencedColumn: $$PlanItemsTableReferences
                                    ._planIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$PlanItemsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn: $$PlanItemsTableReferences
                                    ._garmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanItemsTable,
      PlanItem,
      $$PlanItemsTableFilterComposer,
      $$PlanItemsTableOrderingComposer,
      $$PlanItemsTableAnnotationComposer,
      $$PlanItemsTableCreateCompanionBuilder,
      $$PlanItemsTableUpdateCompanionBuilder,
      (PlanItem, $$PlanItemsTableReferences),
      PlanItem,
      PrefetchHooks Function({bool planId, bool garmentId})
    >;
typedef $$LaundryDaysTableCreateCompanionBuilder =
    LaundryDaysCompanion Function({
      Value<int> id,
      required DateTime day,
      required DateTime washedAt,
      Value<String?> notes,
      required DateTime createdAt,
    });
typedef $$LaundryDaysTableUpdateCompanionBuilder =
    LaundryDaysCompanion Function({
      Value<int> id,
      Value<DateTime> day,
      Value<DateTime> washedAt,
      Value<String?> notes,
      Value<DateTime> createdAt,
    });

final class $$LaundryDaysTableReferences
    extends BaseReferences<_$AppDatabase, $LaundryDaysTable, LaundryDayRow> {
  $$LaundryDaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LaundryItemsTable, List<LaundryItem>>
  _laundryItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.laundryItems,
    aliasName: 'laundry_days__id__laundry_items__laundry_day_id',
  );

  $$LaundryItemsTableProcessedTableManager get laundryItemsRefs {
    final manager = $$LaundryItemsTableTableManager(
      $_db,
      $_db.laundryItems,
    ).filter((f) => f.laundryDayId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_laundryItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LaundryDaysTableFilterComposer
    extends Composer<_$AppDatabase, $LaundryDaysTable> {
  $$LaundryDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get washedAt => $composableBuilder(
    column: $table.washedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> laundryItemsRefs(
    Expression<bool> Function($$LaundryItemsTableFilterComposer f) f,
  ) {
    final $$LaundryItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laundryItems,
      getReferencedColumn: (t) => t.laundryDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryItemsTableFilterComposer(
            $db: $db,
            $table: $db.laundryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LaundryDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $LaundryDaysTable> {
  $$LaundryDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get washedAt => $composableBuilder(
    column: $table.washedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LaundryDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaundryDaysTable> {
  $$LaundryDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get washedAt =>
      $composableBuilder(column: $table.washedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> laundryItemsRefs<T extends Object>(
    Expression<T> Function($$LaundryItemsTableAnnotationComposer a) f,
  ) {
    final $$LaundryItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.laundryItems,
      getReferencedColumn: (t) => t.laundryDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.laundryItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LaundryDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LaundryDaysTable,
          LaundryDayRow,
          $$LaundryDaysTableFilterComposer,
          $$LaundryDaysTableOrderingComposer,
          $$LaundryDaysTableAnnotationComposer,
          $$LaundryDaysTableCreateCompanionBuilder,
          $$LaundryDaysTableUpdateCompanionBuilder,
          (LaundryDayRow, $$LaundryDaysTableReferences),
          LaundryDayRow,
          PrefetchHooks Function({bool laundryItemsRefs})
        > {
  $$LaundryDaysTableTableManager(_$AppDatabase db, $LaundryDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaundryDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaundryDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaundryDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<DateTime> washedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LaundryDaysCompanion(
                id: id,
                day: day,
                washedAt: washedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime day,
                required DateTime washedAt,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
              }) => LaundryDaysCompanion.insert(
                id: id,
                day: day,
                washedAt: washedAt,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LaundryDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({laundryItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (laundryItemsRefs) db.laundryItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (laundryItemsRefs)
                    await $_getPrefetchedData<
                      LaundryDayRow,
                      $LaundryDaysTable,
                      LaundryItem
                    >(
                      currentTable: table,
                      referencedTable: $$LaundryDaysTableReferences
                          ._laundryItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LaundryDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).laundryItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.laundryDayId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LaundryDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LaundryDaysTable,
      LaundryDayRow,
      $$LaundryDaysTableFilterComposer,
      $$LaundryDaysTableOrderingComposer,
      $$LaundryDaysTableAnnotationComposer,
      $$LaundryDaysTableCreateCompanionBuilder,
      $$LaundryDaysTableUpdateCompanionBuilder,
      (LaundryDayRow, $$LaundryDaysTableReferences),
      LaundryDayRow,
      PrefetchHooks Function({bool laundryItemsRefs})
    >;
typedef $$LaundryItemsTableCreateCompanionBuilder =
    LaundryItemsCompanion Function({
      required int laundryDayId,
      required int garmentId,
      Value<int> rowid,
    });
typedef $$LaundryItemsTableUpdateCompanionBuilder =
    LaundryItemsCompanion Function({
      Value<int> laundryDayId,
      Value<int> garmentId,
      Value<int> rowid,
    });

final class $$LaundryItemsTableReferences
    extends BaseReferences<_$AppDatabase, $LaundryItemsTable, LaundryItem> {
  $$LaundryItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LaundryDaysTable _laundryDayIdTable(_$AppDatabase db) => db
      .laundryDays
      .createAlias('laundry_items__laundry_day_id__laundry_days__id');

  $$LaundryDaysTableProcessedTableManager get laundryDayId {
    final $_column = $_itemColumn<int>('laundry_day_id')!;

    final manager = $$LaundryDaysTableTableManager(
      $_db,
      $_db.laundryDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_laundryDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GarmentsTable _garmentIdTable(_$AppDatabase db) =>
      db.garments.createAlias('laundry_items__garment_id__garments__id');

  $$GarmentsTableProcessedTableManager get garmentId {
    final $_column = $_itemColumn<int>('garment_id')!;

    final manager = $$GarmentsTableTableManager(
      $_db,
      $_db.garments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_garmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LaundryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LaundryItemsTable> {
  $$LaundryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LaundryDaysTableFilterComposer get laundryDayId {
    final $$LaundryDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.laundryDayId,
      referencedTable: $db.laundryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryDaysTableFilterComposer(
            $db: $db,
            $table: $db.laundryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableFilterComposer get garmentId {
    final $$GarmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableFilterComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaundryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LaundryItemsTable> {
  $$LaundryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LaundryDaysTableOrderingComposer get laundryDayId {
    final $$LaundryDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.laundryDayId,
      referencedTable: $db.laundryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryDaysTableOrderingComposer(
            $db: $db,
            $table: $db.laundryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableOrderingComposer get garmentId {
    final $$GarmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableOrderingComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaundryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LaundryItemsTable> {
  $$LaundryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$LaundryDaysTableAnnotationComposer get laundryDayId {
    final $$LaundryDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.laundryDayId,
      referencedTable: $db.laundryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LaundryDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.laundryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GarmentsTableAnnotationComposer get garmentId {
    final $$GarmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.garmentId,
      referencedTable: $db.garments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GarmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.garments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LaundryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LaundryItemsTable,
          LaundryItem,
          $$LaundryItemsTableFilterComposer,
          $$LaundryItemsTableOrderingComposer,
          $$LaundryItemsTableAnnotationComposer,
          $$LaundryItemsTableCreateCompanionBuilder,
          $$LaundryItemsTableUpdateCompanionBuilder,
          (LaundryItem, $$LaundryItemsTableReferences),
          LaundryItem,
          PrefetchHooks Function({bool laundryDayId, bool garmentId})
        > {
  $$LaundryItemsTableTableManager(_$AppDatabase db, $LaundryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LaundryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LaundryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LaundryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> laundryDayId = const Value.absent(),
                Value<int> garmentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LaundryItemsCompanion(
                laundryDayId: laundryDayId,
                garmentId: garmentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int laundryDayId,
                required int garmentId,
                Value<int> rowid = const Value.absent(),
              }) => LaundryItemsCompanion.insert(
                laundryDayId: laundryDayId,
                garmentId: garmentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LaundryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({laundryDayId = false, garmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (laundryDayId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.laundryDayId,
                                referencedTable: $$LaundryItemsTableReferences
                                    ._laundryDayIdTable(db),
                                referencedColumn: $$LaundryItemsTableReferences
                                    ._laundryDayIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (garmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.garmentId,
                                referencedTable: $$LaundryItemsTableReferences
                                    ._garmentIdTable(db),
                                referencedColumn: $$LaundryItemsTableReferences
                                    ._garmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LaundryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LaundryItemsTable,
      LaundryItem,
      $$LaundryItemsTableFilterComposer,
      $$LaundryItemsTableOrderingComposer,
      $$LaundryItemsTableAnnotationComposer,
      $$LaundryItemsTableCreateCompanionBuilder,
      $$LaundryItemsTableUpdateCompanionBuilder,
      (LaundryItem, $$LaundryItemsTableReferences),
      LaundryItem,
      PrefetchHooks Function({bool laundryDayId, bool garmentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$OccasionsTableTableManager get occasions =>
      $$OccasionsTableTableManager(_db, _db.occasions);
  $$MoodsTableTableManager get moods =>
      $$MoodsTableTableManager(_db, _db.moods);
  $$WashGroupsTableTableManager get washGroups =>
      $$WashGroupsTableTableManager(_db, _db.washGroups);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$GarmentsTableTableManager get garments =>
      $$GarmentsTableTableManager(_db, _db.garments);
  $$GarmentTagsTableTableManager get garmentTags =>
      $$GarmentTagsTableTableManager(_db, _db.garmentTags);
  $$GarmentSeasonsTableTableManager get garmentSeasons =>
      $$GarmentSeasonsTableTableManager(_db, _db.garmentSeasons);
  $$GarmentOccasionsTableTableManager get garmentOccasions =>
      $$GarmentOccasionsTableTableManager(_db, _db.garmentOccasions);
  $$GarmentMoodsTableTableManager get garmentMoods =>
      $$GarmentMoodsTableTableManager(_db, _db.garmentMoods);
  $$OutfitsTableTableManager get outfits =>
      $$OutfitsTableTableManager(_db, _db.outfits);
  $$OutfitItemsTableTableManager get outfitItems =>
      $$OutfitItemsTableTableManager(_db, _db.outfitItems);
  $$OutfitPlansTableTableManager get outfitPlans =>
      $$OutfitPlansTableTableManager(_db, _db.outfitPlans);
  $$PlanItemsTableTableManager get planItems =>
      $$PlanItemsTableTableManager(_db, _db.planItems);
  $$LaundryDaysTableTableManager get laundryDays =>
      $$LaundryDaysTableTableManager(_db, _db.laundryDays);
  $$LaundryItemsTableTableManager get laundryItems =>
      $$LaundryItemsTableTableManager(_db, _db.laundryItems);
}
