// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ViewContext.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewContext _$ViewContextFromJson(Map<String, dynamic> json) {
  return ViewContext(
    rendererName: json['rendererName'] as String,
    query: DatabaseQueryConfig.fromJson(json['query'] as Map<String, dynamic>),
    viewName: json['viewName'] as String?,
    viewDefinition: json['viewDefinition'] == null
        ? null
        : CVUDefinitionContent.fromJson(json['viewDefinition'] as Map<String, dynamic>),
    viewArguments: json['viewArguments'] == null
        ? null
        : CVUViewArguments.fromJson(json['viewArguments'] as Map<String, dynamic>),
    focusedItem: json['focusedItem'] == null
        ? null
        : ItemRecord.fromJson(json['focusedItem'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ViewContextToJson(ViewContext instance) => <String, dynamic>{
      'viewName': instance.viewName,
      'rendererName': instance.rendererName,
      'viewDefinition': instance.viewDefinition,
      'query': instance.query,
      'viewArguments': instance.viewArguments,
      'focusedItem': instance.focusedItem,
    };

ViewContextHolder _$ViewContextHolderFromJson(Map<String, dynamic> json) {
  return ViewContextHolder(
    ViewContext.fromJson(json['config'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ViewContextHolderToJson(ViewContextHolder instance) => <String, dynamic>{
      'config': instance.config,
    };
