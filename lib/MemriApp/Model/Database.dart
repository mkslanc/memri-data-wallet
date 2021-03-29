import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:moor/moor.dart';

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

  Future<Item> itemRecordFetchWithUID(String uid) {
    return (select(items)..where((t) => t.id.equals(uid))).getSingle();
  }

  Future<int> itemRecordInsert(ItemRecord record) {
    return into(items).insert(record.toCompanion());
  }

  itemRecordsCustomSelect(String query, List<Variable<dynamic>> binding) async {
    return await customSelect("SELECT * from items WHERE $query",
        variables: binding,
        readsFrom: {items}).map((row) => Item.fromData(row.data, this)).get();
  }

  Future<int> itemPropertyRecordInsert(ItemPropertyRecord record) async {
    var data = await getItemPropertyRecordTableData(record);
    return into(data.table).insert(data.companion);
  }

  Future<void> itemPropertyRecordDelete(ItemPropertyRecord record) async {
    ItemRecordPropertyTable table =
        PropertyDatabaseValue.toDBTableName(record.$value.type);
    Item item = await itemRecordFetchWithUID(record.itemUID);
    this.customStatement(
        "DELETE FROM $table WHERE item = ${item.rowId} AND name = ${record.name}");
  }

  Future<int> itemPropertyRecordSave(ItemPropertyRecord record) async {
    var data = await getItemPropertyRecordTableData(record);
    return into(data.table).insertOnConflictUpdate(data.companion);
  }

  Future<ItemPropertyRecordTableData> getItemPropertyRecordTableData(
      ItemPropertyRecord record) async {
    ItemRecordPropertyTable table = PropertyDatabaseValue.toDBTableName(record.$value.type);
    Item item = await itemRecordFetchWithUID(record.itemUID);
    switch (table) {
      case ItemRecordPropertyTable.integers:
        return ItemPropertyRecordTableData(
            table: integers,
            companion: IntegersCompanion(
                item: Value(item.rowId!),
                name: Value(record.name),
                value: Value(record.$value.value)));
      case ItemRecordPropertyTable.reals:
        return ItemPropertyRecordTableData(
            table: reals,
            companion: RealsCompanion(
                item: Value(item.rowId!),
                name: Value(record.name),
                value: Value(record.$value.value)));
      case ItemRecordPropertyTable.strings:
        return ItemPropertyRecordTableData(
            table: strings,
            companion: StringsCompanion(
                item: Value(item.rowId!),
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
}

class ItemPropertyRecordTableData {
  final table;
  final UpdateCompanion companion;

  ItemPropertyRecordTableData({required this.table, required this.companion});
}
