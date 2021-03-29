import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';

import 'ItemRecord.dart';

/// This type is used to describe a database query.
class DatabaseQueryConfig {
  /// A list of item types to include. Default is Empty -> ALL item types
  List<String> itemTypes;

  /// A list of item UIDs to include. Default is Empty -> don't filter on UID
  Set<String> itemUIDs;

  /// A property to sort the results by
  String? sortProperty;

  bool sortAscending;

  /// Only include items modified after this date
  DateTime? dateModifiedAfter;

  /// Only include items modified before this date
  DateTime? dateModifiedBefore;

  /// Only include items created after this date
  DateTime? dateCreatedAfter;

  /// Only include items created before this date
  DateTime? dateCreatedBefore;

  /// The maximum number of items to fetch
  int pageSize;

  /// Use this to change which page is requested by the query (eg. if there are more than `pageSize` items)
  int currentPage;

  /// A search string to match item properties against
  String? searchString;

  /// If enabled the search will find items that link to another item matching the search term. This only goes one edge deep for performance purposes.
  bool includeImmediateEdgeSearch;

  /// A list of conditions. eg. property name = "Demo note"
  var /*List<DatabaseQueryCondition>*/ conditions = [];

  late Database db;

  DatabaseQueryConfig({
    this.itemTypes = const [
      "Person",
      "Note",
      "Address",
      "Photo",
      "Indexer",
      "Importer"
    ],
    this.itemUIDs = const {},
    this.sortProperty = "dateModified",
    this.sortAscending = false,
    this.dateModifiedAfter,
    this.dateModifiedBefore,
    this.dateCreatedAfter,
    this.dateCreatedBefore,
    this.pageSize = 1000,
    this.currentPage = 0,
    this.searchString,
    this.includeImmediateEdgeSearch = true,
    this.conditions = const [],
  });

  _constructFilteredRequest([Set<String>? searchUIDs]) async {
    var limit = pageSize;
    var offset = pageSize * currentPage;

    var queryConditions = [];
    List<Variable<dynamic>> queryBindings = [];

    /// Filter by item type
    if (itemTypes.isNotEmpty) {
      var itemTypesCondition = itemTypes.map((type) {
        queryBindings.add(Variable.withString(type));
        return "type = ?";
      });
      queryConditions.add("(" + itemTypesCondition.join(" OR ") + ")");
    }

    /// Filter to only include items matching the search term (AND if already filtered by UID, those that match both)
    if (searchUIDs != null) {
      var itemUIDCondition;
      if (itemUIDs.isNotEmpty) {
        itemUIDCondition = searchUIDs.intersection(itemUIDs).map((uid) {
          queryBindings.add(Variable.withString(uid));
          return "uid = ?";
        });
      } else {
        itemUIDCondition = searchUIDs.map((uid) {
          queryBindings.add(Variable.withString(uid));
          return "uid = ?";
        });
      }
      queryConditions.add("(" + itemUIDCondition.join(" OR ") + ")");
    } else if (itemUIDs.isNotEmpty) {
      var itemUIDCondition = itemUIDs.map((uid) {
        queryBindings.add(Variable.withString(uid));
        return "uid = ?";
      });
      queryConditions.add("(" + itemUIDCondition.join(" OR ") + ")");
    }

    /// Filter by date ranges
    if (dateModifiedBefore != null) {
      queryConditions.add("dateModified <= ?");
      queryBindings.add(Variable.withDateTime(dateModifiedBefore!));
    }
    if (dateModifiedAfter != null) {
      queryConditions.add("dateModified >= ?");
      queryBindings.add(Variable.withDateTime(dateModifiedAfter!));
    }
    if (dateCreatedBefore != null) {
      queryConditions.add("dateCreated <= ?");
      queryBindings.add(Variable.withDateTime(dateCreatedBefore!));
    }
    if (dateCreatedAfter != null) {
      queryConditions.add("dateCreated >= ?");
      queryBindings.add(Variable.withDateTime(dateCreatedAfter!));
    }

    var itemRecords = await db.itemRecordsCustomSelect(
        queryConditions.join(" and "), queryBindings);
    if (itemRecords.length == 0) {
      return [];
    }

    // Property conditions
    /* let queryPropertyConditions: [SQLExpression] = conditions.compactMap { condition in
            switch condition {
            case let .propertyEquals(info):
                return ItemPropertyRecord.Columns.name == info.name && ItemPropertyRecord.Columns.value == info.value
            default:
                return nil
            }
        }
        if !queryPropertyConditions.isEmpty {
            let propertyFilter = ItemRecord.properties.filter(queryPropertyConditions.joined(operator: .and))
            request = request.having(propertyFilter.isEmpty == false)
        }
        
        // Edge conditions
        let queryEdgeConditions: [SQLExpression] = conditions.compactMap { condition in
            switch condition {
            case let .edgeHasTarget(info):
                return ItemEdgeRecord.Columns.name == info.edgeName && ItemEdgeRecord.Columns.targetUID == info.targetUID
            default:
                return nil
            }
        }
        if !queryEdgeConditions.isEmpty {
            let edgeFilter = ItemRecord.edges.filter(queryEdgeConditions.joined(operator: .and))
            request = request.having(edgeFilter.isEmpty == false)
        }
        
        switch sortProperty?.nilIfBlank {
        case "dateCreated":
            request = request.order(sortAscending ? [ItemRecord.Columns.dateCreated, ItemRecord.Columns.dateModified] : [ItemRecord.Columns.dateCreated.desc, ItemRecord.Columns.dateModified.desc])
        case "dateModified":
            request = request.order(sortAscending ? [ItemRecord.Columns.dateModified, ItemRecord.Columns.dateCreated] : [ItemRecord.Columns.dateModified.desc, ItemRecord.Columns.dateCreated.desc])
        case .some(let sortProperty):
            let sortAlias = TableAlias()
            request = request.joining(optional:
                                        ItemRecord.properties.aliased(sortAlias)
                                        .filter(ItemPropertyRecord.Columns.name == sortProperty)
            )
            .order(sortAscending ? [
                sortAlias[ItemPropertyRecord.Columns.value].ascNullsLast,
                ItemRecord.Columns.dateModified,
                ItemRecord.Columns.dateCreated
            ] : [
                sortAlias[ItemPropertyRecord.Columns.value].desc,
                ItemRecord.Columns.dateModified.desc,
                ItemRecord.Columns.dateCreated.desc
            ])
        default: break
        }*/

    return itemRecords;
  }

