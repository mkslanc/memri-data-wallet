// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ItemRecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemRecord _$ItemRecordFromJson(Map<String, dynamic> json) {
  return ItemRecord(
    rowId: json['rowId'] as int?,
    uid: json['uid'] as String?,
    type: json['type'] as String,
    dateCreated: json['dateCreated'] == null ? null : DateTime.parse(json['dateCreated'] as String),
    dateModified:
        json['dateModified'] == null ? null : DateTime.parse(json['dateModified'] as String),
    deleted: json['deleted'] as bool,
    syncState: _$enumDecode(_$SyncStateEnumMap, json['syncState']),
    syncHasPriority: json['syncHasPriority'] as bool,
  )..dateServerModified = json['dateServerModified'] == null
      ? null
      : DateTime.parse(json['dateServerModified'] as String);
}

Map<String, dynamic> _$ItemRecordToJson(ItemRecord instance) => <String, dynamic>{
      'rowId': instance.rowId,
      'uid': instance.uid,
      'type': instance.type,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'dateServerModified': instance.dateServerModified?.toIso8601String(),
      'dateModified': instance.dateModified.toIso8601String(),
      'deleted': instance.deleted,
      'syncState': _$SyncStateEnumMap[instance.syncState],
      'syncHasPriority': instance.syncHasPriority,
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

const _$SyncStateEnumMap = {
  SyncState.skip: 'skip',
  SyncState.create: 'create',
  SyncState.update: 'update',
  SyncState.noChanges: 'noChanges',
  SyncState.failed: 'failed',
};
