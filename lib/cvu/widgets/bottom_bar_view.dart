//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../controllers/view_context_controller.dart';
import '../models/cvu_value.dart';
import '../services/cvu_action.dart';
import '../../widgets/components/buttons/action_button.dart';

/// This view contains the contents of the 'Bottom bar' which is shown below renderer content.
class BottomBarView extends StatelessWidget {
  final ViewContextController viewContext;

  BottomBarView({required this.viewContext});

  List<Widget> get actionButtons {
    List<Widget> buttons = [];

    List<CVUAction> actions = [];
    if (viewContext.focusedItem != null) {
      actions = viewContext.itemPropertyResolver?.actions("filterButtons") ?? [];
    }

    if (actions.isNotEmpty) {
      buttons = actions.map((action) {
        return ActionButton(
            action: action,
            viewContext: viewContext.getCVUContext(item: viewContext.focusedItem));
      }).toList();
    } else {
      var filterButtons =
          viewContext.viewDefinitionPropertyResolver.stringArray("filterButtons");
      buttons = filterButtons.compactMap((el) {
        var action = cvuAction(el);
        if (action != null) {
          return ActionButton(
              action: action(vars: <String, CVUValue>{}),
              viewContext: viewContext.getCVUContext());
        }
        return null;
      });
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 50,
      padding: EdgeInsets.zero,
      child: Row(
          children: [
        Spacer(),
        Row(children: actionButtons)
      ])
    );
  }
}