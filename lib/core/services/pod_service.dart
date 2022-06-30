import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod_api.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/services/api_service.dart';

class PodService extends ApiService<PodAPI> {
  PodService() : super(api: PodAPI());

  Future<String> podVersion() async =>
      api.podVersion().catchError((error) => '');

  Future<dynamic> bulkAction({
    required PodConnectionDetails connectionConfig,
    required PodPayloadBulkAction bulkPayload,
  }) async {
    api.setConnectionConfig(connectionConfig);
    return api.bulkAction(bulkPayload);
  }

  Future<Item> getItem({
    required PodConnectionDetails connectionConfig,
    required String id,
  }) async {
    api.setConnectionConfig(connectionConfig);
    return api.getItem(id);
  }

  Future<List<Item>> graphql({
    required PodConnectionDetails connectionConfig,
    required String query,
  }) async {
    api.setConnectionConfig(connectionConfig);
    return _parseGQLResponse(await api.queryGraphQL(query));
  }

  List<Item> _parseGQLResponse(Map<String, dynamic> jsonBody) {
    List<Item> result = [];
    List<dynamic> data = jsonBody['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
  }
}
