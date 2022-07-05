import 'package:memri/core/apis/base_api.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class LogAPI extends BaseAPI {
  LogAPI() : super('/${app.settings.podVersion}');

  Future<String?> saveAll(List<String> logs) async {
    var endpoint = '$baseUrl/save-all';
    var response = await dio.post(endpoint, data: logs);
    checkResponseError(response);
    return response.data;
  }
}
