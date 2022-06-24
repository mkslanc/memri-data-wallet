import 'package:dio/dio.dart';
import 'package:memri/core/apis/base_api.dart';

class LogAPI extends BaseAPI {
  LogAPI() : super('/logs');

  Future<String?> saveAll(List<String> logs) async {
    // var endpoint = '$baseUrl/save-all';
    // var response = await dio.post(endpoint, data: logs,options: Options());
    // checkResponseError(response);
    // return response.data;
  }
}
