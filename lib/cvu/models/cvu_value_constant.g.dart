// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_value_constant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUConstantArgument _$CVUConstantArgumentFromJson(Map<String, dynamic> json) =>
    CVUConstantArgument(
      json['value'] as String,
    );

CVUConstantNumber _$CVUConstantNumberFromJson(Map<String, dynamic> json) =>
    CVUConstantNumber(
      (json['value'] as num).toDouble(),
    );

CVUConstantInt _$CVUConstantIntFromJson(Map<String, dynamic> json) =>
    CVUConstantInt(
      (json['value'] as num).toInt(),
    );

CVUConstantString _$CVUConstantStringFromJson(Map<String, dynamic> json) =>
    CVUConstantString(
      json['value'] as String,
      isSingleQuote: json['isSingleQuote'] as bool? ?? false,
      isMultiline: json['isMultiline'] as bool? ?? false,
    );

CVUConstantBool _$CVUConstantBoolFromJson(Map<String, dynamic> json) =>
    CVUConstantBool(
      json['value'] as bool,
    );

CVUConstantColorHex _$CVUConstantColorHexFromJson(Map<String, dynamic> json) =>
    CVUConstantColorHex(
      json['value'] as String,
    );
