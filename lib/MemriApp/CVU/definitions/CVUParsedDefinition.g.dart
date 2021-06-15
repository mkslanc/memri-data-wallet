// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CVUParsedDefinition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUDefinitionContent _$CVUDefinitionContentFromJson(Map<String, dynamic> json) {
  return CVUDefinitionContent(
    definitions: (json['definitions'] as List<dynamic>?)
        ?.map((e) => CVUParsedDefinition.fromJson(e as Map<String, dynamic>))
        .toList(),
    children: (json['children'] as List<dynamic>?)
        ?.map((e) => CVUUINode.fromJson(e as Map<String, dynamic>))
        .toList(),
    properties: (json['properties'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, CVUValue.fromJson(e)),
    ),
  );
}

Map<String, dynamic> _$CVUDefinitionContentToJson(CVUDefinitionContent instance) =>
    <String, dynamic>{
      'definitions': instance.definitions,
      'children': instance.children,
      'properties': instance.properties,
    };

CVUParsedDefinition _$CVUParsedDefinitionFromJson(Map<String, dynamic> json) {
  return CVUParsedDefinition(
    type: _$enumDecode(_$CVUDefinitionTypeEnumMap, json['type']),
    domain: _$enumDecode(_$CVUDefinitionDomainEnumMap, json['domain']),
    selector: json['selector'] as String?,
    renderer: json['renderer'] as String?,
    name: json['name'] as String?,
    parsed: json['parsed'] == null
        ? null
        : CVUDefinitionContent.fromJson(json['parsed'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CVUParsedDefinitionToJson(CVUParsedDefinition instance) => <String, dynamic>{
      'type': _$CVUDefinitionTypeEnumMap[instance.type],
      'domain': _$CVUDefinitionDomainEnumMap[instance.domain],
      'selector': instance.selector,
      'name': instance.name,
      'renderer': instance.renderer,
      'parsed': instance.parsed,
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

const _$CVUDefinitionTypeEnumMap = {
  CVUDefinitionType.view: 'view',
  CVUDefinitionType.views: 'views',
  CVUDefinitionType.uiNode: 'uiNode',
  CVUDefinitionType.sessions: 'sessions',
  CVUDefinitionType.renderer: 'renderer',
  CVUDefinitionType.datasource: 'datasource',
  CVUDefinitionType.language: 'language',
  CVUDefinitionType.other: 'other',
};

const _$CVUDefinitionDomainEnumMap = {
  CVUDefinitionDomain.user: 'user',
};
