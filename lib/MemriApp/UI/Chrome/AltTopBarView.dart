//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class AltTopBarView extends StatefulWidget {
  final SceneController sceneController;

  AltTopBarView({required this.sceneController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<AltTopBarView> {
  late ViewContextController? viewContext;

  @override
  initState() {
    super.initState();
    widget.sceneController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    viewContext = widget.sceneController.mainPageController.topMostContext;
    //var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton"); TODO: we will need it later
    return SizedBox(
      height: 54,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        TextButton(
          onPressed: () {
            if (widget.sceneController.secondaryPageController.canNavigateBack) {
              widget.sceneController.secondaryPageController.navigateBack();
            } else {
              widget.sceneController.secondaryPageController.topMostContext = null;
              widget.sceneController.secondaryPageController.navigationStack.state = [];
              widget.sceneController.secondaryPageController.scheduleUIUpdate();
            }
          },
          child: Icon(
            Icons.close,
            color: Color(0xffDFDEDE),
          ),
        )
      ]),
    );
  }
}
