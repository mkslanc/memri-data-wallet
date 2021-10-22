//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
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
    var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton") ?? [];
    actions.insert(
        0, CVUActionOpenCVUEditor(vars: {"title": CVUValueConstant(CVUConstantString("Script"))}));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 54,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (actions.isNotEmpty && viewContext != null)
              ...actions.map((action) => ActionButton(
                    action: action,
                    viewContext: viewContext!.getCVUContext(item: viewContext!.focusedItem),
                    pageController: widget.pageController,
                  )),
            TextButton(
              onPressed: () {
                widget.pageController.navigateBack();
              },
              child: Icon(
                Icons.close,
                color: Color(0xffDFDEDE),
              ),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FutureBuilder(
              future: title,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData && snapshot.data != "") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        snapshot.data!,
                        style: CVUFont.headline2,
                      ),
                      SizedBox(
                        height: 27,
                      ),
                    ],
                  );
                } else {
                  return Text("");
                }
              }),
        ),
      ],
    );
  }
}
