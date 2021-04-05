//
// NavigationView.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationPaneView.dart';

/// This view manages displaying the navigation pane, as well as its gestures
class NavigationWrapperView extends StatelessWidget {
  final SceneController sceneController;

  final Widget child;
  final double offset = 0; //TODO

  NavigationWrapperView({required this.sceneController, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        ValueListenableBuilder(
          builder: (BuildContext context, bool value, Widget? child) {
            if (value || offset > 0) {
              return Stack(
                children: [
                  ColoredBox(
                    color: Colors.black12,
                  ),
                  NavigationPaneView(sceneController: sceneController)
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          },
          valueListenable: sceneController.navigationIsVisible,
        )
      ],
    );
  }
}
