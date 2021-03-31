import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

import '../AppController.dart';
import 'DatabaseController.dart';
import 'ItemPropertyRecord.dart';

// ignore: must_be_immutable
class ItemRecord extends Equatable {
  int? rowId;
  String uid;
  String type;
  DateTime dateCreated;
  DateTime? dateServerModified;
  DateTime dateModified;
  bool deleted;

  //SyncState syncState; TODO:
  //bool syncHasPriority; TODO:

  ItemRecord({
    this.rowId,
    uid,
    required this.type,
    dateCreated,
    dateModified,
    this.deleted = false,
  })  : this.dateModified = dateModified ?? DateTime.now(),
        this.dateCreated = dateCreated ?? DateTime.now(),
        this.uid = uid ?? Uuid().v4();

  ItemRecord.fromItem(Item item)
      : rowId = item.rowId,
        uid = item.id,
        type = item.type,
        dateCreated = item.dateCreated,
        dateModified = item.dateModified,
        dateServerModified = item.dateServerModified,
        deleted = item.deleted;

  ItemsCompanion toCompanion() {
    return ItemsCompanion(
      rowId: rowId == null ? const Value.absent() : Value(rowId),
      id: Value(uid),
      type: Value(type),
      dateCreated: Value(dateCreated),
      dateModified: Value(dateModified),
      dateServerModified: dateServerModified == null
          ? const Value.absent()
          : Value(dateServerModified),
      deleted: Value(deleted),
    );
  }

  Future<ItemPropertyRecord?> property(String name, DatabaseController? dbController
      /* = AppController.shared.databaseController*/) async {
    return null; //ItemPropertyRecord();
    // return ItemPropertyRecord.getOne(dbController, {
    // name: name,
    // itemUID: this.uid
    // }, this.type);
  }

  List<ItemPropertyRecord> properties(DatabaseController dbController
      /* = AppController.shared.databaseController*/) {
    return [];
    // return ItemPropertyRecord.getAll(dbController, {
    // itemUID: this.uid
    // }, this.type);
  }

  /*TODO PropertyDatabaseValue*/
  dynamic propertyValue(String name, DatabaseController? dbController
      // = AppController.shared.databaseController
      ) {
    // let property = this.property(name, dbController)
    // if (!property) { return undefined }
    // return property.value(this.type, dbController.schema)
  }

  setPropertyValue(String name, dynamic? value, DatabaseController? dbController) {}

