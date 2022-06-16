//  Created by T Brennan on 14/12/20.

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/controllers/permission_controller.dart';
import 'package:memri/controllers/pub_sub_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/controllers/sync_controller.dart';
import 'package:memri/core/apis/auth/authentication_shared.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/services/settings.dart';
import 'package:memri/models/sync_config.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum AppState {
  setup,
  keySaving,
  authentication,
  authenticated,
  incompatibleDevice,
  incompatibleBrowser
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
  late SyncController syncController;
  late CVUController cvuController;
  late PubSubController pubSubController;
  late PermissionsController permissionController;
  late PodSetupModel model;

  Isolate? syncIsolate;
  ValueNotifier<AppState> _state = ValueNotifier(AppState.setup);
  PodConnectionDetails? _podConnectionConfig;
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
    databaseController = DatabaseController(inMemory: false);
    syncController = SyncController(databaseController);
    cvuController = CVUController(databaseController);
    pubSubController = PubSubController(databaseController);
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
      _podConnectionConfig?.ownerKey != null && _podConnectionConfig!.ownerKey.length > 12;

  Future init() async {
    await databaseController.init();
    await cvuController.init();
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

    await syncStream();
    if (!isDevelopersMode) {
      await cvuController.resetToDefault();
    }
  }

  Future<void> syncStream() async {
    _isInDemoMode = await Settings.shared.get<bool>("defaults/general/isInDemoMode") ?? false;
    if (!_isInDemoMode) {
      PodConnectionDetails connection = (await podConnectionConfig)!;
      var receivePort = ReceivePort();
      var documentsDirectory;
      if (!kIsWeb) {
        documentsDirectory = (await getApplicationDocumentsDirectory()).path;
        syncIsolate = await Isolate.spawn(
            runSync,
            IsolateSyncConfig(
                port: receivePort.sendPort,
                connection: connection,
                schema: databaseController.schema,
                documentsDirectory: documentsDirectory,
                rootKey: Authentication.lastRootPublicKey,
                isolate: databaseController.driftIsolate!));
      } else {
        runSync(SyncConfig(connection: connection, schema: databaseController.schema));
      }

      _connectivity = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        var connection = result != ConnectivityResult.none;
        if (hasNetworkConnection && !connection) {
          hasNetworkConnection = false;
          showError(SystemError.connectionLost);
        } else if (!hasNetworkConnection && connection) {
          hideError(SystemError.connectionLost);
          hasNetworkConnection = true;
        }
      });
    }

    isDevelopersMode =
        await Settings.shared.get<bool>("defaults/general/isDevelopersMode") ?? false;
  }

  SetupConfig? getSetupConfig(bool localOnly) {
    if (localOnly) {
      return SetupConfigLocal();
    } else if (model.setupAsNewPod) {
      var config = NewPodConfig(model.podURL ?? AppSettings.defaultPodURL);
      return SetupConfigNewPod(config);
    } else {
      var privateKey =
          model.podPrivateKey?.nullIfBlank ?? Uuid().v4(); //TODO: kill when we will have end-to-end
      var publicKey = model.podPublicKey?.nullIfBlank;
      var databaseKey = model.podDatabaseKey?.nullIfBlank;
      if (publicKey == null || databaseKey == null) {
        return null;
      }
      var config = ExistingPodConfig(
          model.podURL ?? AppSettings.defaultPodURL, privateKey, publicKey, databaseKey);
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
        await Settings.shared.set("defaults/general/isInDemoMode", _isInDemoMode);
        await cvuController.storeDefinitions();
      }
    }
  }

  // MARK: Setup
  Future<void> setupApp(
      {bool localOnly = false, VoidCallback? onPodConnected, String? predefinedKey}) async {
    var config = getSetupConfig(localOnly);
    if (config == null) {
      model.state = PodSetupState.idle;
      return;
    }

    try {
      await connectToPod(config, predefinedKey: predefinedKey);
    } on Exception catch (error) {
      model.state = PodSetupState.error;
      model.errorString = error.toString();
      return;
    }

    if (onPodConnected != null) onPodConnected();
    state = config is SetupConfigNewPod ? AppState.keySaving : AppState.authenticated;
    model.state = PodSetupState.idle;

    await importData(config).then((value) => SceneController.sceneController.scheduleUIUpdate());

    if (_podConnectionConfig != null) {
      if (config is SetupConfigNewPod) {
        _isNewPodSetup = true;
        await Settings.shared.set("defaults/pod/url", config.config.podURL);
        //TODO owner and database key should not be stored in settings
        await Settings.shared.set("defaults/pod/publicKey", _podConnectionConfig!.ownerKey);
        await Settings.shared.set("defaults/pod/databaseKey", _podConnectionConfig!.databaseKey);
      }
      await syncController.sync();
    }

    await Settings.shared.set("defaults/general/isDevelopersMode", isDevelopersMode);
    _isAuthenticated = true;
    await syncStream();
  }

  Future<void> connectToPod(SetupConfig config, {String? predefinedKey}) async {
    if (config is SetupConfigExistingPod) {
      var uri = Uri.parse(config.config.podURL);
      _podConnectionConfig = PodConnectionDetails(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: config.config.podPublicKey,
          databaseKey: config.config.podDatabaseKey);
    } else if (config is SetupConfigNewPod) {
      var uri = Uri.parse(config.config.podURL);
      var keys = await Authentication.createOwnerAndDBKey(predefinedKey);
      _podConnectionConfig = PodConnectionDetails(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: keys.publicKey,
          databaseKey: keys.dbKey);
    }

    if (_podConnectionConfig != null) {
      if (!await syncController.podIsExist(_podConnectionConfig!).timeout(
            Duration(seconds: AppSettings.checkPodExistenceTimeoutSecs),
            onTimeout: () => throw Exception("Pod doesn't respond"),
          )) {
        throw Exception("Pod doesn't respond");
      }
    }
  }

  Future<bool> checkHasBeenSetup() async =>
      await AppController.shared.databaseController.hasImportedSchema;

  // MARK: Pod connection
  Future<PodConnectionDetails?> get podConnectionConfig async {
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
        _podConnectionConfig = PodConnectionDetails(
            scheme: uri.scheme,
            host: uri.host,
            port: uri.port,
            ownerKey: ownerKey,
            databaseKey: databaseKey);
      }
      return _podConnectionConfig!;
    } on Exception catch (error) {
      AppLogger.err(error);
      return null;
    }
  }

  resetApp() async {
    await SceneController.sceneController.reset();
    if (!_isInDemoMode) {
      hasNetworkConnection = true;
      await _connectivity?.cancel();
      _connectivity = null;
      _podConnectionConfig = null;
      syncIsolate?.kill(priority: Isolate.immediate);
    }
    if (syncController.runSyncStream != null) {
      await syncController.runSyncStream!.cancel();
    }
    pubSubController.reset();
    cvuController.reset();
    await FileStorageController.deleteFileStorage();
    await databaseController.delete();
    Authentication.createRootKey();
    state = AppState.setup;
    await init();
    await SceneController.sceneController.init();

    _isAuthenticated = false;
    _isNewPodSetup = false;
    _isInDemoMode = false;
    isDevelopersMode = false;
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

  ExistingPodConfig(this.podURL, this.podPrivateKey, this.podPublicKey, this.podDatabaseKey);
}
