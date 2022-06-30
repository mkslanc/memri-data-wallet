import 'package:flutter/foundation.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

// enum AppState { empty, loading, loaded, success, error, unauthenticated }

class AppProvider with ChangeNotifier {
  final PodService _podService;

  AppProvider(this._podService);

  String podVersion = 'x.x.x.x';
  String appVersion = 'x.x.x.x';
  PackageInfo? _packageInfo;
  late PodConnectionDetails connectionConfig;

  Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    appVersion = _packageInfo!.version +
        '.' +
        (_packageInfo?.buildNumber == null || _packageInfo!.buildNumber.isEmpty
            ? '0'
            : _packageInfo!.buildNumber);

    // TODO connectionConfig = PodConnectionDetails();
    _podService.podVersion(
        connectionConfig: connectionConfig,
        completion: (version, error) {
          podVersion = version!;
        });

    notifyListeners();
  }
}
