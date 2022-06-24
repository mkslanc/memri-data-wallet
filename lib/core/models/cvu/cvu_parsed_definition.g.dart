// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_parsed_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUDefinitionContent _$CVUDefinitionContentFromJson(
        Map<String, dynamic> json) =>
    CVUDefinitionContent(
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

Map<String, dynamic> _$CVUDefinitionContentToJson(
        CVUDefinitionContent instance) =>
    <String, dynamic>{
      'definitions': instance.definitions,
      'children': instance.children,
      'properties': instance.properties,
    };

CVUParsedDefinition _$CVUParsedDefinitionFromJson(Map<String, dynamic> json) =>
    CVUParsedDefinition(
      type: $enumDecodeNullable(_$CVUDefinitionTypeEnumMap, json['type']) ??
          CVUDefinitionType.other,
      domain:
          $enumDecodeNullable(_$CVUDefinitionDomainEnumMap, json['domain']) ??
              CVUDefinitionDomain.user,
      selector: json['selector'] as String?,
      renderer: json['renderer'] as String?,
      name: json['name'] as String?,
      parsed: json['parsed'] == null
          ? null
          : CVUDefinitionContent.fromJson(
              json['parsed'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUParsedDefinitionToJson(
        CVUParsedDefinition instance) =>
    <String, dynamic>{
      'type': _$CVUDefinitionTypeEnumMap[instance.type],
      'domain': _$CVUDefinitionDomainEnumMap[instance.domain],
      'selector': instance.selector,
      'name': instance.name,
      'renderer': instance.renderer,
      'parsed': instance.parsed,
    };

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
