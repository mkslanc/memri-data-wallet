import 'dart:convert';

import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod_api.dart';

class PodService {
  podVersion(
      {required PodConnectionDetails connectionConfig,
      required Function(String?, String?) completion}) async {
    var request = PodStandardRequest.getVersion();
    var response = await request.execute(connectionConfig);

    var error;
    if (response.statusCode != 200) {
      AppLogger.err("ERROR: ${response.statusCode} ${response.reasonPhrase}");
      error =
          response.statusCode.toString() + ' ' + (response.reasonPhrase ?? "");
    }

    var version = jsonDecode(response.body)["cargo"];
    await completion(version, error);
  }

  bulkAction(
      {required PodPayloadBulkAction bulkPayload,
      required Function(String?) completion,
      required PodConnectionDetails connectionConfig}) async {
    var request = PodStandardRequest.bulkAction(bulkPayload);
    var networkCall = await request.execute(connectionConfig);
    var error;
    if (networkCall.statusCode != 200) {
      AppLogger.err(
          "ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
      error = networkCall.statusCode.toString() +
          ' ' +
          (networkCall.reasonPhrase ?? "");
    }
    await completion(error);
  }

  getItem(
      {required Function(Item?, String?)? completion,
      required PodConnectionDetails connectionConfig,
      required String id}) async {
    var payload = id;

    var request = PodStandardRequest.getItem(payload);
    var response = await request.execute(connectionConfig);
    var error;
    if (response.statusCode != 200) {
      AppLogger.err("ERROR: ${response.statusCode} ${response.reasonPhrase}");
      error =
          response.statusCode.toString() + ' ' + (response.reasonPhrase ?? "");
    }
    if (completion != null) {
      var res_dict = jsonDecode(response.body);
      Item item = Item.fromJson(res_dict[0]);
      await completion(item, error);
    }
  }

  graphql({
    required PodConnectionDetails connectionConfig,
    required String query,
    required Function(List<Item>, String?)? completion,
  }) async {
    var request = PodStandardRequest.queryGraphQL(query);
    var response = await request.execute(connectionConfig);
    var error;
    if (response.statusCode != 200) {
      AppLogger.err("ERROR: ${response.statusCode} ${response.reasonPhrase}");
      error =
          response.statusCode.toString() + ' ' + (response.reasonPhrase ?? "");
    }
    if (completion != null) {
      String resBody = Utf8Decoder().convert(response.bodyBytes);
      var items = parseGQLResponse(resBody);
      await completion(items, error);
    }
  }

  List<Item> parseGQLResponse(String body) {
    Map<String, dynamic> dict = jsonDecode(body);
    List<Item> result = [];
    List<dynamic> data = dict['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
  }
}
