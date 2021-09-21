//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';

import '../ViewContextController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class AltTopBarView extends StatefulWidget {
  final memri.PageController pageController;

  AltTopBarView({required this.pageController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<AltTopBarView> {
  late ViewContextController? viewContext;

  @override
  initState() {
    super.initState();
    widget.pageController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    viewContext = widget.pageController.topMostContext;
    var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton");
    return SizedBox(
      height: 54,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (actions != null && viewContext != null)
          ...actions.map((action) => ActionButton(
                action: action,
                viewContext: viewContext!.getCVUContext(),
                pageController: widget.pageController,
              )),
        TextButton(
          onPressed: () {
            if (widget.pageController.canNavigateBack) {
              widget.pageController.navigateBack();
            } else {
              widget.pageController.topMostContext = null;
              widget.pageController.navigationStack.state = [];
              widget.pageController.scheduleUIUpdate();
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
