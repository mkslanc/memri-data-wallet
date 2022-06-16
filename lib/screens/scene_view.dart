//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.

import 'dart:math';
import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/widgets/chrome/top_bar_view.dart';
import 'package:memri/widgets/navigation/main_navigation_view.dart';
import 'package:memri/widgets/navigation/navigation_holder.dart';
import 'package:memri/widgets/navigation/navigation_wrapper_view.dart';

import '../widgets/components/memri_notification.dart';

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
  Map<int, Color> backgroundColor = {};
  int pagesCount = 0;

  init() {
    if (pagesCount != widget.sceneController.pageControllers.length) {
      pagesCount = widget.sceneController.pageControllers.length;
      viewCols = {};
    }
    widget.sceneController.pageControllers.forEachIndexed((index, pageController) {
      var viewContext = pageController.topMostContext;
      int cols = viewContext?.config.cols ??
          viewContext?.viewDefinitionPropertyResolver.syncInteger("cols") ??
          viewCols[index] ??
          (index == 0 ? 12 : 0);

      viewContext?.config.cols = cols;
      viewCols[index] = cols;

      showTopBar[index] =
          viewContext?.viewDefinitionPropertyResolver.syncBoolean("showTopBar") ?? false;
      backgroundColor[index] =
          viewContext?.viewDefinitionPropertyResolver.syncColor("background") ?? Colors.white;
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
                        color: Color(0xffF6F6F6),
                        height: 150,
                        padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                        child: Column(
                          children: [
                            SizedBox(
                                child: MainNavigationView(
                                    sceneController: widget.sceneController,
                                    currentViewName: widget.sceneController.pageControllers
                                        .asMap()[0]
                                        ?.navigationStack
                                        .state
                                        .first
                                        .config
                                        .viewName))
                          ],
                        ),
                      ),
                      if (widget.sceneController.pageControllers.isNotEmpty)
                        TopBarView(pageController: widget.sceneController.pageControllers.first),
                    ],
                    ValueListenableBuilder(
                      valueListenable: widget.sceneController.appController.lastError,
                      builder: (BuildContext context, SystemError? lastError, Widget? child) {
                        return ColoredBox(
                          color: backgroundColor.length > 0 ? backgroundColor[0]! : Colors.white,
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                if (widget.sceneController.parentSceneController == null &&
                                    lastError != null)
                                  MemriNotification(widget.sceneController.appController),
                                Row(
                                    children: widget.sceneController.pageControllers
                                        .mapIndexed((index, pageController) => [
                                              VerticalDivider(
                                                width: 1,
                                                color: Color(0xffF6F6F6),
                                              ),
                                              ColoredBox(
                                                color: backgroundColor[index]!,
                                                child: SizedBox(
                                                  width: max(
                                                      (constraints.maxWidth /
                                                              12 *
                                                              viewCols[index]! -
                                                          (index > 0 && index == pagesCount - 1
                                                              ? 0
                                                              : 1)),
                                                      0),
                                                  height: countPageHeight(constraints.maxHeight),
                                                  child: Column(
                                                    children: [
                                                      if (showTopBar[index]!)
                                                        TopBarView(
                                                          pageController: pageController,
                                                        ),
                                                      Expanded(
                                                        child: NavigationHolder(pageController
                                                            .navigationController
                                                          ..background = backgroundColor[index]!),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ])
                                        .expand((element) => element)
                                        .skip(1)
                                        .toList())
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ));
          }),
        ],
      ),
    );
  }

  countPageHeight(height) {
    var pageHeight = height;
    if (widget.sceneController.appController.shouldShowError &&
        widget.sceneController.parentSceneController == null) pageHeight -= 46;
    if (widget.showMainNavigation) pageHeight -= 190;
    return pageHeight;
  }
}
