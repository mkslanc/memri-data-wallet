// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CVUUINode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUUINode _$CVUUINodeFromJson(Map<String, dynamic> json) {
  return CVUUINode(
    type: _$enumDecode(_$CVUUIElementFamilyEnumMap, json['type']),
    children: (json['children'] as List<dynamic>)
        .map((e) => CVUUINode.fromJson(e as Map<String, dynamic>))
        .toList(),
    properties: (json['properties'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, CVUValue.fromJson(e)),
    ),
  )
    ..shouldExpandWidth = json['shouldExpandWidth'] as bool
    ..shouldExpandHeight = json['shouldExpandHeight'] as bool
    ..id = json['id'] as String;
}

Map<String, dynamic> _$CVUUINodeToJson(CVUUINode instance) => <String, dynamic>{
      'type': _$CVUUIElementFamilyEnumMap[instance.type],
      'children': instance.children,
      'properties': instance.properties,
      'shouldExpandWidth': instance.shouldExpandWidth,
      'shouldExpandHeight': instance.shouldExpandHeight,
      'id': instance.id,
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

const _$CVUUIElementFamilyEnumMap = {
  CVUUIElementFamily.ForEach: 'ForEach',
  CVUUIElementFamily.VStack: 'VStack',
  CVUUIElementFamily.HStack: 'HStack',
  CVUUIElementFamily.ZStack: 'ZStack',
  CVUUIElementFamily.FlowStack: 'FlowStack',
  CVUUIElementFamily.Text: 'Text',
  CVUUIElementFamily.SmartText: 'SmartText',
  CVUUIElementFamily.Textfield: 'Textfield',
  CVUUIElementFamily.Image: 'Image',
  CVUUIElementFamily.Toggle: 'Toggle',
  CVUUIElementFamily.Picker: 'Picker',
  CVUUIElementFamily.MemriButton: 'MemriButton',
  CVUUIElementFamily.Button: 'Button',
  CVUUIElementFamily.ActionButton: 'ActionButton',
  CVUUIElementFamily.Map: 'Map',
  CVUUIElementFamily.Empty: 'Empty',
  CVUUIElementFamily.Spacer: 'Spacer',
  CVUUIElementFamily.Divider: 'Divider',
  CVUUIElementFamily.HorizontalLine: 'HorizontalLine',
  CVUUIElementFamily.Circle: 'Circle',
  CVUUIElementFamily.Rectangle: 'Rectangle',
  CVUUIElementFamily.EditorSection: 'EditorSection',
  CVUUIElementFamily.EditorRow: 'EditorRow',
  CVUUIElementFamily.SubView: 'SubView',
  CVUUIElementFamily.HTMLView: 'HTMLView',
  CVUUIElementFamily.TimelineItem: 'TimelineItem',
  CVUUIElementFamily.FileThumbnail: 'FileThumbnail',
  CVUUIElementFamily.Null: 'Null',
  CVUUIElementFamily.Grid: 'Grid',
};
