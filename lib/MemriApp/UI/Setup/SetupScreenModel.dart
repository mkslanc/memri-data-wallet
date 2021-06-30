//
//  SetupScreenModel.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

/// A model struct used by the setup screen to hold configuration until the user completes the setup
class SetupScreenModel {
  var defaultPodURL = "http://localhost:3030";
  String? podURL;
  String? podPrivateKey;
  String? podPublicKey;
  String? podDatabaseKey;
  bool setupAsNewPod = true;
  bool useDemoData = true;

  PodSetupState state = PodSetupState.idle;
  String? errorString; //this is instead of PodSetupState error(String)

  String getPodURL() {
    return podURL?.nullIfBlank ?? defaultPodURL;
  }

  bool get isValidToProceedToConnect {
    if (setupAsNewPod) {
      return true;
    }

    if (podPrivateKey?.nullIfBlank == null ||
        podPublicKey?.nullIfBlank == null ||
        podDatabaseKey == null) {
      return false;
    }
    return true;
  }

  SetupConfig? getSetupConfig(bool localOnly) {
    if (localOnly) {
      return SetupConfigLocal();
    } else if (this.setupAsNewPod) {
      var config = NewPodConfig(podURL ?? defaultPodURL);
      return SetupConfigNewPod(config);
    } else {
      var privateKey = this.podPrivateKey?.nullIfBlank;
      var publicKey = this.podPublicKey?.nullIfBlank;
      var databaseKey = this.podDatabaseKey?.nullIfBlank;
      if (privateKey == null || publicKey == null || databaseKey == null) {
        return null;
      }
      var config = ExistingPodConfig(podURL ?? defaultPodURL, privateKey, publicKey, databaseKey);
      return SetupConfigExistingPod(config);
    }
  }
}

enum PodSetupState { idle, loading, error }
