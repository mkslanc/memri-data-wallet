//
//  MainView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/API/Authentication_shared.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Setup/OnboardingStart.dart';

import 'Auth/AuthenticationScreen.dart';
import 'SceneView.dart';
import 'Setup/OnboardingKeys.dart';

/// This is the view used in each scene to display the appropriate state
/// This depends on whether the app has been setup, and if the user is authenticated.
class MainView extends StatefulWidget {
  MainView();

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final AppController appController = AppController.shared;
  late final SceneController sceneController;
  late Future<void> _init;
  Exception? authError;

  _MainViewState();

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
