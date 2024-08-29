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
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 1000,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      searchString: json['searchString'] as String?,
      includeImmediateEdgeSearch:
          json['includeImmediateEdgeSearch'] as bool? ?? true,
      conditions: (json['conditions'] as List<dynamic>?)
          ?.map(DatabaseQueryCondition.fromJson)
          .toList(),
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
      'conditions': instance.conditions,
      'edgeTargetsOperator':
          _$ConditionOperatorEnumMap[instance.edgeTargetsOperator]!,
      'groupByProperties': instance.groupByProperties,
      'queryGraphQL': instance.queryGraphQL,
    };

const _$ConditionOperatorEnumMap = {
  ConditionOperator.and: 'and',
  ConditionOperator.or: 'or',
};

DatabaseQueryConditionPropertyEquals
    _$DatabaseQueryConditionPropertyEqualsFromJson(Map<String, dynamic> json) =>
        DatabaseQueryConditionPropertyEquals(
          PropertyEquals.fromJson(json['value'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$DatabaseQueryConditionPropertyEqualsToJson(
        DatabaseQueryConditionPropertyEquals instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

DatabaseQueryConditionEdgeHasTarget
    _$DatabaseQueryConditionEdgeHasTargetFromJson(Map<String, dynamic> json) =>
        DatabaseQueryConditionEdgeHasTarget(
          EdgeHasTarget.fromJson(json['value'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$DatabaseQueryConditionEdgeHasTargetToJson(
        DatabaseQueryConditionEdgeHasTarget instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

DatabaseQueryConditionEdgeHasSource
    _$DatabaseQueryConditionEdgeHasSourceFromJson(Map<String, dynamic> json) =>
        DatabaseQueryConditionEdgeHasSource(
          EdgeHasSource.fromJson(json['value'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$DatabaseQueryConditionEdgeHasSourceToJson(
        DatabaseQueryConditionEdgeHasSource instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

PropertyEquals _$PropertyEqualsFromJson(Map<String, dynamic> json) =>
    PropertyEquals(
      json['name'] as String,
      json['value'],
    );

Map<String, dynamic> _$PropertyEqualsToJson(PropertyEquals instance) =>
    <String, dynamic>{
      'name': instance.name,
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
