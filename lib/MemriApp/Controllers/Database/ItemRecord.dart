import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Controllers/API/AuthKey.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Controllers/FileStorageController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';
import '../AppController.dart';
import 'DatabaseController.dart';
import 'ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ItemRecord.g.dart';

enum SyncState {
  skip,
  create,
  update,
  noChanges,
  failed,
}

enum FileState { skip, needsUpload, needsDownload, noChanges }

extension SyncStateExtension on SyncState {
  static SyncState rawValue(String value) =>
      SyncState.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

extension FileStateExtension on FileState {
  static FileState rawValue(String value) =>
      FileState.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

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
  FileState fileState;
  bool syncHasPriority;

  ItemRecord(
      {this.rowId,
      String? uid,
      required this.type,
      DateTime? dateCreated,
      DateTime? dateModified,
      this.deleted = false,
      this.syncState = SyncState.create,
      this.fileState = FileState.skip,
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
        fileState = FileStateExtension.rawValue(item.fileState),
        syncHasPriority = item.syncHasPriority;

  ItemRecord.fromSyncDict(Map<String, dynamic> dict)
      : uid = dict["id"],
        type = dict["type"],
        dateCreated = DateTime.fromMillisecondsSinceEpoch(dict["dateCreated"]),
        dateModified = DateTime.fromMillisecondsSinceEpoch(dict["dateModified"]),
        dateServerModified = DateTime.fromMillisecondsSinceEpoch(dict["dateServerModified"]),
        deleted = dict["deleted"],
        syncState = SyncState.noChanges,
        fileState = FileState.noChanges,
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
        fileState: Value(fileState.inString),
        syncHasPriority: Value(syncHasPriority));
  }

  Future<ItemPropertyRecord?> property(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var properties = await db.databasePool.itemPropertyRecordsCustomSelect(
        "name = ? AND item = ?", [Variable(name), Variable(rowId)]);
    if (properties.length > 0) {
      SchemaValueType? valueType = db.schema.expectedPropertyType(type, name);
      if (valueType == null) {
        throw Exception("Not found property $name for $type");
      }
      return ItemPropertyRecord(
          itemRowID: properties[0].item,
          name: properties[0].name,
          value: PropertyDatabaseValue.create(properties[0].value, valueType));
    }
    return null;
  }

