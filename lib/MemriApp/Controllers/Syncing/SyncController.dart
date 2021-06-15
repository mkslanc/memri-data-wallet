//
//  SyncController.swift
//  MemriDatabase
//
//  Created by T Brennan on 1/12/20.
//

import 'dart:convert';

import 'package:memri/MemriApp/Controllers/API/PodAPIConnectionDetails.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIRequests.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:moor/moor.dart';

import '../AppController.dart';

enum SyncControllerState {
  idle,
  started,
  uploadedSchema,
  uploadedItems,
  uploadedEdges,
  downloadedItems,
  done,
  failed
}

extension SyncStateExtension on SyncState {
  static SyncState rawValue(String value) =>
      SyncState.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

class SyncController {
  bool syncing = false;
  String? lastError;
  Function(String?)? completion;
  final DatabaseController databaseController;
  SyncControllerState state;
  PodAPIConnectionDetails? currentConnection;

  SyncController(this.databaseController) : state = SyncControllerState.idle;

  setState(SyncControllerState value) async {
    state = value;
    switch (value) {
      case SyncControllerState.started:
        syncing = true;
        print("Downloading items");
        await downloadItems();
        break;
      case SyncControllerState.downloadedItems:
        print("Uploading schema");
        await uploadSchema();
        break;
      case SyncControllerState.uploadedSchema:
        print("Uploading items");
        await uploadItems();
        break;
      case SyncControllerState.uploadedItems:
        print("Uploading edges");
        await uploadEdges();
        break;
      case SyncControllerState.uploadedEdges:
        print("Finishing");
        await finishSync();
        break;
      case SyncControllerState.failed:
        await finishSync();
        break;
      default:
        break;
    }
  }

  Future<bool> podIsExist(PodAPIConnectionDetails config) async {
    try {
      var request = PodAPIStandardRequest.getVersion();
      await request.execute(config);
      return true;
    } catch (e) {
      return false;
    }
  }

  sync({PodAPIConnectionDetails? connectionConfig, Function(String?)? completion}) async {
    /*guard (try? ItemRecord.getOwnerAndDBKey()) != nil else {
    throw StringError(description: "Not Setup")
    }*/ //TODO: auth keys
    currentConnection ??= connectionConfig ?? AppController.shared.podConnectionConfig;

    if (syncing) {
      throw Exception("Already syncing");
    }
    this.completion = completion;
    await setState(SyncControllerState.started);
  }

  finishSync() async {
    await setState(SyncControllerState.done);
    syncing = false;
    if (completion != null) await completion!(lastError);
    await setState(SyncControllerState.idle);
    completion = null;
  }

  uploadSchema() async {
    var syncPayload = await makeSyncSchemaData();
    if (syncPayload.createItems.isEmpty &&
        syncPayload.updateItems.isEmpty &&
        syncPayload.deleteItems.isEmpty) {
      await setState(SyncControllerState.uploadedSchema);
      return;
    }
    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          await ItemRecord.didSyncItems(syncPayload, error, databaseController);
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }

          await setState(SyncControllerState.uploadedSchema);
        }));
  }

  uploadItems() async {
    var syncPayload = await makeSyncUploadData();

    if (syncPayload.createItems.isEmpty &&
        syncPayload.updateItems.isEmpty &&
        syncPayload.deleteItems.isEmpty) {
      await setState(SyncControllerState.uploadedItems);
      return;
    }

    await bulkAction(
        bulkPayload: syncPayload,
        completion: ((error) async {
          await ItemRecord.didSyncItems(syncPayload, error, databaseController);
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }

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
          await ItemEdgeRecord.didSyncEdges(syncPayload, error, databaseController);
          if (error != null) {
            lastError = error;
            await setState(SyncControllerState.failed);
            return;
          }

          // Recurse until we run out of items to sync
          await uploadEdges(maxItems);
        }));
  }

  downloadItems() async {
    var dateServerModified =
        (await ItemRecord.lastSyncedItem(databaseController.databasePool))?.dateServerModified ??
            DateTime.fromMillisecondsSinceEpoch(0);

    await searchAction(
        dateServerModified: dateServerModified,
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
          await Future.forEach(responseObjects, (element) async {
            if (element != null && element is Map<String, dynamic>)
              await ItemRecord.fromSyncItemDict(dict: element, dbController: databaseController);
          });
          await setState(SyncControllerState.downloadedItems);
        });
  }

  Future<PodAPIPayloadBulkAction> makeSyncSchemaData() async {
    var schemaItems = (await databaseController.databasePool.itemRecordsCustomSelect(
            "type = ? AND syncState = ?",
            [Variable("ItemPropertySchema"), Variable(SyncState.create.inString)]))
        .map((item) => ItemRecord.fromItem(item));
    var syncItems =
        (await Future.wait(schemaItems.map((e) async => await e.schemaDict(databaseController))))
            .whereType<Map<String, dynamic>>()
            .toList();
    var bulkAction = PodAPIPayloadBulkAction(
        createItems: syncItems, updateItems: [], deleteItems: [], createEdges: []);
    return bulkAction;
  }

  Future<PodAPIPayloadBulkAction> makeSyncUploadData([int maxItems = 100]) async {
    var createItems = await ItemRecord.syncItemsWithState(
        state: SyncState.create, maxItems: maxItems, dbController: databaseController);
    var updateItems = await ItemRecord.syncItemsWithState(
        state: SyncState.update, maxItems: maxItems, dbController: databaseController);

    var bulkAction = PodAPIPayloadBulkAction(
        createItems: createItems, updateItems: updateItems, deleteItems: [], createEdges: []);

    return bulkAction;
  }

  Future<PodAPIPayloadBulkAction> makeSyncEdgesData([int maxItems = 100]) async {
    var createEdges = await ItemEdgeRecord.syncEdgesWithState(
        state: SyncState.create, maxItems: maxItems, dbController: databaseController);

    var bulkAction = PodAPIPayloadBulkAction(
        createItems: [], updateItems: [], deleteItems: [], createEdges: createEdges);

    return bulkAction;
  }

  bulkAction(
      {required PodAPIPayloadBulkAction bulkPayload,
      required Function(String?) completion,
      PodAPIConnectionDetails? connectionConfig}) async {
    connectionConfig ??= currentConnection ?? AppController.shared.podConnectionConfig;
    if (connectionConfig == null) {
      throw Exception("No pod connection config");
    }

    var request = PodAPIStandardRequest.bulkAction(bulkPayload);
    var networkCall = await request.execute(connectionConfig);
    var error;
    if (networkCall.statusCode != 200) {
      print("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.reasonPhrase;
    }
    await completion(error);
  }

  searchAction(
      {required DateTime dateServerModified,
      required Function(String?, String?)? completion}) async {
    if (currentConnection == null) {
      throw Exception("No pod connection config");
    }
    var timestamp = dateServerModified.millisecondsSinceEpoch;
    var request = PodAPIStandardRequest.searchAction({"dateServerModified>=": timestamp});

    var networkCall = await request.execute(currentConnection!);
    var error;
    if (networkCall.statusCode != 200) {
      print("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.reasonPhrase;
    }
    if (completion != null) await completion(networkCall.body, error);
  }
}
