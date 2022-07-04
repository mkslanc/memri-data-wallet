import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod_api.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/services/api_service.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class PodService extends ApiService<PodAPI> {
  PodService(this._prefs) : super(api: PodAPI()) {
    podConfig = PodConfig(
      baseUrl:
          _prefs.getString(app.keys.podAddress) ?? app.settings.defaultPodUrl,
      ownerKey: _prefs.getString(app.keys.ownerKey) ?? '',
      databaseKey: _prefs.getString(app.keys.dbKey) ?? '',
      apiVersion: app.settings.podVersion,
    );
    api.setConnectionConfig(podConfig);
  }

  final SharedPreferences _prefs;
  late PodConfig podConfig;
  final Map<String, String> _podPropertyTypes = {
    "string": "Text",
    "int": "Integer",
    "double": "Real",
    "bool": "Bool",
    "datetime": "DateTime",
  };

  /**
   *  Authentication
   */
  Future<void> authenticate({
    required String podAddress,
    required String ownerKey,
    required String dbKey,
  }) async {
    podConfig = PodConfig(
      baseUrl: podAddress,
      ownerKey: ownerKey,
      databaseKey: dbKey,
      apiVersion: app.settings.podVersion,
    );
    api.setConnectionConfig(podConfig);
    await api.authenticate();
    await storePodAddress(podAddress);
    await storeOwnerKey(ownerKey);
    await storeDatabaseKey(dbKey);
  }

  Future<void> storeOwnerKey(String ownerKey) async =>
      await _prefs.setString(app.keys.ownerKey, ownerKey);

  Future<void> storeDatabaseKey(String dbKey) async =>
      await _prefs.setString(app.keys.dbKey, dbKey);

  Future<void> storePodAddress(String podAddress) async =>
      await _prefs.setString(app.keys.podAddress, podAddress);

  String generateCryptoStrongKey() {
    return "${Uuid().v4(options: {
          'rng': UuidUtil.cryptoRNG
        })}${Uuid().v4(options: {'rng': UuidUtil.cryptoRNG})}"
        .replaceAll("-", "");
  }

  /**
   * POD
   */

  Future<void> createSchema() async {
    Map<String, dynamic> schemaJson =
        jsonDecode(await rootBundle.loadString("assets/schema.json"));

    List<Map<String, dynamic>> schemaItems = [];

    for (var property in schemaJson["properties"]) {
      schemaItems.add({
        "type": "ItemPropertySchema",
        "itemType": property["item_type"],
        "propertyName": property["property"],
        "valueType": _podPropertyTypes[property["value_type"]],
      });
    }

    for (var edge in schemaJson["edges"]) {
      schemaItems.add({
        "type": "ItemEdgeSchema",
        "sourceType": edge["source_type"],
        "targetType": edge["target_type"],
        "edgeName": edge["edge"],
      });
    }

    debugPrint("[DEBUG] create schema: ${schemaItems.length} items");
    var payload = PodPayloadBulkAction(
        createItems: schemaItems,
        updateItems: [],
        deleteItems: [],
        createEdges: []);
    api.bulkAction(payload);
  }

  Future<String> podVersion() async =>
      api.podVersion().catchError((error) => '');

  Future<void> bulkAction({
    List<Item>? createItems = null,
    List<Item>? updateItems = null,
    List<String>? deleteItems = null,
    List<Edge>? createEdges = null,
  }) async {
    List<Map<String, dynamic>> createPayload = [];
    if (createItems != null) {
      createItems.forEach((item) {
        item.setIdIfNotExists();
        createPayload.add(item.toJson());
      });
    }

    List<Map<String, dynamic>> updatePayload = [];
    if (updateItems != null) {
      updateItems.forEach((item) {
        updatePayload.add(item.toJson());
      });
    }

    List<Map<String, dynamic>> edgePayload = [];
    if (createEdges != null) {
      createEdges.forEach((edge) {
        edgePayload.add(edge.toJson());
      });
    }

    var bulkPayload = PodPayloadBulkAction(
        createItems: createPayload,
        updateItems: updatePayload,
        deleteItems: deleteItems ?? [],
        createEdges: edgePayload);

    await api.bulkAction(bulkPayload);
  }

  Future<Item> getItem({
    required String id,
  }) async =>
      Item.fromJson(await api.getItem(id));

  Future<List<Item>> graphql({
    required String query,
  }) async =>
      _parseGQLResponse(await api.queryGraphQL(query));

  Future<Item> createItem({
    required Item item,
  }) async {
    if (item.type == null) {
      throw new Exception("Attempted to create item without an item type.");
    }
    var itemMap = item.toJson();
    var resultID = await api.createItem(itemMap);
    item.properties["id"] = resultID;
    return item;
  }

  List<Item> _parseGQLResponse(Map<String, dynamic> jsonBody) {
    List<Item> result = [];
    List<dynamic> data = jsonBody['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
  }
}
