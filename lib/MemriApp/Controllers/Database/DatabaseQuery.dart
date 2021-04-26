import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';

import 'ItemRecord.dart';

/// This type is used to describe a database query.
class DatabaseQueryConfig {
  /// A list of item types to include. Default is Empty -> ALL item types
  List<String> itemTypes;

  /// A list of item UIDs to include. Default is Empty -> don't filter on UID
  Set<String> itemUIDs; //TODO: we will need to refactor this to use rowIds

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
  List<DatabaseQueryCondition> conditions = [];

  late DatabaseController dbController;

  DatabaseQueryConfig({
    this.itemTypes = const ["Person", "Note", "Address", "Photo", "Indexer", "Importer"],
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

  DatabaseQueryConfig clone() {
    //TODO find better way to clone object
    return DatabaseQueryConfig(
      itemTypes: itemTypes,
      itemUIDs: itemUIDs,
      sortProperty: sortProperty,
      sortAscending: sortAscending,
      dateModifiedAfter: dateModifiedAfter,
      dateModifiedBefore: dateModifiedBefore,
      dateCreatedAfter: dateCreatedAfter,
      dateCreatedBefore: dateCreatedBefore,
      pageSize: pageSize,
      currentPage: currentPage,
      searchString: searchString,
      includeImmediateEdgeSearch: includeImmediateEdgeSearch,
      conditions: conditions,
    );
  }

  _constructFilteredRequest([Set<int>? searchIDs]) async {
    List<dynamic> intersection(List<List<dynamic>> arrays) {
      if (arrays.length == 0) {
        return [];
      }
      return [...arrays].reduce((a, c) => a.where((i) => c.contains(i)).toList());
    }

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
    if (searchIDs != null) {
      if (searchIDs.isEmpty) {
        return [];
      }
      var itemUIDCondition;
      if (itemUIDs.isNotEmpty) {
        //TODO: reimplement this with rowIds
        var items = await Future.wait(searchIDs
            .map((id) async => await dbController.databasePool.itemRecordFetchWithRowId(id)));
        var searchUIDs = items.map((item) => item.id).toSet();
        itemUIDCondition = searchUIDs.intersection(itemUIDs).map((uid) {
          queryBindings.add(Variable.withString(uid));
          return "uid = ?";
        });
      } else {
        itemUIDCondition = searchIDs.map((rowId) {
          queryBindings.add(Variable.withInt(rowId));
          return "row_id = ?";
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

    var itemRecords = await dbController.databasePool
        .itemRecordsCustomSelect(queryConditions.join(" and "), queryBindings);
    if (itemRecords.length == 0) {
      return [];
    }

    List<int> rowIds = [];
    itemRecords.forEach((itemRecord) => rowIds.add(itemRecord.rowId!));

    // Property conditions TODO
    // Property and edges conditions
    var queryPropertyConditions = [];
    await Future.forEach(conditions, (DatabaseQueryCondition condition) async {
      var info, query;
      List<Variable<dynamic>> binding = [];

      if (condition is DatabaseQueryConditionPropertyEquals) {
        info = condition.value;
        query = "name = ? AND value = ? AND item IN (${rowIds.join(", ")})";
        binding = [Variable.withString(info.name), Variable(info.value)];
        queryPropertyConditions
            .add(await dbController.databasePool.itemPropertyRecordsCustomSelect(query, binding));
      } else if (condition is DatabaseQueryConditionEdgeHasTarget) {
        //TODO: need to watch use cases
        info = condition.value;
        query = "name = ? AND target = ? AND source IN (${rowIds.join(", ")})";
        binding = [Variable(info.edgeName), Variable(info.target)];
        queryPropertyConditions
            .add(await dbController.databasePool.edgeRecordsCustomSelect(query, binding));
      }
    });

    List<int> filteredIds = [];
    if (queryPropertyConditions.isNotEmpty) {
      List<List<int>> allConditionsItemsRowIds = [];
      queryPropertyConditions.forEach((conditions) {
        List<int> itemsRowIds = [];
        conditions.forEach((el) {
          if (el is Edge) {
            itemsRowIds.add(el.source);
          } else {
            itemsRowIds.add(el.item);
          }
        });
        allConditionsItemsRowIds.add(itemsRowIds);
      });
      filteredIds = intersection(allConditionsItemsRowIds) as List<int>;
      if (filteredIds.length == 0) {
        return [];
      } else {
        rowIds = filteredIds;
      }
    }

    var orderBy = "";
    var sortOrder = this.sortAscending ? "" : "DESC";
    switch (sortProperty) {
      case "dateCreated":
        orderBy = "ORDER BY dateCreated $sortOrder, dateModified $sortOrder";
        break;
      case "dateModified":
        orderBy = "ORDER BY dateModified $sortOrder, dateCreated $sortOrder";
        break;
      case "":
        break;
      default:
        //TODO: table alias
        orderBy =
            "ORDER BY ${this.sortProperty} $sortOrder, dateModified $sortOrder, dateCreated $sortOrder";
        break;
    }
    var finalQuery = "row_id IN (${rowIds.join(", ")}) $orderBy LIMIT $limit OFFSET $offset";
    return await dbController.databasePool.itemRecordsCustomSelect(finalQuery, []);
  }

  _constructSearchRequest() async {
    var refinedQuery = "$searchString*";
    if (searchString == null || searchString == "") {
      return;
    }
    return await dbController.databasePool.itemPropertyRecordsCustomSelect(
        "value MATCH ?", [Variable.withString(refinedQuery)], true);
  }

  Stream<List<ItemRecord>> executeRequest(DatabaseController dbController) async* {
    this.dbController = dbController;
    List<dynamic>? itemProperties = await _constructSearchRequest();
    Set<int>? searchIDs;
    if (itemProperties != null) {
      searchIDs = Set.of(itemProperties).map((el) => int.parse(el.item)).toSet();
      if (includeImmediateEdgeSearch) {
        /// Find items connected the the search results by one or more edges. Eg. if a file is found based on the search term, we will also include a Photo or Note that links to it
        var edges = await Future.wait(searchIDs
            .map((id) async => await dbController.databasePool.edgeRecordSelect({"target": id})));
        Set<int>? edgeIDs = edges.where((edge) => edge != null).map((edge) => edge!.source).toSet();
        searchIDs = searchIDs.union(edgeIDs);
      }
    }

    List<dynamic> result = await _constructFilteredRequest(searchIDs);
    if (result.length > 0) {
      yield result.map((item) => ItemRecord.fromItem(item as Item)).toList();
    } else {
      yield [];
    }
  }
}

abstract class DatabaseQueryCondition {
  dynamic get value;
}

class DatabaseQueryConditionPropertyEquals extends DatabaseQueryCondition {
  PropertyEquals value;

  DatabaseQueryConditionPropertyEquals(this.value);
}

class DatabaseQueryConditionEdgeHasTarget extends DatabaseQueryCondition {
  EdgeHasTarget value;

  DatabaseQueryConditionEdgeHasTarget(this.value);
}

class PropertyEquals {
  String name;
  dynamic value;

  PropertyEquals(this.name, this.value);
}

class EdgeHasTarget {
  String edgeName;
  String target;

  EdgeHasTarget(this.edgeName, this.target);
}
