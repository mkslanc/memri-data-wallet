//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import '../ViewContextController.dart';

/// This view contains the contents of the 'Bottom bar' which is shown below renderer content.
class BottomBarView extends StatefulWidget {
  final ViewContextController viewContext;

  final void Function() onSearchPressed;

  BottomBarView({required this.viewContext, required this.onSearchPressed});

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  late Future<List<Widget>>? actionButtons;

  @override
  initState() {
    super.initState();
    actionButtons = _getActionButtons();
  }

  Future<List<Widget>>? _getActionButtons() async {
    List<Widget> buttons = [];

    List<CVUAction> actions = [];
    if (widget.viewContext.focusedItem != null) {
      actions = widget.viewContext.itemPropertyResolver?.actions("filterButtons") ?? [];
    }

    if (actions.isNotEmpty) {
      buttons = actions.map((action) {
        return ActionButton(
            action: action,
            viewContext: widget.viewContext.getCVUContext(item: widget.viewContext.focusedItem));
      }).toList();
    } else {
      var filterButtons =
          await widget.viewContext.viewDefinitionPropertyResolver.stringArray("filterButtons");
      buttons = filterButtons.compactMap((el) {
        var action = cvuAction(el);
        if (action != null) {
          return ActionButton(
              action: action(vars: <String, CVUValue>{}),
              viewContext: widget.viewContext.getCVUContext());
        }
        return null;
      });
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(
        height: 1,
      ),
      ColoredBox(
        color: CVUColor.system("secondarySystemBackground"),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ValueListenableBuilder(
              valueListenable: widget.viewContext.searchStringNotifier,
              builder: (BuildContext context, String? filter, Widget? child) {
                return Row(
                    children: space(4, [
                  Row(
                      children: space(4, [
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.fromLTRB(10, 10, 0, 10)),
                      onPressed: widget.onSearchPressed,
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 7),
                            child: Icon(Icons.search),
                          ),
                          if (filter != null)
                            Text(
                              filter,
                              style: TextStyle(fontSize: 12, color: CVUColor.system("label")),
                            )
                        ],
                      ),
                    ),
                    if (filter != null)
                      IconButton(
                        onPressed: () => widget.viewContext.searchString = null,
                        icon: Icon(
                          Icons.clear,
                          size: 12,
                        ),
                      )
                  ])),
                  Spacer(),
                  if (actionButtons != null)
                    FutureBuilder(
                        future: actionButtons,
                        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              List<Widget> buttons = snapshot.data!;
                              return Row(children: buttons);
                            }
                          }
                          return Empty();
                        })
                ]));
              }),
        ),
      )
    ]);
  }
}
