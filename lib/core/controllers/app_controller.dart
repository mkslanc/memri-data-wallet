//  Created by T Brennan on 14/12/20.

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/controllers/permission_controller.dart';
import 'package:memri/core/controllers/pod_api.dart';
import 'package:memri/core/apis/auth/authentication_shared.dart';
import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/models/pod_setup.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/core/services/settings.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AppState {
  setup,
  keySaving,
  authentication,
  authenticated,
  incompatibleDevice,
  incompatibleBrowser,
  maintenance
}

enum SystemError {
  connectionLost,
  failedToConnectToPod,
  podNotResponding,
  syncFailed,
  generalError
}

extension SystemErrorExt on SystemError {
  int get weight {
    switch (this) {
      case SystemError.connectionLost:
        return 100;
      case SystemError.generalError:
        return 1000;
      default:
        return 0;
    }
  }

  String get errorString {
    switch (this) {
      case SystemError.connectionLost:
        return "No internet connection";
      case SystemError.failedToConnectToPod:
        return "Something went wrong: failed to connect to Pod.";
      case SystemError.podNotResponding:
        return "Pod doesn't respond.";
      case SystemError.syncFailed:
        return "Failed to synchronize with pod.";
      case SystemError.generalError:
        return "Sorry! Something went wrong.";
    }
  }

  bool get showDismiss {
    switch (this) {
      case SystemError.syncFailed:
        return true;
      default:
        return false;
    }
  }

  bool get showRetry {
    switch (this) {
      case SystemError.generalError:
        return true;
      default:
        return false;
    }
  }
}

class AppController {
  static AppController shared = AppController();

  late DatabaseController databaseController;
  late PermissionsController permissionController;
  late PodSetupModel model;
  late PodAPI podApi;

  Isolate? syncIsolate;
  ValueNotifier<AppState> _state = ValueNotifier(AppState.setup);
  PodConfig? _podConnectionConfig;
  StreamSubscription<ConnectivityResult>? _connectivity;

  bool isDevelopersMode = false;
  bool _isInDemoMode = false;
  bool _isNewPodSetup = false;

  // MARK: Authentication
  bool _isAuthenticated = false; //TODO @anijanyan

  ValueNotifier<AppState> get state => _state;

  set state(newValue) => _state.value = newValue;

  bool get shouldShowError => lastError.value != null;
  showError(SystemError error) {
    if ((lastError.value?.weight ?? 0) > error.weight) return;
    lastError.value = error;
  }

  hideError(SystemError error) {
    if (lastError.value == error) lastError.value = null;
  }

  ValueNotifier<SystemError?> lastError = ValueNotifier(null);

  bool hasNetworkConnection = true;

  //TODO: hope this is temporary solution
  Map<String, dynamic> storage = {};

  AppController() {
    podApi = PodAPI();
    permissionController = PermissionsController();
    model = PodSetupModel();
  }

  Future<void> setIsAuthenticated(bool newValue) async {
    if (_isAuthenticated != newValue) {
      _isAuthenticated = newValue;
      await updateState();
    }
  }

  Future<void> requestAuthentication() async {
    if (!await checkHasBeenSetup()) {
      return;
    }
    await setIsAuthenticated(true);
  }

  bool get isOwnerKeyExist =>
      _podConnectionConfig?.ownerKey != null &&
      _podConnectionConfig!.ownerKey.length > 12;

  Future init() async {
    await databaseController.init();
    await MixpanelAnalyticsService().init();
  }

  Future<void> updateState() async {
    if (!await checkHasBeenSetup()) {
      state = AppState.setup;
      return;
    }
    if (!_isAuthenticated) {
      state = AppState.authentication;
      await requestAuthentication();
      return;
    }

    state = _isNewPodSetup ? AppState.keySaving : AppState.authenticated;
  }

  SetupConfig getSetupConfig(bool localOnly) {
    if (localOnly) {
      return SetupConfigLocal();
    } else if (model.setupAsNewPod) {
      var config = NewPodConfig(model.podURL ?? app.settings.defaultPodUrl);
      return SetupConfigNewPod(config);
    } else {
      var privateKey = model.podPrivateKey?.nullIfBlank ??
          Uuid().v4(); //TODO: kill when we will have end-to-end
      var publicKey = model.podPublicKey?.nullIfBlank;
      if (publicKey == null) {
        throw Exception("Login key is required");
      }
      var databaseKey = model.podDatabaseKey?.nullIfBlank;
      if (databaseKey == null) {
        throw Exception("Password key is required");
      }
      var config = ExistingPodConfig(model.podURL ?? app.settings.defaultPodUrl,
          privateKey, publicKey, databaseKey);
      return SetupConfigExistingPod(config);
    }
  }

