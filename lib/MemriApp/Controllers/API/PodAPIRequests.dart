import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:memri/MemriApp/Controllers/FileStorageController.dart';
import 'package:memri/MemriApp/Controllers/Settings/Settings.dart';
import 'package:moor/moor.dart';

import 'PodAPIConnectionDetails.dart';
import 'PodAPIPayloads.dart';

enum HTTPMethod { get, post, delete, put }

extension HTTPMethodExtension on HTTPMethod {
  String get inString {
    return this.toString().toUpperCase();
  }
}

class PodAPIStandardRequest<Payload> {
  HTTPMethod method = HTTPMethod.post;
  String path;
  Map<String, String> headers;
  Payload payload;

  PodAPIStandardRequest(
      {this.method = HTTPMethod.post, required this.path, headers, required this.payload})
      : headers = headers ?? {"content-type": "application/json"};

  Future<http.Response> _executeRequest(PodAPIConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    /// For a `post` request (or other types of request) encode our payload into the body of the request.
    var body = jsonEncode(PodAPIRequestBody(connectionConfig: connectionConfig, payload: payload));
    switch (method) {
      case HTTPMethod.get:
        if (path == "version") {
          url = Uri(
              scheme: connectionConfig.scheme,
              host: connectionConfig.host,
              port: connectionConfig.port,
              path: "/$path");
        } else {
          if (payload is PodAPIPayload) {
            url = Uri(
                scheme: connectionConfig.scheme,
                host: connectionConfig.host,
                port: connectionConfig.port,
                path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path",
                queryParameters: (payload as PodAPIPayload).toJson());
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

  Future<http.Response> execute(PodAPIConnectionDetails connectionConfig) async {
    return await _executeRequest(connectionConfig);
  }

  /*static PodAPIStandardRequest getItemWithEdges(PodAPIPayload id) {
    // Note payload is just item UID (no JSON)
    var payload = id;
    return PodAPIStandardRequest(path: "get_item", payload: payload);
  }

  static PodAPIStandardRequest getItemsWithEdges(Set<String> itemIDs) {
    var payload = PodAPIPayloadItemUIDList(itemIDs);
    return PodAPIStandardRequest(path: "get_items_with_edges", payload: payload);
  }*/

  static PodAPIStandardRequest searchAction<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "search", payload: payload);
  }

  static PodAPIStandardRequest createItem(Map<String, dynamic> syncDict) {
    return PodAPIStandardRequest(path: "create_item", payload: syncDict);
  }

  static PodAPIStandardRequest updateItem(Map<String, dynamic> syncDict) {
    return PodAPIStandardRequest(path: "update_item", payload: syncDict);
  }

  static PodAPIStandardRequest deleteItem(String itemId) {
    // Note payload is just item UID (no JSON)
    return PodAPIStandardRequest(path: "delete_item", payload: itemId);
  }

  static PodAPIStandardRequest getItem<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "get_item", payload: payload);
  }

  static PodAPIStandardRequest bulkAction<Payload>(Payload payload) {
    return PodAPIStandardRequest(path: "bulk", payload: payload);
  }

  static PodAPIStandardRequest getVersion() {
    return PodAPIStandardRequest(method: HTTPMethod.get, path: "version", payload: {});
  }
}

class PodAPIUploadRequest<Payload> {
  String path;
  Payload payload;

  Future<bool> get uploadOnCellular async {
    return (await Settings.shared.getSetting<bool>("device/upload/cellular")) ?? false;
  }

  PodAPIUploadRequest({required this.path, required this.payload});

  Future<http.Response> execute(PodAPIConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    return await http.post(url, body: payload);
  }

  static Future<PodAPIUploadRequest<Uint8List?>> uploadFile(
      {required String fileURL,
      Uint8List? fileData,
      String? fileSHAHash,
      required PodAPIConnectionDetails connectionConfig}) async {
    fileData ??= await FileStorageController.getData(fileURL: fileURL);
    fileSHAHash ??= fileData != null ? FileStorageController.getHashForData(fileData) : "";
    var path = "upload_file/${connectionConfig.databaseKey}/$fileSHAHash";

    return PodAPIUploadRequest(path: path, payload: fileData);
  }
}

class PodAPIDownloadRequest<Payload> {
  String path;
  HTTPMethod method;
  Payload payload;
  String fileUID;
  Map<String, String> headers;

  PodAPIDownloadRequest(
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

  Future<http.Response> execute(PodAPIConnectionDetails connectionConfig) async {
    Uri url = Uri(
        scheme: connectionConfig.scheme,
        host: connectionConfig.host,
        port: connectionConfig.port,
        path: "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    var body = jsonEncode(PodAPIRequestBody(connectionConfig: connectionConfig, payload: payload));

    var response = await http.post(url, headers: headers, body: body);

    await FileStorageController.write(await destination, response.bodyBytes);

    return response;
  }

  static PodAPIDownloadRequest<PodAPIPayloadFileSHA> downloadFile(
      String fileSHAHash, String fileUID) {
    return PodAPIDownloadRequest(
        path: "get_file", payload: PodAPIPayloadFileSHA(fileSHAHash), fileUID: fileUID);
  }
}
