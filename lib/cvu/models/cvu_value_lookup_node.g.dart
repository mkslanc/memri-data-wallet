// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_value_lookup_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVULookupNode _$CVULookupNodeFromJson(Map<String, dynamic> json) =>
    CVULookupNode(
      name: json['name'] as String,
      type: CVULookupType.fromJson(json['type']),
      isArray: json['isArray'] as bool? ?? false,
    );

Map<String, dynamic> _$CVULookupNodeToJson(CVULookupNode instance) =>
    <String, dynamic>{
      'name': instance.name,
      'isArray': instance.isArray,
      'type': instance.type,
    };

CVULookupTypeLookup _$CVULookupTypeLookupFromJson(Map<String, dynamic> json) =>
    CVULookupTypeLookup(
      (json['subexpressions'] as List<dynamic>?)
          ?.map(CVUExpressionNode.fromJson)
          .toList(),
    );

Map<String, dynamic> _$CVULookupTypeLookupToJson(
        CVULookupTypeLookup instance) =>
    <String, dynamic>{
      'subexpressions': instance.subexpressions,
    };

CVULookupTypeFunction _$CVULookupTypeFunctionFromJson(
        Map<String, dynamic> json) =>
    CVULookupTypeFunction(
      (json['args'] as List<dynamic>).map(CVUExpressionNode.fromJson).toList(),
    );

Map<String, dynamic> _$CVULookupTypeFunctionToJson(
        CVULookupTypeFunction instance) =>
    <String, dynamic>{
      'args': instance.args,
    };
