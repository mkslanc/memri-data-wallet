//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/Chrome/BreadCrumbs.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/FilterPanel/SimpleFilterPanel.dart';

import '../ViewContextController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  final memri.PageController pageController;

  TopBarView({required this.pageController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  late ViewContextController? viewContext;
  late Future<void> _init;

  Color? backgroundColor = Color(0xffF4F4F4);
  bool showEditCode = false;

  @override
  initState() {
    super.initState();
    _init = init();
    widget.pageController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  void updateState() {
    setState(() {
      _init = init();
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  Future<void> init() async {
    var viewContext = widget.pageController.topMostContext;

    backgroundColor =
        await viewContext?.viewDefinitionPropertyResolver.color("tobBarColor") ?? Color(0xffF4F4F4);
    showEditCode =
        await viewContext?.viewDefinitionPropertyResolver.boolean("showEditCode") ?? true;
  }

  @override
  Widget build(BuildContext context) {
    viewContext = widget.pageController.topMostContext;
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => Container(
        height: 40,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewContext != null) ...[
                SimpleFilterPanel(viewContext: viewContext!),
                BreadCrumbs(viewContext: viewContext!, pageController: widget.pageController),
                Spacer(),
                if (showEditCode) ...[
                  ActionButton(
                    action: CVUActionOpenCVUEditor(
                        vars: {"title": CVUValueConstant(CVUConstantString("Code  >_"))}),
                    viewContext: viewContext!.getCVUContext(item: viewContext!.focusedItem),
                    pageController: widget.pageController,
                  )
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}
