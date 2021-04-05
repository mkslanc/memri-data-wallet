//
//  MainView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import 'Auth/AuthenticationScreen.dart';
import 'SceneView.dart';
import 'Setup/SetupScreenView.dart';

/// This is the view used in each scene to display the appropriate state
/// This depends on whether the app has been setup, and if the user is authenticated.
class MainView extends StatefulWidget {
  final SceneController sceneController;
  MainView({required this.sceneController});

  @override
  _MainViewState createState() => _MainViewState(sceneController);
}

class _MainViewState extends State<MainView> {
  final AppController appController = AppController.shared;
  final SceneController sceneController;
  _MainViewState(this.sceneController);

  @override
  Widget build(BuildContext context) {
    switch (appController.state) {
      case AppState.setup:
        return SetupScreenView();
      case AppState.authentication:
        return AuthenticationScreen();
      case AppState.authenticated:
        return SceneView(sceneController: sceneController);
    }
  }
}
