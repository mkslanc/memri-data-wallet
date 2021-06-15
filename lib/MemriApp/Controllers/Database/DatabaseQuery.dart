import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/moor.dart';

import 'ItemRecord.dart';
import 'Schema.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;

part 'DatabaseQuery.g.dart';

enum ConditionOperator { and, or }

/// This type is used to describe a database query.
@annotation.JsonSerializable()
class DatabaseQueryConfig extends ChangeNotifier with EquatableMixin {
  /// A list of item types to include. Default is Empty -> ALL item types
  List<String> itemTypes;

  /// A list of item `rowid` to include. Default is Empty -> don't filter on `rowid`
  Set<int> itemRowIDs;

  /// A property to sort the results by
  String? _sortProperty;

  String? get sortProperty => _sortProperty;

  set sortProperty(String? newValue) {
    _sortProperty = newValue;
    notifyListeners();
  }

  bool _sortAscending = false;

  bool get sortAscending => _sortAscending;

  set sortAscending(bool newValue) {
    _sortAscending = newValue;
    notifyListeners();
  }

  /// Only include items modified after this date
  DateTime? _dateModifiedAfter;

  DateTime? get dateModifiedAfter => _dateModifiedAfter;

  set dateModifiedAfter(DateTime? newValue) {
    _dateModifiedAfter = newValue;
    notifyListeners();
  }

  /// Only include items modified before this date
  DateTime? _dateModifiedBefore;

  DateTime? get dateModifiedBefore => _dateModifiedBefore;

  set dateModifiedBefore(DateTime? newValue) {
    _dateModifiedBefore = newValue;
    notifyListeners();
  }

  /// Only include items created after this date
  DateTime? _dateCreatedAfter;

  DateTime? get dateCreatedAfter => _dateCreatedAfter;

  set dateCreatedAfter(DateTime? newValue) {
    _dateCreatedAfter = newValue;
    notifyListeners();
  }

  /// Only include items created before this date
  DateTime? _dateCreatedBefore;

  DateTime? get dateCreatedBefore => _dateCreatedBefore;

  set dateCreatedBefore(DateTime? newValue) {
    _dateCreatedBefore = newValue;
    notifyListeners();
  }

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

  ConditionOperator edgeTargetsOperator = ConditionOperator.and;

  @annotation.JsonKey(ignore: true)
  late DatabaseController dbController;

  int? count;

  DatabaseQueryConfig(
      {List<String>? itemTypes,
      Set<int>? itemRowIDs,
      String? sortProperty = "dateModified",
      bool sortAscending = false,
      DateTime? dateModifiedAfter,
      DateTime? dateModifiedBefore,
      DateTime? dateCreatedAfter,
      DateTime? dateCreatedBefore,
      this.pageSize = 1000,
      this.currentPage = 0,
      this.searchString,
      this.includeImmediateEdgeSearch = true,
      List<DatabaseQueryCondition>? conditions,
      this.edgeTargetsOperator = ConditionOperator.and,
        this.count})
      : itemTypes = itemTypes ?? ["Person", "Note", "Address", "Photo", "Indexer", "Importer"],
        itemRowIDs = itemRowIDs ?? Set.of(<int>[]),
        _sortAscending = sortAscending,
        _sortProperty = sortProperty,
        _dateModifiedAfter = dateModifiedAfter,
        _dateModifiedBefore = dateModifiedBefore,
        _dateCreatedAfter = dateCreatedAfter,
        _dateCreatedBefore = dateCreatedBefore,
        conditions = conditions ?? [];

  DatabaseQueryConfig clone() {
    //TODO find better way to clone object
    return DatabaseQueryConfig(
        itemTypes: itemTypes,
        itemRowIDs: itemRowIDs,
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
        edgeTargetsOperator: edgeTargetsOperator,
        count: count);
  }

