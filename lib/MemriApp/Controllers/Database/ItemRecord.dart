import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Controllers/Syncing/SyncController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

import '../AppController.dart';
import 'DatabaseController.dart';
import 'ItemPropertyRecord.dart';

import 'package:json_annotation/json_annotation.dart';

part 'ItemRecord.g.dart';

@JsonSerializable()
class ItemRecord with EquatableMixin {
  int? rowId;
  String uid;
  String type;
  DateTime dateCreated;
  DateTime? dateServerModified;
  DateTime dateModified;
  bool deleted;

  SyncState syncState;
  bool syncHasPriority;

  ItemRecord(
      {this.rowId,
      String? uid,
      required this.type,
      DateTime? dateCreated,
      DateTime? dateModified,
      this.deleted = false,
      this.syncState = SyncState.create,
      this.syncHasPriority = false})
      : this.dateModified = dateModified ?? DateTime.now(),
        this.dateCreated = dateCreated ?? DateTime.now(),
        this.uid = uid ?? Uuid().v4();

  ItemRecord.fromItem(Item item)
      : rowId = item.rowId,
        uid = item.id,
        type = item.type,
        dateCreated = item.dateCreated,
        dateModified = item.dateModified,
        dateServerModified = item.dateServerModified,
        deleted = item.deleted,
        syncState = SyncState.create,
        syncHasPriority = false;

  ItemsCompanion toCompanion() {
    return ItemsCompanion(
        rowId: rowId == null ? const Value.absent() : Value(rowId!),
        id: Value(uid),
        type: Value(type),
        dateCreated: Value(dateCreated),
        dateModified: Value(dateModified),
        dateServerModified:
            dateServerModified == null ? const Value.absent() : Value(dateServerModified),
        deleted: Value(deleted),
        syncState: Value(syncState.inString),
        syncHasPriority: Value(syncHasPriority));
  }

  Future<ItemPropertyRecord?> property(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var properties = await db.databasePool.itemPropertyRecordsCustomSelect(
        "name = ? AND item = ?", [Variable(name), Variable(rowId)]);
    if (properties.length > 0) {
      SchemaValueType? valueType = db.schema.types[type]?.propertyTypes[name]?.valueType;
      return ItemPropertyRecord(
          itemRowID: properties[0].item,
          name: properties[0].name,
          value: PropertyDatabaseValue.create(properties[0].value, valueType!));
    }
    return null;
  }

