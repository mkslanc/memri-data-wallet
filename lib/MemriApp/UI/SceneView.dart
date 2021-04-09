//
//  ContentView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/TopBarView.dart';
import 'package:memri/MemriApp/UI/FilterPanel/FilterPanelView.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationWrapperView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';

/// This is the view used to display the browser content of each scene
class SceneView extends StatelessWidget {
  final SceneController sceneController;
  final double filterPanelGestureOffset = 0;

  SceneView({required this.sceneController});

  @override
  Widget build(BuildContext context) {
    return NavigationWrapperView(
        sceneController: sceneController,
        child: Stack(
          children: [
            Column(
              children: [
                TopBarView(sceneController: sceneController),
                NavigationHolder(sceneController.navigationController)
              ],
            ),
            ValueListenableBuilder(
              builder: (BuildContext context, bool value, Widget? child) {
                var currentContext = sceneController.topMostContext;
                if (value && currentContext != null) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      GestureDetector(
                        onTap: () => sceneController.filterPanelIsVisible.value = false,
                        child: ColoredBox(
                          color: Colors.black45,
                          child: SizedBox.expand(),
                        ),
                      ),
                      FilterPanelView(viewContext: currentContext)
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
              valueListenable: sceneController.filterPanelIsVisible,
            ),
          ],
        ));
  }
}
