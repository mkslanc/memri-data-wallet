import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/apis/pod_api.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/services/api_service.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

class PodService extends ApiService<PodAPI> {
  PodService(this._prefs) : super(api: PodAPI()) {
    podConfig = PodConfig(
      baseUrl:
          _prefs.getString(app.keys.podAddress) ?? app.settings.defaultPodUrl,
      ownerKey: _prefs.getString(app.keys.ownerKey) ?? '',
      databaseKey: _prefs.getString(app.keys.dbKey) ?? '',
      apiVersion: app.settings.podVersion,
    );
    api.setConnectionConfig(podConfig);
  }

  final SharedPreferences _prefs;
  late PodConfig podConfig;

  /**
   *  Authentication
   */
  Future<void> authenticate({
    required String podAddress,
    required String ownerKey,
    required String dbKey,
  }) async {
    podConfig = PodConfig(
      baseUrl: podAddress,
      ownerKey: ownerKey,
      databaseKey: dbKey,
      apiVersion: app.settings.podVersion,
    );
    api.setConnectionConfig(podConfig);
    await api.authenticate();
    await storePodAddress(podAddress);
    await storeOwnerKey(ownerKey);
    await storeDatabaseKey(dbKey);
  }

  Future<void> storeOwnerKey(String ownerKey) async =>
      await _prefs.setString(app.keys.ownerKey, ownerKey);

  Future<void> storeDatabaseKey(String dbKey) async =>
      await _prefs.setString(app.keys.dbKey, dbKey);

  Future<void> storePodAddress(String podAddress) async =>
      await _prefs.setString(app.keys.podAddress, podAddress);

  String generateCryptoStrongKey() {
    return "${Uuid().v4(options: {
          'rng': UuidUtil.cryptoRNG
        })}${Uuid().v4(options: {'rng': UuidUtil.cryptoRNG})}"
        .replaceAll("-", "");
  }

  /**
   * POD
   */
  Future<String> podVersion() async =>
      api.podVersion().catchError((error) => '');

  Future<dynamic> bulkAction({
    required PodConfig connectionConfig,
    required PodPayloadBulkAction bulkPayload,
  }) async =>
      api.bulkAction(bulkPayload);

  Future<Item> getItem({
    required PodConfig connectionConfig,
    required String id,
  }) async =>
      api.getItem(id);

  Future<List<Item>> graphql({
    required PodConfig connectionConfig,
    required String query,
  }) async =>
      _parseGQLResponse(await api.queryGraphQL(query));

  List<Item> _parseGQLResponse(Map<String, dynamic> jsonBody) {
    List<Item> result = [];
    List<dynamic> data = jsonBody['data'] ?? [];
    data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));
    return result;
  }
}
