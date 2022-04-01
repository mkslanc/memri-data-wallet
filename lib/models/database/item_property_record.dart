import 'package:memri/controllers/app_controller.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/models/database/database.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:moor/moor.dart';

import 'item_record.dart';

class ItemPropertyRecord {
  String? itemUID;
  int? itemRowID;
  String name;

  PropertyDatabaseValue? _$value;

  PropertyDatabaseValue get $value => _$value!;

  set $value(PropertyDatabaseValue $value) => _$value = $value;

  ItemPropertyRecord(
      {this.itemUID, this.itemRowID, required this.name, PropertyDatabaseValue? value})
      : _$value = value;

  PropertyDatabaseValue? value(String itemType, [Schema? schema]) {
    schema ??= AppController.shared.databaseController.schema;
    var expectedType = schema.types[itemType]?.propertyTypes[name]?.valueType;
    if (expectedType == null) {
      return null;
    }
    return PropertyDatabaseValue.createFromDBValue(
        Value($value.value), expectedType); //TODO: check with tests
  }

  insert(Database db) async {
    return await db.itemPropertyRecordInsert(this);
  }

  static Future insertList(List<ItemPropertyRecord> records, {Database? db}) async {
    db ??= AppController.shared.databaseController.databasePool;
    List<String> itemUIds = records
        .map((itemPropertyRecord) {
          List<String> currentUIds = [];
          if (itemPropertyRecord.itemRowID == null) currentUIds.add(itemPropertyRecord.itemUID!);
          return currentUIds;
        })
        .expand((element) => element)
        .toList();

    var itemRecords = await ItemRecord.fetchWithUIDs(itemUIds, db);
    var groupedItemRecords = itemRecords.toMapByKey((itemRecord) => itemRecord.uid);

    records.forEach((itemPropertyRecord) {
      itemPropertyRecord.itemRowID ??= groupedItemRecords[itemPropertyRecord.itemUID!]!.rowId;
    });
    var partItems = records.partition(5000);
    for (var part in partItems) {
      await db.itemPropertyRecordInsertAll(part);
    }
  }

  delete(Database db) async {
    await db.itemPropertyRecordDelete(this);
  }

  save(Database db, {bool? isNew}) async {
    return await db.itemPropertyRecordSave(this, isNew: isNew);
  }
}
