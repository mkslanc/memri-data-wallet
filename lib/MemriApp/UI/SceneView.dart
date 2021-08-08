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
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

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
  bool showTopBar = true;

  /// Keep track of whether the search bar is currently open (keyboard shown)
  final searchBarOpen = ValueNotifier<bool>(false);

  Future<bool> _initShowTopBar() async {
    return await widget.sceneController.topMostContext?.viewDefinitionPropertyResolver
            .boolean("showTopBar") ??
        true;
  }

  @override
  initState() {
    super.initState();
    _showTopBar = _initShowTopBar();
    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  updateState() {
    setState(() {
      _showTopBar = _initShowTopBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavigationWrapperView(
        sceneController: widget.sceneController,
        child: Stack(
          children: [
            Column(
              children: [
                FutureBuilder<bool>(
                  future: _showTopBar,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done)
                      showTopBar = snapshot.data!;
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
                NavigationHolder(widget.sceneController.navigationController)
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
                padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
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
          ],
        ));
  }
}
