// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Item extends DataClass implements Insertable<Item> {
  final int? rowId;
  final String id;
  final String type;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateServerModified;
  final bool deleted;

  Item(
      {this.rowId,
      required this.id,
      required this.type,
      required this.dateCreated,
      required this.dateModified,
      this.dateServerModified,
      required this.deleted});

  factory Item.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Item(
      rowId: intType.mapFromDatabaseResponse(data['${effectivePrefix}row_id']),
      id: stringType.mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      type: stringType.mapFromDatabaseResponse(data['${effectivePrefix}type'])!,
      dateCreated: dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}dateCreated'])!,
      dateModified: dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}dateModified'])!,
      dateServerModified:
          dateTimeType.mapFromDatabaseResponse(data['${effectivePrefix}dateServerModified']),
      deleted: boolType.mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || rowId != null) {
      map['row_id'] = Variable<int?>(rowId);
    }
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['dateCreated'] = Variable<DateTime>(dateCreated);
    map['dateModified'] = Variable<DateTime>(dateModified);
    if (!nullToAbsent || dateServerModified != null) {
      map['dateServerModified'] = Variable<DateTime?>(dateServerModified);
    }
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      rowId: rowId == null && nullToAbsent ? const Value.absent() : Value(rowId),
      id: Value(id),
      type: Value(type),
      dateCreated: Value(dateCreated),
      dateModified: Value(dateModified),
      dateServerModified: dateServerModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateServerModified),
      deleted: Value(deleted),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Item(
      rowId: serializer.fromJson<int?>(json['row_id']),
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateModified: serializer.fromJson<DateTime>(json['dateModified']),
      dateServerModified: serializer.fromJson<DateTime?>(json['dateServerModified']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'row_id': serializer.toJson<int?>(rowId),
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateModified': serializer.toJson<DateTime>(dateModified),
      'dateServerModified': serializer.toJson<DateTime?>(dateServerModified),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Item copyWith(
          {int? rowId,
          String? id,
          String? type,
          DateTime? dateCreated,
          DateTime? dateModified,
          DateTime? dateServerModified,
          bool? deleted}) =>
      Item(
        rowId: rowId ?? this.rowId,
        id: id ?? this.id,
        type: type ?? this.type,
        dateCreated: dateCreated ?? this.dateCreated,
        dateModified: dateModified ?? this.dateModified,
        dateServerModified: dateServerModified ?? this.dateServerModified,
        deleted: deleted ?? this.deleted,
      );
  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('rowId: $rowId, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateModified: $dateModified, ')
          ..write('dateServerModified: $dateServerModified, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      rowId.hashCode,
      $mrjc(
          id.hashCode,
          $mrjc(
              type.hashCode,
              $mrjc(
                  dateCreated.hashCode,
                  $mrjc(dateModified.hashCode,
                      $mrjc(dateServerModified.hashCode, deleted.hashCode)))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Item &&
          other.rowId == this.rowId &&
          other.id == this.id &&
          other.type == this.type &&
          other.dateCreated == this.dateCreated &&
          other.dateModified == this.dateModified &&
          other.dateServerModified == this.dateServerModified &&
          other.deleted == this.deleted);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int?> rowId;
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateModified;
  final Value<DateTime?> dateServerModified;
  final Value<bool> deleted;
  const ItemsCompanion({
    this.rowId = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.dateServerModified = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.rowId = const Value.absent(),
    required String id,
    required String type,
    required DateTime dateCreated,
    required DateTime dateModified,
    this.dateServerModified = const Value.absent(),
    this.deleted = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        dateCreated = Value(dateCreated),
        dateModified = Value(dateModified);
  static Insertable<Item> custom({
    Expression<int?>? rowId,
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateModified,
    Expression<DateTime?>? dateServerModified,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (dateModified != null) 'dateModified': dateModified,
      if (dateServerModified != null) 'dateServerModified': dateServerModified,
      if (deleted != null) 'deleted': deleted,
    });
  }

  ItemsCompanion copyWith(
      {Value<int?>? rowId,
      Value<String>? id,
      Value<String>? type,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateModified,
      Value<DateTime?>? dateServerModified,
      Value<bool>? deleted}) {
    return ItemsCompanion(
      rowId: rowId ?? this.rowId,
      id: id ?? this.id,
      type: type ?? this.type,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateServerModified: dateServerModified ?? this.dateServerModified,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int?>(rowId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dateCreated.present) {
      map['dateCreated'] = Variable<DateTime>(dateCreated.value);
    }
    if (dateModified.present) {
      map['dateModified'] = Variable<DateTime>(dateModified.value);
    }
    if (dateServerModified.present) {
      map['dateServerModified'] = Variable<DateTime?>(dateServerModified.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('dateCreated: $dateCreated, ')
          ..write('dateModified: $dateModified, ')
          ..write('dateServerModified: $dateServerModified, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class Items extends Table with TableInfo<Items, Item> {
  final GeneratedDatabase _db;
  final String? _alias;
  Items(this._db, [this._alias]);
  final VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  late final GeneratedIntColumn rowId = _constructRowId();
  GeneratedIntColumn _constructRowId() {
    return GeneratedIntColumn('row_id', $tableName, true,
        declaredAsPrimaryKey: true, $customConstraints: 'PRIMARY KEY');
  }

  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedTextColumn id = _constructId();
  GeneratedTextColumn _constructId() {
    return GeneratedTextColumn('id', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedTextColumn type = _constructType();

  GeneratedTextColumn _constructType() {
    return GeneratedTextColumn('type', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _dateCreatedMeta = const VerificationMeta('dateCreated');
  late final GeneratedDateTimeColumn dateCreated = _constructDateCreated();

  GeneratedDateTimeColumn _constructDateCreated() {
    return GeneratedDateTimeColumn('dateCreated', $tableName, false,
        $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _dateModifiedMeta = const VerificationMeta('dateModified');
  late final GeneratedDateTimeColumn dateModified = _constructDateModified();

  GeneratedDateTimeColumn _constructDateModified() {
    return GeneratedDateTimeColumn('dateModified', $tableName, false,
        $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _dateServerModifiedMeta = const VerificationMeta('dateServerModified');
  late final GeneratedDateTimeColumn dateServerModified = _constructDateServerModified();

  GeneratedDateTimeColumn _constructDateServerModified() {
    return GeneratedDateTimeColumn('dateServerModified', $tableName, true, $customConstraints: '');
  }

  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedBoolColumn deleted = _constructDeleted();

  GeneratedBoolColumn _constructDeleted() {
    return GeneratedBoolColumn('deleted', $tableName, false,
        $customConstraints: 'NOT NULL DEFAULT false',
        defaultValue: const CustomExpression<bool>('false'));
  }

  @override
  List<GeneratedColumn> get $columns =>
      [rowId, id, type, dateCreated, dateModified, dateServerModified, deleted];
  @override
  Items get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'items';
  @override
  final String actualTableName = 'items';

  @override
  VerificationContext validateIntegrity(Insertable<Item> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(_rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('dateCreated')) {
      context.handle(_dateCreatedMeta,
          dateCreated.isAcceptableOrUnknown(data['dateCreated']!, _dateCreatedMeta));
    } else if (isInserting) {
      context.missing(_dateCreatedMeta);
    }
    if (data.containsKey('dateModified')) {
      context.handle(_dateModifiedMeta,
          dateModified.isAcceptableOrUnknown(data['dateModified']!, _dateModifiedMeta));
    } else if (isInserting) {
      context.missing(_dateModifiedMeta);
    }
    if (data.containsKey('dateServerModified')) {
      context.handle(
          _dateServerModifiedMeta,
          dateServerModified.isAcceptableOrUnknown(
              data['dateServerModified']!, _dateServerModifiedMeta));
    }
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Item.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Items createAlias(String alias) {
    return Items(_db, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Edge extends DataClass implements Insertable<Edge> {
  final int? self;
  final int source;
  final String name;
  final int target;

  Edge({this.self, required this.source, required this.name, required this.target});

  factory Edge.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Edge(
      self: intType.mapFromDatabaseResponse(data['${effectivePrefix}self']),
      source: intType.mapFromDatabaseResponse(data['${effectivePrefix}source'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      target: intType.mapFromDatabaseResponse(data['${effectivePrefix}target'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || self != null) {
      map['self'] = Variable<int?>(self);
    }
    map['source'] = Variable<int>(source);
    map['name'] = Variable<String>(name);
    map['target'] = Variable<int>(target);
    return map;
  }

  EdgesCompanion toCompanion(bool nullToAbsent) {
    return EdgesCompanion(
      self: self == null && nullToAbsent ? const Value.absent() : Value(self),
      source: Value(source),
      name: Value(name),
      target: Value(target),
    );
  }

  factory Edge.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Edge(
      self: serializer.fromJson<int?>(json['self']),
      source: serializer.fromJson<int>(json['source']),
      name: serializer.fromJson<String>(json['name']),
      target: serializer.fromJson<int>(json['target']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'self': serializer.toJson<int?>(self),
      'source': serializer.toJson<int>(source),
      'name': serializer.toJson<String>(name),
      'target': serializer.toJson<int>(target),
    };
  }

  Edge copyWith({int? self, int? source, String? name, int? target}) => Edge(
        self: self ?? this.self,
        source: source ?? this.source,
        name: name ?? this.name,
        target: target ?? this.target,
      );
  @override
  String toString() {
    return (StringBuffer('Edge(')
          ..write('self: $self, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      $mrjf($mrjc(self.hashCode, $mrjc(source.hashCode, $mrjc(name.hashCode, target.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Edge &&
          other.self == this.self &&
          other.source == this.source &&
          other.name == this.name &&
          other.target == this.target);
}

class EdgesCompanion extends UpdateCompanion<Edge> {
  final Value<int?> self;
  final Value<int> source;
  final Value<String> name;
  final Value<int> target;
  const EdgesCompanion({
    this.self = const Value.absent(),
    this.source = const Value.absent(),
    this.name = const Value.absent(),
    this.target = const Value.absent(),
  });
  EdgesCompanion.insert({
    this.self = const Value.absent(),
    required int source,
    required String name,
    required int target,
  })   : source = Value(source),
        name = Value(name),
        target = Value(target);
  static Insertable<Edge> custom({
    Expression<int?>? self,
    Expression<int>? source,
    Expression<String>? name,
    Expression<int>? target,
  }) {
    return RawValuesInsertable({
      if (self != null) 'self': self,
      if (source != null) 'source': source,
      if (name != null) 'name': name,
      if (target != null) 'target': target,
    });
  }

  EdgesCompanion copyWith(
      {Value<int?>? self, Value<int>? source, Value<String>? name, Value<int>? target}) {
    return EdgesCompanion(
      self: self ?? this.self,
      source: source ?? this.source,
      name: name ?? this.name,
      target: target ?? this.target,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (self.present) {
      map['self'] = Variable<int?>(self.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(source.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EdgesCompanion(')
          ..write('self: $self, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('target: $target')
          ..write(')'))
        .toString();
  }
}

class Edges extends Table with TableInfo<Edges, Edge> {
  final GeneratedDatabase _db;
  final String? _alias;
  Edges(this._db, [this._alias]);
  final VerificationMeta _selfMeta = const VerificationMeta('self');
  late final GeneratedIntColumn self = _constructSelf();
  GeneratedIntColumn _constructSelf() {
    return GeneratedIntColumn('self', $tableName, true,
        declaredAsPrimaryKey: true, $customConstraints: 'PRIMARY KEY');
  }

  final VerificationMeta _sourceMeta = const VerificationMeta('source');
  late final GeneratedIntColumn source = _constructSource();
  GeneratedIntColumn _constructSource() {
    return GeneratedIntColumn('source', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _targetMeta = const VerificationMeta('target');
  late final GeneratedIntColumn target = _constructTarget();
  GeneratedIntColumn _constructTarget() {
    return GeneratedIntColumn('target', $tableName, false, $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [self, source, name, target];
  @override
  Edges get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'edges';
  @override
  final String actualTableName = 'edges';

  @override
  VerificationContext validateIntegrity(Insertable<Edge> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('self')) {
      context.handle(_selfMeta, self.isAcceptableOrUnknown(data['self']!, _selfMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target')) {
      context.handle(_targetMeta, target.isAcceptableOrUnknown(data['target']!, _targetMeta));
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {self};
  @override
  Edge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Edge.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Edges createAlias(String alias) {
    return Edges(_db, alias);
  }

  @override
  List<String> get customConstraints => const [
        'FOREIGN KEY (source) REFERENCES items (row_id)',
        'FOREIGN KEY (target) REFERENCES items (row_id)',
        'FOREIGN KEY (self) REFERENCES items (row_id)'
      ];
  @override
  bool get dontWriteConstraints => true;
}

class IntegerDb extends DataClass implements Insertable<IntegerDb> {
  final int item;
  final String name;
  final int value;

  IntegerDb({required this.item, required this.name, required this.value});

  factory IntegerDb.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return IntegerDb(
      item: intType.mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: intType.mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item'] = Variable<int>(item);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<int>(value);
    return map;
  }

  IntegersCompanion toCompanion(bool nullToAbsent) {
    return IntegersCompanion(
      item: Value(item),
      name: Value(name),
      value: Value(value),
    );
  }

  factory IntegerDb.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return IntegerDb(
      item: serializer.fromJson<int>(json['item']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<int>(json['value']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'item': serializer.toJson<int>(item),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<int>(value),
    };
  }

  IntegerDb copyWith({int? item, String? name, int? value}) => IntegerDb(
        item: item ?? this.item,
        name: name ?? this.name,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('IntegerDb(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(item.hashCode, $mrjc(name.hashCode, value.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is IntegerDb &&
          other.item == this.item &&
          other.name == this.name &&
          other.value == this.value);
}

class IntegersCompanion extends UpdateCompanion<IntegerDb> {
  final Value<int> item;
  final Value<String> name;
  final Value<int> value;
  const IntegersCompanion({
    this.item = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });
  IntegersCompanion.insert({
    required int item,
    required String name,
    required int value,
  })   : item = Value(item),
        name = Value(name),
        value = Value(value);
  static Insertable<IntegerDb> custom({
    Expression<int>? item,
    Expression<String>? name,
    Expression<int>? value,
  }) {
    return RawValuesInsertable({
      if (item != null) 'item': item,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  IntegersCompanion copyWith({Value<int>? item, Value<String>? name, Value<int>? value}) {
    return IntegersCompanion(
      item: item ?? this.item,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (item.present) {
      map['item'] = Variable<int>(item.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntegersCompanion(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class Integers extends Table with TableInfo<Integers, IntegerDb> {
  final GeneratedDatabase _db;
  final String? _alias;
  Integers(this._db, [this._alias]);
  final VerificationMeta _itemMeta = const VerificationMeta('item');
  late final GeneratedIntColumn item = _constructItem();
  GeneratedIntColumn _constructItem() {
    return GeneratedIntColumn('item', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedIntColumn value = _constructValue();
  GeneratedIntColumn _constructValue() {
    return GeneratedIntColumn('value', $tableName, false, $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  Integers get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'integers';
  @override
  final String actualTableName = 'integers';
  @override
  VerificationContext validateIntegrity(Insertable<IntegerDb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item')) {
      context.handle(_itemMeta, item.isAcceptableOrUnknown(data['item']!, _itemMeta));
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  IntegerDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return IntegerDb.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Integers createAlias(String alias) {
    return Integers(_db, alias);
  }

  @override
  List<String> get customConstraints => const ['FOREIGN KEY (item) REFERENCES items (row_id)'];

  @override
  bool get dontWriteConstraints => true;
}

class StringDb extends DataClass implements Insertable<StringDb> {
  final int item;
  final String name;
  final String value;

  StringDb({required this.item, required this.name, required this.value});

  factory StringDb.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return StringDb(
      item: intType.mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: stringType.mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item'] = Variable<int>(item);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  StringsCompanion toCompanion(bool nullToAbsent) {
    return StringsCompanion(
      item: Value(item),
      name: Value(name),
      value: Value(value),
    );
  }

  factory StringDb.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return StringDb(
      item: serializer.fromJson<int>(json['item']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'item': serializer.toJson<int>(item),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  StringDb copyWith({int? item, String? name, String? value}) => StringDb(
        item: item ?? this.item,
        name: name ?? this.name,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('StringDb(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(item.hashCode, $mrjc(name.hashCode, value.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is StringDb &&
          other.item == this.item &&
          other.name == this.name &&
          other.value == this.value);
}

class StringsCompanion extends UpdateCompanion<StringDb> {
  final Value<int> item;
  final Value<String> name;
  final Value<String> value;
  const StringsCompanion({
    this.item = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });
  StringsCompanion.insert({
    required int item,
    required String name,
    required String value,
  })   : item = Value(item),
        name = Value(name),
        value = Value(value);
  static Insertable<StringDb> custom({
    Expression<int>? item,
    Expression<String>? name,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (item != null) 'item': item,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  StringsCompanion copyWith({Value<int>? item, Value<String>? name, Value<String>? value}) {
    return StringsCompanion(
      item: item ?? this.item,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (item.present) {
      map['item'] = Variable<int>(item.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StringsCompanion(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class Strings extends Table with TableInfo<Strings, StringDb> {
  final GeneratedDatabase _db;
  final String? _alias;
  Strings(this._db, [this._alias]);
  final VerificationMeta _itemMeta = const VerificationMeta('item');
  late final GeneratedIntColumn item = _constructItem();
  GeneratedIntColumn _constructItem() {
    return GeneratedIntColumn('item', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedTextColumn value = _constructValue();
  GeneratedTextColumn _constructValue() {
    return GeneratedTextColumn('value', $tableName, false, $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  Strings get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'strings';
  @override
  final String actualTableName = 'strings';

  @override
  VerificationContext validateIntegrity(Insertable<StringDb> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item')) {
      context.handle(_itemMeta, item.isAcceptableOrUnknown(data['item']!, _itemMeta));
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  StringDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return StringDb.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Strings createAlias(String alias) {
    return Strings(_db, alias);
  }

  @override
  List<String> get customConstraints => const ['FOREIGN KEY (item) REFERENCES items (row_id)'];

  @override
  bool get dontWriteConstraints => true;
}

class RealDb extends DataClass implements Insertable<RealDb> {
  final int item;
  final String name;
  final double value;

  RealDb({required this.item, required this.name, required this.value});

  factory RealDb.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final doubleType = db.typeSystem.forDartType<double>();
    return RealDb(
      item: intType.mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: doubleType.mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item'] = Variable<int>(item);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<double>(value);
    return map;
  }

  RealsCompanion toCompanion(bool nullToAbsent) {
    return RealsCompanion(
      item: Value(item),
      name: Value(name),
      value: Value(value),
    );
  }

  factory RealDb.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return RealDb(
      item: serializer.fromJson<int>(json['item']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<double>(json['value']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'item': serializer.toJson<int>(item),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<double>(value),
    };
  }

  RealDb copyWith({int? item, String? name, double? value}) => RealDb(
        item: item ?? this.item,
        name: name ?? this.name,
        value: value ?? this.value,
      );
  @override
  String toString() {
    return (StringBuffer('RealDb(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(item.hashCode, $mrjc(name.hashCode, value.hashCode)));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is RealDb &&
          other.item == this.item &&
          other.name == this.name &&
          other.value == this.value);
}

class RealsCompanion extends UpdateCompanion<RealDb> {
  final Value<int> item;
  final Value<String> name;
  final Value<double> value;
  const RealsCompanion({
    this.item = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });
  RealsCompanion.insert({
    required int item,
    required String name,
    required double value,
  })   : item = Value(item),
        name = Value(name),
        value = Value(value);
  static Insertable<RealDb> custom({
    Expression<int>? item,
    Expression<String>? name,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (item != null) 'item': item,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  RealsCompanion copyWith({Value<int>? item, Value<String>? name, Value<double>? value}) {
    return RealsCompanion(
      item: item ?? this.item,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (item.present) {
      map['item'] = Variable<int>(item.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealsCompanion(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class Reals extends Table with TableInfo<Reals, RealDb> {
  final GeneratedDatabase _db;
  final String? _alias;
  Reals(this._db, [this._alias]);
  final VerificationMeta _itemMeta = const VerificationMeta('item');
  late final GeneratedIntColumn item = _constructItem();
  GeneratedIntColumn _constructItem() {
    return GeneratedIntColumn('item', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedTextColumn name = _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false, $customConstraints: 'NOT NULL');
  }

  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedRealColumn value = _constructValue();
  GeneratedRealColumn _constructValue() {
    return GeneratedRealColumn('value', $tableName, false, $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  Reals get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'reals';
  @override
  final String actualTableName = 'reals';

  @override
  VerificationContext validateIntegrity(Insertable<RealDb> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item')) {
      context.handle(_itemMeta, item.isAcceptableOrUnknown(data['item']!, _itemMeta));
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};
  @override
  RealDb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return RealDb.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Reals createAlias(String alias) {
    return Reals(_db, alias);
  }

  @override
  List<String> get customConstraints => const ['FOREIGN KEY (item) REFERENCES items (row_id)'];

  @override
  bool get dontWriteConstraints => true;
}

class StringsSearchData extends DataClass implements Insertable<StringsSearchData> {
  final String item;
  final String name;
  final String value;

  StringsSearchData({required this.item, required this.name, required this.value});

  factory StringsSearchData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    return StringsSearchData(
      item: stringType.mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: stringType.mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item'] = Variable<String>(item);
    map['name'] = Variable<String>(name);
    map['value'] = Variable<String>(value);
    return map;
  }

  StringsSearchCompanion toCompanion(bool nullToAbsent) {
    return StringsSearchCompanion(
      item: Value(item),
      name: Value(name),
      value: Value(value),
    );
  }

  factory StringsSearchData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return StringsSearchData(
      item: serializer.fromJson<String>(json['item']),
      name: serializer.fromJson<String>(json['name']),
      value: serializer.fromJson<String>(json['value']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'item': serializer.toJson<String>(item),
      'name': serializer.toJson<String>(name),
      'value': serializer.toJson<String>(value),
    };
  }

  StringsSearchData copyWith({String? item, String? name, String? value}) => StringsSearchData(
        item: item ?? this.item,
        name: name ?? this.name,
        value: value ?? this.value,
      );

  @override
  String toString() {
    return (StringBuffer('StringsSearchData(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(item.hashCode, $mrjc(name.hashCode, value.hashCode)));

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is StringsSearchData &&
          other.item == this.item &&
          other.name == this.name &&
          other.value == this.value);
}

class StringsSearchCompanion extends UpdateCompanion<StringsSearchData> {
  final Value<String> item;
  final Value<String> name;
  final Value<String> value;

  const StringsSearchCompanion({
    this.item = const Value.absent(),
    this.name = const Value.absent(),
    this.value = const Value.absent(),
  });

  StringsSearchCompanion.insert({
    required String item,
    required String name,
    required String value,
  })   : item = Value(item),
        name = Value(name),
        value = Value(value);

  static Insertable<StringsSearchData> custom({
    Expression<String>? item,
    Expression<String>? name,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (item != null) 'item': item,
      if (name != null) 'name': name,
      if (value != null) 'value': value,
    });
  }

  StringsSearchCompanion copyWith(
      {Value<String>? item, Value<String>? name, Value<String>? value}) {
    return StringsSearchCompanion(
      item: item ?? this.item,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (item.present) {
      map['item'] = Variable<String>(item.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StringsSearchCompanion(')
          ..write('item: $item, ')
          ..write('name: $name, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class StringsSearch extends Table
    with
        TableInfo<StringsSearch, StringsSearchData>,
        VirtualTableInfo<StringsSearch, StringsSearchData> {
  final GeneratedDatabase _db;
  final String? _alias;

  StringsSearch(this._db, [this._alias]);

  final VerificationMeta _itemMeta = const VerificationMeta('item');
  late final GeneratedTextColumn item = _constructItem();

  GeneratedTextColumn _constructItem() {
    return GeneratedTextColumn('item', $tableName, false, $customConstraints: '');
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedTextColumn name = _constructName();

  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn('name', $tableName, false, $customConstraints: '');
  }

  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedTextColumn value = _constructValue();

  GeneratedTextColumn _constructValue() {
    return GeneratedTextColumn('value', $tableName, false, $customConstraints: '');
  }

  @override
  List<GeneratedColumn> get $columns => [item, name, value];

  @override
  StringsSearch get asDslTable => this;

  @override
  String get $tableName => _alias ?? 'strings_search';
  @override
  final String actualTableName = 'strings_search';

  @override
  VerificationContext validateIntegrity(Insertable<StringsSearchData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item')) {
      context.handle(_itemMeta, item.isAcceptableOrUnknown(data['item']!, _itemMeta));
    } else if (isInserting) {
      context.missing(_itemMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => <GeneratedColumn>{};

  @override
  StringsSearchData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return StringsSearchData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  StringsSearch createAlias(String alias) {
    return StringsSearch(_db, alias);
  }

  @override
  bool get dontWriteConstraints => true;

  @override
  String get moduleAndArgs =>
      'fts5(content="strings", item UNINDEXED, name UNINDEXED, value, tokenize = \'porter\')';
}

class NavigationStateData extends DataClass implements Insertable<NavigationStateData> {
  final String sessionID;
  final Uint8List state;

  NavigationStateData({required this.sessionID, required this.state});

  factory NavigationStateData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final uint8ListType = db.typeSystem.forDartType<Uint8List>();
    return NavigationStateData(
      sessionID: stringType.mapFromDatabaseResponse(data['${effectivePrefix}sessionID'])!,
      state: uint8ListType.mapFromDatabaseResponse(data['${effectivePrefix}state'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sessionID'] = Variable<String>(sessionID);
    map['state'] = Variable<Uint8List>(state);
    return map;
  }

  NavigationStateCompanion toCompanion(bool nullToAbsent) {
    return NavigationStateCompanion(
      sessionID: Value(sessionID),
      state: Value(state),
    );
  }

  factory NavigationStateData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return NavigationStateData(
      sessionID: serializer.fromJson<String>(json['sessionID']),
      state: serializer.fromJson<Uint8List>(json['state']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionID': serializer.toJson<String>(sessionID),
      'state': serializer.toJson<Uint8List>(state),
    };
  }

  NavigationStateData copyWith({String? sessionID, Uint8List? state}) => NavigationStateData(
        sessionID: sessionID ?? this.sessionID,
        state: state ?? this.state,
      );

  @override
  String toString() {
    return (StringBuffer('NavigationStateData(')
          ..write('sessionID: $sessionID, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(sessionID.hashCode, state.hashCode));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is NavigationStateData &&
          other.sessionID == this.sessionID &&
          other.state == this.state);
}

class NavigationStateCompanion extends UpdateCompanion<NavigationStateData> {
  final Value<String> sessionID;
  final Value<Uint8List> state;
  const NavigationStateCompanion({
    this.sessionID = const Value.absent(),
    this.state = const Value.absent(),
  });
  NavigationStateCompanion.insert({
    required String sessionID,
    required Uint8List state,
  })   : sessionID = Value(sessionID),
        state = Value(state);

  static Insertable<NavigationStateData> custom({
    Expression<String>? sessionID,
    Expression<Uint8List>? state,
  }) {
    return RawValuesInsertable({
      if (sessionID != null) 'sessionID': sessionID,
      if (state != null) 'state': state,
    });
  }

  NavigationStateCompanion copyWith({Value<String>? sessionID, Value<Uint8List>? state}) {
    return NavigationStateCompanion(
      sessionID: sessionID ?? this.sessionID,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionID.present) {
      map['sessionID'] = Variable<String>(sessionID.value);
    }
    if (state.present) {
      map['state'] = Variable<Uint8List>(state.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NavigationStateCompanion(')
          ..write('sessionID: $sessionID, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }
}

class NavigationState extends Table with TableInfo<NavigationState, NavigationStateData> {
  final GeneratedDatabase _db;
  final String? _alias;

  NavigationState(this._db, [this._alias]);

  final VerificationMeta _sessionIDMeta = const VerificationMeta('sessionID');
  late final GeneratedTextColumn sessionID = _constructSessionID();

  GeneratedTextColumn _constructSessionID() {
    return GeneratedTextColumn('sessionID', $tableName, false,
        $customConstraints: 'PRIMARY KEY NOT NULL');
  }

  final VerificationMeta _stateMeta = const VerificationMeta('state');
  late final GeneratedBlobColumn state = _constructState();
  GeneratedBlobColumn _constructState() {
    return GeneratedBlobColumn('state', $tableName, false, $customConstraints: 'NOT NULL');
  }

  @override
  List<GeneratedColumn> get $columns => [sessionID, state];
  @override
  NavigationState get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'navigationState';
  @override
  final String actualTableName = 'navigationState';

  @override
  VerificationContext validateIntegrity(Insertable<NavigationStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sessionID')) {
      context.handle(
          _sessionIDMeta, sessionID.isAcceptableOrUnknown(data['sessionID']!, _sessionIDMeta));
    } else if (isInserting) {
      context.missing(_sessionIDMeta);
    }
    if (data.containsKey('state')) {
      context.handle(_stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionID};
  @override
  NavigationStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return NavigationStateData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  NavigationState createAlias(String alias) {
    return NavigationState(_db, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final Items items = Items(this);
  late final Index idxItemsId =
      Index('idx_items_id', 'CREATE\r\nUNIQUE INDEX idx_items_id on items (id);');
  late final Index idxItemsTypeDateServerModified = Index('idx_items_type_dateServerModified',
      'CREATE\r\nINDEX idx_items_type_dateServerModified on items (type, dateServerModified);');
  late final Edges edges = Edges(this);
  late final Index idxEdgesSourceName = Index(
      'idx_edges_source_name', 'CREATE\r\nINDEX idx_edges_source_name on edges (source, name);');
  late final Index idxEdgesTargetName = Index(
      'idx_edges_target_name', 'CREATE\r\nINDEX idx_edges_target_name on edges (target, name);');
  late final Integers integers = Integers(this);
  late final Index idxIntegersItemName = Index('idx_integers_item_name',
      'CREATE\r\nUNIQUE INDEX idx_integers_item_name on integers (item, name);');
  late final Index idxIntegersNameValue = Index('idx_integers_name_value',
      'CREATE\r\nINDEX idx_integers_name_value on integers (name, value);');
  late final Index idxIntegersNameItem = Index(
      'idx_integers_name_item', 'CREATE\r\nINDEX idx_integers_name_item on integers (name, item);');
  late final Strings strings = Strings(this);
  late final Index idxStringsItemName = Index('idx_strings_item_name',
      'CREATE\r\nUNIQUE INDEX idx_strings_item_name on strings (item, name);');
  late final Index idxStringsNameValue = Index(
      'idx_strings_name_value', 'CREATE\r\nINDEX idx_strings_name_value on strings (name, value);');
  late final Index idxStringsNameItem = Index(
      'idx_strings_name_item', 'CREATE\r\nINDEX idx_strings_name_item on strings (name, item);');
  late final Reals reals = Reals(this);
  late final Index idxRealsItemName = Index(
      'idx_reals_item_name', 'CREATE\r\nUNIQUE INDEX idx_reals_item_name on reals (item, name);');
  late final Index idxRealsNameValue =
      Index('idx_reals_name_value', 'CREATE\r\nINDEX idx_reals_name_value on reals(name, value);');
  late final Index idxRealsNameItem =
      Index('idx_reals_name_item', 'CREATE\r\nINDEX idx_reals_name_item on reals(name, item);');
  late final StringsSearch stringsSearch = StringsSearch(this);
  late final Trigger tblAi = Trigger(
      'CREATE TRIGGER tbl_ai AFTER INSERT ON strings BEGIN\r\n    INSERT INTO strings_search(item, name, value) VALUES (new.item, new.name, new.value);\r\nEND;',
      'tbl_ai');
  late final Trigger tblAd = Trigger(
      'CREATE TRIGGER tbl_ad AFTER DELETE ON strings BEGIN\r\n    INSERT INTO strings_search(strings_search, item, name, value) VALUES(\'delete\', old.item, old.name, old.value);\r\nEND;',
      'tbl_ad');
  late final Trigger tblAu = Trigger(
      'CREATE TRIGGER tbl_au AFTER UPDATE ON strings BEGIN\r\n    INSERT INTO strings_search(strings_search, item, name, value) VALUES(\'delete\', old.item, old.name, old.value);\r\n    INSERT INTO strings_search(item, name, value) VALUES (new.item, new.name, new.value);\r\nEND;',
      'tbl_au');
  late final NavigationState navigationState = NavigationState(this);

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        items,
        idxItemsId,
        idxItemsTypeDateServerModified,
        edges,
        idxEdgesSourceName,
        idxEdgesTargetName,
        integers,
        idxIntegersItemName,
        idxIntegersNameValue,
        idxIntegersNameItem,
        strings,
        idxStringsItemName,
        idxStringsNameValue,
        idxStringsNameItem,
        reals,
        idxRealsItemName,
        idxRealsNameValue,
        idxRealsNameItem,
        stringsSearch,
        tblAi,
        tblAd,
        tblAu,
        navigationState
      ];

  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('strings', limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('strings_search', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('strings', limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('strings_search', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('strings', limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('strings_search', kind: UpdateKind.insert),
            ],
          ),
        ],
      );
}
