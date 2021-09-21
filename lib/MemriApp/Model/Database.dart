import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/NavigationStack.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Model/DateTimeConverter.dart';
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

  Future<Item?> itemRecordFetchWithUID(String uid) async {
    return await (select(items)..where((t) => t.id.equals(uid))).getSingleOrNull();
  }

  Future<Item?> itemRecordFetchWithRowId(int id) async {
    return await (select(items)..where((t) => t.rowId.equals(id))).getSingleOrNull();
  }

  Future<Item?> itemRecordFetchOne() async {
    return await (select(items)..limit(1)).getSingleOrNull();
  }

  Future<Item?> itemRecordFetchOneByType(String type) async {
    return await ((select(items)..where((t) => t.type.equals(type)))..limit(1)).getSingleOrNull();
  }

  Future<List<Item>> itemRecordsFetchByType(String type) async {
    return await (select(items)..where((t) => t.type.equals(type))).get();
  }

  Stream<List<dynamic>> itemRecordsFetchByTypeStream(String type) {
    return (select(items)..where((t) => t.type.equals(type))).watch();
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
      {String join = "",
      List<TableInfo>? joinTables,
      int? limit,
      int? offset,
      String? orderBy}) async {
    if (query == "") {
      return await customSelect(
          "SELECT * from items ${orderBy != null ? "ORDER BY $orderBy" : ""} ${limit != null ? "LIMIT $limit" : ""} ${limit != null ? "LIMIT $limit" : ""}",
          variables: binding,
          readsFrom: {items}).map((row) => Item.fromData(row.data, this)).get();
    }
    joinTables ??= [];
    return await customSelect(
        "SELECT items.* from items $join WHERE $query ${orderBy != null ? "GROUP BY row_id ORDER BY $orderBy" : ""} ${limit != null ? "LIMIT $limit" : ""} ${offset != null ? "OFFSET $offset" : ""}",
        variables: binding,
        readsFrom: {items, ...joinTables}).map((row) => Item.fromData(row.data, this)).get();
  }

  Future<int> itemPropertyRecordInsert(ItemPropertyRecord record) async {
    var data = getItemPropertyRecordTableData(record);
    return await into(data.table).insert(data.companion);
  }

  Future itemPropertyRecordInsertAll(List<ItemPropertyRecord> records) async {
    List<StringsCompanion> stringCompanions = [];
    List<IntegersCompanion> integerCompanions = [];
    List<RealsCompanion> realCompanions = [];

    for (var record in records) {
      var data = getItemPropertyRecordTableData(record);
      if (data.table is Strings) {
        stringCompanions.add(data.companion as StringsCompanion);
      } else if (data.table is Integers) {
        integerCompanions.add(data.companion as IntegersCompanion);
      } else {
        realCompanions.add(data.companion as RealsCompanion);
      }
    }

    await batch((batch) {
      batch.insertAll(strings, stringCompanions);
      batch.insertAll(integers, integerCompanions);
      batch.insertAll(reals, realCompanions);
    });
  }

  Future schemaImportTransaction(dynamic items) async {
    return transaction(() async {
      var properties = items["properties"];
      var edges = items["edges"];
      List<StringsCompanion> stringCompanions = [];
      for (var property in properties) {
        var itemType = property["item_type"];
        var propertyName = property["property"];
        var propertyValue = property["value_type"];
        if (itemType is String && propertyName is String && propertyValue is String) {
          var recordRowId = await itemRecordInsert(ItemRecord(type: "ItemPropertySchema"));
          stringCompanions.addAll([
            StringsCompanion(
                item: Value(recordRowId), name: Value("itemType"), value: Value(itemType)),
            StringsCompanion(
                item: Value(recordRowId), name: Value("propertyName"), value: Value(propertyName)),
            StringsCompanion(
                item: Value(recordRowId), name: Value("valueType"), value: Value(propertyValue))
          ]);
        }
      }
      for (var edge in edges) {
        var sourceType = edge["source_type"];
        var edgeName = edge["edge"];
        var targetType = edge["target_type"];
        if (sourceType is String && edgeName is String && targetType is String) {
          var recordRowId = await itemRecordInsert(ItemRecord(type: "ItemEdgeSchema"));
          stringCompanions.addAll([
            StringsCompanion(
                item: Value(recordRowId), name: Value("sourceType"), value: Value(sourceType)),
            StringsCompanion(
                item: Value(recordRowId), name: Value("edgeName"), value: Value(edgeName)),
            StringsCompanion(
                item: Value(recordRowId), name: Value("targetType"), value: Value(targetType))
          ]);
        }
      }
      await batch((batch) {
        batch.insertAll(strings, stringCompanions);
      });
    });
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

  Future<List<dynamic>> itemPropertyRecordsCustomSelect(String query,
      [List<Variable<dynamic>>? binding, bool isFTS = false]) async {
    binding ??= [];
    if (isFTS) {
      List<StringsSearchData> stringProps = await customSelect(
              "SELECT * from strings_search WHERE $query",
              variables: binding,
              readsFrom: {stringsSearch})
          .map((row) => StringsSearchData.fromData(row.data, this))
          .get();
      return stringProps;
    } else {
      List<IntegerDb> intProps = await customSelect("SELECT * from integers WHERE $query",
          variables: binding,
          readsFrom: {integers}).map((row) => IntegerDb.fromData(row.data, this)).get();
      List<StringDb> stringProps = await customSelect("SELECT * from strings WHERE $query",
          variables: binding,
          readsFrom: {strings}).map((row) => StringDb.fromData(row.data, this)).get();
      List<RealDb> realProps = await customSelect("SELECT * from reals WHERE $query",
          variables: binding,
          readsFrom: {reals}).map((row) => RealDb.fromData(row.data, this)).get();
      return [...intProps, ...stringProps, ...realProps];
    }
  }

  //TODO: reimplement all select queries as streams
  Stream<List<dynamic>> itemPropertyRecordsCustomSelectStream(String query,
      [List<Variable<dynamic>>? binding, bool isFTS = false]) {
    binding ??= [];
    if (isFTS) {
      return customSelect("SELECT * from strings_search WHERE $query",
              variables: binding, readsFrom: {stringsSearch})
          .map((row) => StringsSearchData.fromData(row.data, this))
          .watch();
    } else {
      return customSelect(
          "SELECT * FROM strings WHERE $query UNION SELECT * FROM integers WHERE $query UNION SELECT * FROM reals WHERE $query",
          variables: [...binding, ...binding, ...binding],
          readsFrom: {integers, strings, reals}).map((row) {
        if (row.data.isEmpty) {
          return [];
        } else {
          if (row.data["value"] is int) {
            return IntegerDb.fromData(row.data, this);
          } else if (row.data["value"] is double) {
            return RealDb.fromData(row.data, this);
          } else {
            return StringDb.fromData(row.data, this);
          }
        }
      }).watch();
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

  TableInfo getTable(String tableName) {
    switch (tableName) {
      case "integers":
        return integers;
      case "reals":
        return reals;
      case "strings":
        return strings;
      case "edges":
        return edges;
      case "items":
        return items;
      default:
        throw ("No such table");
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

  Future itemEdgeRecordInsertAll(List<ItemEdgeRecord> records) async {
    List<EdgesCompanion> edgeCompanions = [];
    for (var record in records) {
      edgeCompanions.add(await record.toCompanion(this));
    }

    await batch((batch) {
      batch.insertAll(edges, edgeCompanions);
    });
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

  Future<List<Edge>> edgeRecordsSelect(Map<String, dynamic> properties, [int? limit]) async {
    return await customSelect(
        "SELECT * from edges WHERE ${properties.keys.join(" = ? AND ") + " = ?"} ${limit != null ? "LIMIT $limit" : ""}",
        variables: properties.values.map((property) => Variable(property)).toList(),
        readsFrom: {edges}).map((row) => Edge.fromData(row.data, this)).get();
  }

  Future<List<Edge>> edgeRecordsCustomSelect(String query, List<Variable<dynamic>> binding) async {
    return await customSelect("SELECT * from edges WHERE $query",
        variables: binding, readsFrom: {edges}).map((row) => Edge.fromData(row.data, this)).get();
  }

  Future<NavigationStateData?> navigationStateFetchOne(String pageLabel) async {
    return await (select(navigationState)..where((t) => t.pageLabel.equals(pageLabel)))
        .getSingleOrNull();
  }

  Future<int> navigationStateSave(NavigationStack record) async {
    return await into(navigationState).insertOnConflictUpdate(record.toCompanion());
  }
}

class ItemPropertyRecordTableData {
  final TableInfo table;
  final UpdateCompanion companion;

  ItemPropertyRecordTableData({required this.table, required this.companion});
}
