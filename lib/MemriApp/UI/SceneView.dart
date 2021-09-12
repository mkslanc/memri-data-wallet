//
//  ContentView.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/TopBarView.dart';
import 'package:memri/MemriApp/UI/FilterPanel/FilterPanelView.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationWrapperView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'Chrome/BottomBarView.dart';
import 'Chrome/SearchView.dart';

/// This is the view used to display the browser content of each scene
class SceneView extends StatefulWidget {
  final SceneController sceneController;

  SceneView({required this.sceneController});

  @override
  _SceneViewState createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> {
  final double filterPanelGestureOffset = 0;
  late Future<bool> _showTopBar;
  late Future<bool> _showBottomBar;
  bool showTopBar = true;
  bool showBottomBar = true;

  /// Keep track of whether the search bar is currently open (keyboard shown)
  final searchBarOpen = ValueNotifier<bool>(false);

  Future<bool> _initShowTopBar() async {
    return await widget.sceneController.topMostContext?.viewDefinitionPropertyResolver
            .boolean("showTopBar") ??
        true;
  }

  Future<bool> _initShowBottomBar() async {
    var viewContext = widget.sceneController.topMostContext;
    var subViewShowBottomBar = await viewContext?.viewDefinitionPropertyResolver
        .subdefinition("arguments")
        ?.boolean("showBottomBar");
    return await viewContext?.viewDefinitionPropertyResolver.boolean("showBottomBar") ??
        subViewShowBottomBar ??
        true;
  }

  CVUDefinitionContent? get bottomBar {
    var viewContext = widget.sceneController.topMostContext;
    var bottomBarDef = widget.sceneController.topMostContext?.cvuController
        .viewDefinitionFor(
            viewName: viewContext?.config.viewName ?? viewContext?.config.rendererName ?? "")
        ?.properties["bottomBar"];

    var bottomBarSubdef = bottomBarDef?.getSubdefinition();

    return bottomBarSubdef;
  }

  @override
  initState() {
    super.initState();
    _showTopBar = _initShowTopBar();
    _showBottomBar = _initShowBottomBar();
    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  updateState() {
    setState(() {
      _showTopBar = _initShowTopBar();
      _showBottomBar = _initShowBottomBar();
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicWidth(
                    child: Column(
                      children: [
                        FutureBuilder<bool>(
                          future: _showTopBar,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done)
                              showTopBar = snapshot.data!;
                            widget.sceneController.showTopBar = showTopBar;
                            return showTopBar
                                ? ValueListenableBuilder<bool>(
                                    builder: (BuildContext context, value, Widget? child) {
                                      var currentContext = widget.sceneController.topMostContext;
                                      return value
                                          ? SearchView(
                                              viewContext: currentContext!, isActive: searchBarOpen)
                                          : TopBarView(
                                              sceneController: widget.sceneController,
                                              onSearchPressed: () {
                                                searchBarOpen.value = true;
                                              },
                                            );
                                    },
                                    valueListenable: searchBarOpen)
                                : Empty();
                          },
                        ),
                        Expanded(
                          child: NavigationHolder(
                            widget.sceneController.navigationController,
                          ),
                        ),
                        FutureBuilder<bool>(
                            future: _showBottomBar,
                            builder: (BuildContext builder, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                showBottomBar = snapshot.data!;
                              }
                              if (showBottomBar) {
                                var nodeDefinition = bottomBar;
                                if (nodeDefinition == null) {
                                  return BottomBarView(
                                    viewContext: widget.sceneController.topMostContext!,
                                  );
                                } else {
                                  return widget.sceneController.topMostContext!
                                      .render(nodeDefinition: nodeDefinition);
                                }
                              }
                              return Empty();
                            })
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2 - 93),
                    child: IntrinsicWidth(
                      child: NavigationHolder(
                        widget.sceneController.secondaryNavigationController,
                      ),
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                builder: (BuildContext context, bool value, Widget? child) {
                  var currentContext = widget.sceneController.topMostContext;
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
              if (widget.sceneController.canNavigateBack)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 0, 0),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      onPressed: () {
                        widget.sceneController.navigateBack();
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
