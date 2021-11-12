//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
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
  late Future<String?> title;

  Future<String?> get _title async {
    return await widget.pageController.topMostContext?.viewDefinitionPropertyResolver
            .string("title") ??
        (viewContext?.focusedItem != null
            ? await viewContext!.itemPropertyResolver?.string("title")
            : "");
  }

  @override
  initState() {
    super.initState();
    title = _title;
    widget.pageController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  void updateState() {
    setState(() {
      title = _title;
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    title = _title;
  }

  @override
  Widget build(BuildContext context) {
    viewContext = widget.pageController.topMostContext;
    return Container(
      height: 40,
      color: Color(0xffF4F4F4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewContext != null) ...[
              SimpleFilterPanel(viewContext: viewContext!),
              Spacer(),
              ActionButton(
                action: CVUActionOpenCVUEditor(
                    vars: {"title": CVUValueConstant(CVUConstantString("Code  >_"))}),
                viewContext: viewContext!.getCVUContext(item: viewContext!.focusedItem),
                pageController: widget.pageController,
              )
            ]
          ],
        ),
      ),
    );
  }
}
