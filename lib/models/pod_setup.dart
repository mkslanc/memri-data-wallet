//  Created by T Brennan on 28/1/21.

enum PodSetupState { idle, loading, error }

/// A model struct used by the setup screen to hold configuration until the user completes the setup
class PodSetupModel {
  String? podURL;
  String? podPrivateKey;
  String? podPublicKey;
  String? podDatabaseKey;
  bool setupAsNewPod = true;
  bool useDemoData = false;

  PodSetupState state = PodSetupState.idle;
  String? errorString; //this is instead of PodSetupState error(String)
}