  Future<List<ItemPropertyRecord>> properties([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var properties =
        await db.databasePool.itemPropertyRecordsCustomSelect("item = ?", [Variable(rowId)]);
    if (properties.length > 0) {
      return properties.map((property) {
        SchemaValueType? valueType =
            db?.schema.types[type]?.propertyTypes[property.name]?.valueType;
        return ItemPropertyRecord(
            itemRowID: property.item,
            name: property.name,
            value: PropertyDatabaseValue.create(property.value, valueType!));
      }).toList();
    }
    return [];
  }

  Future<PropertyDatabaseValue?> propertyValue(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var itemPropertyRecord = await property(name, db);
    if (itemPropertyRecord == null) {
      return null;
    }
    return itemPropertyRecord.value(type, db.schema);
  }

  save(Database db) async {
    var savedRowID = await db.itemRecordSave(this);
    if (rowId == null) rowId = savedRowID;
  }

  setPropertyValue(String name, PropertyDatabaseValue? value, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    /// Mark the item as modified, and mark for syncing (unless already marked as a newly created item to be synced)
    dateModified = DateTime.now();
    if (syncState != SyncState.create) {
      syncState = SyncState.update;
    }

    /// Save the item record including the above changes - do this before editing the property so we know the item definitely exists
    await save(db.databasePool);

    /// Create or update the property
    var itemPropertyRecord = await property(name, db);
    if (itemPropertyRecord != null) {
      if (value != null) {
        itemPropertyRecord.$value = value;
        await itemPropertyRecord.save(db.databasePool);
        await addChangeLog(name, value, db); //TODO: maybe we need audit for all actions
      } else {
        await itemPropertyRecord.delete(db.databasePool);
      }
    } else if (value != null) {
      itemPropertyRecord =
          ItemPropertyRecord(itemUID: uid, itemRowID: rowId!, name: name, value: value);
      await itemPropertyRecord.save(db.databasePool);
    }
  }

  static Future<ItemRecord?> fetchWithUID(String uid, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      Item item = await db.databasePool.itemRecordFetchWithUID(uid);
      return ItemRecord.fromItem(item);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<ItemRecord?> fetchWithRowID(int id, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      Item item = await db.databasePool.itemRecordFetchWithRowId(id);
      return ItemRecord.fromItem(item);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> insert(Database db) async {
    return await db.itemRecordInsert(this);
  }

  Future<int> delete(Database db) async {
    List<ItemPropertyRecord> itemPropertyRecords = await properties();
    await Future.forEach(itemPropertyRecords, (ItemPropertyRecord itemPropertyRecord) async {
      await itemPropertyRecord.delete(db);
    });

    return await db.itemRecordDelete(this);
  }

  Future<List<ItemEdgeRecord>> edges(String name, [DatabaseController? db]) async {
    //TODO: need to test
    db ??= AppController.shared.databaseController;
    try {
      var edges = await db.databasePool.edgeRecordsSelect({"source": rowId, "name": name});
      return edges
          .map((edge) => ItemEdgeRecord.fromEdge(edge))
          .whereType<ItemEdgeRecord>()
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ItemRecord?> edgeItem(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      var edge = await db.databasePool.edgeRecordSelect({"source": rowId, "name": name});
      if (edge != null) {
        return await ItemEdgeRecord.fromEdge(edge).targetItem(db);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ItemRecord>> edgeItems(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      var edges = await db.databasePool.edgeRecordsSelect({"source": rowId, "name": name});
      return (await Future.wait(
              edges.map((edge) async => await ItemEdgeRecord.fromEdge(edge).targetItem(db!))))
          .whereType<ItemRecord>()
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ItemRecord?> reverseEdgeItem(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    try {
      var edge = await db.databasePool.edgeRecordSelect({"target": rowId, "name": name});
      if (edge != null) {
        return await ItemEdgeRecord.fromEdge(edge).owningItem(db);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ItemRecord>> reverseEdgeItems(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    try {
      var edges = await db.databasePool.edgeRecordsSelect({"target": rowId, "name": name});
      return (await Future.wait(
              edges.map((edge) async => await ItemEdgeRecord.fromEdge(edge).owningItem(db!))))
          .whereType<ItemRecord>()
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<FutureBinding> propertyBinding(
      {required String name, dynamic defaultValue, DatabaseController? db, Type? type}) async {
    db ??= AppController.shared.databaseController;
    switch (type) {
      case bool:
        return FutureBinding<bool>(
            () async => (await propertyValue(name, db))?.asBool() ?? defaultValue,
            (newValue) async {
          await setPropertyValue(name, PropertyDatabaseValueBool(newValue), db);
        });
      default:
        return FutureBinding<String>(
            () async =>
                (await propertyValue(name, db))?.asString() ?? defaultValue?.toString() ?? "",
            (newValue) async {
          await setPropertyValue(name, PropertyDatabaseValueString(newValue), db);
        });
    }
  }

  factory ItemRecord.fromJson(Map<String, dynamic> json) => _$ItemRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ItemRecordToJson(this);

  @override
  List<Object> get props => [uid, type];

/*
    func syncDict(db: Database, schema: Schema) -> [String: AnyEncodable] {
        let properties = try! request(for: ItemRecord.properties).fetchAll(db)
//        let edges = try! request(for: ItemRecord.edges).fetchAll(db)
        return _syncDict(properties: properties, schema: schema)//, edges: edges)
    }

    func _syncDict(properties: [ItemPropertyRecord], schema: Schema) -> [String: AnyEncodable] { //, edges: [ItemEdgeRecord]
        let keyProperties: [String: AnyEncodable] = [
            "_type": type,
            "uid": uid,
            "dateCreated": DatabaseHelperFunctions.encode(dateCreated),
            "dateModified": DatabaseHelperFunctions.encode(dateModified),
            "version": version,
            "deleted": deleted,
        ].mapValues { AnyEncodable($0) }

        let otherProperties: [(String, AnyEncodable)] = properties.compactMap {
            guard let propertyValue = $0.value(itemType: type, schema: schema) else { return nil }
            return ($0.name, AnyEncodable(propertyValue))
        }

        return keyProperties
            .merging(otherProperties, uniquingKeysWith: { a, b in a })
    }
  */
  static Future<List<ItemRecord>> search(DatabaseController dbController, String pattern) async {
    List<dynamic> list = await dbController.databasePool
        .itemPropertyRecordsCustomSelect("value MATCH ?", [Variable.withString(pattern)], true);
    return await Future.wait(list.map((el) async => ItemRecord.fromItem(
        await dbController.databasePool.itemRecordFetchWithRowId(int.parse(el.item)))));
  }

  static Future<ItemRecord?> get me async {
    DatabaseController dbController = AppController.shared.databaseController;
    var edge = await dbController.databasePool.edgeRecordSelect({"name": "me"});
    if (edge == null) {
      return null;
    }

    return await ItemRecord.fetchWithRowID(edge.target, dbController);
  }

  addChangeLog(String name, PropertyDatabaseValue? value,
      [DatabaseController? dbController]) async {
    dbController ??= AppController.shared.databaseController;
    var auditItem = ItemRecord(type: "AuditItem");
    await auditItem.save(dbController.databasePool);
    if (rowId == null || auditItem.rowId == null) {
      throw Exception("Add changelog: Item doesn't have row id, possibly not saved?");
    }

    await auditItem.setPropertyValue(
        "date", PropertyDatabaseValueDatetime(DateTime.now()), dbController);
    await auditItem.setPropertyValue("content", PropertyDatabaseValueString(name), dbController);
    await auditItem.setPropertyValue("action", PropertyDatabaseValueString("edit"), dbController);
    await ItemEdgeRecord(sourceRowID: rowId, name: "changelog", targetRowID: auditItem.rowId)
        .save(dbController.databasePool);
  }
}
