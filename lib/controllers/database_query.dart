import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/database/database.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:moor/moor.dart';

part 'database_query.g.dart';

enum ConditionOperator { and, or }

/// This type is used to describe a database query.
@JsonSerializable()
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

  bool? deleted = false;

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

  /// A list of `join` queries with edge conditions.
  List<JoinQueryStruct>? sortEdges;

  ConditionOperator edgeTargetsOperator = ConditionOperator.and;

  @annotation.JsonKey(ignore: true)
  late DatabaseController dbController;

  int? count;

  /// A list of conditions. eg. property name = "Demo note"
  List<String> groupByProperties = [];

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
      this.count,
      this.sortEdges})
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
        count: count,
        sortEdges: sortEdges);
  }

  Future<List<Item>> constructFilteredRequest([Set<int>? searchRowIDs]) async {
    List<dynamic> intersection(List<List<dynamic>> arrays) {
      if (arrays.length == 0) {
        return [];
      }
      return [...arrays].reduce((a, c) => a.where((i) => c.contains(i)).toList());
    }

    var limit = count ?? pageSize;
    var offset = (count ?? 0) > 0 ? 0 : pageSize * currentPage;

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
      queryBindings.add(Variable.withInt(dateModifiedBefore!.millisecondsSinceEpoch));
    }
    if (dateModifiedAfter != null) {
      queryConditions.add("dateModified >= ?");
      queryBindings.add(Variable.withInt(dateModifiedAfter!.millisecondsSinceEpoch));
    }
    if (dateCreatedBefore != null) {
      queryConditions.add("dateCreated <= ?");
      queryBindings.add(Variable.withInt(dateCreatedBefore!.millisecondsSinceEpoch));
    }
    if (dateCreatedAfter != null) {
      queryConditions.add("dateCreated >= ?");
      queryBindings.add(Variable.withInt(dateCreatedAfter!.millisecondsSinceEpoch));
    }
    if (deleted != null) {
      queryConditions.add("deleted = ?");
      queryBindings.add(Variable.withBool(deleted!));
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
        query =
            "name = ? AND target IN (${info.target.join(", ")}) AND source IN (${rowIds.join(", ")})";
        binding = [Variable(info.edgeName)];
        edgeConditionsItemsRowIds.add(
            (await dbController.databasePool.edgeRecordsCustomSelect(query, binding))
                .map((el) => el.source)
                .whereType<int>()
                .toList());
      } else if (condition is DatabaseQueryConditionEdgeHasSource) {
        info = condition.value;
        query =
            "name = ? AND source IN (${info.source.join(", ")}) AND target IN (${rowIds.join(", ")})";
        binding = [Variable(info.edgeName)];
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
    Set<TableInfo> joinTables = {};
    var sortOrder = sortAscending ? "" : "DESC";
    var groupBy;

    switch (sortProperty) {
      case "dateCreated":
        orderBy = "dateCreated $sortOrder, dateModified $sortOrder";
        break;
      case "dateModified":
        orderBy = "dateModified $sortOrder, dateCreated $sortOrder";
        break;
      case "dateSent":
        TableInfo table = dbController.databasePool.integers;
        String tableName = table.aliasedName;
        joinTables.add(table);
        join =
            "LEFT OUTER JOIN $tableName ON items.row_id = $tableName.item AND $tableName.name = '$sortProperty'";

        orderBy = "$tableName.value $sortOrder";
        break;
      case "":
      case null:
        break;
      case "edge":
        if (sortEdges != null && sortEdges!.isNotEmpty) {
          sortEdges!.forEach((element) {
            join += " " + element.joinQuery;
            joinTables.add(dbController.databasePool.getTable(element.table));
          });
          orderBy =
              "${sortOrder == "DESC" ? "MAX" : "MIN"}(prop.value) $sortOrder, dateModified $sortOrder, dateCreated $sortOrder";
          groupBy = "row_id";
        } else {
          orderBy = "dateModified $sortOrder, dateCreated $sortOrder";
        }
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
          String tableName = table.aliasedName;
          joinTables.add(table);
          join =
              "LEFT JOIN $tableName ON items.row_id = $tableName.item AND $tableName.name = '$sortProperty'";
          propertyOrderBy = "$tableName.value $sortOrder, ";
        }

        orderBy = "$propertyOrderBy dateModified $sortOrder, dateCreated $sortOrder";
        break;
    }

    if (groupByProperties.isNotEmpty) {
      //TODO: group by multiple properties
      SchemaValueType? schemaValueType =
          dbController.schema.expectedPropertyType(itemTypes.first, groupByProperties[0]);
      if (schemaValueType != null) {
        ItemRecordPropertyTable itemRecordPropertyTable =
            PropertyDatabaseValue.toDBTableName(schemaValueType);
        TableInfo table =
            dbController.databasePool.getItemPropertyRecordTable(itemRecordPropertyTable);
        String tableName = table.aliasedName;
        joinTables.add(table);
        join +=
            "LEFT JOIN $tableName as grouping ON items.row_id = grouping.item AND grouping.name = '${groupByProperties[0]}'";
        groupBy = "grouping.value";
      } else {
        print("Error: Unknown property ${groupByProperties[0]} for ${itemTypes.first}");
      }
    }

    var finalQuery = "row_id IN (${rowIds.join(", ")})";
    return await dbController.databasePool.itemRecordsCustomSelect(finalQuery, [],
        join: join,
        joinTables: joinTables.toList(),
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        groupBy: groupBy);
  }

  _constructSearchRequest() async {
    var searchQuery = searchString?.replaceAll('"', "").nullIfBlank;
    if (searchQuery == null) return;
    searchQuery =
        searchQuery.split(" ").compactMap((e) => e.nullIfBlank == null ? null : '"$e"').join(" ");
    var refinedQuery = '$searchQuery*';
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

    List<Item> result = await constructFilteredRequest(searchIDs);
    if (result.length > 0) {
      yield result.map((item) => ItemRecord.fromItem(item)).toList();
    } else {
      yield [];
    }
  }

  Future<List<JoinQueryStruct>?> combineSortEdgesQuery(
      {required CVUPropertyResolver sortResolver,
      required DatabaseController dbController,
      List<JoinQueryStruct>? conditions}) async {
    conditions ??= [];
    String? targetType = await sortResolver.string("targetType");
    if (itemTypes.isNotEmpty) {
      //Assigning sortProperty to special type - edge
      sortProperty = "edge";
      var edgeTarget = sortResolver.subdefinition("edgeTarget");
      var edgeSource = sortResolver.subdefinition("edgeSource");
      var edgeSorting = edgeTarget ?? edgeSource;
      if (edgeSorting != null) {
        var direction = "source";
        var oppositeDirection = "target";
        if (edgeTarget != null) {
          direction = "target";
          oppositeDirection = "source";
        }

        var tableAliasName = 'e' + conditions.length.toString();
        var subCond = [];
        await Future.forEach(edgeSorting.properties.keys, (String key) async {
          if (key == "name" ||
              key == "sortProperty" ||
              key == "sortAscending" ||
              key == "edgeTarget" ||
              key == "edgeSource") return;
          if (targetType != null) {
            ResolvedType? valueType = dbController.schema.expectedType(targetType, key);
            if (valueType != null) {
              var val = await edgeSorting.integer(key);
              if (val != null) {
                subCond.add("$tableAliasName.$oppositeDirection = '${val.toString()}'");
              }
            }
          }
        });

        if (edgeSorting.properties["name"] != null) {
          var sortEdgeName = await edgeSorting.string("name");

          var join;
          if (conditions.isEmpty || conditions.last.direction == null) {
            join =
                "LEFT JOIN edges $tableAliasName ON items.row_id = $tableAliasName.$oppositeDirection AND $tableAliasName.name = '$sortEdgeName'"; //TODO: source/target
          } else {
            join =
                "LEFT JOIN edges $tableAliasName ON ${conditions.last.direction} = $tableAliasName.$oppositeDirection AND $tableAliasName.name = '$sortEdgeName'"; //TODO: source/target
          }
          if (subCond.isNotEmpty) {
            join += ' AND (${subCond.join(" OR ")})';
          }

          conditions.add(JoinQueryStruct(
              table: "edges", joinQuery: join, direction: "$tableAliasName.$direction"));

          if (edgeSorting.properties["sortProperty"] != null) {
            var sortPropertyCondition = await edgeSorting.string("sortProperty");

            targetType ??= dbController.schema.expectedTargetType(itemTypes.first, sortEdgeName!);
            if (targetType == null) {
              print("No target type for $sortEdgeName");
              return conditions;
            }
            SchemaValueType? schemaValueType =
                dbController.schema.expectedPropertyType(targetType, sortPropertyCondition!);
            if (schemaValueType == null) {
              print("No schema type for property $sortPropertyCondition");
              return conditions;
            }
            ItemRecordPropertyTable itemRecordPropertyTable =
                PropertyDatabaseValue.toDBTableName(schemaValueType);
            TableInfo table =
                dbController.databasePool.getItemPropertyRecordTable(itemRecordPropertyTable);
            String tableName = table.aliasedName;
            var join =
                "LEFT JOIN $tableName prop on $tableAliasName.$direction = prop.item AND prop.name = '$sortPropertyCondition'";

            conditions.add(JoinQueryStruct(
                table: tableName, joinQuery: join, direction: "$tableAliasName.$direction"));
          }
          if (edgeSorting.properties["sortAscending"] != null) {
            var sortAscending = await edgeSorting.boolean("sortAscending");
            if (sortAscending != null) {
              this.sortAscending = sortAscending;
            }
          }
        } else {
          var join;
          if (conditions.isEmpty || conditions.last.direction == null) {
            join = "LEFT JOIN edges $tableAliasName ON items.row_id = $tableAliasName.$direction";
          } else {
            join =
                "LEFT JOIN edges $tableAliasName ON ${conditions.last.direction} = $tableAliasName.$direction";
          }
          if (subCond.isNotEmpty) {
            join += ' AND (${subCond.join(" OR ")})';
          }
          conditions.add(JoinQueryStruct(
              table: "edges", joinQuery: join, direction: "$tableAliasName.$direction"));
        }
        return combineSortEdgesQuery(
            sortResolver: edgeSorting, dbController: dbController, conditions: conditions);
      }
    }
    return conditions;
  }

  static Future<DatabaseQueryConfig> queryConfigWith(
      {required CVUContext context,
      CVUParsedDefinition? datasource,
      DatabaseQueryConfig? inheritQuery,
      Set<int>? overrideUIDs,
      ItemRecord? targetItem,
      DateTimeRange? dateRange,
      DatabaseController? databaseController}) async {
    var datasourceResolver = datasource?.parsed.propertyResolver(
        context: context,
        lookup: CVULookupController(),
        db: AppController.shared.databaseController);
    var uidList = overrideUIDs ?? Set.from(await datasourceResolver?.intArray("uids") ?? []);
    var filterDef = datasourceResolver?.subdefinition("filter");

    var edgeTargets = filterDef?.subdefinition("edgeTargets");
    List<DatabaseQueryCondition> edgeTargetConditions = (await Future.wait<DatabaseQueryCondition?>(
            (edgeTargets?.properties.keys.toList() ?? [])
                .map<Future<DatabaseQueryCondition?>>((key) async {
      List<int>? target = (await edgeTargets?.items(key))?.compactMap((e) => e.rowId);
      if (target == null || target.isEmpty) {
        target = [(await edgeTargets?.integer(key)) ?? 0];
      }
      return DatabaseQueryConditionEdgeHasTarget(EdgeHasTarget(key, target));
    })))
        .compactMap();

    var edgeSources = filterDef?.subdefinition("edgeSources");
    List<DatabaseQueryCondition> edgeSourceConditions = (await Future.wait<DatabaseQueryCondition?>(
            (edgeSources?.properties.keys.toList() ?? [])
                .map<Future<DatabaseQueryCondition?>>((key) async {
      List<int>? source = (await edgeSources?.items(key))?.compactMap((e) => e.rowId);
      if (source == null || source.isEmpty) {
        source = [(await edgeSources?.integer(key)) ?? 0];
      }
      return DatabaseQueryConditionEdgeHasSource(EdgeHasSource(key, source));
    })))
        .compactMap();

    var queryConfig = inheritQuery?.clone() ?? DatabaseQueryConfig();
    var itemTypes =
        await datasourceResolver?.stringArray("query") ?? [targetItem?.type].compactMap();
    if (itemTypes.isNotEmpty) {
      queryConfig.itemTypes = itemTypes;
    }

    if (uidList.isNotEmpty) {
      queryConfig.itemRowIDs = uidList;
    }

    var properties = filterDef?.subdefinition("properties");
    List<DatabaseQueryCondition> propertyConditions = (await Future.wait<DatabaseQueryCondition?>(
            (properties?.properties.keys.toList() ?? [])
                .map<Future<DatabaseQueryCondition?>>((key) async {
      dynamic value;
      var schemaType = databaseController?.schema.expectedPropertyType(itemTypes[0], key) ??
          SchemaValueType.string;
      if (schemaType == SchemaValueType.bool) {
        value = await properties?.boolean(key);
      } else {
        value = await properties?.string(key) ?? "";
      }
      return DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value));
    })))
        .compactMap();

    var sortDef = datasourceResolver?.subdefinition("sort");

    if (sortDef != null) {
      queryConfig.sortEdges = await queryConfig.combineSortEdgesQuery(
          sortResolver: sortDef,
          dbController: databaseController ?? AppController.shared.databaseController);
    }

    var edgeTargetsOperator = datasourceResolver?.properties["edgeTargetsOperator"];
    if (edgeTargetsOperator != null &&
        edgeTargetsOperator is CVUValueConstant &&
        edgeTargetsOperator.value is CVUConstantString) {
      var operator = (edgeTargetsOperator.value as CVUConstantString).value;
      queryConfig.edgeTargetsOperator =
          operator == "OR" ? ConditionOperator.or : ConditionOperator.and;
    }

    var sortProperty = await datasourceResolver?.string("sortProperty");
    if (sortProperty != null) {
      queryConfig.sortProperty = sortProperty;
    }
    var sortAscending = await datasourceResolver?.boolean("sortAscending");
    if (sortAscending != null) {
      queryConfig.sortAscending = sortAscending;
    }

    if (dateRange != null) {
      queryConfig.dateModifiedAfter = dateRange.start;
      queryConfig.dateModifiedBefore = dateRange.end;
    }
    if (edgeTargetConditions.isNotEmpty ||
        edgeSourceConditions.isNotEmpty ||
        propertyConditions.isNotEmpty) {
      queryConfig.conditions = []
        ..addAll(edgeTargetConditions)
        ..addAll(edgeSourceConditions)
        ..addAll(propertyConditions);
    }

    var count = await datasourceResolver?.integer("count");
    if (count != null) {
      queryConfig.count = count;
    }

    var groupByDef = datasourceResolver?.subdefinition("groupBy");
    var groupByProperties = await groupByDef?.stringArray("properties");
    queryConfig.groupByProperties = groupByProperties ?? [];

    return queryConfig;
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
        conditions,
        sortEdges
      ];
}

