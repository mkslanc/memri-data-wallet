import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:memri/core/apis/base_api.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/services/settings.dart';
import 'package:moor/moor.dart';

class PodAPI extends BaseAPI {
  PodAPI() : super('');

  late PodConnectionDetails connectionConfig;
  String endpointUrl = '';

  void setConnectionConfig(PodConnectionDetails cc) {
    connectionConfig = cc;
    endpointUrl =
        '${connectionConfig.baseUrl}/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}';
  }

  Future<dynamic> search(dynamic payload) async {
    var endpoint = '$endpointUrl/save-all';
    var response = await dio.post(endpoint, data: payload);
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> createItem(Map<String, dynamic> syncDict) async {
    String endpoint = '$endpointUrl/create_item';
    var response = await dio.post(endpoint, data: syncDict);
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> updateItem(Map<String, dynamic> syncDict) async {
    String endpoint = '$endpointUrl/update_item';
    var response = await dio.post(endpoint, data: syncDict);
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> deleteItem(String itemId) async {
    String endpoint = '$endpointUrl/delete_item';
    var response = await dio.post(endpoint, data: itemId);
    checkResponseError(response);
    return response.data;
  }

  Future<Item> getItem(String id) async {
    String endpoint = '$endpointUrl/get_item';
    var response = await dio.post(endpoint, data: id);
    checkResponseError(response);
    var res_dict = jsonDecode(response.data);
    return Item.fromJson(res_dict[0]);
  }

  Future<dynamic> getLogsForPluginRun(String itemId) async {
    String endpoint = '$endpointUrl/get_pluginrun_log';
    var response = await dio.post(endpoint, data: itemId);
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> bulkAction(dynamic payload) async {
    String endpoint = '$endpointUrl/bulk';
    var response = await dio.post(endpoint, data: payload);
    checkResponseError(response);
    return response.data;
  }

  Future<Map<String, dynamic>> queryGraphQL(String query) async {
    String endpoint = '$endpointUrl/graphql';
    var response = await dio.post(endpoint, data: query);
    checkResponseError(response);
    String resBody = Utf8Decoder().convert(response.data);
    return jsonDecode(resBody);
  }

  Future<String> podVersion() async {
    String endpoint = '$baseUrl/version';
    var response = await dio.get(endpoint);
    checkResponseError(response);
    return jsonDecode(response.data)['cargo'];
  }
}

enum HTTPMethod { get, post, delete, put }

extension HTTPMethodExtension on HTTPMethod {
  String get inString {
    return this.toString().toUpperCase();
  }
}

class PodUploadRequest<Payload> {
  String path;
  Payload payload;

  Future<bool> get uploadOnCellular async {
    return (await Settings.shared.getSetting<bool>("device/upload/cellular")) ??
        false;
  }

  PodUploadRequest({required this.path, required this.payload});

  Future<http.Response> execute(PodConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path:
            "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    return await http.post(url, body: payload);
  }

  static Future<PodUploadRequest<Uint8List?>> uploadFile(
      {required String fileURL,
      Uint8List? fileData,
      String? fileSHAHash,
      required PodConnectionDetails connectionConfig}) async {
    fileData ??= await FileStorageController.getData(fileURL: fileURL);
    fileSHAHash ??=
        fileData != null ? FileStorageController.getHashForData(fileData) : "";
    var path = "upload_file/${connectionConfig.databaseKey}/$fileSHAHash";

    return PodUploadRequest(path: path, payload: fileData);
  }
}

class PodDownloadRequest<Payload> {
  String path;
  HTTPMethod method;
  Payload payload;
  String fileUID;
  Map<String, String> headers;

  PodDownloadRequest(
      {required this.path,
      this.method = HTTPMethod.post,
      required this.payload,
      required this.fileUID,
      Map<String, String>? headers})
      : headers = headers ?? {"content-type": "application/json"};

  Future<bool> get uploadOnCellular async {
    return (await Settings.shared.getSetting<bool>("device/upload/cellular")) ??
        false;
  }

  Future<String> get destination async {
    return await FileStorageController.getURLForFile(fileUID);
  }

  Future<http.Response> execute(PodConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path:
            "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    var body = jsonEncode(
        PodRequestBody(connectionConfig: connectionConfig, payload: payload));

    var response = await http.post(url, headers: headers, body: body);

    await FileStorageController.write(await destination, response.bodyBytes);

    return response;
  }

  static PodDownloadRequest<PodPayloadFileSHA> downloadFile(
      String fileSHAHash, String fileUID) {
    return PodDownloadRequest(
        path: "get_file",
        payload: PodPayloadFileSHA(fileSHAHash),
        fileUID: fileUID);
  }
}
