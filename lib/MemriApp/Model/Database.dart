import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:moor/moor.dart';

export 'shared.dart';

part 'Database.g.dart';

@UseMoor(
  include: {'tables.moor'},
)
class Database extends _$Database {
  Database(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
    );
  }

  Future resetDb() async {
    for (var table in allTables) {
      await delete(table).go();
    }
  }

  Future<Item> itemRecordFetchWithUID(String uid) async {
    return await (select(items)..where((t) => t.id.equals(uid))).getSingle();
  }

  Future<Item> itemRecordFetchWithRowId(int id) async {
    return await (select(items)..where((t) => t.rowId.equals(id))).getSingle();
  }

  Future<Item?> itemRecordFetchOne() async {
    return await (select(items)..limit(1)).getSingleOrNull();
  }

  Future<int> itemRecordInsert(ItemRecord record) async {
    return await into(items).insert(record.toCompanion());
  }

  Future<int> itemRecordSave(ItemRecord record) async {
    return await into(items).insertOnConflictUpdate(record.toCompanion());
  }

  Future<int> itemRecordDelete(ItemRecord record) async {
    return await (delete(items)..where((tbl) => tbl.rowId.equals(record.rowId))).go();
  }

  Future<List<Item>> itemRecordsCustomSelect(String query, List<Variable<dynamic>> binding,
      {String join = "", List<TableInfo>? joinTables}) async {
    if (query == "") {
      return await customSelect("SELECT * from items", variables: binding, readsFrom: {items})
          .map((row) => Item.fromData(row.data, this))
          .get();
    }
    joinTables ??= [];
    return await customSelect("SELECT * from items $join WHERE $query",
        variables: binding,
        readsFrom: {items, ...joinTables}).map((row) => Item.fromData(row.data, this)).get();
  }

  Future<int> itemPropertyRecordInsert(ItemPropertyRecord record) async {
    var data = getItemPropertyRecordTableData(record);
    return into(data.table).insert(data.companion);
  }

  Future<void> itemPropertyRecordDelete(ItemPropertyRecord record) async {
    var data = getItemPropertyRecordTableData(record);
    TableInfo tbl = data.table;
    await (delete(tbl)
          ..where((tbl) {
            if (tbl is Integers) {
              //TODO find a way to avoid this?
              return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
            } else if (tbl is Strings) {
              return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
            } else if (tbl is Reals) {
              return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
            } else {
              throw Exception("Unknown table ${tbl.toString()}");
            }
          }))
        .go();
  }

  Future<dynamic> itemPropertyRecordSave(ItemPropertyRecord record) async {
    var data = getItemPropertyRecordTableData(record);
    var property = await itemPropertyRecordsCustomSelect(
        "name = ? AND item = ?", [Variable(record.name), Variable(record.itemRowID)]);
    if (property.length > 0) {
      return await (update(data.table)
            ..where((tbl) {
              if (tbl is Integers) {
                //TODO find a way to avoid this?
                return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
              } else if (tbl is Strings) {
                return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
              } else if (tbl is Reals) {
                return tbl.item.equals(record.itemRowID) & tbl.name.equals(record.name);
              } else {
                throw Exception("Unknown table ${data.table.toString()}");
              }
            }))
          .write(data.companion);
    } else {
      return into(data.table).insert(data.companion);
    }
  }

  Future<List<dynamic>> itemPropertyRecordsCustomSelect(
      String query, List<Variable<dynamic>> binding,
      [bool isFTS = false]) async {
    if (isFTS) {
      try {
        List<StringsSearchData> stringProps = await customSelect(
                "SELECT * from strings_search WHERE $query",
                variables: binding,
                readsFrom: {stringsSearch})
            .map((row) => StringsSearchData.fromData(row.data, this))
            .get();
        return stringProps;
      } catch (e) {
        if (e.toString().contains('267')) {
          //workaround for corrupted fts index until we find better solution
          await customInsert("INSERT INTO strings_search(strings_search) VALUES('rebuild')");
          List<StringsSearchData> stringProps = await customSelect(
                  "SELECT * from strings_search WHERE $query",
                  variables: binding,
                  readsFrom: {stringsSearch})
              .map((row) => StringsSearchData.fromData(row.data, this))
              .get();
          return stringProps;
        }
        throw e;
      }
    } else {
      List<IntegerDb> intProps = await customSelect("SELECT * from integers WHERE $query",
          variables: binding,
          readsFrom: {integers}).map((row) => IntegerDb.fromData(row.data, this)).get();
      List<StringDb> stringProps = await customSelect("SELECT * from strings WHERE $query",
          variables: binding,
          readsFrom: {strings}).map((row) => StringDb.fromData(row.data, this)).get();
      List<RealDb> realProps = await customSelect("SELECT * from reals WHERE $query",
          variables: binding,
          readsFrom: {integers}).map((row) => RealDb.fromData(row.data, this)).get();
      return [...intProps, ...stringProps, ...realProps];
    }
  }

  TableInfo getItemPropertyRecordTable(ItemRecordPropertyTable table) {
    switch (table) {
      case ItemRecordPropertyTable.integers:
        return integers;
      case ItemRecordPropertyTable.reals:
        return reals;
      case ItemRecordPropertyTable.strings:
        return strings;
    }
  }

  ItemPropertyRecordTableData getItemPropertyRecordTableData(ItemPropertyRecord record) {
    ItemRecordPropertyTable table = PropertyDatabaseValue.toDBTableName(record.$value.type);
    switch (table) {
      case ItemRecordPropertyTable.integers:
        var value = record.$value.value;
        if (value is bool) {
          value = value ? 1 : 0;
        } else if (value is DateTime) {
          value = value.millisecondsSinceEpoch;
        }
        return ItemPropertyRecordTableData(
            table: integers,
            companion: IntegersCompanion(
                item: Value(record.itemRowID), name: Value(record.name), value: Value(value)));
      case ItemRecordPropertyTable.reals:
        return ItemPropertyRecordTableData(
            table: reals,
            companion: RealsCompanion(
                item: Value(record.itemRowID),
                name: Value(record.name),
                value: Value(record.$value.value)));
      case ItemRecordPropertyTable.strings:
        return ItemPropertyRecordTableData(
            table: strings,
            companion: StringsCompanion(
                item: Value(record.itemRowID),
                name: Value(record.name),
                value: Value(record.$value.value)));
    }
  }

  Future<int> itemEdgeRecordInsert(ItemEdgeRecord record) async {
    return into(edges).insert(await record.toCompanion(this));
  }

  Future<int> itemEdgeRecordSave(ItemEdgeRecord record) async {
    return into(edges).insertOnConflictUpdate(await record.toCompanion(this));
  }

  Future<int> itemEdgeRecordDelete(ItemEdgeRecord record) async {
    await (delete(items)..where((tbl) => tbl.rowId.equals(record.selfRowID))).go();
    return (delete(edges)..where((tbl) => tbl.self.equals(record.selfRowID))).go();
  }

  Future<Edge?> edgeRecordSelect(Map<String, dynamic> properties) async {
    return await customSelect(
        "SELECT * from edges WHERE ${properties.keys.join(" = ? AND ") + " = ?"} LIMIT 1",
        variables: properties.values.map((property) => Variable(property)).toList(),
        readsFrom: {edges}).map((row) => Edge.fromData(row.data, this)).getSingleOrNull();
  }

  Future<List<Edge>> edgeRecordsSelect(Map<String, dynamic> properties) async {
    return await customSelect(
        "SELECT * from edges WHERE ${properties.keys.join(" = ? AND ") + " = ?"}",
        variables: properties.values.map((property) => Variable(property)).toList(),
        readsFrom: {edges}).map((row) => Edge.fromData(row.data, this)).get();
  }

  Future<List<Edge>> edgeRecordsCustomSelect(String query, List<Variable<dynamic>> binding) async {
    return await customSelect("SELECT * from edges WHERE $query",
        variables: binding, readsFrom: {edges}).map((row) => Edge.fromData(row.data, this)).get();
  }

  Future<NavigationStateData?> navigationStateFetchOne() async {
    return await select(navigationState).getSingleOrNull();
  }
}

class ItemPropertyRecordTableData {
  final TableInfo table;
  final UpdateCompanion companion;

  ItemPropertyRecordTableData({required this.table, required this.companion});
}