  /*private func constructSearchRequest() -> SQLRequest<StringUUID?>? {
        guard let searchString = searchString?.nilIfBlank,
              let searchQuery = FTS3Pattern(matchingAllTokensIn: searchString),
              let refinedQuery = try? FTS3Pattern(rawPattern: "\(searchQuery.rawPattern)*")
        else {
            return nil
        }
        return SQLRequest(sql:
            """
               SELECT DISTINCT \(ItemPropertyRecord.Columns.itemUID)
               FROM \(ItemPropertyRecord.databaseSearchTableName)
               WHERE \(ItemPropertyRecord.databaseSearchTableName) MATCH ?
            """, arguments: [refinedQuery])
    }*/

  Future<List<ItemRecord>> executeRequest(Database db) async {
    this.db = db;
    /*var searchUIDs = try constructSearchRequest().map { try Set($0.fetchAll(db).compactMap { $0 }) }
        if includeImmediateEdgeSearch {
            /// Find items connected the the search results by one or more edges. Eg. if a file is found based on the search term, we will also include a Photo or Note that links to it
            let edgeUIDs = try searchUIDs.map { searchUIDs -> [StringUUID] in
                try ItemEdgeRecord.filter(searchUIDs.contains(ItemEdgeRecord.Columns.targetUID)).select([ItemEdgeRecord.Columns.sourceUID]).fetchAll(db)
            }
            searchUIDs = searchUIDs?.union(edgeUIDs ?? [])
        }*/

    List<Item> result = await _constructFilteredRequest(); /*searchUIDs*/
    if (result.length > 0) {
      return result.map((item) => ItemRecord.fromItem(item)).toList();
    }
    return [];
  }
}

/*
enum DatabaseQueryCondition: Codable, Equatable {
    case propertyEquals(PropertyEquals)
    case edgeHasTarget(EdgeHasTarget)
    
    enum CodingKeys: CodingKey {
        case propertyEquals, edgeHasTarget
    }
    
    struct PropertyEquals: Codable, Equatable {
        var name: String
        var value: String
    }
    
    struct EdgeHasTarget: Codable, Equatable {
        var edgeName: String
        var targetUID: StringUUID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .propertyEquals(let info):
            try container.encode(info, forKey: .propertyEquals)
        case .edgeHasTarget(let info):
            try container.encode(info, forKey: .edgeHasTarget)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        
        switch key {
        case .propertyEquals:
            try self = .propertyEquals(container.decode(PropertyEquals.self, forKey: .propertyEquals))
        case .edgeHasTarget:
            try self = .edgeHasTarget(container.decode(EdgeHasTarget.self, forKey: .edgeHasTarget))
        case .none:
            throw StringError(description: "Unknown database query condition")
        }
    }
}
*/