  _constructFilteredRequest([Set<int>? searchRowIDs]) async {
    List<dynamic> intersection(List<List<dynamic>> arrays) {
      if (arrays.length == 0) {
        return [];
      }
      return [...arrays].reduce((a, c) => a.where((i) => c.contains(i)).toList());
    }

    var limit = count ?? pageSize;
    var offset = count == null ? pageSize * currentPage : 0;

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
    if (searchRowIDs != null) {
      if (searchRowIDs.isEmpty) {
        return [];
      }
      var itemRowIDCondition;
      if (itemRowIDs.isNotEmpty) {
        itemRowIDCondition = searchRowIDs.intersection(itemRowIDs).map((rowid) {
          queryBindings.add(Variable.withInt(rowid));
          return "row_id = ?";
        });
      } else {
        itemRowIDCondition = searchRowIDs.map((rowId) {
          queryBindings.add(Variable.withInt(rowId));
          return "row_id = ?";
        });
      }
      queryConditions.add("(" + itemRowIDCondition.join(" OR ") + ")");
    } else if (itemRowIDs.isNotEmpty) {
      var itemRowIDCondition = itemRowIDs.map((rowId) {
        queryBindings.add(Variable.withInt(rowId));
        return "row_id = ?";
      });
      queryConditions.add("(" + itemRowIDCondition.join(" OR ") + ")");
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
    itemRecords.forEach((itemRecord) => rowIds.add(itemRecord.rowId));

    // Property and edges conditions
    List<List<int>> allConditionsItemsRowIds = [];
    List<List<int>> edgeConditionsItemsRowIds = [];
    await Future.forEach(conditions, (DatabaseQueryCondition condition) async {
      var info, query;
      List<Variable<dynamic>> binding = [];

      if (condition is DatabaseQueryConditionPropertyEquals) {
        info = condition.value;
        query = "name = ? AND value = ? AND item IN (${rowIds.join(", ")})";
        binding = [Variable.withString(info.name), Variable(info.value)];
        allConditionsItemsRowIds.add(
            (await dbController.databasePool.itemPropertyRecordsCustomSelect(query, binding))
                .map((el) => el.item)
                .whereType<int>()
                .toList());
      } else if (condition is DatabaseQueryConditionEdgeHasTarget) {
        info = condition.value;
        query = "name = ? AND target = ? AND source IN (${rowIds.join(", ")})";
        binding = [Variable(info.edgeName), Variable(info.target)];
        edgeConditionsItemsRowIds.add(
            (await dbController.databasePool.edgeRecordsCustomSelect(query, binding))
                .map((el) => el.source)
                .whereType<int>()
                .toList());
      } else if (condition is DatabaseQueryConditionEdgeHasSource) {
        info = condition.value;
        query = "name = ? AND source = ? AND target IN (${rowIds.join(", ")})";
        binding = [Variable(info.edgeName), Variable(info.source)];
        edgeConditionsItemsRowIds.add(
            (await dbController.databasePool.edgeRecordsCustomSelect(query, binding))
                .map((el) => el.target)
                .whereType<int>()
                .toList());
      }
    });
    if (edgeConditionsItemsRowIds.isNotEmpty) {
      if (edgeTargetsOperator == ConditionOperator.or) {
        var uniqueRowIds = <int>{};
        uniqueRowIds.addAll(edgeConditionsItemsRowIds.expand((element) => element));
        allConditionsItemsRowIds.addAll([uniqueRowIds.toList()]);
      } else {
        allConditionsItemsRowIds.addAll(edgeConditionsItemsRowIds);
      }
    }

    List<int> filteredIds = [];
    if (conditions.isNotEmpty) {
      if (allConditionsItemsRowIds.isNotEmpty) {
        filteredIds = intersection(allConditionsItemsRowIds) as List<int>;
        if (filteredIds.length == 0) {
          return [];
        } else {
          rowIds = filteredIds;
        }
      } else {
        return [];
      }
    }

    var orderBy;
    var join = "";
    List<TableInfo> joinTables = [];
    var sortOrder = sortAscending ? "" : "DESC";
    switch (sortProperty) {
      case "dateCreated":
        orderBy = "dateCreated $sortOrder, dateModified $sortOrder";
        break;
      case "dateModified":
        orderBy = "dateModified $sortOrder, dateCreated $sortOrder";
        break;
      case "dateSent":
        TableInfo table = dbController.databasePool.integers;
        String tableName = table.$tableName;
        joinTables.add(table);
        join =
            "LEFT OUTER JOIN $tableName ON items.row_id = $tableName.item AND $tableName.name = '$sortProperty'";

        orderBy = "$tableName.value";
        break;
      case "":
      case null:
        break;
      default:
        var propertyOrderBy = "";
        //TODO multiple itemTypes?
        if (itemTypes.length == 1) {
          SchemaValueType schemaValueType =
              dbController.schema.expectedPropertyType(itemTypes.first, sortProperty!)!;
          ItemRecordPropertyTable itemRecordPropertyTable =
              PropertyDatabaseValue.toDBTableName(schemaValueType);
          TableInfo table =
              dbController.databasePool.getItemPropertyRecordTable(itemRecordPropertyTable);
          String tableName = table.$tableName;
          joinTables.add(table);
          join =
              "LEFT OUTER JOIN $tableName ON items.row_id = $tableName.item AND $tableName.name = '$sortProperty'";
          propertyOrderBy = "$tableName.value $sortOrder, ";
        }

        orderBy = "$propertyOrderBy dateModified $sortOrder, dateCreated $sortOrder";
        break;
    }
    var finalQuery = "row_id IN (${rowIds.join(", ")})";
    return await dbController.databasePool.itemRecordsCustomSelect(finalQuery, [],
        join: join, joinTables: joinTables, limit: limit, offset: offset, orderBy: orderBy);
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

  factory DatabaseQueryConfig.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DatabaseQueryConfigToJson(this);

  @override
  List<Object?> get props => [
        itemTypes,
        itemRowIDs,
        _sortProperty,
        _sortAscending,
        _dateModifiedAfter,
        _dateModifiedBefore,
        _dateCreatedAfter,
        _dateCreatedBefore,
        pageSize,
        currentPage,
        searchString,
        includeImmediateEdgeSearch,
        conditions
      ];
}

abstract class DatabaseQueryCondition {
  dynamic get value;

  Map<String, dynamic> toJson();

  DatabaseQueryCondition();

  factory DatabaseQueryCondition.fromJson(json) {
    switch (json["type"]) {
      case "DatabaseQueryConditionPropertyEquals":
        return DatabaseQueryConditionPropertyEquals.fromJson(json);
      case "DatabaseQueryConditionEdgeHasTarget":
        return DatabaseQueryConditionEdgeHasTarget.fromJson(json);
      case "DatabaseQueryConditionEdgeHasSource":
        return DatabaseQueryConditionEdgeHasSource.fromJson(json);
      default:
        throw Exception("Unknown DatabaseQueryCondition: ${json["type"]}");
    }
  }
}

// A property of this item equals a particular value
@annotation.JsonSerializable()
class DatabaseQueryConditionPropertyEquals extends DatabaseQueryCondition {
  PropertyEquals value;

  DatabaseQueryConditionPropertyEquals(this.value);

  factory DatabaseQueryConditionPropertyEquals.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionPropertyEqualsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionPropertyEqualsToJson(this)..addAll({"type": runtimeType.toString()});
}

// This item has an edge pointing to 'x' item
@annotation.JsonSerializable()
class DatabaseQueryConditionEdgeHasTarget extends DatabaseQueryCondition {
  EdgeHasTarget value;

  DatabaseQueryConditionEdgeHasTarget(this.value);

  factory DatabaseQueryConditionEdgeHasTarget.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionEdgeHasTargetFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionEdgeHasTargetToJson(this)..addAll({"type": runtimeType.toString()});
}

@annotation.JsonSerializable()
class DatabaseQueryConditionEdgeHasSource extends DatabaseQueryCondition {
  EdgeHasSource value;

  DatabaseQueryConditionEdgeHasSource(this.value);

  factory DatabaseQueryConditionEdgeHasSource.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionEdgeHasSourceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionEdgeHasSourceToJson(this)..addAll({"type": runtimeType.toString()});
}

@annotation.JsonSerializable()
class PropertyEquals {
  String name;
  dynamic value;

  PropertyEquals(this.name, this.value);

  factory PropertyEquals.fromJson(Map<String, dynamic> json) => _$PropertyEqualsFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyEqualsToJson(this);
}

@annotation.JsonSerializable()
class EdgeHasTarget {
  String edgeName;
  int target;

  EdgeHasTarget(this.edgeName, this.target);

  factory EdgeHasTarget.fromJson(Map<String, dynamic> json) => _$EdgeHasTargetFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasTargetToJson(this);
}

@annotation.JsonSerializable()
class EdgeHasSource {
  String edgeName;
  int source;

  EdgeHasSource(this.edgeName, this.source);

  factory EdgeHasSource.fromJson(Map<String, dynamic> json) => _$EdgeHasSourceFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasSourceToJson(this);
}
