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
class BottomBarView extends StatelessWidget {
  final ViewContextController viewContext;

  final void Function() onSearchPressed;

  BottomBarView({required this.viewContext, required this.onSearchPressed});

  Future<List<Widget>>? _getActionButtons() async {
    List<Widget> buttons = [];

    List<CVUAction> actions = [];
    if (viewContext.focusedItem != null) {
      actions = viewContext.itemPropertyResolver?.actions("filterButtons") ?? [];
    }

    if (actions.isNotEmpty) {
      buttons = actions.map((action) {
        return ActionButton(
            action: action, viewContext: viewContext.getCVUContext(item: viewContext.focusedItem));
      }).toList();
    } else {
      var filterButtons =
          await viewContext.viewDefinitionPropertyResolver.stringArray("filterButtons");
      buttons = filterButtons.compactMap((el) {
        var action = cvuAction(el);
        if (action != null) {
          return ActionButton(
              action: action(vars: <String, CVUValue>{}), viewContext: viewContext.getCVUContext());
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
              valueListenable: viewContext.searchStringNotifier,
              builder: (BuildContext context, String? filter, Widget? child) => Row(
                      children: space(4, [
                    Row(
                        children: space(4, [
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.fromLTRB(10, 10, 0, 10)),
                        onPressed: onSearchPressed,
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
                          onPressed: () => viewContext.searchString = null,
                          icon: Icon(
                            Icons.clear,
                            size: 12,
                          ),
                        )
                    ])),
                    Spacer(),
                    FutureBuilder(
                        future: _getActionButtons(),
                        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            if (snapshot.hasData) {
                              List<Widget> buttons = snapshot.data!;
                              return Row(children: buttons);
                            }
                          }
                          return Empty();
                        })
                  ]))),
        ),
      )
    ]);
  }
}
