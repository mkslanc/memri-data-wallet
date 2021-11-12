//
// NavigationView.swift
// Copyright © 2020 memri. All rights reserved.

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return body(constraints);
    });
  }

  Widget body(BoxConstraints geom) {
    //TODO: animation
    return Stack(
      children: [
        SizedBox(width: geom.maxWidth, height: geom.maxHeight, child: child),
        ValueListenableBuilder(
          builder: (BuildContext context, bool value, Widget? child) {
            if (value) {
              return Container(
                  height: 368,
                  width: geom.maxWidth,
                  color: Color(0xff4F56FE),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                    child: NavigationPaneView(sceneController: sceneController),
                  ));
            } else {
              return Empty();
            }
          },
          valueListenable: sceneController.navigationIsVisible,
        )
      ],
    );
  }

  /* Widget bodyForLargeScreen(BoxConstraints geom) {
    var navigationPanelWidth = navWidth(geom);
    return ColoredBox(
      color: Color(0xffE5E5E5),
      child: Row(
        children: [
          SizedBox(
              width: navWidth(geom),
              height: geom.maxHeight,
              child: NavigationPaneView(sceneController: sceneController)),
          Expanded(child: child),
          if (geom.maxWidth - navigationPanelWidth > 1345)
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, geom.maxWidth - navigationPanelWidth - 1345, 0))
        ],
      ),
    );
  }*/
}
