import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:memri/core/apis/base_api.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';

class PodAPI extends BaseAPI {
  PodAPI() : super('');

  late PodConfig _podConfig;
  String _endpointUrl = '';
  String _endpointUrlV5 = '';

  void setConnectionConfig(PodConfig podConfig) {
    _podConfig = podConfig;
    _endpointUrl = '${_podConfig.baseUrl}/${_podConfig.apiVersion}/${_podConfig.ownerKey}';
    _endpointUrlV5 = '${_podConfig.baseUrl}/v5/${_podConfig.ownerKey}';
  }

  Future<void> createSchema(PodPayloadCreateSchema request) async {
    String endpoint = '$_endpointUrlV5/schema';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': request.toJson(),
      },
    );
    checkResponseError(response);
  }

  Future<dynamic> authenticate() async {
    String endpoint = '${_podConfig.baseUrl}/${_podConfig.apiVersion}/account/pod/open';
    var response = await dio.post(
      endpoint,
      data: {
        'ownerKey': _podConfig.ownerKey,
        'databaseKey': _podConfig.databaseKey,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> search(dynamic payload) async {
    var endpoint = '$_endpointUrl/search';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': payload,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<String> createItem(Map<String, dynamic> item_map) async {
    String endpoint = '$_endpointUrl/create_item';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': item_map,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> updateItem(Map<String, dynamic> syncDict) async {
    String endpoint = '$_endpointUrl/update_item';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': syncDict,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> deleteItem(String itemId) async {
    String endpoint = '$_endpointUrl/delete_item';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': itemId,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<Map<String, dynamic>> getItem(String id) async {
    String endpoint = '$_endpointUrl/get_item';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': id,
      },
    );
    checkResponseError(response);
    return jsonDecode(response.data);
  }

  Future<dynamic> getLogsForPluginRun(String itemId) async {
    String endpoint = '$_endpointUrl/get_pluginrun_log';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': itemId,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<dynamic> bulkAction(dynamic payload) async {
    String endpoint = '$_endpointUrl/bulk';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': payload,
      },
    );
    checkResponseError(response);
    return response.data;
  }

  Future<Map<String, dynamic>> queryGraphQL(String query) async {
    String endpoint = '$_endpointUrl/graphql';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': query,
      },
    );
    checkResponseError(response);

    return response.data;
  }


  Future<Map<String, dynamic>> getSchema() async {
    String endpoint = '$_endpointUrlV5/get_schema';
    var response = await dio.post(
      endpoint,
      data: {
        'auth': {'type': 'ClientAuth', 'databaseKey': _podConfig.databaseKey},
        'payload': null
      },
    );
    checkResponseError(response);

    return jsonDecode(response.toString());
  }

  Future<String> podVersion() async {
    String endpoint = '$baseUrl/version';
    var response = await dio.get(endpoint);
    checkResponseError(response);
    return jsonDecode(response.data)['cargo'];
  }

  uploadFile(String url) async {
    var request = await PodUploadRequest.uploadFile(fileURL: url, connectionConfig: _podConfig);
    var response = await request.execute(_podConfig);
    //checkResponseError(response); TODO:

    //return jsonDecode(response.toString());
  }


  downloadFile(String fileSHA) async {
    var request = PodDownloadRequest.downloadFile(fileSHA, fileSHA);
    await request.execute(_podConfig);
    //checkResponseError(response); TODO:

    //return jsonDecode(response.toString());
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

  PodUploadRequest({required this.path, required this.payload});

  Future<http.Response> execute(PodConfig connectionConfig) async {
    Uri url = Uri.parse(connectionConfig.baseUrl + "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");

    return await http.post(url, body: payload);
  }

  static Future<PodUploadRequest<Uint8List?>> uploadFile(
      {required String fileURL,
      Uint8List? fileData,
      String? fileSHAHash,
      required PodConfig connectionConfig}) async {
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

  Future<String> get destination async {
    return FileStorageController.getURLForFile(fileUID);
  }

  Future<http.Response> execute(PodConfig connectionConfig) async {
    Uri url = Uri.parse(connectionConfig.baseUrl + "/${connectionConfig.apiVersion}/${connectionConfig.ownerKey}/$path");
    var body = jsonEncode(PodRequestBody(connectionConfig: connectionConfig, payload: payload));

    var response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      await FileStorageController.write(await destination, response.bodyBytes);
    }

    return response;
  }

  static PodDownloadRequest<PodPayloadFileSHA> downloadFile(String fileSHAHash, String fileUID) {
    return PodDownloadRequest(
        path: "get_file", payload: PodPayloadFileSHA(fileSHAHash), fileUID: fileUID);
  }
}