  static Future<ItemRecord?> fetchWithUID(String uid,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      Item item = await db.databasePool.itemRecordFetchWithUID(uid);
      return ItemRecord.fromItem(item);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<int> insert(Database db) async {
    return await db.itemRecordInsert(this);
  }

  Future<ItemRecord?> edgeItem(String name, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    try {
      var edge = await db.databasePool
          .edgeRecordSelect({"source": rowId, "name": name});
      if (edge != null) {
        return await ItemEdgeRecord.fromEdge(edge).targetItem(db);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ItemRecord>> edgeItems(String name,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    try {
      var edges = await db.databasePool
          .edgeRecordsSelect({"source": rowId, "name": name});
      return (await Future.wait(edges.map((edge) async =>
      await ItemEdgeRecord.fromEdge(edge).targetItem(db!))))
          .whereType<ItemRecord>()
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<ItemRecord?> reverseEdgeItem(String name,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    try {
      var edge = await db.databasePool
          .edgeRecordSelect({"target": rowId, "name": name});
      if (edge != null) {
        return await ItemEdgeRecord.fromEdge(edge).targetItem(db);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ItemRecord>> reverseEdgeItems(String name,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    try {
      var edges = await db.databasePool
          .edgeRecordsSelect({"target": rowId, "name": name});
      return (await Future.wait(edges.map((edge) async =>
      await ItemEdgeRecord.fromEdge(edge).targetItem(db!))))
          .whereType<ItemRecord>()
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Binding<dynamic> propertyBinding(
      {required String name, dynamic? defaultValue, DatabaseController? db, Type? type}) {
    db ??= AppController.shared.databaseController;
    switch (type) {
      case bool:
        return Binding<bool>(() => propertyValue(name, db)?.asBool() ?? defaultValue, (newValue) {
          setPropertyValue(name, /*PropertyDatabaseValue.bool(newValue)*/ null, db);
        });
      default:
        return Binding<String>(() => propertyValue(name, db)?.asString() ?? defaultValue.toString(),
            (newValue) {
          setPropertyValue(name, /*PropertyDatabaseValue.bool(newValue)*/ null, db);
        });
    }
  }

  @override
  List<Object> get props => [uid, type];

/*static var properties = hasMany(ItemPropertyRecord.self, key: "itemProperty")

    func property(_ name: String, db: DatabaseController = AppController.shared.databaseController) -> ItemPropertyRecord? {
        try? db.read { db in
            try? request(for: ItemRecord.properties).filter(ItemPropertyRecord.Columns.name == name).fetchOne(db)
        }
    }
    
    func properties(db: DatabaseController = AppController.shared.databaseController) -> [ItemPropertyRecord] {
        (try? db.read { db in
    try? request(for: ItemRecord.properties).fetchAll(db)
        }) ?? []
    }
    
    func propertyValue(
        _ name: String,
        db: DatabaseController = AppController.shared.databaseController
    ) -> PropertyDatabaseValue? {
        guard let property = property(name, db: db) else { return nil }
        return property.value(itemType: type, schema: db.schema)
    }
    
    func save(db dbController: DatabaseController = AppController.shared.databaseController) throws {
        try dbController.writeSync { (db) in
            try save(db)
        }
    }
    
    
    func setPropertyValue(
        name: String,
        value: PropertyDatabaseValue?,
        db dbController: DatabaseController = AppController.shared.databaseController
    ) throws {
        try dbController.writeSync { (db) in
            /// Mark the item as modified, and mark for syncing (unless already marked as a newly created item to be synced)
            dateModified = Date()
            if syncState != .create {
                syncState = .update
            }
            /// Save the item record including the above changes - do this before editing the property so we know the item definitely exists
            try save(db: dbController)
            
            /// Create or update the property
            if let property = property(name, db: dbController) {
                if let value = value {
                    property.value = value.databaseValue
                    try property.save(db)
                } else {
                    try property.delete(db: dbController)
                }
            } else if let value = value {
                let property = ItemPropertyRecord(itemUID: uid, name: name, value: value)
                try property.save(db)
            }
        }
    }
    
    
    static let edges = hasMany(ItemEdgeRecord.self, using: ItemEdgeRecord.ownerForeignKey)

    func edgeItem(_ name: String, db: DatabaseController = AppController.shared.databaseController) -> ItemRecord? {
        try? db.read { db in
         try? request(for: ItemRecord.edges).filter(ItemEdgeRecord.Columns.name == name).fetchOne(db)?.targetItem(db: db)
        }
    }
    func edgeItems(_ name: String, db: DatabaseController = AppController.shared.databaseController) -> [ItemRecord] {
        (try? db.read { db in
         try? request(for: ItemRecord.edges).filter(ItemEdgeRecord.Columns.name == name).fetchAll(db).lazy.compactMap { $0.targetItem(db: db) }
        }) ?? []
    }
    
    static var reverseEdges = hasMany(ItemEdgeRecord.self, using: ItemEdgeRecord.targetForeignKey)
    func reverseEdgeItem(_ name: String, db: DatabaseController = AppController.shared.databaseController) -> ItemRecord? {
        
            try? db.read { db in
        try? request(for: ItemRecord.reverseEdges).filter(ItemEdgeRecord.Columns.name == name).fetchOne(db)?.owningItem(db: db)
            }
    }
    func reverseEdgeItems(_ name: String, db: DatabaseController = AppController.shared.databaseController) -> [ItemRecord] {
        
            (try? db.read { db in
       try? request(for: ItemRecord.reverseEdges).filter(ItemEdgeRecord.Columns.name == name).fetchAll(db).lazy.compactMap { $0.owningItem(db: db) }
            }) ?? []
    }

    static let intrinsicProperties: Set<String> = ["type", "uid", "dateCreated", "dateModified", "version", "deleted"]

    func syncDict(db: Database, schema: Schema) -> [String: AnyEncodable] {
        let properties = try! request(for: ItemRecord.properties).fetchAll(db)
//        let edges = try! request(for: ItemRecord.edges).fetchAll(db)
        return _syncDict(properties: properties, schema: schema)//, edges: edges)
    }
    
    func _syncDict(properties: [ItemPropertyRecord], schema: Schema) -> [String: AnyEncodable] { //, edges: [ItemEdgeRecord]
        let keyProperties: [String: AnyEncodable] = [
            "_type": type,
            "uid": uid,
            "dateCreated": DatabaseHelperFunctions.encode(dateCreated),
            "dateModified": DatabaseHelperFunctions.encode(dateModified),
            "version": version,
            "deleted": deleted,
        ].mapValues { AnyEncodable($0) }

        let otherProperties: [(String, AnyEncodable)] = properties.compactMap {
            guard let propertyValue = $0.value(itemType: type, schema: schema) else { return nil }
            return ($0.name, AnyEncodable(propertyValue))
        }

        return keyProperties
            .merging(otherProperties, uniquingKeysWith: { a, b in a })
    }
    
    init(fromSyncDict dict: [String: AnyDecodable]) throws {
        guard let uidString = dict["uid"]?.value as? String,
              let type = dict["type"]?.value as? String,
              let dateCreated = (dict["dateCreated"]?.value as? Int).flatMap(DatabaseHelperFunctions.decode)
        else {
            throw NSError()
        }
        self.uid = StringUUID(uid: uidString)
        self.type = type
        self.dateCreated = dateCreated
        self.dateModified = (dict["dateModified"]?.value as? Int).flatMap(DatabaseHelperFunctions.decode) ?? dateCreated
        self.version = dict["version"]?.value as? Int ?? 1
        self.deleted = dict["deleted"]?.value as? Bool ?? false
        
        // This is direct from the latest version so no need to sync again
        self.syncState = .noChanges
        self.syncHasPriority = false
        super.init()
    }
    
    static func search(_ db: Database, pattern: FTS3Pattern) throws -> [ItemRecord] {
        try ItemRecord.fetchAll(db, sql:
        """
           SELECT DISTINCT \(ItemRecord.databaseTableName).*
           FROM \(ItemRecord.databaseTableName)
           JOIN \(ItemPropertyRecord.databaseSearchTableName)
               ON \(ItemPropertyRecord.databaseSearchTableName).itemUID = \(ItemRecord.databaseTableName).uid
               AND \(ItemPropertyRecord.databaseSearchTableName) MATCH ?
        """, arguments: [pattern])
    }*/
  static Future<List<ItemRecord>> search(DatabaseController dbController, String pattern) async {
    List<dynamic> list = await dbController.databasePool
        .itemPropertyRecordsCustomSelect("value MATCH ?", [Variable.withString(pattern)], true);
    return await Future.wait(list.map((el) async => ItemRecord.fromItem(
        await dbController.databasePool.itemRecordFetchWithRowId(int.parse(el.item)))));
  }
}
/*extension ItemRecord {
    func propertyBinding(name: String, defaultValue: String? = nil, db: DatabaseController = AppController.shared.databaseController) -> Binding<String?> {
        Binding {
            self.propertyValue(name, db: db)?.asString() ?? defaultValue
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: newValue?.nilIfBlank.map { .string($0) }, db: db)
        }
    }
    
    func propertyBinding(name: String, defaultValue: String = "", db: DatabaseController = AppController.shared.databaseController) -> Binding<String> {
        Binding {
            self.propertyValue(name, db: db)?.asString() ?? defaultValue
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: .string(newValue), db: db)
        }
    }
    
    func propertyBinding(name: String, db: DatabaseController = AppController.shared.databaseController) -> Binding<Bool?> {
        Binding {
            self.propertyValue(name, db: db)?.asBool()
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: newValue.map { .bool($0) }, db: db)
        }
    }
    
    func propertyBinding(name: String, defaultValue: Bool = false, db: DatabaseController = AppController.shared.databaseController) -> Binding<Bool> {
        Binding {
            self.propertyValue(name, db: db)?.asBool() ?? defaultValue
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: .bool(newValue), db: db)
        }
    }
    
    func propertyBinding(name: String, db: DatabaseController = AppController.shared.databaseController) -> Binding<Double?> {
        Binding {
            self.propertyValue(name, db: db)?.asDouble()
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: newValue.map { .double($0) }, db: db)
        }
    }
    
    func propertyBinding(name: String, db: DatabaseController = AppController.shared.databaseController) -> Binding<Date?> {
        Binding {
            self.propertyValue(name, db: db)?.asDate()
        } set: { (newValue) in
            try? self.setPropertyValue(name: name, value: newValue.map { .datetime($0) }, db: db)
        }
    }
}*/
