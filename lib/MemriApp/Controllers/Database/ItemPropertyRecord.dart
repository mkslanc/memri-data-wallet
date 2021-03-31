import 'package:memri/MemriApp/Model/Database.dart';

import '../AppController.dart';
import 'PropertyDatabaseValue.dart';
import 'Schema.dart';

class ItemPropertyRecord {
  String? itemUID;
  int itemRowID;
  String name;

  PropertyDatabaseValue $value;

  ItemPropertyRecord(
      {this.itemUID,
      required this.itemRowID,
      required this.name,
      required PropertyDatabaseValue value})
      : $value = value;

  PropertyDatabaseValue? value(String itemType, [Schema? schema]) {
    schema ??= AppController.shared.databaseController.schema;
    var expectedType = schema.types[itemType]?.propertyTypes[name]?.valueType;
    if (expectedType == null) {
      return null;
    }
    return PropertyDatabaseValue.createFromDBValue(
        $value.value, expectedType); //TODO: check with tests
  }

  insert(Database db) async {
    return await db.itemPropertyRecordInsert(this);
  }

  delete(Database db) async {
    await db.itemPropertyRecordDelete(this);
  }

  save(Database db) async {
    return await db.itemPropertyRecordSave(this);
  }
}
