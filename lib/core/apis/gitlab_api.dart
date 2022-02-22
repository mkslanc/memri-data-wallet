import 'dart:convert';

import 'package:http/http.dart' as http;

class GitlabApi {
  static Future<String> getTextFileContentFromGitlab(
      {required int gitProjectId, required String filename, String branch = "main"}) async {
    var repoUri = Uri.parse(
        "https://gitlab.memri.io/api/v4/projects/$gitProjectId/repository/files/$filename?ref=$branch");
    var response = await http.get(repoUri, headers: {"content-type": "application/json"});
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
}
