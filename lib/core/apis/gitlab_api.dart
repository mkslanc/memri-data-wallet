import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:memri/core/apis/base_api.dart';

class GitlabAPI extends BaseAPI {
  GitlabAPI()
      : super('https://gitlab.memri.io/api/v4/projects', isPodUrl: false);

  Future<String> getTextFileContentFromGitlab({
    required int gitProjectId,
    required String filename,
    String? branch = 'main',
  }) async {
    var endpoint =
        '$baseUrl/$gitProjectId/repository/files/$filename?ref=$branch';
    var response = await dio.get(
      endpoint,
      options: Options(responseType: ResponseType.json),
    );
    checkResponseError(response);
    var decodedGitJson = jsonDecode(response.data);
    if (decodedGitJson.length == 0 || decodedGitJson["content"] == null) {
      throw "$filename is not available in provided repository link";
    }
    return Utf8Decoder().convert(base64Decode(decodedGitJson["content"]));
  }

  Future<String> downloadSingleArtifact({
    required int gitProjectId,
    required String filename,
    required String jobName,
    String? branch = 'main',
  }) async {
    var endpoint =
        '$baseUrl/$gitProjectId/jobs/artifacts/$branch/raw/$filename?job=$jobName';
    var response = await dio.get(
      endpoint,
      options: Options(responseType: ResponseType.json),
    );
    checkResponseError(response);
    return response.data;
  }
}

/// Old Implementation
@deprecated
class GitlabApi {
  static Future<String> getTextFileContentFromGitlab(
      {required int gitProjectId,
      required String filename,
      String branch = "main"}) async {
    var repoUri = Uri.parse(
        "https://gitlab.memri.io/api/v4/projects/$gitProjectId/repository/files/$filename?ref=$branch");
    var response =
        await http.get(repoUri, headers: {"content-type": "application/json"});
    if (response.statusCode != 200) {
      throw "ERROR: ${response.statusCode} ${response.reasonPhrase}";
    }

    var gitJson = Utf8Decoder().convert(response.bodyBytes);
    var decodedGitJson = jsonDecode(gitJson);
    if (decodedGitJson.length == 0 || decodedGitJson["content"] == null) {
      throw "$filename is not available in provided repository link";
    }
    return Utf8Decoder().convert(base64Decode(decodedGitJson["content"]));
  }

  static Future<String> downloadSingleArtifact(
      {required int gitProjectId,
      required String filename,
      required String jobName,
      String branch = "main"}) async {
    var repoUri = Uri.parse(
        "https://gitlab.memri.io/api/v4/projects/$gitProjectId/jobs/artifacts/$branch/raw/$filename?job=$jobName");
    var response =
        await http.get(repoUri, headers: {"content-type": "application/json"});
    if (response.statusCode != 200) {
      throw "ERROR: ${response.statusCode} ${response.reasonPhrase}";
    }
    return Utf8Decoder().convert(response.bodyBytes);
  }
}