  Future<void> importData(SetupConfig config) async {
    bool test = await databaseController.hasImportedDefaultData;
    if (!test) {
      if (config is SetupConfigLocal || config is SetupConfigNewPod) {
        await databaseController.importRequiredData();
        if (model.useDemoData) await databaseController.setupWithDemoData();
        if (config is SetupConfigLocal) _isInDemoMode = true;
        await Settings.shared
            .set("defaults/general/isInDemoMode", _isInDemoMode);
      }
    }
  }

  // MARK: Setup
  Future<void> setupApp(
      {bool localOnly = false,
      VoidCallback? onPodConnected,
      VoidCallback? onError,
      String? predefinedKey}) async {
    SetupConfig config;
    try {
      config = getSetupConfig(localOnly);
      await connectToPod(config, predefinedKey: predefinedKey);
    } on Exception catch (error) {
      model.state = PodSetupState.error;
      model.errorString = error.toString().replaceFirst("Exception: ", "");
      if (onError != null) onError();
      return;
    }

    if (onPodConnected != null) onPodConnected();
    state = config is SetupConfigNewPod
        ? AppState.keySaving
        : AppState.authenticated;
    model.state = PodSetupState.idle;

    await importData(config);

    if (_podConnectionConfig != null) {
      if (config is SetupConfigNewPod) {
        _isNewPodSetup = true;
        await Settings.shared.set("defaults/pod/url", config.config.podURL);
        //TODO owner and database key should not be stored in settings
        await Settings.shared
            .set("defaults/pod/publicKey", _podConnectionConfig!.ownerKey);
        await Settings.shared
            .set("defaults/pod/databaseKey", _podConnectionConfig!.databaseKey);
      }
    }

    await Settings.shared
        .set("defaults/general/isDevelopersMode", isDevelopersMode);
    _isAuthenticated = true;
  }

  Future<void> connectToPod(SetupConfig config, {String? predefinedKey}) async {
    if (config is SetupConfigExistingPod) {
      var uri = Uri.parse(config.config.podURL);
      _podConnectionConfig = PodConfig(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: config.config.podPublicKey,
          databaseKey: config.config.podDatabaseKey);
    } else if (config is SetupConfigNewPod) {
      var uri = Uri.parse(config.config.podURL);
      var keys = await Authentication.createOwnerAndDBKey(predefinedKey);
      _podConnectionConfig = PodConfig(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: keys.publicKey,
          databaseKey: keys.dbKey);
    } else {
      return;
    }
  }

  Future<bool> checkHasBeenSetup() async =>
      await AppController.shared.databaseController.hasImportedSchema;

  // MARK: Pod connection
  Future<PodConfig?> get podConnectionConfig async {
    if (_isInDemoMode) return null;
    try {
      // Here you should retrieve the connection details stored in the database
      if (_podConnectionConfig == null) {
        var podURL = await Settings.shared.get("defaults/pod/url");
        var keys = await Authentication.getOwnerAndDBKey();
        var ownerKey = keys.ownerKey;
        var databaseKey = keys.dbKey;
        if (podURL == null) return null;
        var uri = Uri.parse(podURL);
        _podConnectionConfig = PodConfig(
            scheme: uri.scheme,
            host: uri.host,
            port: uri.port,
            ownerKey: ownerKey,
            databaseKey: databaseKey);
      }
      return _podConnectionConfig!;
    } on Exception catch (error, stackTrace) {
      AppLogger.err(error, stackTrace: stackTrace);
      return null;
    }
  }

  resetApp() async {
    try {
      // navigationIsVisible.value = false;
      if (!_isInDemoMode) {
        hasNetworkConnection = true;
        await _connectivity?.cancel();
        _connectivity = null;
        _podConnectionConfig = null;
        syncIsolate?.kill(priority: Isolate.immediate);
      }
      await FileStorageController.deleteFileStorage();
      await databaseController.delete();
      Authentication.createRootKey();
      state = AppState.setup;
      await init();

      _isAuthenticated = false;
      _isNewPodSetup = false;
      _isInDemoMode = false;
      isDevelopersMode = false;
    } catch (e) {
      AppLogger.err(e);
    }
  }
}

abstract class SetupConfig {}

class SetupConfigLocal extends SetupConfig {}

class SetupConfigNewPod extends SetupConfig {
  final NewPodConfig config;

  SetupConfigNewPod(this.config);
}

class SetupConfigExistingPod extends SetupConfig {
  final ExistingPodConfig config;

  SetupConfigExistingPod(this.config);
}

class NewPodConfig {
  final String podURL;

  NewPodConfig(this.podURL);
}

class ExistingPodConfig {
  final String podURL;
  final String podPrivateKey;
  final String podPublicKey;
  final String podDatabaseKey;

  ExistingPodConfig(
      this.podURL, this.podPrivateKey, this.podPublicKey, this.podDatabaseKey);
}
