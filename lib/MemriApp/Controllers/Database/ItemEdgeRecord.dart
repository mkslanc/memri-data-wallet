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

  ItemEdgeRecord(
      {required this.name,
      this.selfUID,
      this.sourceUID,
      this.targetUID,
      this.selfRowID,
      this.sourceRowID,
      this.targetRowID});

  ItemEdgeRecord.fromEdge(Edge edge)
      : name = edge.name,
        selfRowID = edge.self,
        sourceRowID = edge.source,
        targetRowID = edge.target;

  Future<EdgesCompanion> toCompanion(Database db) async {
    if (selfRowID == null) {
      Item self = await db.itemRecordFetchWithUID(selfUID!);
      selfRowID = self.rowId!;
    }
    if (sourceRowID == null) {
      Item source = await db.itemRecordFetchWithUID(sourceUID!);
      sourceRowID = source.rowId!;
    }
    if (targetRowID == null) {
      Item target = await db.itemRecordFetchWithUID(targetUID!);
      targetRowID = target.rowId!;
    }
    return EdgesCompanion(
      self: Value(selfRowID!),
      source: Value(sourceRowID!),
      name: Value(name),
      target: Value(targetRowID!),
    );
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

/*
  Map<String, dynamic> _syncDict() {
    Map<String, dynamic> keyProperties = {
      "_type": name,
      "_source": sourceUID,
      "_target": targetUID
    };

    return keyProperties;
  }
*/

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
}
