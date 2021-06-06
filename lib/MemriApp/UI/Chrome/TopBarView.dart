//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  final SceneController sceneController;

  TopBarView({required this.sceneController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  late ViewContextController? viewContext;
  late Future<String?> title;

  Future<String?> get _title async {
    return await widget.sceneController.topMostContext?.viewDefinitionPropertyResolver
            .string("title") ??
        (viewContext?.focusedItem != null
            ? await viewContext!.itemPropertyResolver?.string("title")
            : "");
  }

  @override
  initState() {
    super.initState();
    title = _title;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    title = _title;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          ValueListenableBuilder(
            builder: (BuildContext context, bool value, Widget? child) {
              viewContext = widget.sceneController.topMostContext;
              var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton");
              return ColoredBox(
                color: Color(0xfff2f2f7),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: space(4, [
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          widget.sceneController.navigationIsVisible.value = true,
                                      icon: Icon(Icons.dehaze),
                                      padding: EdgeInsets.all(10),
                                    ),
                                    if (widget.sceneController.canNavigateBack)
                                      IconButton(
                                        onPressed: () {
                                          widget.sceneController.navigateBack();
                                          widget.sceneController.isInEditMode.value = false;
                                        },
                                        icon: Icon(Icons.arrow_back),
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                          FutureBuilder(
                              future: title,
                              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                if (snapshot.hasData) {
                                  return Expanded(
                                      child: Center(
                                    child: Text(
                                      snapshot.data!,
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                    ),
                                  ));
                                } else {
                                  return Spacer();
                                }
                              }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: 100),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FutureBuilder<List<String>?>(
                                      future: widget.sceneController.topMostContext
                                          ?.viewDefinitionPropertyResolver
                                          .stringArray("editActionButton"),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          var editAction = snapshot.data?.asMap()[0];
                                          var action = cvuAction(editAction ?? "");
                                          if (action != null) {
                                            return ActionButton(
                                                action: action(vars: {
                                                  "icon":
                                                      CVUValueConstant(CVUConstantString("pencil"))
                                                }),
                                                viewContext: viewContext!.getCVUContext());
                                          }
                                        }
                                        return Empty();
                                      }),
                                  if (actions != null)
                                    ...actions.map((action) => ActionButton(
                                        action: action, viewContext: viewContext!.getCVUContext()))
                                ],
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                            ),
                          )
                        ]),
                      ),
                    )
                  ],
                ),
              );
            },
            valueListenable: widget.sceneController.shouldUpdate,
          ),
          Divider(
            height: 1,
          )
        ],
      ),
    );
  }
}
