import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/src/response.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod/pod_requests.dart';

import '../core/apis/pod/item.dart';



  class PodAPI{
    // PodConnectionDetails? currentConnection;

    bulkAction(
        {required PodPayloadBulkAction bulkPayload,
        required Function(String?) completion,
        PodConnectionDetails? connectionConfig}) async {
      connectionConfig ??= await AppController.shared.podConnectionConfig;
      if (connectionConfig == null) {
        throw Exception("No pod connection config");
      }

      var request = PodStandardRequest.bulkAction(bulkPayload);
      var networkCall = await request.execute(connectionConfig);
      var error;
      if (networkCall.statusCode != 200) {
        AppLogger.err("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
        error = networkCall.statusCode.toString() + ' ' + (networkCall.reasonPhrase ?? "");
      }
      await completion(error);
    }
    getItem(
        {
        required Function(Item?, String?)? completion,
        PodConnectionDetails? connectionConfig,
        required String id
        }) async {
      connectionConfig ??= await AppController.shared.podConnectionConfig;
      if (connectionConfig == null) {
        throw Exception("No pod connection config");
      }
      var payload = id;

      var request = PodStandardRequest.getItem(payload);
      var response = await request.execute(connectionConfig);
      var error;
      if (response.statusCode != 200) {
        AppLogger.err("ERROR: ${response.statusCode} ${response.reasonPhrase}");
        error = response.statusCode.toString() + ' ' + (response.reasonPhrase ?? "");
      }
      if (completion != null){
        var res_dict = jsonDecode(response.body);
        Item item = Item.fromJson(res_dict[0]);
        completion(item, error);
      }
    }

    graphql({
        PodConnectionDetails? connectionConfig,
        required String query,
        required Function(List<Item>, String?)? completion,
        }) async {
      connectionConfig ??= await AppController.shared.podConnectionConfig;
      if (connectionConfig == null) {
        throw Exception("No pod connection config");
      }
      var request = PodStandardRequest.queryGraphQL(query);
      var response = await request.execute(connectionConfig);
      var error;
      if (response.statusCode != 200) {
        AppLogger.err("ERROR: ${response.statusCode} ${response.reasonPhrase}");
        error = response.statusCode.toString() + ' ' + (response.reasonPhrase ?? "");
      }
      if (completion != null){
        String resBody = Utf8Decoder().convert(response.bodyBytes);
        var items = parseGQLResponse(resBody);
        await completion(items, error);
      }
    }

  Future<List<Item>> getDataset(PodConnectionDetails connectionConfig, String datasetName, Function(List<Item>, String?)? completion) async {
    var query = '''
      query {
        Dataset (filter: {name: {eq: "$datasetName"}}) {
            type
            id
            name
            entry (limit: 5000, offset: 0) {
                id
                data {
                    content
                }
                annotation {
                    labelValue
                }
            }
        }
    }''';
    return graphql(connectionConfig: connectionConfig, query: query, completion: completion);
  }

  List<Item> parseGQLResponse(String body) {
    Map<String, dynamic> dict = jsonDecode(body);
    List<Item> result = [];
    List<dynamic> data = dict['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
}

  //   search(
  //     {required int dateServerModifiedTimestamp,
  //     required Function(String?, String?)? completion,
  //     required int limit,
  //     PodConnectionDetails? connectionConfig,
  //     order = "Asc"}) async {

  //   connectionConfig ??= await AppController.shared.podConnectionConfig;
  //   var payload = {
  //     "dateServerModified>=": dateServerModifiedTimestamp,
  //     "[[edges]]": {},
  //     "_limit": limit,
  //     "_sortOrder": order
  //   };
  //   var request = PodStandardRequest.searchAction(payload);
  //   var networkCall = await request.execute(connectionConfig!);
  //   var error;
  //   if (networkCall.statusCode != 200) {
  //     AppLogger.err("ERROR: ${networkCall.statusCode} ${networkCall.reasonPhrase}");
  //     error = networkCall.statusCode.toString() + ' ' + (networkCall.reasonPhrase ?? "");
  //   }
  //   if (completion != null) await completion(Utf8Decoder().convert(networkCall.bodyBytes), error);
  // }
  }