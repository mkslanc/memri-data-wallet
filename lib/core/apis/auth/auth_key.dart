import 'package:memri/core/models/database/database.dart';
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';

class AuthKey {
  int ownerId;
  String type;
  String? role;
  String key;
  String name;
  bool active;

  AuthKey(
      {required this.ownerId,
      required this.type,
      this.role,
      required this.key,
      required this.name,
      required this.active});

  Future<ItemRecord?> save(Database db) async {
    var item = ItemRecord(type: "CryptoKey");
    await item.save();
    var itemRowId = item.rowId;
    if (itemRowId == null) {
      throw Exception("Error saving key");
    }

    await ItemPropertyRecord(
            itemRowID: itemRowId,
            name: "itemType",
            value: PropertyDatabaseValueString(type))
        .save(db, isNew: true);
    if (role != null) {
      await ItemPropertyRecord(
              itemRowID: itemRowId,
              name: "role",
              value: PropertyDatabaseValueString(role!))
          .save(db, isNew: true);
    }
    await ItemPropertyRecord(
            itemRowID: itemRowId,
            name: "keystr",
            value: PropertyDatabaseValueString(key))
        .save(db,
            isNew: true); // "keystr" because "key" is restricted in pod db
    await ItemPropertyRecord(
            itemRowID: itemRowId,
            name: "name",
            value: PropertyDatabaseValueString(name))
        .save(db, isNew: true);
    await ItemPropertyRecord(
            itemRowID: itemRowId,
            name: "active",
            value: PropertyDatabaseValueBool(active))
        .save(db, isNew: true);

    return item;
  }
}

class AuthKeys {
  String ownerKey;
  String dbKey;

  AuthKeys({required this.ownerKey, required this.dbKey});
}

class GeneratedKeys {
  String publicKey;
  String privateKey;
  String dbKey;

  GeneratedKeys(
      {required this.publicKey, required this.privateKey, required this.dbKey});
}
