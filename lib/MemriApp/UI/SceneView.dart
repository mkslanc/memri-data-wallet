//
//  ContentView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/TopBarView.dart';
import 'package:memri/MemriApp/UI/FilterPanel/FilterPanelView.dart';
import 'package:memri/MemriApp/UI/Navigation/MainNavigationView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'Navigation/NavigationWrapperView.dart';

/// This is the view used to display the browser content of each scene
class SceneView extends StatefulWidget {
  final SceneController sceneController;

  SceneView({required this.sceneController});

  @override
  _SceneViewState createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> {
  final double filterPanelGestureOffset = 0;
  bool showTopBar = true;
  int? mainViewCols;
  int? secondaryViewCols;

  init() {
    var mainContext = widget.sceneController.mainPageController.topMostContext;
    var secondaryContext = widget.sceneController.secondaryPageController.topMostContext;

    mainViewCols =
        mainContext?.viewDefinitionPropertyResolver.syncInteger("cols") ?? mainContext?.config.cols;
    mainContext?.config.cols = mainViewCols;
    secondaryViewCols = secondaryContext != null
        ? secondaryContext.viewDefinitionPropertyResolver.syncInteger("cols") ??
            secondaryContext.config.cols ??
            secondaryViewCols
        : null;

    secondaryContext?.config.cols = secondaryViewCols;

    showTopBar = widget
            .sceneController.mainPageController.topMostContext?.viewDefinitionPropertyResolver
            .syncBoolean("showTopBar") ??
        true;
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
                    ColoredBox(
                      color: Colors.white,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight - 190,
                        child: Column(
                          children: [
                            TopBarView(
                              pageController: widget.sceneController.mainPageController,
                            ),
                            Expanded(
                              child: NavigationHolder(
                                widget.sceneController.mainPageController.navigationController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ));
          }),
          ValueListenableBuilder(
            builder: (BuildContext context, bool value, Widget? child) {
              var currentContext = widget.sceneController.mainPageController.topMostContext;
              if (value && currentContext != null) {
                return Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    GestureDetector(
                      onTap: () => widget.sceneController.filterPanelIsVisible.value = false,
                      child: ColoredBox(
                        color: Colors.black45,
                        child: SizedBox.expand(),
                      ),
                    ),
                    FilterPanelView(viewContext: currentContext)
                  ],
                );
              } else {
                return Empty();
              }
            },
            valueListenable: widget.sceneController.filterPanelIsVisible,
          ),
          if (widget.sceneController.mainPageController.canNavigateBack)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 0, 0),
              child: SizedBox(
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  onPressed: () {
                    widget.sceneController.mainPageController.navigateBack();
                  },
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
