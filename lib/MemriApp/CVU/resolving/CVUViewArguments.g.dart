// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CVUViewArguments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUViewArguments _$CVUViewArgumentsFromJson(Map<String, dynamic> json) {
  return CVUViewArguments(
    args: (json['args'] as Map<String, dynamic>?)?.map(
      (k, e) => MapEntry(k, CVUValue.fromJson(e)),
    ),
    argumentItem: json['argumentItem'] == null
        ? null
        : ItemRecord.fromJson(json['argumentItem'] as Map<String, dynamic>),
    parentArguments: json['parentArguments'] == null
        ? null
        : CVUViewArguments.fromJson(json['parentArguments'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CVUViewArgumentsToJson(CVUViewArguments instance) => <String, dynamic>{
      'args': instance.args,
      'argumentItem': instance.argumentItem,
      'parentArguments': instance.parentArguments,
    };
