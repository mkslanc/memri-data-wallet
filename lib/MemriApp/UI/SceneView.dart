//
//  ContentView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/TopBarView.dart';
import 'package:memri/MemriApp/UI/Navigation/MainNavigationView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';

import 'Navigation/NavigationWrapperView.dart';

/// This is the view used to display the browser content of each scene
class SceneView extends StatefulWidget {
  final SceneController sceneController;
  final showMainNavigation;

  SceneView({required this.sceneController, this.showMainNavigation = true});

  @override
  _SceneViewState createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> {
  Map<int, int> viewCols = {};
  Map<int, bool> showTopBar = {};
  int pagesCount = 0;

  init() {
    if (pagesCount != widget.sceneController.pageControllers.length) {
      pagesCount = widget.sceneController.pageControllers.length;
      viewCols = {};
    }
    widget.sceneController.pageControllers.forEachIndexed((index, pageController) {
      var viewContext = pageController.topMostContext;
      int cols = viewContext?.viewDefinitionPropertyResolver.syncInteger("cols") ??
          viewContext?.config.cols ??
          viewCols[index] ??
          (index == 0 ? 10 : 0);

      viewContext?.config.cols = cols;
      viewCols[index] = cols;

      showTopBar[index] =
          viewContext?.viewDefinitionPropertyResolver.syncBoolean("showTopBar") ?? false;
    });
  }

  @override
  initState() {
    super.initState();
    init();

    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  @override
  void didUpdateWidget(oldWidget) {
    init();
    super.didUpdateWidget(oldWidget);
  }

  updateState() {
    setState(() {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Stack(
        children: [
          LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            return NavigationWrapperView(
                sceneController: widget.sceneController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.showMainNavigation) ...[
                      Container(
                        color: Color(0xffF4F4F4),
                        height: 150,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            SizedBox(
                                height: 150,
                                child: MainNavigationView(
                                  sceneController: widget.sceneController,
                                ))
                          ],
                        ),
                      ),
                      if (widget.sceneController.pageControllers.isNotEmpty)
                        TopBarView(pageController: widget.sceneController.pageControllers.first)
                    ],
                    ColoredBox(
                      color: Colors.white,
                      child: Row(
                          children: widget.sceneController.pageControllers
                              .mapIndexed((index, pageController) => [
                                    VerticalDivider(
                                      width: 1,
                                      color: Color(0xffE5E5E5),
                                    ),
                                    ColoredBox(
                                      color: Colors.white,
                                      child: SizedBox(
                                        width: constraints.maxWidth / 10 * viewCols[index]! -
                                            (index > 0 && index == pagesCount - 1 ? 0 : 1),
                                        height: constraints.maxHeight -
                                            (widget.showMainNavigation ? 190 : 0),
                                        child: Column(
                                          children: [
                                            if (showTopBar[index]!)
                                              TopBarView(
                                                pageController: pageController,
                                              ),
                                            Expanded(
                                              child: NavigationHolder(
                                                pageController.navigationController,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ])
                              .expand((element) => element)
                              .skip(1)
                              .toList()),
                    ),
                  ],
                ));
          }),
        ],
      ),
    );
  }
}
