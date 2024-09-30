import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod_api.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/services/api_service.dart';
import 'package:memri/providers/settings_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:uuid/data.dart';
import 'package:uuid/rng.dart';
import 'package:uuid/uuid.dart';

import '../controllers/authentication.dart';
import './demo_data_pod.dart';
import 'error_service.dart';

class PodService extends ApiService<PodAPI> {
  PodService._(this._settings) : super(api: PodAPI());

  static Future<PodService> create(SettingsProvider settings) async {
    final service = PodService._(settings);
    await service._init();
    return service;
  }

  final SettingsProvider _settings;
  late PodConfig podConfig;
  final Map<String, String> _podPropertyTypes = {
    "string": "Text",
    "int": "Integer",
    "double": "Real",
    "bool": "Bool",
    "datetime": "DateTime",
  };

  Future<void> _init() async {
    final podAddress = _settings.podAddress;
    final ownerKey = await Authentication.instance.getOwnerKey() ?? '';
    final dbKey = await Authentication.instance.getDbKey() ?? '';

    podConfig = PodConfig(
      baseUrl: podAddress,
      ownerKey: ownerKey,
      databaseKey: dbKey,
      apiVersion: app.settings.podVersion,
    );

    api.setConnectionConfig(podConfig);
  }

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
      await Authentication.instance.setOwnerKey(ownerKey);

  Future<void> storeDatabaseKey(String dbKey) async =>
      await Authentication.instance.setDbKey(dbKey);

  Future<void> storePodAddress(String podAddress) async =>
      await _settings.setPodAddress(podAddress);

  String generateCryptoStrongKey() {
    return "${Uuid().v4(config: V4Options(null, CryptoRNG()))}${Uuid().v4(config: V4Options(null, CryptoRNG()))}"
        .replaceAll("-", "");
  }

  /**
   * POD
   */

  Future<void> createSchema() async {
    Map<String, dynamic> schemaJson =
        jsonDecode(await rootBundle.loadString("assets/outputSchema.json"));
    try {
      api.createSchema(PodPayloadCreateSchema(
          SchemaMeta.fromJson(schemaJson['meta']), schemaJson['nodes'], schemaJson['edges']));
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> loadDemoFiles(bool downloadDemoAssets) async {
    var result = await DemoData.importDataToPod(defaultData: false, downloadDemoAssets: downloadDemoAssets);
    await uploadData(result["items"], result["urls"]);
  }

  Future<void> loadDefaultData() async {
    var result = await DemoData.importDataToPod();
    await uploadData(result["items"], result["urls"]);
  }

  Future<void> uploadData(List<Item> items, List<String> urls) async {
    var allEdges = items.expand((Item item) => item.getAllEdges() ?? []).cast<Edge>().toList();
    await this.bulkAction(createItems: items, createEdges: allEdges);
    try {
      for (var url in urls) {
        await api.uploadFile(url);
      }
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<String> podVersion() async => api.podVersion().catchError((error) => '');

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
        var itemMap = item.toJson();
        itemMap.remove("dateServerModified");
        updatePayload.add(itemMap);
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

    try {
      await api.bulkAction(bulkPayload);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<Item> getItem({
    required String id,
  }) async {
    try {
      return Item.fromJson(await api.getItem(id));
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<List<Item>> graphql({
    required String query,
  }) async {
    try {
      final response = await api.queryGraphQL(query);
      return _parseGQLResponse(response);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  _handleException(Exception e) {
    if (ErrorService.isConnectionError(e)) {
      throw e;
    } else if (e is DioException && e.type == DioExceptionType.badResponse) {
      // Bad response (e.g., 404, 500)
      final statusCode = e.response?.statusCode;
      final statusMessage = e.response?.statusMessage;
      throw Exception('Server Error: $statusCode - $statusMessage');
    } else {
      // Other errors
      throw Exception('Unexpected Error');
    }
  }

  Future<List<Item>> getNavigationItems() async {
    var query = '''
  query {
          NavigationItem {
            title
            itemType
            sessionName
          }
        }
''';
    return graphql(query: query);
  }

  Future<Item> createItem({
    required Item item,
  }) async {
    var itemMap = item.toJson();
    try {
      var resultID = await api.createItem(itemMap);
      item.properties["id"] = resultID;
      return item;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<Item> updateItem({
    required Item item,
  }) async {
    var itemMap = item.toJson();
    itemMap.remove("dateServerModified");
    try {
      await api.updateItem(itemMap);
      return item;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<void> deleteItem({
    required Item item,
  }) async {
    try {
      await api.deleteItem(item.id);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  List<Item> _parseGQLResponse(Map<String, dynamic> jsonBody) {
    List<Item> result = [];
    List<dynamic> data = jsonBody['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
  }

  Future<Map<String, dynamic>> getSchema() async {
    try {
      return await api.getSchema();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  downloadFile(String fileSHAHash) async {
    try {
      return await api.downloadFile(fileSHAHash);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Future<Map<String, int>> countItemsByType(List<String> types) async {
    //TODO: this is very expensive and should be optimized
    final Map<String, int> itemCountByType = {};

    for (var type in types) {
      try {
        var query = '''
      query {
        $type {
          dateCreated
        }
      }
      ''';

        final List<Item> items = await graphql(query: query);

        itemCountByType[type] = items.length;
      } catch (error) {
        print('Failed to fetch data for type $type: $error');
      }
    }

    return itemCountByType;
  }
}
