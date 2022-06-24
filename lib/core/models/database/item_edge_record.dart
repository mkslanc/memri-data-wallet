import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/models/database/database.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:moor/moor.dart';

class ItemEdgeRecord {
  String name;

  String? selfUID;
  String? sourceUID;
  String? targetUID;

  int? selfRowID;
  int? sourceRowID;
  int? targetRowID;

  SyncState syncState;
  bool syncHasPriority;

  ItemEdgeRecord(
      {required this.name,
      this.selfUID,
      this.sourceUID,
      this.targetUID,
      this.selfRowID,
      this.sourceRowID,
      this.targetRowID,
      this.syncState = SyncState.create,
      this.syncHasPriority = false});

  ItemEdgeRecord.fromEdge(Edge edge)
      : name = edge.name,
        selfRowID = edge.self,
        sourceRowID = edge.source,
        targetRowID = edge.target,
        syncState = SyncStateExtension.rawValue(edge.syncState),
        syncHasPriority = edge.syncHasPriority;

  ItemEdgeRecord.fromSyncDict(Map<String, dynamic> dict)
      : name = dict["name"],
        selfUID = dict["self"],
        sourceUID = dict["source"],
        targetUID = dict["target"],
        selfRowID = dict["selfRowId"],
        sourceRowID = dict["sourceRowId"],
        targetRowID = dict["targetRowId"],
        syncState = SyncState.noChanges,
        syncHasPriority = false;

  Future<EdgesCompanion> toCompanion(Database db) async {
    if (selfRowID == null) {
      if (selfUID != null) {
        Item self = (await db.itemRecordFetchWithUID(selfUID!))!;
        selfRowID = self.rowId;
      } else {
        await insertSelfItemRecord(db);
      }
    }
    if (sourceRowID == null) {
      Item source = (await db.itemRecordFetchWithUID(sourceUID!))!;
      sourceRowID = source.rowId;
    }
    if (targetRowID == null) {
      Item target = (await db.itemRecordFetchWithUID(targetUID!))!;
      targetRowID = target.rowId;
    }
    return EdgesCompanion(
        self: Value(selfRowID!),
        source: Value(sourceRowID!),
        name: Value(name),
        target: Value(targetRowID!),
        syncState: Value(syncState.inString),
        syncHasPriority: Value(syncHasPriority));
  }

  Future<int> insert(Database db) async {
    await insertSelfItemRecord(db);
    return await db.itemEdgeRecordInsert(this);
  }

  static Future insertList(List<ItemEdgeRecord> records, {Database? db}) async {
    db ??= AppController.shared.databaseController.databasePool;
    var selfItemRecords = <ItemRecord>[];
    List<String> itemUIds = records
        .map((itemEdgeRecord) {
          List<String> currentUIds = [];
          if (itemEdgeRecord.selfRowID == null) {
            if (itemEdgeRecord.selfUID == null) {
              var selfItemRecord = ItemRecord(type: "Edge");
              selfItemRecords.add(selfItemRecord);
              itemEdgeRecord.selfUID = selfItemRecord.uid;
            }
            currentUIds.add(itemEdgeRecord.selfUID!);
          }
          if (itemEdgeRecord.sourceRowID == null)
            currentUIds.add(itemEdgeRecord.sourceUID!);
          if (itemEdgeRecord.targetRowID == null)
            currentUIds.add(itemEdgeRecord.targetUID!);
          return currentUIds;
        })
        .expand((element) => element)
        .toList();

    await ItemRecord.insertList(selfItemRecords, db: db);
    var itemRecords = await ItemRecord.fetchWithUIDs(itemUIds, db);
    var groupedItemRecords =
        itemRecords.toMapByKey((itemRecord) => itemRecord.uid);

    records.forEach((itemEdgeRecord) {
      itemEdgeRecord.selfRowID ??=
          groupedItemRecords[itemEdgeRecord.selfUID!]!.rowId;
      itemEdgeRecord.sourceRowID ??=
          groupedItemRecords[itemEdgeRecord.sourceUID!]!.rowId;
      itemEdgeRecord.targetRowID ??=
          groupedItemRecords[itemEdgeRecord.targetUID!]!.rowId;
    });

    var partItems = records.partition(5000);
    for (var part in partItems) {
      await db.itemEdgeRecordInsertAll(part);
    }
  }

