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
class BottomBarView extends StatefulWidget {
  final ViewContextController viewContext;

  BottomBarView({required this.viewContext});

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  List<Widget> actionButtons = [];

  @override
  initState() {
    super.initState();
    actionButtons = _getActionButtons();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    actionButtons = _getActionButtons();
  }

  List<Widget> _getActionButtons() {
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
          widget.viewContext.viewDefinitionPropertyResolver.stringArray("filterButtons");
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