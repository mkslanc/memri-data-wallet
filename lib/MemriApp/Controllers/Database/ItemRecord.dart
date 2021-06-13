import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import '../AppController.dart';
import 'DatabaseController.dart';
import 'ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

enum SyncState {
  create,
  update,
  noChanges,
  failed,
}

extension SyncStateExtension on SyncState {
  static SyncState rawValue(String value) =>
      SyncState.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

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
      uid,
      required this.type,
      dateCreated,
      dateModified,
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
        syncState = SyncStateExtension.rawValue(item.syncState),
        syncHasPriority = item.syncHasPriority;

  ItemRecord.fromSyncDict(Map<String, dynamic> dict)
      : uid = dict["id"],
        type = dict["type"],
        dateCreated = DateTime.fromMillisecondsSinceEpoch(dict["dateCreated"]),
        dateModified = DateTime.fromMillisecondsSinceEpoch(dict["dateModified"]),
        dateServerModified = DateTime.fromMillisecondsSinceEpoch(dict["dateServerModified"]),
        deleted = dict["deleted"],
        syncState = SyncState.noChanges,
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

    /// Create or update the property
    var itemPropertyRecord = await property(name, db);
    if (itemPropertyRecord != null) {
      if (value != null) {
        itemPropertyRecord.$value = value;
        await itemPropertyRecord.save(db.databasePool);
      } else {
        await itemPropertyRecord.delete(db.databasePool);
      }
    } else if (value != null) {
      itemPropertyRecord =
          ItemPropertyRecord(itemUID: uid, itemRowID: rowId!, name: name, value: value);
      await itemPropertyRecord.save(db.databasePool);
    }
    syncState = SyncState.update;

