//  Created by T Brennan on 1/12/20.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod/pod_requests.dart';
import 'package:memri/core/services/database/shared.dart';
import 'package:memri/models/database/database.dart';
import 'package:memri/models/database/item_edge_record.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/sync_config.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:moor/moor.dart';

enum SyncControllerState {
  idle,
  started,
  uploadedSchemaProperties,
  uploadedSchemaEdges,
  uploadedItems,
  uploadedEdges,
  downloadedItems,
  uploadedFiles,
  downloadedFiles,
  done,
  failed
}

class SyncController {
  bool syncing = false;
  String? lastError;
  Function(String?)? completion;
  final DatabaseController databaseController;
  SyncControllerState state;
  PodConnectionDetails? currentConnection;
  static String? documentsDirectory;
  static String? lastRootKey;
  StreamSubscription? runSyncStream;

  SyncController(this.databaseController) : state = SyncControllerState.idle;

  setState(SyncControllerState value) async {
    state = value;
    switch (value) {
      case SyncControllerState.started:
        syncing = true;
        try {
          await downloadItems();
        } catch (e) {
          await finishSync();
          throw (e);
        }
        break;
      case SyncControllerState.downloadedItems:
        try {
          await uploadSchemaProperties();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.uploadedSchemaProperties:
        try {
          await uploadSchemaEdges();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.uploadedSchemaEdges:
        try {
          await uploadItems();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.uploadedItems:
        try {
          await uploadEdges();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.uploadedEdges:
        try {
          await uploadFiles();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.uploadedFiles:
        try {
          await downloadFiles();
          break;
        } catch (e) {
          await finishSync();
          throw (e);
        }
      case SyncControllerState.downloadedFiles:
        await finishSync();
        break;
      case SyncControllerState.failed:
        await finishSync();
        break;
      default:
        break;
    }
  }

  Future<bool> podIsExist(PodConnectionDetails config) async {
    try {
      var request = PodStandardRequest.getVersion();
      await request.execute(config);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> runSync(SyncConfig config) async {
    var dbController = DatabaseController();
    dbController.schema = config.schema;
    if (kIsWeb) {
      dbController.databasePool = Database.connect(connectToWorker());
    } else {
      if (config is IsolateSyncConfig) {
        SyncController.documentsDirectory = config.documentsDirectory;
        SyncController.lastRootKey = config.rootKey;
        dbController.driftIsolate = config.isolate;
        dbController.databasePool = Database.connect(await config.isolate.connect());
      }
    }
    final syncController = SyncController(dbController);
    runSyncStream = Stream.periodic(const Duration(seconds: AppSettings.syncControllerIntervalSecs))
        .listen((_) => syncController.sync(connectionConfig: config.connection));
  }

  sync({PodConnectionDetails? connectionConfig, Function(String?)? completion}) async {
    currentConnection = connectionConfig ?? await AppController.shared.podConnectionConfig;
    if (currentConnection == null) {
      return;
    }

    if (syncing) {
      return;
    }

    if (!await podIsExist(currentConnection!).timeout(
      Duration(seconds: 3),
      onTimeout: () async {
        try {
          await setState(SyncControllerState.failed);
          throw Exception("Pod doesn't respond");
        } catch (e) {
          AppLogger.err(e);
          return false;
        }
      },
    )) {
      return;
    }

    this.completion = completion;
    await setState(SyncControllerState.started);
  }

  uploadFiles() async {
    var fileItemRecordToUpload = await ItemRecord.fileItemRecordToUpload(databaseController);
    if (fileItemRecordToUpload == null) {
      await setState(SyncControllerState.uploadedFiles);
      return;
    }

    var item = fileItemRecordToUpload["item"];
    var fileName = fileItemRecordToUpload["fileName"];

    await uploadFile(fileName, (data, error) async {
      if (error != null) {
        lastError = error;
        await setState(SyncControllerState.failed);
        return;
      }

      await ItemRecord.didUploadFileForItem(item, databaseController);
      await uploadFiles();
    });
  }

  downloadFiles() async {
    var fileItemRecordToDownload = await ItemRecord.fileItemRecordToDownload(databaseController);
    if (fileItemRecordToDownload == null) {
      await setState(SyncControllerState.downloadedFiles);
      return;
    }
    var item = fileItemRecordToDownload["item"];
    var sha256 = fileItemRecordToDownload["sha256"];
    var fileName = fileItemRecordToDownload["fileName"];

    AppLogger.info("Downloading File: $fileName");

    await downloadFile(sha256, fileName, (error) async {
      if (error != null) {
        lastError = error;
        await setState(SyncControllerState.failed);
        return;
      }

      await ItemRecord.didDownloadFileForItem(item, databaseController);
      await downloadFiles();
    });
  }

  finishSync() async {
    await setState(SyncControllerState.done);
    syncing = false;
    if (completion != null) await completion!(lastError);
    await setState(SyncControllerState.idle);
    completion = null;
  }

  uploadSchemaProperties() async {
    var syncPayload = await makeSyncSchemaPropertiesData();
    if (syncPayload.createItems.isEmpty &&
        syncPayload.updateItems.isEmpty &&
        syncPayload.deleteItems.isEmpty) {
      await setState(SyncControllerState.uploadedSchemaProperties);
      return;
    }
    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          await databaseController.databasePool.transaction(() async {
            await ItemRecord.didSyncItems(syncPayload, error, databaseController);
            if (error != null) {
              lastError = error;
              await setState(SyncControllerState.failed);
              return;
            }
          });

          await setState(SyncControllerState.uploadedSchemaProperties);
        }));
  }

  uploadSchemaEdges() async {
    var syncPayload = await makeSyncSchemaEdgesData();
    if (syncPayload.createItems.isEmpty &&
        syncPayload.updateItems.isEmpty &&
        syncPayload.deleteItems.isEmpty) {
      await setState(SyncControllerState.uploadedSchemaEdges);
      return;
    }
    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          await databaseController.databasePool.transaction(() async {
            await ItemRecord.didSyncItems(syncPayload, error, databaseController);
          });
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }

          await setState(SyncControllerState.uploadedSchemaEdges);
        }));
  }

