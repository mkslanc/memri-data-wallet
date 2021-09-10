//
// NavigationView.swift
// Copyright © 2020 memri. All rights reserved.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationPaneView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// This view manages displaying the navigation pane, as well as its gestures
class NavigationWrapperView extends StatelessWidget {
  final SceneController sceneController;

  final Widget child;
  final double offset = 0; //TODO
  final double widthRatio = 0.8;

  NavigationWrapperView({required this.sceneController, required this.child});

  double navWidth(BoxConstraints geom) {
    return 93;
  }

  double cappedOffset(BoxConstraints geom) {
    if (sceneController.navigationIsVisible.value) {
      return max(min(0, offset), -navWidth(geom));
    } else {
      return min(max(0, offset), navWidth(geom));
    }
  }

  double fractionVisible(BoxConstraints geom) {
    var fraction = cappedOffset(geom).abs() / navWidth(geom);
    return sceneController.navigationIsVisible.value ? 1 - fraction : fraction;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 714) {
        sceneController.isBigScreen = true;
        return bodyForLargeScreen(constraints);
      } else {
        return body(constraints);
      }
    });
  }

  Widget body(BoxConstraints geom) {
    //TODO: animation
    return Stack(
      children: [
        SizedBox(width: geom.maxWidth, height: geom.maxHeight, child: child),
        ValueListenableBuilder(
          builder: (BuildContext context, bool value, Widget? child) {
            if (value || offset > 0) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => sceneController.navigationIsVisible.value = false,
                    child: SizedBox(
                      width: geom.maxWidth,
                      height: geom.maxHeight,
                      child: ColoredBox(
                        color: Color.fromRGBO(0, 0, 0, fractionVisible(geom) * 0.5),
                      ),
                    ),
                  ),
                  SizedBox(
                      width: navWidth(geom),
                      height: geom.maxHeight,
                      child: NavigationPaneView(sceneController: sceneController))
                ],
              );
            } else {
              return Empty();
            }
          },
          valueListenable: sceneController.navigationIsVisible,
        )
      ],
    );
  }

  Widget bodyForLargeScreen(BoxConstraints geom) {
    var navigationPanelWidth = navWidth(geom);
    return Row(
      children: [
        SizedBox(
            width: navWidth(geom),
            height: geom.maxHeight,
            child: NavigationPaneView(sceneController: sceneController)),
        SizedBox(width: geom.maxWidth - navigationPanelWidth, height: geom.maxHeight, child: child),
      ],
    );
  }
}
