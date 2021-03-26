import 'package:memri/MemriApp/Model/Database.dart';

import 'PropertyDatabaseValue.dart';
import 'Schema.dart';

class ItemPropertyRecord {
  String itemUID;
  String name;

  PropertyDatabaseValue $value;

  ItemPropertyRecord(
      {required this.itemUID, required this.name, required PropertyDatabaseValue value})
      : $value = value;

  PropertyDatabaseValue? value(String itemType, Schema schema
      /* = AppController.shared.databaseController.schema*/) {
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

/* TODO

    func delete(db dbController: DatabaseController = AppController.shared.databaseController) throws {
        try dbController.writeSync { (db) in
            try db.execute(literal: "DELETE FROM itemProperty WHERE \(Columns.itemUID) = \(itemUID) AND \(Columns.name) = \(name)")
        }
    }
    
    func save(db dbController: DatabaseController = AppController.shared.databaseController) throws {
        try dbController.writeSync { (db) in
            try save(db)
        }
    }*/
}
