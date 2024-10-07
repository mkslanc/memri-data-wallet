import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:memri/core/models/item.dart';
import 'package:memri/core/services/error_service.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../../core/services/database/schema.dart';
import '../services/resolving/cvu_context.dart';

part 'database_query.g.dart';

enum ConditionOperator { and, or }

/// This type is used to describe a database query.
@JsonSerializable()
class DatabaseQueryConfig extends ChangeNotifier with EquatableMixin {
  Map<String, dynamic> _filterProperties;
  T _get<T>(key) => _filterProperties[key] as T;
  void _set<T>(String key, T newValue) {
    if (_filterProperties[key] != newValue) {
      _filterProperties[key] = newValue;
      notifyListeners();
    }
  }

  @annotation.JsonKey(ignore: true)
  late final PodService _podService;

  @annotation.JsonKey(ignore: true)
  Schema? _schema;
  Schema get schema => _schema ??= GetIt.I<Schema>();

  /// A list of item types to include. Default is Empty -> ALL item types
  List<String> itemTypes;

  /// A list of item `rowid` to include. Default is Empty -> don't filter on `rowid`
  Set<int> itemRowIDs;

  String? get sortProperty => _get<String?>("sortProperty");
  set sortProperty(String? newValue) => _set<String?>("sortProperty", newValue);

  bool get sortAscending => _get<bool>("sortAscending");
  set sortAscending(bool newValue) => _set<bool>("sortAscending", newValue);

  /// A search string to match item properties against
  String? get searchString => _get<String?>("searchString");
  set searchString(String? newValue) => _set<String?>("searchString", newValue);

  bool? deleted = false;

  /// The maximum number of items to fetch
  int pageSize;

  /// Use this to change which page is requested by the query (eg. if there are more than `pageSize` items)
  int currentPage;

  /// If enabled the search will find items that link to another item matching the search term. This only goes one edge deep for performance purposes.
  bool includeImmediateEdgeSearch;

