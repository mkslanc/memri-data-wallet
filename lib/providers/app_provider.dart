import 'package:flutter/foundation.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppState { init, loading, success, error, unauthenticated }

class AppProvider with ChangeNotifier {
  final PodService _podService;
  final SharedPreferences _prefs;

  AppProvider(this._podService, this._prefs);

  AppState state = AppState.init;
  PackageInfo? _packageInfo;
  String podVersion = 'x.x.x.x';
  String appVersion = 'x.x.x.x';
  String errorMessage = '';
  bool navigationIsVisible = false;

  Future<void> initialize(bool checkAuth) async {
    // _handleLoading();
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      appVersion = _packageInfo!.version +
          '.' +
          (_packageInfo?.buildNumber == null ||
                  _packageInfo!.buildNumber.isEmpty
              ? '0'
              : _packageInfo!.buildNumber);
      podVersion = await _podService.podVersion();

      if (checkAuth) {
        String key = _podService.podConfig.ownerKey;
        if (key.isEmpty) {
          _handleUnauthenticated();
        } else {
          _handleSuccess();
        }
      } else {
        _handleSuccess();
      }
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  void _handleLoading() {
    state = AppState.loading;
    errorMessage = '';
    notifyListeners();
  }

  void _handleUnauthenticated() {
    state = AppState.unauthenticated;
    errorMessage = '';
    notifyListeners();
  }

  void _handleSuccess() {
    state = AppState.success;
    errorMessage = '';
    notifyListeners();
  }

  void _handleError(e) {
    state = AppState.error;
    errorMessage = e.toString();
    notifyListeners();
  }
}
