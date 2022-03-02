//  Created by T Brennan on 14/12/20.

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:memri/constants/app_logger.dart';
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
import 'package:memri/models/ui/setup_model.dart';
import 'package:path_provider/path_provider.dart';

enum AppState { setup, keySaving, authentication, authenticated }

class AppController {
  static AppController shared = AppController();

  late DatabaseController databaseController;
  late SyncController syncController;
  late CVUController cvuController;
  late PubSubController pubSubController;
  late PermissionsController permissionController;
  late SetupScreenModel model;

  StreamSubscription? syncStreamSub;
  Isolate? syncIsolate;
  ValueNotifier<AppState> _state = ValueNotifier(AppState.setup);
  PodConnectionDetails? _podConnectionConfig;

  bool isDevelopersMode = false;
  bool _isInDemoMode = false;
  bool _isNewPodSetup = false;

  // MARK: Authentication
  bool _isAuthenticated = false; //TODO @anijanyan

  ValueNotifier<AppState> get state => _state;

  set state(newValue) => _state.value = newValue;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> setIsAuthenticated(bool newValue) async {
    if (_isAuthenticated != newValue) {
      _isAuthenticated = newValue;
      await updateState();
    }
  }

  requestAuthentication() async {
    if (!await checkHasBeenSetup()) {
      return;
    }
    await setIsAuthenticated(true);
  }

  bool get isOwnerKeyExist =>
      _podConnectionConfig?.ownerKey != null && _podConnectionConfig!.ownerKey.length > 12;

  AppController() {
    databaseController = DatabaseController(inMemory: false);
    syncController = SyncController(databaseController);
    cvuController = CVUController(databaseController);
    pubSubController = PubSubController(databaseController);
    permissionController = PermissionsController();
    model = SetupScreenModel();
  }

  Future init() async {
    await databaseController.init();
    await cvuController.init();
  }

  Future<void> updateState() async {
    if (!await checkHasBeenSetup()) {
      state = AppState.setup;
      return;
    }
    if (!isAuthenticated) {
      state = AppState.authentication;
      await requestAuthentication();
      return;
    }

    if (_isNewPodSetup) {
      state = AppState.keySaving;
    } else {
      state = AppState.authenticated;
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
            syncController.runSync,
            IsolateSyncConfig(
                port: receivePort.sendPort,
                connection: connection,
                schema: databaseController.schema,
                documentsDirectory: documentsDirectory,
                rootKey: Authentication.lastRootPublicKey,
                isolate: databaseController.driftIsolate!));
      } else {
        syncController
            .runSync(SyncConfig(connection: connection, schema: databaseController.schema));
      }
    }

    isDevelopersMode =
        await Settings.shared.get<bool>("defaults/general/isDevelopersMode") ?? false;
  }

  Future<void> importData(SetupConfig config) async {
    if (!await databaseController.hasImportedDefaultData) {
      if (config is SetupConfigLocal || config is SetupConfigNewPod) {
        databaseController.importRequiredData();
        if (model.useDemoData) await databaseController.setupWithDemoData();
        if (config is SetupConfigLocal) _isInDemoMode = true;
        await Settings.shared.set("defaults/general/isInDemoMode", _isInDemoMode);
        await cvuController.storeDefinitions();
      }
    }
  }

  // MARK: Setup
  Future<void> setupApp({bool localOnly = false}) async {
    var config = model.getSetupConfig(localOnly);
    if (config == null) {
      model.state = PodSetupState.idle;
      return;
    }

    try {
      await connectToPod(config);
      await importData(config);
    } on Exception catch (error) {
      model.state = PodSetupState.error;
      model.errorString = error.toString();
      return;
    }

    if (_podConnectionConfig != null) {
      if (config is SetupConfigNewPod) {
        await Settings.shared.set("defaults/pod/url", config.config.podURL);
        //TODO owner and database key should not be stored in settings
        await Settings.shared.set("defaults/pod/publicKey", _podConnectionConfig!.ownerKey);
        await Settings.shared.set("defaults/pod/databaseKey", _podConnectionConfig!.databaseKey);
        _isNewPodSetup = true;
      }
      if (_isInDemoMode) await syncController.sync();
    }

    await Settings.shared.set("defaults/general/isDevelopersMode", isDevelopersMode);
    _isAuthenticated = true;
    await syncStream();
  }

  Future<void> connectToPod(SetupConfig config) async {
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
      var keys = await Authentication.createOwnerAndDBKey();
      _podConnectionConfig = PodConnectionDetails(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: keys.publicKey,
          databaseKey: keys.dbKey);
    }
    state = config is SetupConfigNewPod ? AppState.keySaving : AppState.authenticated;
    model.state = PodSetupState.idle;

    if (_podConnectionConfig != null) {
      if (!await syncController.podIsExist(_podConnectionConfig!).timeout(
        Duration(seconds: 3),
        onTimeout: () {
          throw Exception("Pod doesn't respond");
        },
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
    state = AppState.setup;
    Authentication.createRootKey();

    await SceneController.sceneController.reset();
    if (!_isInDemoMode) {
      await syncStreamSub?.cancel();
      syncStreamSub = null;
      _podConnectionConfig = null;
      syncIsolate?.kill(priority: Isolate.immediate);
    }
    await FileStorageController.deleteFileStorage();
    await databaseController.delete();

    if (syncController.runSyncStream != null) {
      syncController.runSyncStream!.cancel();
    }

    pubSubController.reset();
    cvuController.reset();

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
