import 'package:uuid/uuid.dart';

import 'DatabaseController.dart';

class ItemRecord {
  static var databaseTableName = "item";

  String uid;
  String type;
  DateTime? dateCreated;

  DateTime? dateModified;
  int version;
  bool deleted;

  //SyncState syncState; TODO:
  //bool syncHasPriority; TODO:

  ItemRecord({
    uid,
    required this.type,
    dateCreated,
    dateModified,
    this.version = 1,
    this.deleted = false,
  })  : this.dateModified = dateModified ?? DateTime.now(),
        this.dateCreated = dateCreated ?? DateTime.now(),
        this.uid = uid ?? Uuid().v4().toString();

  /* TODO:
    static func == (lhs: ItemRecord, rhs: ItemRecord) -> Bool {
        lhs.uid == rhs.uid && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(type)
    }*/

  static fetchWithUID(String uid, DatabaseController db
      /* = AppController.shared.databaseController*/) async {
    try {
      return await db.databasePool.itemRecordFetchWithUID(uid);
    } catch (e) {
      return null;
    }
  }

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
    
    enum Columns: String, ColumnExpression {
        case uid, type, dateCreated, dateModified, version, deleted, syncState, syncHasPriority
    }
    
    
    internal init(uid: StringUUID = StringUUID(), type: String, dateCreated: Date? = nil, dateModified: Date? = nil, version: Int = 1, deleted: Bool = false, syncState: SyncState = .create, syncHasPriority: Bool = false) {
        self.uid = uid
        self.type = type
        self.dateCreated = dateCreated ?? Date()
        self.dateModified = dateModified ?? Date()
        self.version = version
        self.deleted = deleted
        self.syncState = syncState
        self.syncHasPriority = syncHasPriority
        super.init()
    }
    
    required init(row: Row) {
        self.uid = row[Columns.uid]
        self.type = row[Columns.type]
        self.dateCreated = row[Columns.dateCreated]
        self.dateModified = row[Columns.dateModified]
        self.version = row[Columns.version]
        self.deleted = row[Columns.deleted]
        self.syncState = row[Columns.syncState]
        self.syncHasPriority = row[Columns.syncHasPriority]
        super.init(row: row)
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container[Columns.uid] = uid
        container[Columns.type] = type
        container[Columns.dateCreated] = dateCreated
        container[Columns.dateModified] = dateModified
        container[Columns.version] = version
        container[Columns.deleted] = deleted
        container[Columns.syncState] = syncState
        container[Columns.syncHasPriority] = syncHasPriority
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
