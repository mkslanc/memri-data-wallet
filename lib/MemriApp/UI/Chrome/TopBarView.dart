//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  final SceneController sceneController;
  final void Function() onSearchPressed;

  TopBarView({required this.sceneController, required this.onSearchPressed});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
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
    viewContext = widget.sceneController.topMostContext;
    var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton");
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(children: [
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        if (!widget.sceneController.canNavigateBack)
                          TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.all(27)),
                            onPressed: () {},
                            child: Icon(
                              Icons.dehaze,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: 78,
                  child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                    onPressed: widget.onSearchPressed,
                    child: Row(
                      children: [
                        Text(
                          "Search in App",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: CVUColor.textGrey),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 100),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder<List<String>?>(
                          future: widget
                              .sceneController.topMostContext?.viewDefinitionPropertyResolver
                              .stringArray("editActionButton"),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              var editAction = snapshot.data?.asMap()[0];
                              var action = cvuAction(editAction ?? "");
                              if (action != null) {
                                return ActionButton(
                                    action: action(vars: {
                                      "icon": CVUValueConstant(CVUConstantString("pencil"))
                                    }),
                                    viewContext: viewContext!.getCVUContext());
                              }
                            }
                            return Empty();
                          }),
                      if (actions != null)
                        ...actions.map((action) =>
                            ActionButton(action: action, viewContext: viewContext!.getCVUContext()))
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                ),
              ),
            ]),
          ),
          Divider(
            height: 1,
          ),
        ],
      ),
    );
  }
}