  uploadItems() async {
    var syncPayload = await makeSyncUploadData();

    if (syncPayload.createItems.isEmpty &&
        syncPayload.updateItems.isEmpty &&
        syncPayload.deleteItems.isEmpty &&
        syncPayload.createEdges.isEmpty) {
      await setState(SyncControllerState.uploadedItems);
      return;
    }

    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }
          await databaseController.databasePool.transaction(() async {
            await ItemRecord.didSyncItems(syncPayload, error, databaseController);
            await ItemEdgeRecord.didSyncEdges(syncPayload, error, databaseController);
          });

          // Recurse until we run out of items to sync
          await uploadItems();
        }));
  }

  uploadEdges([int maxItems = 100]) async {
    var syncPayload = await makeSyncEdgesData(maxItems);
    if (syncPayload.createEdges.isEmpty) {
      await setState(SyncControllerState.uploadedEdges);
      return;
    }

    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }
          await databaseController.databasePool.transaction(() async {
            await ItemEdgeRecord.didSyncEdges(syncPayload, error, databaseController);
          });

          // Recurse until we run out of items to sync
          await uploadEdges(maxItems);
        }));
  }

  downloadItems() async {
    var lastItem = await ItemRecord.lastSyncedItem(databaseController.databasePool);
    var dateServerModifiedTimestamp = lastItem != null && lastItem.dateServerModified != null
        ? lastItem.dateServerModified!.millisecondsSinceEpoch + 1
        : DateTime.fromMillisecondsSinceEpoch(0).millisecondsSinceEpoch;

    await searchAction(
        dateServerModifiedTimestamp: dateServerModifiedTimestamp,
        completion: (data, error) async {
          if (error != null || data == null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }
          var responseObjects = jsonDecode(data);
          if (responseObjects is! List) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }
          if (responseObjects.isNotEmpty)
            await ItemRecord.fromSyncItemDictList(
                responseObjects: responseObjects,
                dbController: databaseController,
                documentsDirectory: documentsDirectory);

          await setState(SyncControllerState.downloadedItems);
        });
  }

  Future<PodPayloadBulkAction> makeSyncSchemaPropertiesData() async {
    var schemaPropertyItems = (await databaseController.databasePool.itemRecordsCustomSelect(
            "type = ? AND syncState = ?",
            [Variable("ItemPropertySchema"), Variable(SyncState.create.inString)]))
        .map((item) => ItemRecord.fromItem(item));
    var syncPropertyItems = (await Future.wait(
            schemaPropertyItems.map((e) async => await e.schemaPropertyDict(databaseController))))
        .whereType<Map<String, dynamic>>()
        .toList();

    var bulkAction = PodPayloadBulkAction(
        createItems: syncPropertyItems, updateItems: [], deleteItems: [], createEdges: []);
    return bulkAction;
  }

  Future<PodPayloadBulkAction> makeSyncSchemaEdgesData() async {
    var schemaEdgeItems = (await databaseController.databasePool.itemRecordsCustomSelect(
            "type = ? AND syncState = ?",
            [Variable("ItemEdgeSchema"), Variable(SyncState.create.inString)]))
        .map((item) => ItemRecord.fromItem(item));
    var syncEdgeItems = (await Future.wait(
            schemaEdgeItems.map((e) async => await e.schemaEdgeDict(databaseController))))
        .whereType<Map<String, dynamic>>()
        .toList();

    var bulkAction = PodPayloadBulkAction(
        createItems: syncEdgeItems, updateItems: [], deleteItems: [], createEdges: []);
    return bulkAction;
  }

  Future<PodPayloadBulkAction> makeSyncUploadData([int maxItems = 100]) async {
    var createItems = await ItemRecord.syncItemsWithState(
        state: SyncState.create, maxItems: maxItems, dbController: databaseController);
    var updatedItems = await ItemRecord.syncItemsWithState(
        state: SyncState.update, maxItems: maxItems, dbController: databaseController);

    var updateItems = <Map<String, dynamic>>[];

    updatedItems.forEach((itemRecord) {
      if (itemRecord["dateServerModified"] != null) {
        updateItems.add(itemRecord);
      } else {
        createItems.add(itemRecord);
      }
    });

    var bulkAction = PodPayloadBulkAction(
        createItems: createItems, updateItems: updateItems, deleteItems: [], createEdges: []);

    if (createItems.isNotEmpty || updateItems.isNotEmpty) {
      await updateSyncPayloadWithEdges(bulkAction);
    }

    return bulkAction;
  }

  updateSyncPayloadWithEdges(PodPayloadBulkAction syncPayload) async {
    List<String> allItemRecordIDs = (<Map<String, dynamic>>[]
          ..addAll(syncPayload.createItems)
          ..addAll(syncPayload.updateItems))
        .map<String>((item) => item["id"])
        .toList();
    List<ItemRecord> allItemRecords = (await databaseController.databasePool
            .itemRecordsCustomSelect("id IN ('${allItemRecordIDs.join("', '")}')", []))
        .map((item) => ItemRecord.fromItem(item))
        .toList();
    var targetItemRecords = await getTargetItems(allItemRecords);

    var edgeRowIDs = allItemRecords.compactMap((itemRecord) =>
        itemRecord.type == "Edge" && itemRecord.syncState == SyncState.create
            ? itemRecord.rowId!
            : null);
    if (targetItemRecords.isNotEmpty) {
      await Future.forEach<ItemRecord>(targetItemRecords, (itemRecord) async {
        var item = await itemRecord.syncDict(databaseController);
        if (itemRecord.type == "Edge" && itemRecord.syncState == SyncState.create) {
          edgeRowIDs.add(itemRecord.rowId!);
        }

        if (itemRecord.dateServerModified != null) {
          syncPayload.updateItems.add(item);
        } else {
          syncPayload.createItems.add(item);
        }
      });
    }

    if (edgeRowIDs.isEmpty) {
      return;
    }

    var edges = await databaseController.databasePool.edgeRecordsCustomSelect(
        "self IN (${edgeRowIDs.join(", ")}) AND syncState = ?",
        [Variable(SyncState.create.inString)]);
    syncPayload.createEdges = (await Future.wait(edges.map(
            (edge) async => await (ItemEdgeRecord.fromEdge(edge)).syncDict(databaseController))))
        .compactMap((edge) =>
            edge?["_name"][0] == "~" //TODO handling reverse edges, but why do we even need them?
                ? null
                : edge);
  }

  Future<List<ItemRecord>> getTargetItems(List<ItemRecord> parentItemRecords,
      [List<int>? parentAllItemIDs]) async {
    List<ItemEdgeRecord> targetEdges = (await Future.wait(parentItemRecords.map((itemRecord) async {
      return await itemRecord.edges(null, db: databaseController);
    })))
        .expand((element) => element)
        .toList();

    if (targetEdges.isEmpty) return [];

    var allItemIDs = <int>[]..addAll(parentAllItemIDs ?? []);
    allItemIDs.addAll(parentItemRecords.map((item) => item.rowId!));
    var targetItemIDs = targetEdges
        .map((edge) => [
              !allItemIDs.contains(edge.targetRowID) ? edge.targetRowID : null,
              !allItemIDs.contains(edge.selfRowID) ? edge.selfRowID : null
            ])
        .expand((element) => element)
        .toList()
        .compactMap();

    if (targetItemIDs.isEmpty) return [];

    List<ItemRecord> addItems = (await databaseController.databasePool.itemRecordsCustomSelect(
            "row_id IN (${targetItemIDs.join(", ")}) AND (syncState = ? OR syncState = ?)",
            [Variable(SyncState.create.inString), Variable(SyncState.update.inString)]))
        .map((item) => ItemRecord.fromItem(item))
        .toList();
    if (addItems.isEmpty) return [];

    var targetItems = await getTargetItems(addItems, allItemIDs);
    return addItems..addAll(targetItems);
  }

  Future<PodPayloadBulkAction> makeSyncEdgesData([int maxItems = 100]) async {
    var createEdges = await ItemEdgeRecord.syncEdgesWithState(
        state: SyncState.create, maxItems: maxItems, dbController: databaseController);

    var bulkAction = PodPayloadBulkAction(
        createItems: [], updateItems: [], deleteItems: [], createEdges: createEdges);

    return bulkAction;
  }

  bulkAction(
      {required PodPayloadBulkAction bulkPayload,
      required Function(String?) completion,
      PodConnectionDetails? connectionConfig}) async {
    connectionConfig ??= currentConnection ?? await AppController.shared.podConnectionConfig;
    if (connectionConfig == null) {
      throw Exception("No pod connection config");
    }

    var request = PodStandardRequest.bulkAction(bulkPayload);
    var networkCall = await request.execute(connectionConfig);
    var error;
    if (networkCall.statusCode != 200) {
      AppLogger.err("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.reasonPhrase;
    }
    await completion(error);
  }

  searchAction(
      {required int dateServerModifiedTimestamp,
      required Function(String?, String?)? completion}) async {
    if (currentConnection == null) {
      throw Exception("No pod connection config");
    }
    var request = PodStandardRequest.searchAction(
        {"dateServerModified>=": dateServerModifiedTimestamp, "[[edges]]": {}});

    var networkCall = await request.execute(currentConnection!);
    var error;
    if (networkCall.statusCode != 200) {
      AppLogger.err("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.reasonPhrase;
    }
    if (completion != null) await completion(Utf8Decoder().convert(networkCall.bodyBytes), error);
  }

  uploadFile(String uuid, Future<void> Function(String? data, String? error)? completion) async {
    var connectionConfig = currentConnection ?? await AppController.shared.podConnectionConfig;

    if (connectionConfig == null) {
      throw Exception("No pod connection config");
    }

    var fileURL = await FileStorageController.getURLForFile(uuid);
    var request =
        await PodUploadRequest.uploadFile(fileURL: fileURL, connectionConfig: connectionConfig);

    var networkCall = await request.execute(connectionConfig);

    var error;
    if (networkCall.statusCode != 200) {
      error = networkCall.reasonPhrase;
      if (error == "Conflict") {
        if (completion != null)
          await completion(Utf8Decoder().convert(networkCall.bodyBytes), null);
        return;
      }
      AppLogger.err("ERROR: ${networkCall.statusCode} $error on file $fileURL");
    }
    if (completion != null) await completion(Utf8Decoder().convert(networkCall.bodyBytes), error);
  }

  downloadFile(
      String sha256, String fileName, Future<void> Function(String? error)? completion) async {
    var connectionConfig = currentConnection ?? await AppController.shared.podConnectionConfig;

    if (connectionConfig == null) {
      throw Exception("No pod connection config");
    }

    var request = PodDownloadRequest.downloadFile(sha256, fileName);

    var networkCall = await request.execute(connectionConfig);

    var error;
    if (networkCall.statusCode != 200) {
      AppLogger.err("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.reasonPhrase;
    }
    if (completion != null) await completion(error);
  }
}
