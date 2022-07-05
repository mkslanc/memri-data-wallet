import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_annotation/json_annotation.dart' as annotation;
import 'package:memri/core/apis/pod/pod_requests.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/core/models/database/item_record.dart';

import '../services/resolving/cvu_context.dart';

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

  ConditionOperator edgeTargetsOperator = ConditionOperator.and;

  @annotation.JsonKey(ignore: true)
  late DatabaseController dbController;

  int? count;

  /// A list of conditions. eg. property name = "Demo note"
  List<String> groupByProperties = [];

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
      this.edgeTargetsOperator = ConditionOperator.and,
      this.count})
      : itemTypes = itemTypes ??
            ["Person", "Note", "Address", "Photo", "Indexer", "Importer"],
        itemRowIDs = itemRowIDs ?? Set.of(<int>[]),
        _sortAscending = sortAscending,
        _sortProperty = sortProperty,
        _dateModifiedAfter = dateModifiedAfter,
        _dateModifiedBefore = dateModifiedBefore,
        _dateCreatedAfter = dateCreatedAfter,
        _dateCreatedBefore = dateCreatedBefore;

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
    );
  }

  Future<List<Item>> executeGraphQLRequest() async {
    var request = PodStandardRequest.queryGraphQL(queryGraphQL!);
    var networkCall = await request
        .execute((await AppController.shared.podConnectionConfig)!);
    var res = jsonDecode(networkCall.body);

    List<Item> items = (res["data"] as List<dynamic>)
        .map((itemMap) => Item.fromJson(itemMap))
        .toList();

    return items;
  }

  factory DatabaseQueryConfig.queryConfigWith(
      {required CVUContext context,
      CVUParsedDefinition? datasource,
      CVUDefinitionContent? datasourceContent,
      DatabaseQueryConfig? inheritQuery,
      Set<int>? overrideUIDs,
      ItemRecord? targetItem,
      DateTimeRange? dateRange,
      DatabaseController? databaseController}) {
    databaseController ??= AppController.shared.databaseController;

    datasourceContent ??= datasource?.parsed;
    var datasourceResolver = datasourceContent?.propertyResolver(
        context: context,
        lookup: CVULookupController(),
        db: databaseController);

    var queryConfig = inheritQuery?.clone() ?? DatabaseQueryConfig();
    queryConfig.dbController = databaseController;
    var queryGraphQL = datasourceResolver?.string("queryGraphQL") ?? "";
    if (queryGraphQL.isNotEmpty) {
      queryConfig.queryGraphQL =
          queryGraphQL.replaceAll("[", "{").replaceAll("]", "}");
    }
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
      ];
}
