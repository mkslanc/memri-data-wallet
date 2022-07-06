// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatabaseQueryConfig _$DatabaseQueryConfigFromJson(Map<String, dynamic> json) =>
    DatabaseQueryConfig(
      itemTypes: (json['itemTypes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      itemRowIDs:
          (json['itemRowIDs'] as List<dynamic>?)?.map((e) => e as int).toSet(),
      sortProperty: json['sortProperty'] as String? ?? "dateModified",
      sortAscending: json['sortAscending'] as bool? ?? false,
      dateModifiedAfter: json['dateModifiedAfter'] == null
          ? null
          : DateTime.parse(json['dateModifiedAfter'] as String),
      dateModifiedBefore: json['dateModifiedBefore'] == null
          ? null
          : DateTime.parse(json['dateModifiedBefore'] as String),
      dateCreatedAfter: json['dateCreatedAfter'] == null
          ? null
          : DateTime.parse(json['dateCreatedAfter'] as String),
      dateCreatedBefore: json['dateCreatedBefore'] == null
          ? null
          : DateTime.parse(json['dateCreatedBefore'] as String),
      pageSize: json['pageSize'] as int? ?? 1000,
      currentPage: json['currentPage'] as int? ?? 0,
      searchString: json['searchString'] as String?,
      includeImmediateEdgeSearch:
          json['includeImmediateEdgeSearch'] as bool? ?? true,
      edgeTargetsOperator: $enumDecodeNullable(
              _$ConditionOperatorEnumMap, json['edgeTargetsOperator']) ??
          ConditionOperator.and,
    )
      ..deleted = json['deleted'] as bool?
      ..groupByProperties = (json['groupByProperties'] as List<dynamic>)
          .map((e) => e as String)
          .toList()
      ..queryGraphQL = json['queryGraphQL'] as String?;

Map<String, dynamic> _$DatabaseQueryConfigToJson(
        DatabaseQueryConfig instance) =>
    <String, dynamic>{
      'itemTypes': instance.itemTypes,
      'itemRowIDs': instance.itemRowIDs.toList(),
      'sortProperty': instance.sortProperty,
      'sortAscending': instance.sortAscending,
      'dateModifiedAfter': instance.dateModifiedAfter?.toIso8601String(),
      'dateModifiedBefore': instance.dateModifiedBefore?.toIso8601String(),
      'dateCreatedAfter': instance.dateCreatedAfter?.toIso8601String(),
      'deleted': instance.deleted,
      'dateCreatedBefore': instance.dateCreatedBefore?.toIso8601String(),
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'searchString': instance.searchString,
      'includeImmediateEdgeSearch': instance.includeImmediateEdgeSearch,
      'edgeTargetsOperator':
          _$ConditionOperatorEnumMap[instance.edgeTargetsOperator],
      'groupByProperties': instance.groupByProperties,
      'queryGraphQL': instance.queryGraphQL,
    };

const _$ConditionOperatorEnumMap = {
  ConditionOperator.and: 'and',
  ConditionOperator.or: 'or',
};
