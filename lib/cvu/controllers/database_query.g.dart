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
      itemRowIDs: (json['itemRowIDs'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toSet(),
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 1000,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      includeImmediateEdgeSearch:
          json['includeImmediateEdgeSearch'] as bool? ?? true,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map((e) => QueryCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      edgeTargetsOperator: $enumDecodeNullable(
              _$ConditionOperatorEnumMap, json['edgeTargetsOperator']) ??
          ConditionOperator.and,
    )
      ..sortProperty = json['sortProperty'] as String?
      ..sortAscending = json['sortAscending'] as bool
      ..dateModifiedAfter = json['dateModifiedAfter'] == null
          ? null
          : DateTime.parse(json['dateModifiedAfter'] as String)
      ..dateModifiedBefore = json['dateModifiedBefore'] == null
          ? null
          : DateTime.parse(json['dateModifiedBefore'] as String)
      ..dateCreatedAfter = json['dateCreatedAfter'] == null
          ? null
          : DateTime.parse(json['dateCreatedAfter'] as String)
      ..dateCreatedBefore = json['dateCreatedBefore'] == null
          ? null
          : DateTime.parse(json['dateCreatedBefore'] as String)
      ..searchString = json['searchString'] as String?
      ..deleted = json['deleted'] as bool?
      ..edges =
          (json['edges'] as List<dynamic>).map((e) => e as String).toList()
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
      'dateCreatedBefore': instance.dateCreatedBefore?.toIso8601String(),
      'searchString': instance.searchString,
      'deleted': instance.deleted,
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'includeImmediateEdgeSearch': instance.includeImmediateEdgeSearch,
      'conditions': instance.conditions,
      'edges': instance.edges,
      'edgeTargetsOperator':
          _$ConditionOperatorEnumMap[instance.edgeTargetsOperator]!,
      'groupByProperties': instance.groupByProperties,
      'queryGraphQL': instance.queryGraphQL,
    };

const _$ConditionOperatorEnumMap = {
  ConditionOperator.and: 'and',
  ConditionOperator.or: 'or',
};

PropertyCondition _$PropertyConditionFromJson(Map<String, dynamic> json) =>
    PropertyCondition(
      json['name'] as String,
      json['value'],
      $enumDecode(_$ComparisonTypeEnumMap, json['comparisonType']),
    );

Map<String, dynamic> _$PropertyConditionToJson(PropertyCondition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'comparisonType': _$ComparisonTypeEnumMap[instance.comparisonType]!,
    };

const _$ComparisonTypeEnumMap = {
  ComparisonType.equals: 'equals',
  ComparisonType.greaterThan: 'greaterThan',
  ComparisonType.lessThan: 'lessThan',
  ComparisonType.like: 'like',
};

EdgeHasTargetCondition _$EdgeHasTargetConditionFromJson(
        Map<String, dynamic> json) =>
    EdgeHasTargetCondition(
      EdgeHasTarget.fromJson(json['value'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EdgeHasTargetConditionToJson(
        EdgeHasTargetCondition instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

EdgeHasSourceCondition _$EdgeHasSourceConditionFromJson(
        Map<String, dynamic> json) =>
    EdgeHasSourceCondition(
      EdgeHasSource.fromJson(json['value'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EdgeHasSourceConditionToJson(
        EdgeHasSourceCondition instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

EdgeHasTarget _$EdgeHasTargetFromJson(Map<String, dynamic> json) =>
    EdgeHasTarget(
      json['edgeName'] as String,
      (json['target'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$EdgeHasTargetToJson(EdgeHasTarget instance) =>
    <String, dynamic>{
      'edgeName': instance.edgeName,
      'target': instance.target,
    };

EdgeHasSource _$EdgeHasSourceFromJson(Map<String, dynamic> json) =>
    EdgeHasSource(
      json['edgeName'] as String,
      (json['source'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
    );

Map<String, dynamic> _$EdgeHasSourceToJson(EdgeHasSource instance) =>
    <String, dynamic>{
      'edgeName': instance.edgeName,
      'source': instance.source,
    };
