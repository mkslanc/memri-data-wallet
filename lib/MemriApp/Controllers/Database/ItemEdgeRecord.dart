import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';

import '../AppController.dart';
import 'ItemRecord.dart';

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

  Future<EdgesCompanion> toCompanion(Database db) async {
    if (selfRowID == null) {
      Item self = (await db.itemRecordFetchWithUID(selfUID!))!;
      selfRowID = self.rowId;
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

  Future<ItemRecord?> owningItem(DatabaseController db) async {
    return await ItemRecord.fetchWithRowID(sourceRowID!, db);
  }

  Future<ItemRecord?> targetItem(DatabaseController db) async {
    return await ItemRecord.fetchWithRowID(targetRowID!, db);
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
      selfRowID = await selfRecord.insert(db);
    }
  }

  Future<bool> delete([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    var rows = await db.itemEdgeRecordDelete(this);
    return rows > 0;
  }

  static Future<List<Map<String, dynamic>>> syncEdgesWithState(
      {required SyncState state, int maxItems = 100, DatabaseController? dbController}) async {
    dbController ??= AppController.shared.databaseController;

    /// Select the items to sync, giving priority to those marked as `syncHasPriority`
    var edges = (await dbController.databasePool
        .edgeRecordsSelect({"syncState": state.inString}, maxItems));
    var syncEdges = (await Future.wait(
            edges.map((edge) async => await ItemEdgeRecord.fromEdge(edge).syncDict(dbController))))
        .whereType<Map<String, dynamic>>()
        .toList();

    return syncEdges;
  }

  Future<Map<String, dynamic>?> syncDict([DatabaseController? dbController]) async {
    if (sourceRowID == null || targetRowID == null) {
      return null;
    }
    var sourceItem = await ItemRecord.fetchWithRowID(sourceRowID!, dbController);
    var targetItem = await ItemRecord.fetchWithRowID(targetRowID!, dbController);
    if (sourceItem == null ||
        targetItem == null ||
        sourceItem.syncState == SyncState.create ||
        targetItem.syncState == SyncState.create) {
      return null;
    }

    return {"_source": sourceItem.uid, "_target": targetItem.uid, "_name": name};
  }

  static didSyncEdges(PodAPIPayloadBulkAction syncItems, String? error,
      [DatabaseController? dbController]) async {
    if (error != null) {
      throw Exception("Sync Failed");
    }
    dbController ??= AppController.shared.databaseController;

    for (var syncedEdge in syncItems.createEdges) {
      var sourceItemId = syncedEdge["_source"];
      var targetItemId = syncedEdge["_target"];
      var name = syncedEdge["_name"];
      if (sourceItemId != null && targetItemId != null && name != null) {
        var sourceItem = await ItemRecord.fetchWithUID(sourceItemId, dbController);
        var targetItem = await ItemRecord.fetchWithUID(targetItemId, dbController);
        var edge = await dbController.databasePool.edgeRecordSelect(
            {"source": sourceItem?.rowId, "target": targetItem?.rowId, "name": name});
        if (sourceItem != null && targetItem != null && edge != null) {
          var edgeRecord = ItemEdgeRecord.fromEdge(edge);
          edgeRecord.syncState = SyncState.noChanges;
          await edgeRecord.save(dbController.databasePool);
        } else {
          print("ERROR: Count not locate edge for synced edge: $syncedEdge");
        }
      } else {
        print("ERROR: Count not locate edge for synced edge: $syncedEdge");
      }
    }
  }
}
