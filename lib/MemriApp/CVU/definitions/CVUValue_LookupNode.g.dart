// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CVUValue_LookupNode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVULookupNode _$CVULookupNodeFromJson(Map<String, dynamic> json) => CVULookupNode(
      name: json['name'] as String,
      type: CVULookupType.fromJson(json['type']),
      isArray: json['isArray'] as bool? ?? false,
    );

Map<String, dynamic> _$CVULookupNodeToJson(CVULookupNode instance) => <String, dynamic>{
      'name': instance.name,
      'isArray': instance.isArray,
      'type': instance.type,
    };

CVULookupTypeLookup _$CVULookupTypeLookupFromJson(Map<String, dynamic> json) => CVULookupTypeLookup(
      json['subExpression'] == null ? null : CVUExpressionNode.fromJson(json['subExpression']),
    );

Map<String, dynamic> _$CVULookupTypeLookupToJson(CVULookupTypeLookup instance) => <String, dynamic>{
      'subExpression': instance.subExpression,
    };

CVULookupTypeFunction _$CVULookupTypeFunctionFromJson(Map<String, dynamic> json) =>
    CVULookupTypeFunction(
      (json['args'] as List<dynamic>).map((e) => CVUExpressionNode.fromJson(e)).toList(),
    );

Map<String, dynamic> _$CVULookupTypeFunctionToJson(CVULookupTypeFunction instance) =>
    <String, dynamic>{
      'args': instance.args,
    };