  Future<List<ItemPropertyRecord>> properties([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var properties =
        await db.databasePool.itemPropertyRecordsCustomSelect("item = ?", [Variable(rowId)]);
    if (properties.length > 0) {
      return properties.map((property) {
        SchemaValueType? valueType = db?.schema.expectedPropertyType(type, property.name);
        if (valueType == null) {
          throw Exception("Not found property type ${property.name} for item $type");
        }
        return ItemPropertyRecord(
            itemRowID: property.item,
            name: property.name,
            value: PropertyDatabaseValue.create(property.value, valueType));
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

  Future<int> save([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    var savedRowID = await db.itemRecordSave(this);
    if (rowId == null) rowId = savedRowID;
    return rowId!;
  }

  setPropertyValue(String name, PropertyDatabaseValue? value,
      {SyncState state = SyncState.update, DatabaseController? db}) async {
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
    if (syncState != SyncState.skip) {
      syncState = state;
    }

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

  Future<int> delete(DatabaseController db) async {
    deleted = true;
    syncState = SyncState.update;
    var targetEdges = await edges(null, db: db, deleted: null);
    var sourceEdges = await reverseEdges(null, db: db, deleted: null);
    List<ItemEdgeRecord> relatedEdges = targetEdges + sourceEdges;

    await Future.forEach(relatedEdges, (ItemEdgeRecord edge) async => await edge.delete(db));

    return await save(db.databasePool);
  }

  Future<List<ItemEdgeRecord>> edges(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    db ??= AppController.shared.databaseController;
    try {
      Map<String, dynamic> properties = {"source": rowId};
      if (name != null) {
        properties["name"] = name;
      }
      var edges = await db.databasePool.edgeRecordsSelect(properties);
      var edgeRecords = edges.map<ItemEdgeRecord>((edge) => ItemEdgeRecord.fromEdge(edge)).toList();
      if (deleted != null) {
        edgeRecords = (await Future.wait(edgeRecords.map((edge) async {
          var itemRecord = await edge.selfItem(db!);
          return itemRecord.deleted == deleted ? edge : null;
        })))
            .compactMap<ItemEdgeRecord>();
      }

      return edgeRecords;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ItemRecord?> edgeItem(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    var edgeItemRecords = await edgeItems(name, db: db, deleted: deleted);
    return edgeItemRecords.asMap()[0];
  }

  Future<List<ItemRecord>> edgeItems(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    db ??= AppController.shared.databaseController;
    var edgeRecords = await edges(name, db: db, deleted: deleted);
    return (await Future.wait(edgeRecords.map((edge) async => edge.targetItem(db!)))).compactMap();
  }

  Future<List<ItemEdgeRecord>> reverseEdges(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    db ??= AppController.shared.databaseController;
    try {
      Map<String, dynamic> properties = {"target": rowId};
      if (name != null) {
        properties["name"] = name;
      }
      var edges = await db.databasePool.edgeRecordsSelect(properties);
      var edgeRecords = edges.map<ItemEdgeRecord>((edge) => ItemEdgeRecord.fromEdge(edge)).toList();
      if (deleted != null) {
        edgeRecords = (await Future.wait(edgeRecords.map((edge) async {
          var itemRecord = await edge.selfItem(db!);
          return itemRecord.deleted == deleted ? edge : null;
        })))
            .compactMap<ItemEdgeRecord>();
      }

      return edgeRecords;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ItemRecord?> reverseEdgeItem(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    var edgeItemRecords = await reverseEdgeItems(name, db: db, deleted: deleted);
    return edgeItemRecords.asMap()[0];
  }

  Future<List<ItemRecord>> reverseEdgeItems(String? name,
      {DatabaseController? db, bool? deleted = false}) async {
    db ??= AppController.shared.databaseController;
    var edgeRecords = await reverseEdges(name, db: db, deleted: deleted);
    return (await Future.wait(edgeRecords.map((edge) async => edge.owningItem(db!)))).compactMap();
  }

  Future<FutureBinding> propertyBinding(
      {required String name, dynamic defaultValue, DatabaseController? db, Type? type}) async {
    db ??= AppController.shared.databaseController;
    switch (type) {
      case bool:
        return FutureBinding<bool>(
            () async => (await propertyValue(name, db))?.asBool() ?? defaultValue,
            (newValue) async {
          await setPropertyValue(name, PropertyDatabaseValueBool(newValue), db: db);
        });
      default:
        return FutureBinding<String>(
            () async =>
                (await propertyValue(name, db))?.asString() ?? defaultValue?.toString() ?? "",
            (newValue) async {
          await setPropertyValue(name, PropertyDatabaseValueString(newValue), db: db);
        });
    }
  }

  factory ItemRecord.fromJson(Map<String, dynamic> json) => _$ItemRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ItemRecordToJson(this);

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

  static Future<ItemRecord?> me([DatabaseController? dbController]) async {
    dbController ??= AppController.shared.databaseController;
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

    await ItemEdgeRecord(sourceRowID: myself.rowId, name: "me", targetRowID: myself.rowId)
        .save(dbController.databasePool);
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

    await auditItem.setPropertyValue("date", PropertyDatabaseValueDatetime(DateTime.now()),
        db: dbController);
    await auditItem.setPropertyValue("content", PropertyDatabaseValueString(name),
        db: dbController);
    await auditItem.setPropertyValue("action", PropertyDatabaseValueString("edit"),
        db: dbController);
    await ItemEdgeRecord(sourceRowID: rowId, name: "changelog", targetRowID: auditItem.rowId)
        .save(dbController.databasePool);
  }

  static Map<String, String> _mapSchemaValueType = {
    "string": "Text",
    "int": "Integer",
    "double": "Real",
    "bool": "Bool",
    "datetime": "DateTime",
  };

  static String? mapSchemaValueType(String nativeType) {
    return _mapSchemaValueType[nativeType];
  }

  static String? reverseMapSchemaValueType(String propertyValue) {
    return _mapSchemaValueType.keys.firstWhere(
        (nativeType) => _mapSchemaValueType[nativeType] == propertyValue,
        orElse: () => propertyValue);
  }

  static Map<String, String> _mapSchemaPropertyName = {
    "action": "actionName",
    "query": "queryName",
    "key": "keyName",
    "type": "typeName",
  };

  static String mapSchemaPropertyName(String propertyName) {
    return _mapSchemaPropertyName[propertyName] ?? propertyName;
  }

  static String reverseMapSchemaPropertyName(String propertyName) {
    return _mapSchemaPropertyName.keys.firstWhere(
        (nativePropertyName) =>
            _mapSchemaPropertyName[nativePropertyName]?.toLowerCase() == propertyName.toLowerCase(),
        orElse: () => propertyName);
  }

  static getPropertyFromSync(itemType, propertyName, propertyValue) {
    switch (itemType) {
      case "ItemPropertySchema":
        switch (propertyName) {
          case "valueType":
            propertyValue = reverseMapSchemaValueType(propertyValue);
            break;
          case "propertyName":
            propertyValue = reverseMapSchemaPropertyName(propertyValue);
            break;
        }
        break;
      case "ItemEdgeSchema":
        switch (propertyName) {
          case "edgeName":
            propertyValue = reverseMapSchemaPropertyName(propertyValue);
            break;
        }
        break;
    }

    return propertyValue;
  }

  static Future<ItemRecord?> fromSyncItemDict(
      {required Map<String, dynamic> dict, required DatabaseController dbController}) async {
    var id = dict["id"];
    if (id == null) {
      return null;
    }

    ItemRecord? item = await ItemRecord.fetchWithUID(id, dbController);
    ItemRecord newItem = ItemRecord.fromSyncDict(dict);
    newItem.rowId = item?.rowId;
    await newItem.save(dbController.databasePool);

    if (dict["_item"] == null) {
      await Future.forEach(dict.entries, (MapEntry entry) async {
        if (newItem.type == "PluginRun" && entry.key == "status") {
          //TODO dirty hack to wait cvuStoredDefinition (edge) to be saved before status update
          return;
        }
        String propertyName = entry.key;
        var expectedType = dbController.schema.expectedPropertyType(newItem.type, propertyName);
        if (expectedType == null) {
          //first initialization with existing pod crashes without this
          if (newItem.type == "ItemPropertySchema" &&
              ["itemType", "propertyName", "valueType"].contains(propertyName)) {
            expectedType = SchemaValueType.string;
          } else {
            return;
          }
        }
        var propertyValue = getPropertyFromSync(newItem.type, propertyName, entry.value);
        var databaseValue = PropertyDatabaseValue.create(propertyValue, expectedType);
        await newItem.setPropertyValue(propertyName, databaseValue,
            db: dbController, state: SyncState.noChanges);

        // If the item has file and it does not exist on disk, mark the file to be downloaded
        if (newItem.type == "File" && propertyName == "filename") {
          String? fileName = entry.value;
          if (fileName != null &&
              !(await FileStorageController.fileExists(
                  (await FileStorageController.getFileStorageURL()) + "/$fileName"))) {
            newItem.fileState = FileState.needsDownload;
            newItem.save(dbController.databasePool);
          }
        }
      });
    }

    var edges = dict["[[edges]]"];
    if (edges is List && edges.isNotEmpty) {
      await Future.forEach(edges, (edge) async {
        if (edge is! Map<String, dynamic>) {
          return;
        }
        var edgeDict = {
          "self": edge["id"],
          "source": dict["id"],
          "name": edge["_edge"],
          "target": edge["_item"]["id"]
        };
        ItemRecord? item = await ItemRecord.fetchWithUID(edge["_item"]["id"], dbController);
        if (item == null) {
          await ItemRecord.fromSyncItemDict(dict: edge["_item"], dbController: dbController);
        }
        ItemRecord? self = await ItemRecord.fetchWithUID(edge["id"], dbController);
        if (self == null) {
          await ItemRecord.fromSyncItemDict(dict: edge, dbController: dbController);
        }
        await ItemEdgeRecord.fromSyncEdgeDict(dict: edgeDict, dbController: dbController);
      });
    }

    if (newItem.type == "ItemPropertySchema" || newItem.type == "ItemEdgeSchema") {
      await dbController.schema.load(dbController.databasePool);
    }
    if (newItem.type == "PluginRun") {
      //TODO dirty hack to wait cvuStoredDefinition (edge) to be saved before status update
      await newItem.setPropertyValue("status", PropertyDatabaseValueString(dict["status"]),
          state: SyncState.noChanges);
    }

    return newItem;
  }

  Future<Map<String, dynamic>?> schemaPropertyDict(DatabaseController dbController) async {
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

  Future<Map<String, dynamic>?> schemaEdgeDict(DatabaseController dbController) async {
    if (rowId != null) {
      var edgeName = (await property("edgeName", dbController))?.$value.value;
      var sourceType = (await property("sourceType", dbController))?.$value.value;
      var targetType = (await property("targetType", dbController))?.$value.value;

      if (edgeName == null || sourceType == null || targetType == null) {
        return null;
      }

      return {
        "id": uid,
        "type": "ItemEdgeSchema",
        "sourceType": sourceType,
        "edgeName": ItemRecord.mapSchemaPropertyName(edgeName),
        "targetType": targetType
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
      "dateServerModified": dateServerModified?.millisecondsSinceEpoch,
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
        "type != ? AND type != ? AND syncState = ?",
        [Variable("ItemPropertySchema"), Variable("ItemEdgeSchema"), Variable(state.inString)],
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
    var items = (await db.itemRecordsCustomSelect("", [], orderBy: "dateServerModified DESC"));
    if (items.length > 0) {
      return ItemRecord.fromItem(items[0]);
    }
    return null;
  }

  static Future<Map?> fileItemRecordToUpload() async {
    var itemList = await ItemRecord.fetchWithType("File");
    var item =
        itemList.firstWhereOrNull((itemRecord) => itemRecord.fileState == FileState.needsUpload);

    if (item == null) {
      return null;
    }

    String? fileName;
    var fileNameValue = await item.propertyValue("filename");
    if (fileNameValue is PropertyDatabaseValueString) {
      fileName = fileNameValue.value;
    }

    if (fileName == null) {
      return null;
    }

    return {"item": item, "fileName": fileName};
  }

  static didUploadFileForItem(ItemRecord item) async {
    var rowId = item.rowId;
    if (rowId == null) return;
    var fetchedItem = await ItemRecord.fetchWithRowID(rowId);
    if (fetchedItem == null) return;

    fetchedItem.fileState = FileState.noChanges;
    await fetchedItem.save();
  }

  static Future<Map?> fileItemRecordToDownload() async {
    var itemList = await ItemRecord.fetchWithType("File");
    var item =
        itemList.firstWhereOrNull((itemRecord) => itemRecord.fileState == FileState.needsDownload);

    if (item == null) {
      return null;
    }

    String? sha256;
    String? fileName;
    var sha256Value = await item.propertyValue("sha256");
    var fileNameValue = await item.propertyValue("filename");
    if (fileNameValue is PropertyDatabaseValueString &&
        sha256Value is PropertyDatabaseValueString) {
      sha256 = sha256Value.value;
      fileName = fileNameValue.value;
    }

    if (sha256 == null || fileName == null) {
      return null;
    }

    return {"item": item, "sha256": sha256, "fileName": fileName};
  }

  static didDownloadFileForItem(ItemRecord item) async {
    var rowId = item.rowId;
    if (rowId == null) return;
    var fetchedItem = await ItemRecord.fetchWithRowID(rowId);
    if (fetchedItem == null) {
      return;
    }

    fetchedItem.fileState = FileState.noChanges;
    await fetchedItem.save();
  }

  static deleteExistingDBKeys([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var dbKeys = await db.databasePool.itemRecordsFetchByType("CryptoKey");
    if (dbKeys.isNotEmpty) {
      await Future.forEach(
          dbKeys, (Item item) async => await ItemRecord.fromItem(item).delete(db!));
    }
  }

  static setOwnerAndDBKey(
      {required String privateKey,
      required String publicKey,
      required String dbKey,
      Database? db}) async {
    db ??= AppController.shared.databaseController.databasePool;
    try {
      await ItemRecord.deleteExistingDBKeys();
      var meRowId = (await ItemRecord.me())?.rowId ?? (await ItemRecord.createMe())?.rowId;
      if (meRowId == null) {
        throw Exception("Could not find me user");
      }

      await AuthKey(
              ownerId: meRowId,
              type: "64CharacterRandomHex",
              role: null,
              key: dbKey,
              name: "Memri Database Key",
              active: true)
          .save(db);
      var privateKeyItem = await AuthKey(
              ownerId: meRowId,
              type: "ED25519",
              role: "private",
              key: privateKey,
              name: "Memri Owner Key",
              active: true)
          .save(db);
      var publicKeyItem = await AuthKey(
              ownerId: meRowId,
              type: "ED25519",
              role: "public",
              key: publicKey,
              name: "Memri Owner Key",
              active: true)
          .save(db);

      await ItemEdgeRecord(sourceRowID: privateKeyItem!.rowId, name: "owner", targetRowID: meRowId)
          .save(db);
      await ItemEdgeRecord(sourceRowID: publicKeyItem!.rowId, name: "owner", targetRowID: meRowId)
          .save(db);
      await ItemEdgeRecord(
              sourceRowID: privateKeyItem.rowId,
              name: "publicKey",
              targetRowID: publicKeyItem.rowId)
          .save(db);
      await ItemEdgeRecord(
              sourceRowID: publicKeyItem.rowId,
              name: "privateKey",
              targetRowID: privateKeyItem.rowId)
          .save(db);
    } catch (error) {
      print("ERROR: setOwnerAndDBKey $error");
      throw Exception("Error deleting existing db keys");
    }
  }

  static Future<AuthKeys> getOwnerAndDBKey([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    var meRowId = (await ItemRecord.me())?.rowId;
    if (meRowId == null) {
      throw Exception("Could not find me user");
    }

    var items = await db.itemRecordsFetchByType("CryptoKey");
    ItemRecord? ownerKey, dbKey;
    var ownerKeyValue, dbKeyValue;
    if (items.isNotEmpty) {
      for (var item in items) {
        var itemRecord = ItemRecord.fromItem(item);
        if (await itemRecord.propertyValue("role") == PropertyDatabaseValueString("public")) {
          if (await itemRecord.propertyValue("active") == PropertyDatabaseValueBool(true)) {
            if ((await itemRecord.edgeItem("owner"))?.rowId == meRowId) {
              ownerKey = itemRecord;
              ownerKeyValue = (await ownerKey.propertyValue("keystr"))?.value;
            }
          }
        }
        if (await itemRecord.propertyValue("name") ==
            PropertyDatabaseValueString("Memri Database Key")) {
          if (await itemRecord.propertyValue("active") == PropertyDatabaseValueBool(true)) {
            dbKey = itemRecord;
            dbKeyValue = (await dbKey.propertyValue("keystr"))?.value;
          }
        }
      }
    }
    if (ownerKey == null || dbKey == null || ownerKeyValue == null || dbKeyValue == null) {
      throw Exception("Keys not found");
    }
    return AuthKeys(ownerKey: ownerKeyValue, dbKey: dbKeyValue);
  }
}
