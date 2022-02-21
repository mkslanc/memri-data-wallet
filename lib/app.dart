//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/core/apis/auth/authentication_shared.dart';
import 'package:memri/screens/authentication_screen.dart';
import 'package:memri/screens/scene_view.dart';
import 'package:memri/screens/setup/onboarding_keys.dart';
import 'package:memri/screens/setup/onboarding_start.dart';

/// This is the view used in each scene to display the appropriate state
/// This depends on whether the app has been setup, and if the user is authenticated.
class App extends StatefulWidget {
  App();

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final AppController appController = AppController.shared;
  late final SceneController sceneController;
  late Future<void> _init;
  Exception? authError;

  _AppState();

  @override
  void initState() {
    sceneController = SceneController();
    SceneController.sceneController = sceneController;
    super.initState();
    _init = init();
  }

  Future<void> init() async {
    try {
      if (await Authentication.storageDoesNotExist) {
        await Authentication.createRootKey();
      }
      await AppController.shared.init();
      await sceneController.init();
      await AppController.shared.onLaunch();
    } on Exception catch (e) {
      authError = e;
      appController.state = AppState.authentication;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
                valueListenable: appController.state,
                builder: (BuildContext context, AppState value, Widget? child) {
                  switch (value) {
                    case AppState.setup:
                      return OnboardingStart();
                    case AppState.keySaving:
                      return OnboardingKeys();
                    case AppState.authentication:
                      return AuthenticationScreen(
                          authError: authError,
                          callback: () {
                            _init = init();
                            setState(() {});
                          });
                    case AppState.authenticated:
                      return SceneView(sceneController: sceneController);
                  }
                });
          } else {
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            );
          }
        });
  }
}
