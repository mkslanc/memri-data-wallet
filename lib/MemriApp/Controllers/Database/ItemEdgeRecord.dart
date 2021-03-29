import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';

class ItemEdgeRecord {
  String selfUID;
  String sourceUID;
  String name;
  String targetUID;

  ItemEdgeRecord(
      {required this.selfUID,
      required this.sourceUID,
      required this.name,
      required this.targetUID});

  Future<EdgesCompanion> toCompanion(Database db) async {
    Item self = await db.itemRecordFetchWithUID(selfUID);
    Item source = await db.itemRecordFetchWithUID(sourceUID);
    Item target = await db.itemRecordFetchWithUID(targetUID);
    return EdgesCompanion(
      self: Value(self.rowId!),
      source: Value(source.rowId!),
      name: Value(name),
      target: Value(target.rowId!),
    );
  }

  insert(Database db) async {
    return await db.itemEdgeRecordInsert(this);
  }

/*

    ItemRecord? owningItem(Database db)  {
       return ItemRecord.filter(key: sourceUID).fetchOne(db);
    }

    ItemRecord? targetItem(Database db) {
        return ItemRecord.filter(key: targetUID).fetchOne(db);
    }

  Map<String, dynamic> _syncDict() {
    Map<String, dynamic> keyProperties = {
      "_type": name,
      "_source": sourceUID,
      "_target": targetUID
    };

    return keyProperties;
  }
*/

  save(Database db) async {
    return await db.itemEdgeRecordSave(this);
  }
}