  /// A list of conditions. eg. property name = "Demo note"
  List<QueryCondition> conditions = [];

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
      Map<String, dynamic>? filterProperties,
      this.pageSize = 1000,
      this.currentPage = 0,
      this.includeImmediateEdgeSearch = true,
      List<QueryCondition>? conditions,
      this.edgeTargetsOperator = ConditionOperator.and,
      this.count})
      : itemTypes = itemTypes ?? ["Person", "Note", "Address", "Photo"],
        itemRowIDs = itemRowIDs ?? Set.of(<int>[]),
        _filterProperties = filterProperties ??
            {
              "searchString": null,
              "sortProperty": "dateModified",
              "sortAscending": false,
            },
        _podService = GetIt.I(),
        conditions = conditions ?? [];

  DatabaseQueryConfig clone() {
    //TODO find better way to clone object
    return DatabaseQueryConfig(
      itemTypes: itemTypes,
      itemRowIDs: itemRowIDs,
      filterProperties: Map.from(_filterProperties)..remove("searchString"),
      pageSize: pageSize,
      currentPage: currentPage,
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
      } on Exception catch (e) {
        if (ErrorService.isConnectionError(e)) {
          throw e;
        }
        //ignore other exceptions for now
      }
      items += itemsByType;
    }
    if (searchString != null && searchString!.isNotEmpty) {
      items = localFullTextSearch(items: items, needle: searchString!);
    }

    items = _filterByLikeConditions(items);

    return items;
  }

  factory DatabaseQueryConfig.queryConfigWith({
    required CVUContext context,
    CVUParsedDefinition? datasource,
    CVUDefinitionContent? datasourceContent,
    DatabaseQueryConfig? inheritQuery,
    Set<int>? overrideUIDs,
    DateTimeRange? dateRange,
    String? itemType,
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
          datasourceResolver?.stringArray("query") ?? [itemType].compactMap();
      if (itemTypes.isNotEmpty) {
        queryConfig.itemTypes = itemTypes;
      }

      var properties = filterDef?.subdefinition("properties");

      if (properties != null) {
        for (var key in properties.properties.keys) {
          dynamic value = properties.string(key) ?? "";
          queryConfig._addPropertyCondition(key, value, ComparisonType.equals); //TODO: should rely on different comparison types
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

  void addPropertyCondition(String key, dynamic value, ComparisonType comparisonType) {
    _addPropertyCondition(key, value, comparisonType);
    notifyListeners();
  }

  List<PropertyCondition> get propertyConditions =>
      conditions.whereType<PropertyCondition>().toList();

  PropertyCondition? getPropertyCondition(String key, [ComparisonType? comparisonType]) =>
      propertyConditions.firstWhereOrNull(
          (condition) => condition.name == key
              && (comparisonType == null || condition.comparisonType == comparisonType)
      );

  bool existsPropertyCondition(String key, [ComparisonType? comparisonType]) =>
      getPropertyCondition(key, comparisonType) != null;

  removePropertyCondition(String key, [ComparisonType? comparisonType]) {
    var condition = getPropertyCondition(key, comparisonType);
    if (condition == null)
      return;
    conditions.remove(condition);
    notifyListeners();
  }

  void _addPropertyCondition(String key, dynamic value, ComparisonType comparisonType) {
    var propertyCondition = getPropertyCondition(key, comparisonType);

    if (propertyCondition == null) {
      conditions.add(PropertyCondition(key, value, comparisonType));
    } else if (propertyCondition.value != value) {
      propertyCondition.value = value;
      propertyCondition.comparisonType = comparisonType;
    }
  }

  Iterable<String> _constructGraphQLQueries() {
    return itemTypes.map(_constructGraphQLQuery);
  }

  String _constructGraphQLQuery(String itemType) {
    if (!schema.isLoaded) return "";

    // Fetch the properties for the current item type using the Schema object
    List<String> properties = schema.propertyNamesForItemType(itemType);

    String filter = _graphQlFilter(itemType);
    String edgesQuery = _graphQlEdgesQuery(itemType);
    String order = sortAscending ? "order_asc" : "order_desc";

    return '''query {
      $itemType (
        ${order}: ${sortProperty ?? 'dateModified'}, 
        ${filter.isNotEmpty ? "filter: ${filter}, " : ""}
      ) {
        ${properties.join('\n')}
        $edgesQuery
      }
    }''';
  }

  // Build the filter part of the query based on the config
  String _graphQlFilter(String itemType) {
    List<String> filterParts = [];

    // if (deleted != null) {
    //   filterParts.add(filterPart("deleted", deleted, "eq"));
    // }
    for (var condition in propertyConditions) {
      var operation = condition.operation;
      if (operation == null)
        continue;
      filterParts.add(filterPart(condition.name, condition.value, operation, itemType));
    }

    if (filterParts.isEmpty)
      return "";
    return combineFilterParts(filterParts);
  }

  String combineFilterParts(List<String> filterParts) {
    if (filterParts.length > 1) {
      return "{and: [" + filterParts.removeAt(0) + ", " + combineFilterParts(filterParts) + "]}";
    } else {
      return filterParts.first;
    }
  }

  String filterPart(String key, dynamic value, String op, String itemType) {
    var expectedType = schema.expectedPropertyType(itemType, key);
    if (key == "dateModified" || key == "dateCreated")
      expectedType = SchemaValueType.datetime;//TODO why in our schema they're not datetime?
    switch (expectedType) {
      case SchemaValueType.string:
        value = '"$value"';
        break;
      case SchemaValueType.datetime:
        value = value.millisecondsSinceEpoch;
        break;
      default: break;
    }
    return '{${key}: { ${op}: ${value} }}';
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
    List<String> edgeNames = schema.edgeNamesForItemType(currentType);

    for (String edge in edgeNames) {
      String? targetType = schema.expectedTargetType(currentType, edge);
      if (targetType != null) {
        List<String> edgeProperties = schema.propertyNamesForItemType(targetType);
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

  List<Item> localFullTextSearch({
    required List<Item> items,
    required String needle,
  }) {
    // Convert the needle to lowercase for case-insensitive search
    String searchNeedle = needle.toLowerCase();

    // Filter items that contain the needle in any of their string properties
    List<Item> filteredResults = items.where((item) {
      // Get all property names for the item's type
      List<String> properties = schema.propertyNamesForItemType(item.type);

      // Check if any of the item's string properties contain the needle
      for (String property in properties) {
        // Check if the property type is string
        if (schema.expectedPropertyType(item.type, property) == SchemaValueType.string) {
          var propertyValue = item.get(property);
          if (propertyValue is String && propertyValue.toLowerCase().contains(searchNeedle)) {
            return true; // Needle found in one of the string properties
          }
        }
      }
      return false; // Needle not found in any string properties
    }).toList();

    return filteredResults;
  }

  List<Item> _filterByLikeConditions(List<Item> items) {
    List<PropertyCondition> likeConditions = propertyConditions
        .where((condition) => condition.comparisonType == ComparisonType.like).toList();

    if (likeConditions.isEmpty)
      return items;

    return items.where((item) {
      return likeConditions.every((condition) {
        var propertyValue = item.get(condition.name);
        return propertyValue is String &&
            propertyValue.toLowerCase().contains(condition.value.toString().toLowerCase());
      });
    }).toList();
  }



  factory DatabaseQueryConfig.fromJson(Map<String, dynamic> json) =>
      _$DatabaseQueryConfigFromJson(json);

  Map<String, dynamic> toJson() => _$DatabaseQueryConfigToJson(this);

  @override
  List<Object?> get props => [
        itemTypes,
        itemRowIDs,
        _filterProperties,
        pageSize,
        currentPage,
        searchString,
        includeImmediateEdgeSearch,
        conditions,
      ];
}

abstract class QueryCondition {
  dynamic get value;

  Map<String, dynamic> toJson();

  QueryCondition();

  factory QueryCondition.fromJson(Map<String, dynamic> json) {
    switch (json["type"]) {
      case "PropertyCondition":
        return PropertyCondition.fromJson(json);
      case "EdgeHasTargetCondition":
        return EdgeHasTargetCondition.fromJson(json);
      case "EdgeHasSourceCondition":
        return EdgeHasSourceCondition.fromJson(json);
      default:
        throw Exception("Unknown QueryCondition: ${json["type"]}");
    }
  }
}

@annotation.JsonSerializable()
class PropertyCondition extends QueryCondition {
  String name;
  dynamic value;
  ComparisonType comparisonType;

  PropertyCondition(this.name, this.value, this.comparisonType);

  String? get operation => switch (comparisonType) {
        ComparisonType.equals => "eq",
        ComparisonType.greaterThan => "gte",
        ComparisonType.lessThan => "lte",
        ComparisonType.like => null,
      };

  factory PropertyCondition.fromJson(Map<String, dynamic> json) =>
      _$PropertyConditionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PropertyConditionToJson(this)..addAll({"type": runtimeType.toString()});
}

// This item has an edge pointing to 'x' item
@annotation.JsonSerializable()
class EdgeHasTargetCondition extends QueryCondition {
  EdgeHasTarget value;

  EdgeHasTargetCondition(this.value);

  factory EdgeHasTargetCondition.fromJson(Map<String, dynamic> json) =>
      _$EdgeHasTargetConditionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EdgeHasTargetConditionToJson(this)..addAll({"type": runtimeType.toString()});
}

@annotation.JsonSerializable()
class EdgeHasSourceCondition extends QueryCondition {
  EdgeHasSource value;

  EdgeHasSourceCondition(this.value);

  factory EdgeHasSourceCondition.fromJson(Map<String, dynamic> json) =>
      _$EdgeHasSourceConditionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$EdgeHasSourceConditionToJson(this)..addAll({"type": runtimeType.toString()});
}

enum ComparisonType {
  equals,
  greaterThan,
  lessThan,
  like,
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


