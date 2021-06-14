// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DatabaseQuery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatabaseQueryConfig _$DatabaseQueryConfigFromJson(Map<String, dynamic> json) {
  return DatabaseQueryConfig(
    itemTypes: (json['itemTypes'] as List<dynamic>?)?.map((e) => e as String).toList(),
    itemRowIDs: (json['itemRowIDs'] as List<dynamic>?)?.map((e) => e as int).toSet(),
    sortProperty: json['sortProperty'] as String?,
    sortAscending: json['sortAscending'] as bool,
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
    pageSize: json['pageSize'] as int,
    currentPage: json['currentPage'] as int,
    searchString: json['searchString'] as String?,
    includeImmediateEdgeSearch: json['includeImmediateEdgeSearch'] as bool,
    conditions: (json['conditions'] as List<dynamic>?)
        ?.map((e) => DatabaseQueryCondition.fromJson(e))
        .toList(),
    edgeTargetsOperator: _$enumDecode(_$ConditionOperatorEnumMap, json['edgeTargetsOperator']),
  );
}

Map<String, dynamic> _$DatabaseQueryConfigToJson(DatabaseQueryConfig instance) => <String, dynamic>{
      'itemTypes': instance.itemTypes,
      'itemRowIDs': instance.itemRowIDs.toList(),
      'sortProperty': instance.sortProperty,
      'sortAscending': instance.sortAscending,
      'dateModifiedAfter': instance.dateModifiedAfter?.toIso8601String(),
      'dateModifiedBefore': instance.dateModifiedBefore?.toIso8601String(),
      'dateCreatedAfter': instance.dateCreatedAfter?.toIso8601String(),
      'dateCreatedBefore': instance.dateCreatedBefore?.toIso8601String(),
      'pageSize': instance.pageSize,
      'currentPage': instance.currentPage,
      'searchString': instance.searchString,
      'includeImmediateEdgeSearch': instance.includeImmediateEdgeSearch,
      'conditions': instance.conditions,
      'edgeTargetsOperator': _$ConditionOperatorEnumMap[instance.edgeTargetsOperator],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$ConditionOperatorEnumMap = {
  ConditionOperator.and: 'and',
  ConditionOperator.or: 'or',
};

DatabaseQueryConditionPropertyEquals _$DatabaseQueryConditionPropertyEqualsFromJson(
    Map<String, dynamic> json) {
  return DatabaseQueryConditionPropertyEquals(
    PropertyEquals.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DatabaseQueryConditionPropertyEqualsToJson(
        DatabaseQueryConditionPropertyEquals instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

DatabaseQueryConditionEdgeHasTarget _$DatabaseQueryConditionEdgeHasTargetFromJson(
    Map<String, dynamic> json) {
  return DatabaseQueryConditionEdgeHasTarget(
    EdgeHasTarget.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DatabaseQueryConditionEdgeHasTargetToJson(
        DatabaseQueryConditionEdgeHasTarget instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

DatabaseQueryConditionEdgeHasSource _$DatabaseQueryConditionEdgeHasSourceFromJson(
    Map<String, dynamic> json) {
  return DatabaseQueryConditionEdgeHasSource(
    EdgeHasSource.fromJson(json['value'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DatabaseQueryConditionEdgeHasSourceToJson(
        DatabaseQueryConditionEdgeHasSource instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

PropertyEquals _$PropertyEqualsFromJson(Map<String, dynamic> json) {
  return PropertyEquals(
    json['name'] as String,
    json['value'],
  );
}

Map<String, dynamic> _$PropertyEqualsToJson(PropertyEquals instance) => <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
    };

EdgeHasTarget _$EdgeHasTargetFromJson(Map<String, dynamic> json) {
  return EdgeHasTarget(
    json['edgeName'] as String,
    json['target'] as int,
  );
}

Map<String, dynamic> _$EdgeHasTargetToJson(EdgeHasTarget instance) => <String, dynamic>{
      'edgeName': instance.edgeName,
      'target': instance.target,
    };

EdgeHasSource _$EdgeHasSourceFromJson(Map<String, dynamic> json) {
  return EdgeHasSource(
    json['edgeName'] as String,
    json['source'] as int,
  );
}

Map<String, dynamic> _$EdgeHasSourceToJson(EdgeHasSource instance) => <String, dynamic>{
      'edgeName': instance.edgeName,
      'source': instance.source,
    };
