// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_view_arguments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUViewArguments _$CVUViewArgumentsFromJson(Map<String, dynamic> json) =>
    CVUViewArguments(
      args: (json['args'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, CVUValue.fromJson(e)),
      ),
      argumentItem: json['argumentItem'] == null
          ? null
          : Item.fromJson(json['argumentItem'] as Map<String, dynamic>),
      parentArguments: json['parentArguments'] == null
          ? null
          : CVUViewArguments.fromJson(
              json['parentArguments'] as Map<String, dynamic>),
      argumentItems: (json['argumentItems'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CVUViewArgumentsToJson(CVUViewArguments instance) =>
    <String, dynamic>{
      'args': instance.args,
      'argumentItem': instance.argumentItem,
      'argumentItems': instance.argumentItems,
      'parentArguments': instance.parentArguments,
    };