@JsonSerializable()
class JoinQueryStruct {
  String table;
  String joinQuery;
  String? direction;

  JoinQueryStruct({required this.table, required this.joinQuery, this.direction});

  factory JoinQueryStruct.fromJson(Map<String, dynamic> json) => _$JoinQueryStructFromJson(json);

  Map<String, dynamic> toJson() => _$JoinQueryStructToJson(this);
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
@JsonSerializable()
class DatabaseQueryConditionPropertyEquals extends DatabaseQueryCondition {
  PropertyEquals value;

  DatabaseQueryConditionPropertyEquals(this.value);

  factory DatabaseQueryConditionPropertyEquals.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionPropertyEqualsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionPropertyEqualsToJson(this)..addAll({"type": runtimeType.toString()});
}

// This item has an edge pointing to 'x' item
@JsonSerializable()
class DatabaseQueryConditionEdgeHasTarget extends DatabaseQueryCondition {
  EdgeHasTarget value;

  DatabaseQueryConditionEdgeHasTarget(this.value);

  factory DatabaseQueryConditionEdgeHasTarget.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionEdgeHasTargetFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionEdgeHasTargetToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class DatabaseQueryConditionEdgeHasSource extends DatabaseQueryCondition {
  EdgeHasSource value;

  DatabaseQueryConditionEdgeHasSource(this.value);

  factory DatabaseQueryConditionEdgeHasSource.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConditionEdgeHasSourceFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DatabaseQueryConditionEdgeHasSourceToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class PropertyEquals {
  String name;
  dynamic value;

  PropertyEquals(this.name, this.value);

  factory PropertyEquals.fromJson(Map<String, dynamic> json) => _$PropertyEqualsFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyEqualsToJson(this);
}

@JsonSerializable()
class EdgeHasTarget {
  String edgeName;
  List<dynamic> target;

  EdgeHasTarget(this.edgeName, this.target);

  factory EdgeHasTarget.fromJson(Map<String, dynamic> json) => _$EdgeHasTargetFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasTargetToJson(this);
}

@JsonSerializable()
class EdgeHasSource {
  String edgeName;
  List<dynamic> source;

  EdgeHasSource(this.edgeName, this.source);

  factory EdgeHasSource.fromJson(Map<String, dynamic> json) => _$EdgeHasSourceFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasSourceToJson(this);
}
