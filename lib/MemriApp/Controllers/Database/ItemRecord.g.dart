// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ItemRecord.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemRecord _$ItemRecordFromJson(Map<String, dynamic> json) => ItemRecord(
      rowId: json['rowId'] as int?,
      uid: json['uid'] as String?,
      type: json['type'] as String,
      dateCreated:
          json['dateCreated'] == null ? null : DateTime.parse(json['dateCreated'] as String),
      dateModified:
          json['dateModified'] == null ? null : DateTime.parse(json['dateModified'] as String),
      deleted: json['deleted'] as bool? ?? false,
      syncState: $enumDecodeNullable(_$SyncStateEnumMap, json['syncState']) ?? SyncState.create,
      fileState: $enumDecodeNullable(_$FileStateEnumMap, json['fileState']) ?? FileState.skip,
      syncHasPriority: json['syncHasPriority'] as bool? ?? false,
    )..dateServerModified = json['dateServerModified'] == null
        ? null
        : DateTime.parse(json['dateServerModified'] as String);

Map<String, dynamic> _$ItemRecordToJson(ItemRecord instance) => <String, dynamic>{
      'rowId': instance.rowId,
      'uid': instance.uid,
      'type': instance.type,
      'dateCreated': instance.dateCreated.toIso8601String(),
      'dateServerModified': instance.dateServerModified?.toIso8601String(),
      'dateModified': instance.dateModified.toIso8601String(),
      'deleted': instance.deleted,
      'syncState': _$SyncStateEnumMap[instance.syncState],
      'fileState': _$FileStateEnumMap[instance.fileState],
      'syncHasPriority': instance.syncHasPriority,
    };

const _$SyncStateEnumMap = {
  SyncState.skip: 'skip',
  SyncState.create: 'create',
  SyncState.update: 'update',
  SyncState.noChanges: 'noChanges',
  SyncState.failed: 'failed',
};

const _$FileStateEnumMap = {
  FileState.skip: 'skip',
  FileState.needsUpload: 'needsUpload',
  FileState.needsDownload: 'needsDownload',
  FileState.noChanges: 'noChanges',
};
