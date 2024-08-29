// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_lexer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUTokenLocation _$CVUTokenLocationFromJson(Map<String, dynamic> json) =>
    CVUTokenLocation(
      (json['ln'] as num).toInt(),
      (json['ch'] as num).toInt(),
    );

Map<String, dynamic> _$CVUTokenLocationToJson(CVUTokenLocation instance) =>
    <String, dynamic>{
      'ln': instance.ln,
      'ch': instance.ch,
    };
