//
//  AppController.swift
//  MemriDatabase
//
//  Created by T Brennan on 14/12/20.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:uuid/uuid.dart';

import 'API/PodAPIConnectionDetails.dart';
import 'Database/DatabaseController.dart';
import 'Syncing/SyncController.dart';

enum AppState { setup, authentication, authenticated }

class AppController {
  static AppController shared = AppController();

  late DatabaseController databaseController;
  late SyncController syncController;
  late CVUController cvuController;

  ValueNotifier<AppState> _state = ValueNotifier(AppState.setup);
  get state => _state;
  set state(newValue) => _state.value = newValue;

  static String keychainDatabaseKey = "memri_databaseKey";

  AppController() {
    databaseController = DatabaseController(inMemory: false);
    syncController = SyncController(databaseController);
    cvuController = CVUController();
    cvuController.init();
  }

  void onLaunch() {
    requestAuthentication();
  }

  updateState() async {
    if (!await checkHasBeenSetup()) {
      state = AppState.setup;
      return;
    }
    if (!isAuthenticated) {
      state = AppState.authentication;
      requestAuthentication();
      return;
    }

    state = AppState.authenticated;
  }

  // MARK: Setup
  setupApp(SetupConfig config, void Function(Exception? error) onCompletion) async {
    if (config is SetupConfigLocal || config is SetupConfigNewPod) {
      try {
        if (await databaseController.databaseIsSetup) {
          // If there is already data set up, don't import
          onCompletion(null);
        } else {
          if (config is SetupConfigNewPod) {
            var uri = Uri.parse(config.config.podURL);
            var connectionConfig =
                PodAPIConnectionDetails(scheme: uri.scheme, host: uri.host, port: uri.port);
            if (await syncController.podIsExist(connectionConfig)) {
              await databaseController.setupWithDemoData();
              await syncController.sync(connectionConfig: connectionConfig);
            } else {
              throw Exception("Pod doesn't respond");
            }
          } else {
            await databaseController.setupWithDemoData();
          }
        }
      } on Exception catch (error) {
        onCompletion(error);
        return;
      }
    }

    /// During this setup function would be a good place to generate a database encryption key, create a new database with this key, and then import the demo data.
    /// NOTE: This is a temporary placehold until encryption is implemented.
    /// - UUID is not a good option for a randomly generated key, should use an existing generator from CryptoKit
    var newDatabaseEncryptionKey = Uuid().v4();
    setHasBeenSetup(newDatabaseEncryptionKey);
    onCompletion(null);
  }

  // MARK: Authentication
  bool _isAuthenticated = false; //TODO @anijanyan
  bool get isAuthenticated {
    return _isAuthenticated;
  }

  set isAuthenticated(bool newValue) {
    if (_isAuthenticated != newValue) {
      _isAuthenticated = newValue;
      updateState();
    }
  }

  requestAuthentication() async {
    if (!await checkHasBeenSetup()) {
      return;
    }
    isAuthenticated = true;
    // var dbKey = Keychain().getString(AppController.keychainDatabaseKey);
    //TODO @anijanyan
    /*if (dbKey != null) {
        print(`GOT KEY: $dbKey`);
        isAuthenticated = true;
    } else {
        isAuthenticated = false;
        print("NEEDS AUTH");
    }*/
  }

  Future<bool> checkHasBeenSetup() async {
    /*if (!(new Keychain().contains(AppController.keychainDatabaseKey, true))) {
        return false
    }*/
    if (!await AppController.shared.databaseController.databaseIsSetup) {
      return false;
    }
    return true;
  }

  setHasBeenSetup(String? databaseKey) {
    if (databaseKey != null) {
      // Keychain().set(databaseKey, key: AppController.keychainDatabaseKey);
    } else {
      // Keychain().remove(AppController.keychainDatabaseKey);
    }
    updateState();
  }

  // MARK: Pod connection
  PodAPIConnectionDetails? get podConnectionConfig {
    try {
      // Here you should retrieve the connection details stored in the database
      return PodAPIConnectionDetails();
    } on Exception catch (error) {
      print(error);
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

  ExistingPodConfig(this.podURL, this.podPrivateKey, this.podPublicKey, this.podDatabaseKey);
}
