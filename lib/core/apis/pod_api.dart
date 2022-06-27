import 'dart:convert';

import 'package:memri/core/apis/base_api.dart';

class PodAPI extends BaseAPI {
  PodAPI() : super('');

  Future<String> podVersion() async {
    String endpoint = '$baseUrl/version';
    var response = await dio.get(endpoint);
    checkResponseError(response);
    return jsonDecode(response.data)['cargo'];
  }
}
