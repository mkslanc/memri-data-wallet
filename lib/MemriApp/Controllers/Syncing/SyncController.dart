//
//  SyncController.swift
//  MemriDatabase
//
//  Created by T Brennan on 1/12/20.
//

import 'package:memri/MemriApp/Controllers/API/PodAPIConnectionDetails.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIPayloads.dart';
import 'package:memri/MemriApp/Controllers/API/PodAPIRequests.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import '../AppController.dart';

enum SyncState {
  create,
  update,
  noChanges,
  failed,
}

class SyncController {
  final DatabaseController databaseController;

  SyncController(this.databaseController);

  Future<bool> podIsExist(PodAPIConnectionDetails config) async {
    try {
      var request = PodAPIStandardRequest.getVersion();
      await request.execute(config);
      return true;
    } catch (e) {
      return false;
    }
  }

  sync(
      {int maxItems = 100,
      Function(Exception?)? completion,
      PodAPIConnectionDetails? connectionConfig}) async {
    if (await ItemRecord.me == null) {
      throw Exception("Cannot Sync, unauthenticated");
    }

    await syncSchema(
        completion: (error) {
          if (error != null) {
            if (completion != null) {
              completion(error);
              return;
            }
          }
          /*try {
                try self?.syncUpload(maxItems: maxItems, completion: { (error) in
                    completion?(error)
                })
            } catch (error) {
                completion?(error);
            }*/
        },
        connectionConfig: connectionConfig);
  }

  syncSchema(
      {required Function(Exception?) completion, PodAPIConnectionDetails? connectionConfig}) async {
    var syncSchemaPayload = await makeSyncSchemaData();
    await bulkAction(
        bulkPayload: syncSchemaPayload, completion: completion, connectionConfig: connectionConfig);
  }

  Future<PodAPIPayloadBulkAction> makeSyncSchemaData() async {
    var schemaItems = await ItemRecord.fetchWithType("ItemPropertySchema", databaseController);
    var syncItems =
        (await Future.wait(schemaItems.map((e) async => await e.schemaDict(databaseController))))
            .whereType<Map<String, dynamic>>()
            .toList();
    var bulkAction =
        PodAPIPayloadBulkAction(createItems: syncItems, updateItems: [], deleteItems: []);
    return bulkAction;
  }

  bulkAction(
      {required PodAPIPayloadBulkAction bulkPayload,
      required Function(Exception?) completion,
      PodAPIConnectionDetails? connectionConfig}) async {
    connectionConfig ??= AppController.shared.podConnectionConfig;
    if (connectionConfig == null) {
      throw Exception("No pod connection config");
    }

    var request = PodAPIStandardRequest.bulkAction(bulkPayload);
    await request.execute(connectionConfig);
  }
}
