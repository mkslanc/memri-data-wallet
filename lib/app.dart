//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
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
  Exception? authError;
  bool _isInitializing = true;

  _AppState();

  @override
  void initState() {
    SceneController.sceneController = SceneController();
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      await AppController.shared.init();
      await SceneController.sceneController.init();
      await AppController.shared.updateState();
    } on Exception catch (e) {
      authError = e;
      appController.state = AppState.authentication;
    }
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()));
    }
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
                  setState(() {
                    _isInitializing = true;
                  });
                  init();
                });
          case AppState.authenticated:
            return SceneView(sceneController: SceneController.sceneController);
        }
      },
    );
  }
}
