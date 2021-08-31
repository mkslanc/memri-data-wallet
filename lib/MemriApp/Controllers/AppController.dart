//
//  AppController.swift
//  MemriDatabase
//
//  Created by T Brennan on 14/12/20.
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/Controllers/FileStorageController.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Controllers/Settings/Settings.dart';

import 'API/Authentication_mobile.dart';
import 'API/PodAPIConnectionDetails.dart';
import 'Database/DatabaseController.dart';
import 'PermissionController.dart';
import 'PubSubController.dart';
import 'Syncing/SyncController.dart';

enum AppState { setup, authentication, authenticated }

class AppController {
  static AppController shared = AppController();

  late DatabaseController databaseController;
  late SyncController syncController;
  late CVUController cvuController;
  late PubSubController pubsubController;
  late PermissionsController permissionController;
  late StreamSubscription? syncStream;

  ValueNotifier<AppState> _state = ValueNotifier(AppState.setup);

  get state => _state;

  set state(newValue) => _state.value = newValue;

  static String keychainDatabaseKey = "memri_databaseKey";

  PodAPIConnectionDetails? _podConnectionConfig;
  bool isInDemoMode = false;

  AppController() {
    databaseController = DatabaseController(inMemory: true);
    syncController = SyncController(databaseController);
    cvuController = CVUController();
    pubsubController = PubSubController(databaseController);
    permissionController = PermissionsController();
  }

  Future onLaunch() async {
    await updateState();
  }

  updateState() async {
    if (!await checkHasBeenSetup()) {
      state = AppState.setup;
      return;
    }
    if (!isAuthenticated) {
      state = AppState.authentication;
      await requestAuthentication();
      return;
    }

    state = AppState.authenticated;

    isInDemoMode = await Settings.shared.get<bool>("defaults/general/isInDemoMode") ?? false;
    if (!isInDemoMode) {
      syncStream = Stream.periodic(const Duration(milliseconds: 3000))
          .listen((_) => AppController.shared.syncController.sync());
    }
  }

  // MARK: Setup
  setupApp(
      {required SetupConfig config,
      bool useDemoData = true,
      required void Function(Exception? error) onCompletion}) async {
    await Future.delayed(Duration(
        milliseconds:
            200)); //TODO find the reason why setstate rebuilds widget too late without this in SetupScreenView
    try {
      if (!await databaseController.hasImportedDefaultData) {
        await connectToPod(config, () async {
          if (config is SetupConfigLocal || config is SetupConfigNewPod) {
            await databaseController.importRequiredData();
            if (useDemoData) await databaseController.setupWithDemoData();
            if (config is SetupConfigLocal) isInDemoMode = true;
            await Settings.shared.set("defaults/general/isInDemoMode", isInDemoMode);
          }
          if (_podConnectionConfig != null) {
            if (config is SetupConfigNewPod) {
              await Settings.shared.set("defaults/pod/url", config.config.podURL);
              //TODO owner and database key should not be stored in settings
              await Settings.shared.set("defaults/pod/publicKey", _podConnectionConfig!.ownerKey);
              await Settings.shared
                  .set("defaults/pod/databaseKey", _podConnectionConfig!.databaseKey);
            }

            await syncController.sync();
          }
        });
      }
    } on Exception catch (error) {
      onCompletion(error);
      return;
    }

    await updateState();
    onCompletion(null);
  }

  connectToPod(SetupConfig config, Future Function() callback) async {
    if (config is SetupConfigExistingPod) {
      var uri = Uri.parse(config.config.podURL);
      _podConnectionConfig = PodAPIConnectionDetails(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: config.config.podPublicKey,
          databaseKey: config.config.podDatabaseKey);
    } else if (config is SetupConfigNewPod) {
      var uri = Uri.parse(config.config.podURL);

      var keys = await Authentication.createOwnerAndDBKey();
      var ownerKey = keys.publicKey;
      var databaseKey = keys.dbKey;
      _podConnectionConfig = PodAPIConnectionDetails(
          scheme: uri.scheme,
          host: uri.host,
          port: uri.port,
          ownerKey: ownerKey,
          databaseKey: databaseKey);
    }

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

    await callback();
  }

  // MARK: Authentication
  bool _isAuthenticated = false; //TODO @anijanyan
  bool get isAuthenticated {
    return _isAuthenticated;
  }

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

  Future<bool> checkHasBeenSetup() async {
    if (!await AppController.shared.databaseController.hasImportedSchema) {
      return false;
    }
    return true;
  }

  // MARK: Pod connection
  Future<PodAPIConnectionDetails?> get podConnectionConfig async {
    if (isInDemoMode) return null;
    try {
      // Here you should retrieve the connection details stored in the database
      if (_podConnectionConfig == null) {
        var podURL = await Settings.shared.get("defaults/pod/url");
        var keys = await Authentication.getOwnerAndDBKey();
        var ownerKey = keys.ownerKey;
        var databaseKey = keys.dbKey;
        if (podURL == null) return null;
        var uri = Uri.parse(podURL);
        _podConnectionConfig = PodAPIConnectionDetails(
            scheme: uri.scheme,
            host: uri.host,
            port: uri.port,
            ownerKey: ownerKey,
            databaseKey: databaseKey);
      }
      return _podConnectionConfig!;
    } on Exception catch (error) {
      print(error);
      return null;
    }
  }

  resetApp() async {
    await Authentication.deleteRootKey();
    await Authentication.createRootKey();

    if (!isInDemoMode) {
      await syncStream?.cancel();
      syncStream = null;
      _podConnectionConfig = null;
    }

    await databaseController.delete();
    await FileStorageController.deleteFileStorage();
    pubsubController.reset();

    await SceneController.sceneController.reset();

    await setIsAuthenticated(false);
    isInDemoMode = false;
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
