//
//  ContentView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/AltTopBarView.dart';
import 'package:memri/MemriApp/UI/Chrome/TopBarView.dart';
import 'package:memri/MemriApp/UI/FilterPanel/FilterPanelView.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationWrapperView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

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
    mainViewCols = widget
        .sceneController.mainPageController.topMostContext?.viewDefinitionPropertyResolver
        .syncInteger("cols");
    secondaryViewCols = widget
        .sceneController.secondaryPageController.topMostContext?.viewDefinitionPropertyResolver
        .syncInteger("cols");
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
      child: NavigationWrapperView(
          sceneController: widget.sceneController,
          child: Stack(
            children: [
              LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColoredBox(
                      color: Colors.white,
                      child: SizedBox(
                        width: mainViewCols != null
                            ? constraints.maxWidth / 10 * mainViewCols! - 1
                            : constraints.maxWidth - 1,
                        height: constraints.maxHeight,
                        child: Column(
                          children: [
                            showTopBar
                                ? TopBarView(
                                    pageController: widget.sceneController.mainPageController,
                                  )
                                : Empty(),
                            Expanded(
                              child: NavigationHolder(
                                widget.sceneController.mainPageController.navigationController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      color: Color(0xffE5E5E5),
                    ),
                    ColoredBox(
                      color: Colors.white,
                      child: SizedBox(
                        width: secondaryViewCols != null
                            ? constraints.maxWidth / 10 * secondaryViewCols!
                            : 0,
                        child: Column(
                          children: [
                            if (widget.sceneController.secondaryPageController.topMostContext !=
                                null)
                              AltTopBarView(
                                  pageController: widget.sceneController.secondaryPageController),
                            Expanded(
                              child: NavigationHolder(
                                widget.sceneController.secondaryPageController.navigationController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
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
          )),
    );
  }
}
