//
//  MainView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AddressBookController.dart';
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
    return ValueListenableBuilder(
        valueListenable: appController.state,
        builder: (BuildContext context, AppState value, Widget? child) {
          switch (value) {
            case AppState.setup:
              return SetupScreenView();
            case AppState.authentication:
              return AuthenticationScreen();
            case AppState.authenticated:
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Contacts importing'),
                    content: const Text('Do you want to import contacts from Android Contacts?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          await AddressBookController.sync();
                          Navigator.pop(context, 'OK');
                        },
                        child: const Text('OK'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              });

              //TODO: this should not run without pod
              Stream.periodic(const Duration(milliseconds: 10000))
                  .listen((_) => AppController.shared.syncController.sync());
              return SceneView(sceneController: sceneController);
          }
        });
  }
}
