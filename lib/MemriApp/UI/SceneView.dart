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
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
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
  late Future<String?> title;

  Future<String?> get _title async {
    return await widget.sceneController.topMostContext?.viewDefinitionPropertyResolver
            .string("title") ??
        "";
  }

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
    title = _title;
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
    title = _title;
  }

  updateState() {
    setState(() {
      title = _title;
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(27, 10, 0, 10),
                  child: FutureBuilder(
                      future: title,
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            alignment: Alignment.topLeft,
                            child: Text(
                              snapshot.data!.toUpperCase(),
                              style: CVUFont.headline3,
                            ),
                          );
                        } else {
                          return Empty();
                        }
                      }),
                ),
                NavigationHolder(
                  widget.sceneController.navigationController,
                )
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
                padding: const EdgeInsets.fromLTRB(23, 35, 0, 0),
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
        ));
  }
}
