import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:memri/core/models/item.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';

import '../../core/services/database/schema.dart';
import '../services/resolving/cvu_context.dart';

part 'database_query.g.dart';

enum ConditionOperator { and, or }

/// This type is used to describe a database query.
@JsonSerializable()
class DatabaseQueryConfig extends ChangeNotifier with EquatableMixin {
  @annotation.JsonKey(ignore: true)
  final PodService _podService;
  Schema? schema;

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

  /// A list of edges to include in query. eg. ".file"
  List<String> edges = [];

  ConditionOperator edgeTargetsOperator = ConditionOperator.and;

  @annotation.JsonKey(ignore: true)
  int? count;

  /// A list of conditions. eg. property name = "Demo note"
  List<String> groupByProperties = [];

  /// Only include items created before this date
  String? queryGraphQL;

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
      : itemTypes = itemTypes ?? ["Person", "Note", "Address", "Photo"],
        itemRowIDs = itemRowIDs ?? Set.of(<int>[]),
        _sortAscending = sortAscending,
        _sortProperty = sortProperty,
        _dateModifiedAfter = dateModifiedAfter,
        _dateModifiedBefore = dateModifiedBefore,
        _dateCreatedAfter = dateCreatedAfter,
        _dateCreatedBefore = dateCreatedBefore,
        _podService = GetIt.I(),
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
      edgeTargetsOperator: edgeTargetsOperator,
      count: count,
      conditions: conditions,
    );
  }

  Future<List<Item>> executeRequest() async {
    List<Item> items = [];
    Iterable<String> queries = queryGraphQL != null ? [queryGraphQL!] : _constructGraphQLQueries();
    for (var query in queries) {
      List<Item> itemsByType = [];
      try {
        itemsByType = await _podService.graphql(query: query);
      } catch (e) {
        //ignore for now
      }
      items += itemsByType;
    }
    return items;
  }

  factory DatabaseQueryConfig.queryConfigWith({
    required CVUContext context,
    CVUParsedDefinition? datasource,
    CVUDefinitionContent? datasourceContent,
    DatabaseQueryConfig? inheritQuery,
    Set<int>? overrideUIDs,
    DateTimeRange? dateRange,
  }) {
    datasourceContent ??= datasource?.parsed;
    var datasourceResolver = datasourceContent?.propertyResolver(
      context: context,
      lookup: CVULookupController(),
    );
    var filterDef = datasourceResolver?.subdefinition("filter");

    if (inheritQuery == null) {
      var queryConfig = DatabaseQueryConfig();
      var itemTypes =
          datasourceResolver?.stringArray("query") /*?? [targetItem?.type].compactMap()*/ ?? [];
      if (itemTypes.isNotEmpty) {
        queryConfig.itemTypes = itemTypes;
      }

      var properties = filterDef?.subdefinition("properties");

      if (properties != null) {
        for (var key in properties.properties.keys) {
          dynamic value = properties.string(key) ?? "";
          queryConfig._addPropertyEqualCondition(key, value);
        }
      }

      queryConfig.edges = datasourceResolver?.stringArray("edges") ?? []; //TODO

      var queryGraphQL = datasourceResolver?.string("queryGraphQL") ?? "";
      if (queryGraphQL.isNotEmpty) {
        // direct graphql query in cvu
        queryConfig.queryGraphQL = queryGraphQL.replaceAll("[", "{").replaceAll("]", "}");
      }

      return queryConfig;
    } else {
      return inheritQuery.clone();
    }
  }

  void addPropertyEqualCondition(String key, dynamic value) {
    _addPropertyEqualCondition(key, value);
    notifyListeners();
  }

  void _addPropertyEqualCondition(String key, dynamic value) {
    // Check if a condition with the same key and value already exists
    bool exists = conditions.any((condition) =>
        condition is DatabaseQueryConditionPropertyEquals &&
        condition.value.name == key &&
        condition.value.value == value);

    // Add the condition only if it doesn't already exist
    if (!exists) {
      conditions.add(DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value)));
    }
  }

  Iterable<String> _constructGraphQLQueries() {
    return itemTypes.map(_constructGraphQLQuery);
  }

  String _constructGraphQLQuery(String itemType) {
    schema ??= GetIt.I<Schema>();
    if (!schema!.isLoaded) return "";

    // Fetch the properties for the current item type using the Schema object
    List<String> properties = schema!.propertyNamesForItemType(itemType);

    String filter = _graphQlFilter();
    String edgesQuery = _graphQlEdgesQuery(itemType);

    return '''query {
      $itemType (
        order_desc: ${sortProperty ?? 'dateModified'}, 
        ${filter.isNotEmpty ? "filter: $filter" : ""}
      ) {
        ${properties.join('\n')}
        $edgesQuery
      }
    }''';
  }

  // Build the filter part of the query based on the config
  String _graphQlFilter() {
    String filter = '';

    /*if (deleted != null) {
        filter += 'deleted: { eq: ${deleted} }, ';
      }*/
    /*if (dateModifiedAfter != null) {
        filter += 'dateModified: { gte: "${dateModifiedAfter!.toIso8601String()}" }, ';
      }
      if (dateModifiedBefore != null) {
        filter += 'dateModified: { lte: "${dateModifiedBefore!.toIso8601String()}" }, ';
      }*/
    for (var condition in conditions) {
      if (condition is DatabaseQueryConditionPropertyEquals) {
        filter += '{${condition.value.name}: { eq: ${condition.value.value} }}, ';
      }
    }
    return filter;
  }

  // Initialize edges query parts
  String _graphQlEdgesQuery(itemType) {
    // Map to keep track of the nested edge structures
    Map<dynamic, dynamic> edgeTree = {};
    // Process each edge to build the nested map structure
    for (String edge in edges) {
      List<String> edgeLevels = edge.split('.');
      Map<dynamic, dynamic> currentLevel = edgeTree;

      for (String level in edgeLevels) {
        currentLevel = currentLevel.putIfAbsent(level, () => {});
      }
    }

    // Convert the edge tree into a GraphQL query string
    String edgesQuery = _buildEdgeQuery(itemType, edgeTree, 0);

    return edgesQuery;
  }

  // Recursive function to convert edge tree to GraphQL query string
  String _buildEdgeQuery(String currentType, Map<dynamic, dynamic> subEdges, int depth) {
    if (depth > 1 && subEdges.isEmpty) return ''; // Restrict recursion depth to 2 levels

    String result = '';
    // Fetch all edges for the current item type
    List<String> edgeNames = schema!.edgeNamesForItemType(currentType) ?? [];

    for (String edge in edgeNames) {
      String? targetType = schema!.expectedTargetType(currentType, edge);
      if (targetType != null) {
        List<String> edgeProperties = schema!.propertyNamesForItemType(targetType) ?? [];
        String nestedQuery = _buildEdgeQuery(targetType, subEdges[edge] ?? {}, depth + 1);
        result += '''
        $edge {
          ${edgeProperties.join('\n')}
          $nestedQuery
        }
        ''';
      }
    }
    return result;
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
  List<int> target;

  EdgeHasTarget(this.edgeName, this.target);

  factory EdgeHasTarget.fromJson(Map<String, dynamic> json) => _$EdgeHasTargetFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasTargetToJson(this);
}

@annotation.JsonSerializable()
class EdgeHasSource {
  String edgeName;
  List<int> source;

  EdgeHasSource(this.edgeName, this.source);

  factory EdgeHasSource.fromJson(Map<String, dynamic> json) => _$EdgeHasSourceFromJson(json);

  Map<String, dynamic> toJson() => _$EdgeHasSourceToJson(this);
}