    /// Save the item record including the above changes - do this before editing the property so we know the item definitely exists
    await save(db.databasePool);
    //await addChangeLog(name, value, db); //TODO
  }

  static Future<ItemRecord?> fetchWithUID(String uid, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      Item? item = await db.databasePool.itemRecordFetchWithUID(uid);
      if (item == null) return null;
      return ItemRecord.fromItem(item);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<ItemRecord?> fetchWithRowID(int id, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      Item? item = await db.databasePool.itemRecordFetchWithRowId(id);
      if (item == null) return null;
      return ItemRecord.fromItem(item);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<ItemRecord>> fetchWithType(String type, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    List<Item> item = await db.databasePool.itemRecordsFetchByType(type);
    return item.map((e) => ItemRecord.fromItem(e)).toList();
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

  @override
  List<Object> get props => [uid, type];

  static Future<List<ItemRecord>> search(DatabaseController dbController, String pattern) async {
    List<dynamic> list = await dbController.databasePool
        .itemPropertyRecordsCustomSelect("value MATCH ?", [Variable.withString(pattern)], true);
    return (await Future.wait(list.map((el) async {
      Item? item = await dbController.databasePool.itemRecordFetchWithRowId(int.parse(el.item));
      if (item == null) return null;
      return ItemRecord.fromItem(item);
    })))
        .whereType<ItemRecord>()
        .toList();
  }

  static Future<ItemRecord?> get me async {
    DatabaseController dbController = AppController.shared.databaseController;
    var edge = await dbController.databasePool.edgeRecordSelect({"name": "me"});
    if (edge == null) {
      return null;
    }

    return await ItemRecord.fetchWithRowID(edge.target, dbController);
  }

  static Future<ItemRecord?> createMe([DatabaseController? dbController]) async {
    dbController ??= AppController.shared.databaseController;
    var myself = ItemRecord(type: "Person");
    await myself.save(dbController.databasePool);

    await ItemEdgeRecord(sourceRowID: myself.rowId, name: "me", targetRowID: myself.rowId).save();
    return myself;
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

  static mapSchemaValueType(String nativeType) {
    switch (nativeType) {
      case "string":
        return "Text";
      case "int":
        return "Integer";
      case "double":
        return "Real";
      case "bool":
        return "Bool";
      case "datetime":
        return "DateTime";
      default:
        return null;
    }
  }

  static mapSchemaPropertyName(String propertyName) {
    switch (propertyName) {
      case "action":
        return "actionName";
      case "query":
        return "queryName";
      case "key":
        return "keyName";
      case "type":
        return "typeName";
      default:
        return propertyName;
    }
  }

  static Future<ItemRecord?> fromSyncItemDict(
      {required Map<String, dynamic> dict, required DatabaseController dbController}) async {
    var id = dict["id"];
    if (id == null) {
      return null;
    }

    ItemRecord? item = await ItemRecord.fetchWithUID(id, dbController);
    if (item == null) {
      item = ItemRecord.fromSyncDict(dict);
      await item.save(dbController.databasePool);
    }
    await Future.forEach(dict.entries, (MapEntry entry) async {
      var expectedType = dbController.schema.types[item!.type]?.propertyTypes[entry.key];
      if (expectedType == null) {
        return;
      }
      var databaseValue = PropertyDatabaseValue.create(entry.value, expectedType.valueType);
      await item.setPropertyValue(entry.key, databaseValue, dbController);
    });

    return item;
  }

  Future<Map<String, dynamic>?> schemaDict(DatabaseController dbController) async {
    if (rowId != null) {
      var itemType = (await property("itemType", dbController))?.$value.value;
      var propertyName = (await property("propertyName", dbController))?.$value.value;
      var valueType = (await property("valueType", dbController))?.$value.value;
      var schemaValueType = ItemRecord.mapSchemaValueType(valueType);
      if (itemType == null ||
          propertyName == null ||
          valueType == null ||
          schemaValueType == null) {
        return null;
      }
      return {
        "id": uid,
        "type": "ItemPropertySchema",
        "itemType": itemType,
        "propertyName": ItemRecord.mapSchemaPropertyName(propertyName),
        "valueType": schemaValueType
      };
    }
    return null;
  }

  Map<String, dynamic> mergeDict(
      {required List<ItemPropertyRecord> properties, required Schema schema}) {
    Map<String, dynamic> keyProperties = {
      "type": type,
      "id": uid,
      "dateCreated": dateCreated.millisecondsSinceEpoch,
      "dateModified": dateModified.millisecondsSinceEpoch,
      "deleted": deleted,
    };

    properties.forEach((element) {
      var propertyValue = element.$value.value;
      keyProperties.addEntries([MapEntry(element.name, propertyValue)]);
    });

    return keyProperties;
  }

  Future<Map<String, dynamic>> syncDict(DatabaseController dbController) async {
    return mergeDict(properties: await properties(dbController), schema: dbController.schema);
  }

  static Future<List<Map<String, dynamic>>> syncItemsWithState(
      {required SyncState state, int maxItems = 100, DatabaseController? dbController}) async {
    dbController ??= AppController.shared.databaseController;

    /// Select the items to sync, giving priority to those marked as `syncHasPriority`
    var items = await dbController.databasePool.itemRecordsCustomSelect(
        "type != ? AND syncState = ?", [Variable("ItemPropertySchema"), Variable(state.inString)],
        limit: maxItems);
    var syncItems = (await Future.wait(
            items.map((item) async => await ItemRecord.fromItem(item).syncDict(dbController!))))
        .whereType<Map<String, dynamic>>()
        .toList();
    return syncItems;
  }

  static didSyncItems(PodAPIPayloadBulkAction syncItems, String? error,
      [DatabaseController? dbController]) async {
    if (error != null) {
      throw Exception("Sync Failed");
    }
    dbController ??= AppController.shared.databaseController;

    List<String> createItemIDs =
        syncItems.createItems.compactMap((el) => (el["id"] is String) ? el["id"] : null);

    List<String> updateItemIDs =
        syncItems.updateItems.compactMap((el) => (el["id"] is String) ? el["id"] : null);

    var allItems = createItemIDs;
    allItems.addAll(updateItemIDs);
    var now = DateTime.now();
    for (var itemId in allItems) {
      var item = await fetchWithUID(itemId, dbController);
      if (item != null) {
        item.syncState = SyncState.noChanges;
        item.dateServerModified = now;
        await item.save(dbController.databasePool);
      }
    }
  }

  static Future<ItemRecord?> lastSyncedItem([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    var items = (await db.itemRecordsCustomSelect(
        "syncState = ?", [Variable(SyncState.noChanges.inString)],
        orderBy: "dateServerModified DESC"));
    if (items.length > 0) {
      return ItemRecord.fromItem(items[0]);
    }
    return null;
  }
}
