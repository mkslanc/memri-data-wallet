import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:memri/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/services/settings.dart';
import 'package:moor/moor.dart';

enum HTTPMethod { get, post, delete, put }

extension HTTPMethodExtension on HTTPMethod {
  String get inString {
    return this.toString().toUpperCase();
  }
}

class PodStandardRequest<Payload> {
  HTTPMethod method = HTTPMethod.post;
  String path;
  Map<String, String> headers;
  Payload payload;

  PodStandardRequest(
      {this.method = HTTPMethod.post, required this.path, headers, required this.payload})
      : headers = headers ?? {"content-type": "application/json"};

  Future<http.Response> _executeRequest(PodConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    /// For a `post` request (or other types of request) encode our payload into the body of the request.
    var body = jsonEncode(PodRequestBody(connectionConfig: connectionConfig, payload: payload));
    switch (method) {
      case HTTPMethod.get:
        if (path == "version") {
          url = Uri(
              scheme: connectionConfig.scheme,
              host: connectionConfig.host,
              port: connectionConfig.port,
              path: "/$path");
        } else {
          if (payload is PodPayload) {
            url = Uri(
                scheme: connectionConfig.scheme,
                host: connectionConfig.host,
                port: connectionConfig.port,
                path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path",
                queryParameters: (payload as PodPayload).toJson());
          }
        }

        /// For a `get` request, encode our payload into the URL.
        return await http.get(url, headers: headers);
      case HTTPMethod.post:
        return await http.post(url, headers: headers, body: body);
      case HTTPMethod.delete:
        return await http.delete(url, headers: headers, body: body);
      case HTTPMethod.put:
        return await http.put(url, headers: headers, body: body);
    }
  }

  Future<http.Response> execute(PodConnectionDetails connectionConfig) async {
    return await _executeRequest(connectionConfig);
  }

  /*static PodStandardRequest getItemWithEdges(PodPayload id) {
    // Note payload is just item UID (no JSON)
    var payload = id;
    return PodStandardRequest(path: "get_item", payload: payload);
  }

  static PodStandardRequest getItemsWithEdges(Set<String> itemIDs) {
    var payload = PodPayloadItemUIDList(itemIDs);
    return PodStandardRequest(path: "get_items_with_edges", payload: payload);
  }*/

  static PodStandardRequest searchAction<Payload>(Payload payload) {
    return PodStandardRequest(path: "search", payload: payload);
  }

  static PodStandardRequest createItem(Map<String, dynamic> syncDict) {
    return PodStandardRequest(path: "create_item", payload: syncDict);
  }

  static PodStandardRequest updateItem(Map<String, dynamic> syncDict) {
    return PodStandardRequest(path: "update_item", payload: syncDict);
  }

  static PodStandardRequest deleteItem(String itemId) {
    // Note payload is just item UID (no JSON)
    return PodStandardRequest(path: "delete_item", payload: itemId);
  }

  static PodStandardRequest getItem<Payload>(Payload payload) {
    return PodStandardRequest(path: "get_item", payload: payload);
  }

  static PodStandardRequest getLogsForPluginRun(String itemId) {
    return PodStandardRequest(path: "get_pluginrun_log", payload: itemId);
  }

  static PodStandardRequest bulkAction<Payload>(Payload payload) {
    return PodStandardRequest(path: "bulk", payload: payload);
  }

  static PodStandardRequest getVersion() {
    return PodStandardRequest(method: HTTPMethod.get, path: "version", payload: {});
  }
}

class PodUploadRequest<Payload> {
  String path;
  Payload payload;

  Future<bool> get uploadOnCellular async {
    return (await Settings.shared.getSetting<bool>("device/upload/cellular")) ?? false;
  }

  PodUploadRequest({required this.path, required this.payload});

  Future<http.Response> execute(PodConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    return await http.post(url, body: payload);
  }

  static Future<PodUploadRequest<Uint8List?>> uploadFile(
      {required String fileURL,
      Uint8List? fileData,
      String? fileSHAHash,
      required PodConnectionDetails connectionConfig}) async {
    fileData ??= await FileStorageController.getData(fileURL: fileURL);
    fileSHAHash ??= fileData != null ? FileStorageController.getHashForData(fileData) : "";
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
    return (await Settings.shared.getSetting<bool>("device/upload/cellular")) ?? false;
  }

  Future<String> get destination async {
    return await FileStorageController.getURLForFile(fileUID);
  }

  Future<http.Response> execute(PodConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    var body = jsonEncode(PodRequestBody(connectionConfig: connectionConfig, payload: payload));

    var response = await http.post(url, headers: headers, body: body);

    await FileStorageController.write(await destination, response.bodyBytes);

    return response;
  }

  static PodDownloadRequest<PodPayloadFileSHA> downloadFile(String fileSHAHash, String fileUID) {
    return PodDownloadRequest(
        path: "get_file", payload: PodPayloadFileSHA(fileSHAHash), fileUID: fileUID);
  }
}
