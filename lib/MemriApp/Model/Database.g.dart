// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Item extends DataClass implements Insertable<Item> {
  final int rowId;
  final String id;
  final String type;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateServerModified;
  final bool deleted;
  final String syncState;
  final String fileState;
  final bool syncHasPriority;
  Item(
      {required this.rowId,
      required this.id,
      required this.type,
      required this.dateCreated,
      required this.dateModified,
      this.dateServerModified,
      required this.deleted,
      required this.syncState,
      required this.fileState,
      required this.syncHasPriority});
  factory Item.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Item(
      rowId: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}row_id'])!,
      id: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      type: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}type'])!,
      dateCreated: Items.$converter0.mapToDart(
          const IntType().mapFromDatabaseResponse(data['${effectivePrefix}dateCreated']))!,
      dateModified: Items.$converter1.mapToDart(
          const IntType().mapFromDatabaseResponse(data['${effectivePrefix}dateModified']))!,
      dateServerModified: Items.$converter2.mapToDart(
          const IntType().mapFromDatabaseResponse(data['${effectivePrefix}dateServerModified'])),
      deleted: const BoolType().mapFromDatabaseResponse(data['${effectivePrefix}deleted'])!,
      syncState: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}syncState'])!,
      fileState: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}fileState'])!,
      syncHasPriority:
          const BoolType().mapFromDatabaseResponse(data['${effectivePrefix}syncHasPriority'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    {
      final converter = Items.$converter0;
      map['dateCreated'] = Variable<int>(converter.mapToSql(dateCreated)!);
    }
    {
      final converter = Items.$converter1;
      map['dateModified'] = Variable<int>(converter.mapToSql(dateModified)!);
    }
    if (!nullToAbsent || dateServerModified != null) {
      final converter = Items.$converter2;
      map['dateServerModified'] = Variable<int?>(converter.mapToSql(dateServerModified));
    }
    map['deleted'] = Variable<bool>(deleted);
    map['syncState'] = Variable<String>(syncState);
    map['fileState'] = Variable<String>(fileState);
    map['syncHasPriority'] = Variable<bool>(syncHasPriority);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      rowId: Value(rowId),
      id: Value(id),
      type: Value(type),
      dateCreated: Value(dateCreated),
      dateModified: Value(dateModified),
      dateServerModified: dateServerModified == null && nullToAbsent
          ? const Value.absent()
          : Value(dateServerModified),
      deleted: Value(deleted),
      syncState: Value(syncState),
      fileState: Value(fileState),
      syncHasPriority: Value(syncHasPriority),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Item(
      rowId: serializer.fromJson<int>(json['row_id']),
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      dateCreated: serializer.fromJson<DateTime>(json['dateCreated']),
      dateModified: serializer.fromJson<DateTime>(json['dateModified']),
      dateServerModified: serializer.fromJson<DateTime?>(json['dateServerModified']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      syncState: serializer.fromJson<String>(json['syncState']),
      fileState: serializer.fromJson<String>(json['fileState']),
      syncHasPriority: serializer.fromJson<bool>(json['syncHasPriority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'row_id': serializer.toJson<int>(rowId),
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'dateCreated': serializer.toJson<DateTime>(dateCreated),
      'dateModified': serializer.toJson<DateTime>(dateModified),
      'dateServerModified': serializer.toJson<DateTime?>(dateServerModified),
      'deleted': serializer.toJson<bool>(deleted),
      'syncState': serializer.toJson<String>(syncState),
      'fileState': serializer.toJson<String>(fileState),
      'syncHasPriority': serializer.toJson<bool>(syncHasPriority),
    };
  }

  Item copyWith(
          {int? rowId,
          String? id,
          String? type,
          DateTime? dateCreated,
          DateTime? dateModified,
          DateTime? dateServerModified,
          bool? deleted,
          String? syncState,
          String? fileState,
          bool? syncHasPriority}) =>
      Item(
        rowId: rowId ?? this.rowId,
        id: id ?? this.id,
        type: type ?? this.type,
        dateCreated: dateCreated ?? this.dateCreated,
        dateModified: dateModified ?? this.dateModified,
        dateServerModified: dateServerModified ?? this.dateServerModified,
        deleted: deleted ?? this.deleted,
        syncState: syncState ?? this.syncState,
        fileState: fileState ?? this.fileState,
        syncHasPriority: syncHasPriority ?? this.syncHasPriority,
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
          ..write('deleted: $deleted, ')
          ..write('syncState: $syncState, ')
          ..write('fileState: $fileState, ')
          ..write('syncHasPriority: $syncHasPriority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(rowId, id, type, dateCreated, dateModified, dateServerModified,
      deleted, syncState, fileState, syncHasPriority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.rowId == this.rowId &&
          other.id == this.id &&
          other.type == this.type &&
          other.dateCreated == this.dateCreated &&
          other.dateModified == this.dateModified &&
          other.dateServerModified == this.dateServerModified &&
          other.deleted == this.deleted &&
          other.syncState == this.syncState &&
          other.fileState == this.fileState &&
          other.syncHasPriority == this.syncHasPriority);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> rowId;
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> dateCreated;
  final Value<DateTime> dateModified;
  final Value<DateTime?> dateServerModified;
  final Value<bool> deleted;
  final Value<String> syncState;
  final Value<String> fileState;
  final Value<bool> syncHasPriority;
  const ItemsCompanion({
    this.rowId = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.dateCreated = const Value.absent(),
    this.dateModified = const Value.absent(),
    this.dateServerModified = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.fileState = const Value.absent(),
    this.syncHasPriority = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.rowId = const Value.absent(),
    required String id,
    required String type,
    required DateTime dateCreated,
    required DateTime dateModified,
    this.dateServerModified = const Value.absent(),
    this.deleted = const Value.absent(),
    this.syncState = const Value.absent(),
    this.fileState = const Value.absent(),
    this.syncHasPriority = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        dateCreated = Value(dateCreated),
        dateModified = Value(dateModified);
  static Insertable<Item> custom({
    Expression<int>? rowId,
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? dateCreated,
    Expression<DateTime>? dateModified,
    Expression<DateTime?>? dateServerModified,
    Expression<bool>? deleted,
    Expression<String>? syncState,
    Expression<String>? fileState,
    Expression<bool>? syncHasPriority,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (dateCreated != null) 'dateCreated': dateCreated,
      if (dateModified != null) 'dateModified': dateModified,
      if (dateServerModified != null) 'dateServerModified': dateServerModified,
      if (deleted != null) 'deleted': deleted,
      if (syncState != null) 'syncState': syncState,
      if (fileState != null) 'fileState': fileState,
      if (syncHasPriority != null) 'syncHasPriority': syncHasPriority,
    });
  }

  ItemsCompanion copyWith(
      {Value<int>? rowId,
      Value<String>? id,
      Value<String>? type,
      Value<DateTime>? dateCreated,
      Value<DateTime>? dateModified,
      Value<DateTime?>? dateServerModified,
      Value<bool>? deleted,
      Value<String>? syncState,
      Value<String>? fileState,
      Value<bool>? syncHasPriority}) {
    return ItemsCompanion(
      rowId: rowId ?? this.rowId,
      id: id ?? this.id,
      type: type ?? this.type,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateServerModified: dateServerModified ?? this.dateServerModified,
      deleted: deleted ?? this.deleted,
      syncState: syncState ?? this.syncState,
      fileState: fileState ?? this.fileState,
      syncHasPriority: syncHasPriority ?? this.syncHasPriority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dateCreated.present) {
      final converter = Items.$converter0;
      map['dateCreated'] = Variable<int>(converter.mapToSql(dateCreated.value)!);
    }
    if (dateModified.present) {
      final converter = Items.$converter1;
      map['dateModified'] = Variable<int>(converter.mapToSql(dateModified.value)!);
    }
    if (dateServerModified.present) {
      final converter = Items.$converter2;
      map['dateServerModified'] = Variable<int?>(converter.mapToSql(dateServerModified.value));
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (syncState.present) {
      map['syncState'] = Variable<String>(syncState.value);
    }
    if (fileState.present) {
      map['fileState'] = Variable<String>(fileState.value);
    }
    if (syncHasPriority.present) {
      map['syncHasPriority'] = Variable<bool>(syncHasPriority.value);
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
          ..write('deleted: $deleted, ')
          ..write('syncState: $syncState, ')
          ..write('fileState: $fileState, ')
          ..write('syncHasPriority: $syncHasPriority')
          ..write(')'))
        .toString();
  }
}

class Items extends Table with TableInfo<Items, Item> {
  final GeneratedDatabase _db;
  final String? _alias;
  Items(this._db, [this._alias]);
  final VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  late final GeneratedColumn<int?> rowId = GeneratedColumn<int?>('row_id', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: false, $customConstraints: 'PRIMARY KEY');
  final VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String?> id = GeneratedColumn<String?>('id', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String?> type = GeneratedColumn<String?>('type', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _dateCreatedMeta = const VerificationMeta('dateCreated');
  late final GeneratedColumnWithTypeConverter<DateTime, int?> dateCreated = GeneratedColumn<int?>(
          'dateCreated', aliasedName, false,
          typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL')
      .withConverter<DateTime>(Items.$converter0);
  final VerificationMeta _dateModifiedMeta = const VerificationMeta('dateModified');
  late final GeneratedColumnWithTypeConverter<DateTime, int?> dateModified = GeneratedColumn<int?>(
          'dateModified', aliasedName, false,
          typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL')
      .withConverter<DateTime>(Items.$converter1);
  final VerificationMeta _dateServerModifiedMeta = const VerificationMeta('dateServerModified');
  late final GeneratedColumnWithTypeConverter<DateTime, int?> dateServerModified =
      GeneratedColumn<int?>('dateServerModified', aliasedName, true,
              typeName: 'INTEGER', requiredDuringInsert: false, $customConstraints: '')
          .withConverter<DateTime>(Items.$converter2);
  final VerificationMeta _deletedMeta = const VerificationMeta('deleted');
  late final GeneratedColumn<bool?> deleted = GeneratedColumn<bool?>('deleted', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT false',
      defaultValue: const CustomExpression<bool>('false'));
  final VerificationMeta _syncStateMeta = const VerificationMeta('syncState');
  late final GeneratedColumn<String?> syncState = GeneratedColumn<String?>(
      'syncState', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'create\'',
      defaultValue: const CustomExpression<String>('\'create\''));
  final VerificationMeta _fileStateMeta = const VerificationMeta('fileState');
  late final GeneratedColumn<String?> fileState = GeneratedColumn<String?>(
      'fileState', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'skip\'',
      defaultValue: const CustomExpression<String>('\'skip\''));
  final VerificationMeta _syncHasPriorityMeta = const VerificationMeta('syncHasPriority');
  late final GeneratedColumn<bool?> syncHasPriority = GeneratedColumn<bool?>(
      'syncHasPriority', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT false',
      defaultValue: const CustomExpression<bool>('false'));
  @override
  List<GeneratedColumn> get $columns => [
        rowId,
        id,
        type,
        dateCreated,
        dateModified,
        dateServerModified,
        deleted,
        syncState,
        fileState,
        syncHasPriority
      ];
  @override
  String get aliasedName => _alias ?? 'items';
  @override
  String get actualTableName => 'items';
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
    context.handle(_dateCreatedMeta, const VerificationResult.success());
    context.handle(_dateModifiedMeta, const VerificationResult.success());
    context.handle(_dateServerModifiedMeta, const VerificationResult.success());
    if (data.containsKey('deleted')) {
      context.handle(_deletedMeta, deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta));
    }
    if (data.containsKey('syncState')) {
      context.handle(
          _syncStateMeta, syncState.isAcceptableOrUnknown(data['syncState']!, _syncStateMeta));
    }
    if (data.containsKey('fileState')) {
      context.handle(
          _fileStateMeta, fileState.isAcceptableOrUnknown(data['fileState']!, _fileStateMeta));
    }
    if (data.containsKey('syncHasPriority')) {
      context.handle(_syncHasPriorityMeta,
          syncHasPriority.isAcceptableOrUnknown(data['syncHasPriority']!, _syncHasPriorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Item.fromData(data, _db, prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  Items createAlias(String alias) {
    return Items(_db, alias);
  }

  static TypeConverter<DateTime, int> $converter0 = const DateTimeConverter();
  static TypeConverter<DateTime, int> $converter1 = const DateTimeConverter();
  static TypeConverter<DateTime, int> $converter2 = const DateTimeConverter();
  @override
  bool get dontWriteConstraints => true;
}

class Edge extends DataClass implements Insertable<Edge> {
  final int self;
  final int source;
  final String name;
  final int target;
  final String syncState;
  final bool syncHasPriority;
  Edge(
      {required this.self,
      required this.source,
      required this.name,
      required this.target,
      required this.syncState,
      required this.syncHasPriority});
  factory Edge.fromData(Map<String, dynamic> data, GeneratedDatabase db, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Edge(
      self: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}self'])!,
      source: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}source'])!,
      name: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      target: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}target'])!,
      syncState: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}syncState'])!,
      syncHasPriority:
          const BoolType().mapFromDatabaseResponse(data['${effectivePrefix}syncHasPriority'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['self'] = Variable<int>(self);
    map['source'] = Variable<int>(source);
    map['name'] = Variable<String>(name);
    map['target'] = Variable<int>(target);
    map['syncState'] = Variable<String>(syncState);
    map['syncHasPriority'] = Variable<bool>(syncHasPriority);
    return map;
  }

  EdgesCompanion toCompanion(bool nullToAbsent) {
    return EdgesCompanion(
      self: Value(self),
      source: Value(source),
      name: Value(name),
      target: Value(target),
      syncState: Value(syncState),
      syncHasPriority: Value(syncHasPriority),
    );
  }

  factory Edge.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Edge(
      self: serializer.fromJson<int>(json['self']),
      source: serializer.fromJson<int>(json['source']),
      name: serializer.fromJson<String>(json['name']),
      target: serializer.fromJson<int>(json['target']),
      syncState: serializer.fromJson<String>(json['syncState']),
      syncHasPriority: serializer.fromJson<bool>(json['syncHasPriority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'self': serializer.toJson<int>(self),
      'source': serializer.toJson<int>(source),
      'name': serializer.toJson<String>(name),
      'target': serializer.toJson<int>(target),
      'syncState': serializer.toJson<String>(syncState),
      'syncHasPriority': serializer.toJson<bool>(syncHasPriority),
    };
  }

  Edge copyWith(
          {int? self,
          int? source,
          String? name,
          int? target,
          String? syncState,
          bool? syncHasPriority}) =>
      Edge(
        self: self ?? this.self,
        source: source ?? this.source,
        name: name ?? this.name,
        target: target ?? this.target,
        syncState: syncState ?? this.syncState,
        syncHasPriority: syncHasPriority ?? this.syncHasPriority,
      );
  @override
  String toString() {
    return (StringBuffer('Edge(')
          ..write('self: $self, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('target: $target, ')
          ..write('syncState: $syncState, ')
          ..write('syncHasPriority: $syncHasPriority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(self, source, name, target, syncState, syncHasPriority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Edge &&
          other.self == this.self &&
          other.source == this.source &&
          other.name == this.name &&
          other.target == this.target &&
          other.syncState == this.syncState &&
          other.syncHasPriority == this.syncHasPriority);
}

class EdgesCompanion extends UpdateCompanion<Edge> {
  final Value<int> self;
  final Value<int> source;
  final Value<String> name;
  final Value<int> target;
  final Value<String> syncState;
  final Value<bool> syncHasPriority;
  const EdgesCompanion({
    this.self = const Value.absent(),
    this.source = const Value.absent(),
    this.name = const Value.absent(),
    this.target = const Value.absent(),
    this.syncState = const Value.absent(),
    this.syncHasPriority = const Value.absent(),
  });
  EdgesCompanion.insert({
    this.self = const Value.absent(),
    required int source,
    required String name,
    required int target,
    this.syncState = const Value.absent(),
    this.syncHasPriority = const Value.absent(),
  })  : source = Value(source),
        name = Value(name),
        target = Value(target);
  static Insertable<Edge> custom({
    Expression<int>? self,
    Expression<int>? source,
    Expression<String>? name,
    Expression<int>? target,
    Expression<String>? syncState,
    Expression<bool>? syncHasPriority,
  }) {
    return RawValuesInsertable({
      if (self != null) 'self': self,
      if (source != null) 'source': source,
      if (name != null) 'name': name,
      if (target != null) 'target': target,
      if (syncState != null) 'syncState': syncState,
      if (syncHasPriority != null) 'syncHasPriority': syncHasPriority,
    });
  }

  EdgesCompanion copyWith(
      {Value<int>? self,
      Value<int>? source,
      Value<String>? name,
      Value<int>? target,
      Value<String>? syncState,
      Value<bool>? syncHasPriority}) {
    return EdgesCompanion(
      self: self ?? this.self,
      source: source ?? this.source,
      name: name ?? this.name,
      target: target ?? this.target,
      syncState: syncState ?? this.syncState,
      syncHasPriority: syncHasPriority ?? this.syncHasPriority,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (self.present) {
      map['self'] = Variable<int>(self.value);
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
    if (syncState.present) {
      map['syncState'] = Variable<String>(syncState.value);
    }
    if (syncHasPriority.present) {
      map['syncHasPriority'] = Variable<bool>(syncHasPriority.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EdgesCompanion(')
          ..write('self: $self, ')
          ..write('source: $source, ')
          ..write('name: $name, ')
          ..write('target: $target, ')
          ..write('syncState: $syncState, ')
          ..write('syncHasPriority: $syncHasPriority')
          ..write(')'))
        .toString();
  }
}

class Edges extends Table with TableInfo<Edges, Edge> {
  final GeneratedDatabase _db;
  final String? _alias;
  Edges(this._db, [this._alias]);
  final VerificationMeta _selfMeta = const VerificationMeta('self');
  late final GeneratedColumn<int?> self = GeneratedColumn<int?>('self', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: false, $customConstraints: 'PRIMARY KEY');
  final VerificationMeta _sourceMeta = const VerificationMeta('source');
  late final GeneratedColumn<int?> source = GeneratedColumn<int?>('source', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>('name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _targetMeta = const VerificationMeta('target');
  late final GeneratedColumn<int?> target = GeneratedColumn<int?>('target', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _syncStateMeta = const VerificationMeta('syncState');
  late final GeneratedColumn<String?> syncState = GeneratedColumn<String?>(
      'syncState', aliasedName, false,
      typeName: 'TEXT',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT \'create\'',
      defaultValue: const CustomExpression<String>('\'create\''));
  final VerificationMeta _syncHasPriorityMeta = const VerificationMeta('syncHasPriority');
  late final GeneratedColumn<bool?> syncHasPriority = GeneratedColumn<bool?>(
      'syncHasPriority', aliasedName, false,
      typeName: 'INTEGER',
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL DEFAULT false',
      defaultValue: const CustomExpression<bool>('false'));
  @override
  List<GeneratedColumn> get $columns => [self, source, name, target, syncState, syncHasPriority];
  @override
  String get aliasedName => _alias ?? 'edges';
  @override
  String get actualTableName => 'edges';
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
    if (data.containsKey('syncState')) {
      context.handle(
          _syncStateMeta, syncState.isAcceptableOrUnknown(data['syncState']!, _syncStateMeta));
    }
    if (data.containsKey('syncHasPriority')) {
      context.handle(_syncHasPriorityMeta,
          syncHasPriority.isAcceptableOrUnknown(data['syncHasPriority']!, _syncHasPriorityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {self};
  @override
  Edge map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Edge.fromData(data, _db, prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
    return IntegerDb(
      item: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
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
  int get hashCode => Object.hash(item, name, value);
  @override
  bool operator ==(Object other) =>
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
  })  : item = Value(item),
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
  late final GeneratedColumn<int?> item = GeneratedColumn<int?>('item', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>('name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<int?> value = GeneratedColumn<int?>('value', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  String get aliasedName => _alias ?? 'integers';
  @override
  String get actualTableName => 'integers';
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
    return IntegerDb.fromData(data, _db, prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
    return StringDb(
      item: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
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
  int get hashCode => Object.hash(item, name, value);
  @override
  bool operator ==(Object other) =>
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
  })  : item = Value(item),
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
  late final GeneratedColumn<int?> item = GeneratedColumn<int?>('item', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>('name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String?> value = GeneratedColumn<String?>('value', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  String get aliasedName => _alias ?? 'strings';
  @override
  String get actualTableName => 'strings';
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
    return StringDb.fromData(data, _db, prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
    return RealDb(
      item: const IntType().mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: const RealType().mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
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
  int get hashCode => Object.hash(item, name, value);
  @override
  bool operator ==(Object other) =>
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
  })  : item = Value(item),
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
  late final GeneratedColumn<int?> item = GeneratedColumn<int?>('item', aliasedName, false,
      typeName: 'INTEGER', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>('name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<double?> value = GeneratedColumn<double?>('value', aliasedName, false,
      typeName: 'REAL', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  String get aliasedName => _alias ?? 'reals';
  @override
  String get actualTableName => 'reals';
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
    return RealDb.fromData(data, _db, prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
    return StringsSearchData(
      item: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}item'])!,
      name: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      value: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}value'])!,
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
  int get hashCode => Object.hash(item, name, value);
  @override
  bool operator ==(Object other) =>
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
  })  : item = Value(item),
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
  late final GeneratedColumn<String?> item = GeneratedColumn<String?>('item', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: '');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>('name', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: '');
  final VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String?> value = GeneratedColumn<String?>('value', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [item, name, value];
  @override
  String get aliasedName => _alias ?? 'strings_search';
  @override
  String get actualTableName => 'strings_search';
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
    return StringsSearchData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  StringsSearch createAlias(String alias) {
    return StringsSearch(_db, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(content= "strings", item UNINDEXED, name UNINDEXED, value, tokenize = \'porter\')';
}

class NavigationStateData extends DataClass implements Insertable<NavigationStateData> {
  final String sessionID;
  final String pageLabel;
  final Uint8List state;
  NavigationStateData({required this.sessionID, required this.pageLabel, required this.state});
  factory NavigationStateData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return NavigationStateData(
      sessionID: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}sessionID'])!,
      pageLabel: const StringType().mapFromDatabaseResponse(data['${effectivePrefix}pageLabel'])!,
      state: const BlobType().mapFromDatabaseResponse(data['${effectivePrefix}state'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sessionID'] = Variable<String>(sessionID);
    map['pageLabel'] = Variable<String>(pageLabel);
    map['state'] = Variable<Uint8List>(state);
    return map;
  }

  NavigationStateCompanion toCompanion(bool nullToAbsent) {
    return NavigationStateCompanion(
      sessionID: Value(sessionID),
      pageLabel: Value(pageLabel),
      state: Value(state),
    );
  }

  factory NavigationStateData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return NavigationStateData(
      sessionID: serializer.fromJson<String>(json['sessionID']),
      pageLabel: serializer.fromJson<String>(json['pageLabel']),
      state: serializer.fromJson<Uint8List>(json['state']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionID': serializer.toJson<String>(sessionID),
      'pageLabel': serializer.toJson<String>(pageLabel),
      'state': serializer.toJson<Uint8List>(state),
    };
  }

  NavigationStateData copyWith({String? sessionID, String? pageLabel, Uint8List? state}) =>
      NavigationStateData(
        sessionID: sessionID ?? this.sessionID,
        pageLabel: pageLabel ?? this.pageLabel,
        state: state ?? this.state,
      );
  @override
  String toString() {
    return (StringBuffer('NavigationStateData(')
          ..write('sessionID: $sessionID, ')
          ..write('pageLabel: $pageLabel, ')
          ..write('state: $state')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sessionID, pageLabel, state);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NavigationStateData &&
          other.sessionID == this.sessionID &&
          other.pageLabel == this.pageLabel &&
          other.state == this.state);
}

class NavigationStateCompanion extends UpdateCompanion<NavigationStateData> {
  final Value<String> sessionID;
  final Value<String> pageLabel;
  final Value<Uint8List> state;
  const NavigationStateCompanion({
    this.sessionID = const Value.absent(),
    this.pageLabel = const Value.absent(),
    this.state = const Value.absent(),
  });
  NavigationStateCompanion.insert({
    required String sessionID,
    required String pageLabel,
    required Uint8List state,
  })  : sessionID = Value(sessionID),
        pageLabel = Value(pageLabel),
        state = Value(state);
  static Insertable<NavigationStateData> custom({
    Expression<String>? sessionID,
    Expression<String>? pageLabel,
    Expression<Uint8List>? state,
  }) {
    return RawValuesInsertable({
      if (sessionID != null) 'sessionID': sessionID,
      if (pageLabel != null) 'pageLabel': pageLabel,
      if (state != null) 'state': state,
    });
  }

  NavigationStateCompanion copyWith(
      {Value<String>? sessionID, Value<String>? pageLabel, Value<Uint8List>? state}) {
    return NavigationStateCompanion(
      sessionID: sessionID ?? this.sessionID,
      pageLabel: pageLabel ?? this.pageLabel,
      state: state ?? this.state,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionID.present) {
      map['sessionID'] = Variable<String>(sessionID.value);
    }
    if (pageLabel.present) {
      map['pageLabel'] = Variable<String>(pageLabel.value);
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
          ..write('pageLabel: $pageLabel, ')
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
  late final GeneratedColumn<String?> sessionID = GeneratedColumn<String?>(
      'sessionID', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'PRIMARY KEY NOT NULL');
  final VerificationMeta _pageLabelMeta = const VerificationMeta('pageLabel');
  late final GeneratedColumn<String?> pageLabel = GeneratedColumn<String?>(
      'pageLabel', aliasedName, false,
      typeName: 'TEXT', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  final VerificationMeta _stateMeta = const VerificationMeta('state');
  late final GeneratedColumn<Uint8List?> state = GeneratedColumn<Uint8List?>(
      'state', aliasedName, false,
      typeName: 'BLOB', requiredDuringInsert: true, $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [sessionID, pageLabel, state];
  @override
  String get aliasedName => _alias ?? 'navigationState';
  @override
  String get actualTableName => 'navigationState';
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
    if (data.containsKey('pageLabel')) {
      context.handle(
          _pageLabelMeta, pageLabel.isAcceptableOrUnknown(data['pageLabel']!, _pageLabelMeta));
    } else if (isInserting) {
      context.missing(_pageLabelMeta);
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
    return NavigationStateData.fromData(data, _db,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
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
  _$Database.connect(DatabaseConnection c) : super.connect(c);
  late final Items items = Items(this);
  late final Index idxItemsId =
      Index('idx_items_id', 'CREATE\r\n    UNIQUE INDEX idx_items_id on items (id);');
  late final Index idxItemsTypeDateServerModified = Index('idx_items_type_dateServerModified',
      'CREATE\r\n    INDEX idx_items_type_dateServerModified on items (type, dateServerModified);');
  late final Edges edges = Edges(this);
  late final Index idxEdgesSourceName = Index('idx_edges_source_name',
      'CREATE\r\n    INDEX idx_edges_source_name on edges (source, name);');
  late final Index idxEdgesTargetName = Index('idx_edges_target_name',
      'CREATE\r\n    INDEX idx_edges_target_name on edges (target, name);');
  late final Integers integers = Integers(this);
  late final Index idxIntegersItemName = Index('idx_integers_item_name',
      'CREATE\r\n    UNIQUE INDEX idx_integers_item_name on integers (item, name);');
  late final Index idxIntegersNameValue = Index('idx_integers_name_value',
      'CREATE\r\n    INDEX idx_integers_name_value on integers (name, value);');
  late final Index idxIntegersNameItem = Index('idx_integers_name_item',
      'CREATE\r\n    INDEX idx_integers_name_item on integers (name, item);');
  late final Strings strings = Strings(this);
  late final Index idxStringsItemName = Index('idx_strings_item_name',
      'CREATE\r\n    UNIQUE INDEX idx_strings_item_name on strings (item, name);');
  late final Index idxStringsNameValue = Index('idx_strings_name_value',
      'CREATE\r\n    INDEX idx_strings_name_value on strings (name, value);');
  late final Index idxStringsNameItem = Index('idx_strings_name_item',
      'CREATE\r\n    INDEX idx_strings_name_item on strings (name, item);');
  late final Reals reals = Reals(this);
  late final Index idxRealsItemName = Index('idx_reals_item_name',
      'CREATE\r\n    UNIQUE INDEX idx_reals_item_name on reals (item, name);');
  late final Index idxRealsNameValue = Index(
      'idx_reals_name_value', 'CREATE\r\n    INDEX idx_reals_name_value on reals (name, value);');
  late final Index idxRealsNameItem = Index(
      'idx_reals_name_item', 'CREATE\r\n    INDEX idx_reals_name_item on reals (name, item);');
  late final StringsSearch stringsSearch = StringsSearch(this);
  late final Trigger stringsSearchAfterInsert = Trigger(
      'CREATE TRIGGER strings_search_after_insert\r\n    AFTER INSERT\r\n    ON strings\r\nBEGIN\r\n    INSERT INTO strings_search(item, name, value) VALUES (new.item, new.name, new.value);\r\nEND;',
      'strings_search_after_insert');
  late final Trigger stringsSearchBeforeDelete = Trigger(
      'CREATE TRIGGER strings_search_before_delete\r\n    BEFORE DELETE\r\n    ON strings\r\nBEGIN\r\n    DELETE FROM strings_search WHERE name = old.name AND item = old.item;\r\nEND;',
      'strings_search_before_delete');
  late final Trigger stringsSearchAfterUpdate = Trigger(
      'CREATE TRIGGER strings_search_after_update\r\n    AFTER UPDATE\r\n    ON strings\r\nBEGIN\r\n    UPDATE strings_search\r\n    SET item  = new.item,\r\n        name  = new.name,\r\n        value = new.value\r\n    WHERE item = new.item\r\n      AND name = new.name;\r\nEND;',
      'strings_search_after_update');
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
        stringsSearchAfterInsert,
        stringsSearchBeforeDelete,
        stringsSearchAfterUpdate,
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
              TableUpdate('strings_search', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('strings', limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('strings_search', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}
