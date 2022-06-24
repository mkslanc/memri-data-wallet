// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUValueExpression _$CVUValueExpressionFromJson(Map<String, dynamic> json) =>
    CVUValueExpression(
      CVUExpressionNode.fromJson(json['value']),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueExpressionToJson(CVUValueExpression instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };

CVUValueConstant _$CVUValueConstantFromJson(Map<String, dynamic> json) =>
    CVUValueConstant(
      CVUConstant.fromJson(json['value']),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueConstantToJson(CVUValueConstant instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };

CVUValueItem _$CVUValueItemFromJson(Map<String, dynamic> json) => CVUValueItem(
      json['value'] as int,
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueItemToJson(CVUValueItem instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };

CVUValueArray _$CVUValueArrayFromJson(Map<String, dynamic> json) =>
    CVUValueArray(
      (json['value'] as List<dynamic>)
          .map((e) => CVUValue.fromJson(e))
          .toList(),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueArrayToJson(CVUValueArray instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };

CVUValueDictionary _$CVUValueDictionaryFromJson(Map<String, dynamic> json) =>
    CVUValueDictionary(
      (json['value'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, CVUValue.fromJson(e)),
      ),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueDictionaryToJson(CVUValueDictionary instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };

CVUValueSubdefinition _$CVUValueSubdefinitionFromJson(
        Map<String, dynamic> json) =>
    CVUValueSubdefinition(
      CVUDefinitionContent.fromJson(json['value'] as Map<String, dynamic>),
      tokenLocation: json['tokenLocation'] == null
          ? null
          : CVUTokenLocation.fromJson(
              json['tokenLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CVUValueSubdefinitionToJson(
        CVUValueSubdefinition instance) =>
    <String, dynamic>{
      'tokenLocation': instance.tokenLocation,
      'value': instance.value,
    };
