//
//  SetupScreenModel.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:uuid/uuid.dart';

/// A model struct used by the setup screen to hold configuration until the user completes the setup
class SetupScreenModel {
  String? podURL;
  String? podPrivateKey;
  String? podPublicKey;
  String? podDatabaseKey;
  bool setupAsNewPod = true;
  bool useDemoData = false;

  PodSetupState state = PodSetupState.idle;
  String? errorString; //this is instead of PodSetupState error(String)

  String getPodURL() {
    return podURL?.nullIfBlank ?? AppSettings.defaultPodURL;
  }

  bool get isValidToProceedToConnect {
    if (setupAsNewPod) {
      return true;
    }

    if (podPublicKey?.nullIfBlank == null || podDatabaseKey == null) {
      return false;
    }
    return true;
  }

  SetupConfig? getSetupConfig(bool localOnly) {
    if (localOnly) {
      return SetupConfigLocal();
    } else if (this.setupAsNewPod) {
      var config = NewPodConfig(podURL ?? AppSettings.defaultPodURL);
      return SetupConfigNewPod(config);
    } else {
      var privateKey =
          this.podPrivateKey?.nullIfBlank ?? Uuid().v4(); //TODO: kill when we will have end-to-end
      var publicKey = this.podPublicKey?.nullIfBlank;
      var databaseKey = this.podDatabaseKey?.nullIfBlank;
      if (publicKey == null || databaseKey == null) {
        return null;
      }
      var config = ExistingPodConfig(podURL ?? AppSettings.defaultPodURL, privateKey, publicKey, databaseKey);
      return SetupConfigExistingPod(config);
    }
  }
}

enum PodSetupState { idle, loading, error }