  Future<ItemRecord> selfItem([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    return (await ItemRecord.fetchWithRowID(selfRowID!, db))!;
  }

  Future<ItemRecord?> owningItem(DatabaseController db) async {
    return await ItemRecord.fetchWithRowID(sourceRowID!, db);
  }

  Future<ItemRecord?> targetItem(DatabaseController db) async {
    return await ItemRecord.fetchWithRowID(targetRowID!, db);
  }

  static Future<List<ItemRecord>> selfItems(List<ItemEdgeRecord> edges,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var items = await ItemRecord.fetchWithRowIDs(
        edges.map((edge) => edge.selfRowID!).toList(), db.databasePool);
    return items;
  }

  static Future<List<ItemRecord>> owningItems(List<ItemEdgeRecord> edges,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    return (await ItemRecord.fetchWithRowIDs(
        edges.map((edge) => edge.sourceRowID!).toList(), db.databasePool));
  }

  static Future<List<ItemRecord>> targetItems(List<ItemEdgeRecord> edges,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    return (await ItemRecord.fetchWithRowIDs(
        edges.map((edge) => edge.targetRowID!).toList(), db.databasePool));
  }

  save([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    await insertSelfItemRecord(db);
    return await db.itemEdgeRecordSave(this);
  }

  insertSelfItemRecord([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    if (selfUID == null && selfRowID == null) {
      ItemRecord selfRecord = ItemRecord(type: "Edge");
      selfRecord.syncState = syncState;
      selfRowID = await selfRecord.insert(db);
    }
  }

  Future<bool> delete([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    var selfRecord = await selfItem(db);
    return await selfRecord.delete(db) > 0;
  }

  static Future<List<Map<String, dynamic>>> syncEdgesWithState(
      {required SyncState state,
      int maxItems = 100,
      DatabaseController? dbController}) async {
    dbController ??= AppController.shared.databaseController;

    /// Select the items to sync, giving priority to those marked as `syncHasPriority`
    var edges = (await dbController.databasePool
        .edgeRecordsSelect({"syncState": state.inString}, maxItems));
    var syncEdges = (await Future.wait(edges.map((edge) async =>
            await ItemEdgeRecord.fromEdge(edge).syncDict(dbController))))
        .whereType<Map<String, dynamic>>()
        .toList();

    return syncEdges;
  }

  static Future insertAll(List<ItemEdgeRecord> records,
      {DatabaseController? dbController}) async {
    dbController ??= AppController.shared.databaseController;
    return await dbController.databasePool.itemEdgeRecordInsertAll(records);
  }

  Future<Map<String, dynamic>?> syncDict(
      [DatabaseController? dbController]) async {
    if (sourceRowID == null || targetRowID == null || selfRowID == null) {
      return null;
    }
    var sourceItem =
        await ItemRecord.fetchWithRowID(sourceRowID!, dbController);
    var targetItem =
        await ItemRecord.fetchWithRowID(targetRowID!, dbController);
    var selfItem = await ItemRecord.fetchWithRowID(selfRowID!, dbController);
    if (sourceItem == null || targetItem == null || selfItem == null) {
      return null;
    }

    return {
      "_source": sourceItem.uid,
      "_target": targetItem.uid,
      "_self": selfItem.uid,
      "_name": name
    };
  }

  static didSyncEdges(PodPayloadBulkAction syncItems, String? error,
      [DatabaseController? dbController]) async {
    if (error != null) {
      throw Exception("Sync Failed");
    }
    dbController ??= AppController.shared.databaseController;

    for (var syncedEdge in syncItems.createEdges) {
      var selfItemId = syncedEdge["_self"];
      if (selfItemId != null) {
        var selfItem = await ItemRecord.fetchWithUID(selfItemId, dbController);
        var edge = await dbController.databasePool
            .edgeRecordSelect({"self": selfItem?.rowId});
        if (edge != null) {
          var edgeRecord = ItemEdgeRecord.fromEdge(edge);
          edgeRecord.syncState = SyncState.noChanges;
          await edgeRecord.save(dbController.databasePool);
          continue;
        }
      }

      AppLogger.err(
          "ERROR: Could not locate edge for synced edge: $syncedEdge");
    }
  }
}
