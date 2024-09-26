// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_ui_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUUINode _$CVUUINodeFromJson(Map<String, dynamic> json) => CVUUINode(
      type: $enumDecode(_$CVUUIElementFamilyEnumMap, json['type']),
      children: (json['children'] as List<dynamic>)
          .map((e) => CVUUINode.fromJson(e as Map<String, dynamic>))
          .toList(),
      properties: (json['properties'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CVUValue.fromJson(e)),
      ),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    )
      ..shouldExpandWidth = json['shouldExpandWidth'] as bool
      ..shouldExpandHeight = json['shouldExpandHeight'] as bool
      ..id = json['id'] as String;

Map<String, dynamic> _$CVUUINodeToJson(CVUUINode instance) => <String, dynamic>{
      'type': _$CVUUIElementFamilyEnumMap[instance.type]!,
      'children': instance.children,
      'properties': instance.properties,
      'tokenLocation': instance.tokenLocation,
      'shouldExpandWidth': instance.shouldExpandWidth,
      'shouldExpandHeight': instance.shouldExpandHeight,
      'id': instance.id,
    };

const _$CVUUIElementFamilyEnumMap = {
  CVUUIElementFamily.ForEach: 'ForEach',
  CVUUIElementFamily.VStack: 'VStack',
  CVUUIElementFamily.HStack: 'HStack',
  CVUUIElementFamily.ZStack: 'ZStack',
  CVUUIElementFamily.FlowStack: 'FlowStack',
  CVUUIElementFamily.Text: 'Text',
  CVUUIElementFamily.SmartText: 'SmartText',
  CVUUIElementFamily.Image: 'Image',
  CVUUIElementFamily.Picker: 'Picker',
  CVUUIElementFamily.MemriButton: 'MemriButton',
  CVUUIElementFamily.MessageComposer: 'MessageComposer',
  CVUUIElementFamily.Button: 'Button',
  CVUUIElementFamily.ActionButton: 'ActionButton',
  CVUUIElementFamily.Empty: 'Empty',
  CVUUIElementFamily.Spacer: 'Spacer',
  CVUUIElementFamily.Divider: 'Divider',
  CVUUIElementFamily.Circle: 'Circle',
  CVUUIElementFamily.Rectangle: 'Rectangle',
  CVUUIElementFamily.EditorSection: 'EditorSection',
  CVUUIElementFamily.SubView: 'SubView',
  CVUUIElementFamily.HTMLView: 'HTMLView',
  CVUUIElementFamily.TimelineItem: 'TimelineItem',
  CVUUIElementFamily.FileThumbnail: 'FileThumbnail',
  CVUUIElementFamily.Null: 'Null',
  CVUUIElementFamily.Grid: 'Grid',
  CVUUIElementFamily.DropZone: 'DropZone',
  CVUUIElementFamily.Wrap: 'Wrap',
  CVUUIElementFamily.Dropdown: 'Dropdown',
  CVUUIElementFamily.RichText: 'RichText',
  CVUUIElementFamily.LoadingIndicator: 'LoadingIndicator',
  CVUUIElementFamily.Map: 'Map',
  CVUUIElementFamily.Toggle: 'Toggle',
};
