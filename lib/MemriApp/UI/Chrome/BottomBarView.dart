//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import '../ViewContextController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;

/// This view contains the contents of the 'Bottom bar' which is shown below renderer content.
class BottomBarView extends StatefulWidget {
  final ViewContextController viewContext;
  final memri.PageController pageController;

  BottomBarView({required this.viewContext, required this.pageController});

  @override
  _BottomBarViewState createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  late Future<List<Widget>>? _actionButtons;
  List<Widget> actionButtons = [];

  @override
  initState() {
    super.initState();
    _actionButtons = _getActionButtons();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _actionButtons = _getActionButtons();
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
            viewContext: widget.viewContext.getCVUContext(item: widget.viewContext.focusedItem),
            pageController: widget.pageController);
      }).toList();
    } else {
      var filterButtons =
          await widget.viewContext.viewDefinitionPropertyResolver.stringArray("filterButtons");
      buttons = filterButtons.compactMap((el) {
        var action = cvuAction(el);
        if (action != null) {
          return ActionButton(
              action: action(vars: <String, CVUValue>{}),
              viewContext: widget.viewContext.getCVUContext(),
              pageController: widget.pageController);
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
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ValueListenableBuilder(
            valueListenable: widget.viewContext.searchStringNotifier,
            builder: (BuildContext context, String? filter, Widget? child) {
              return Row(
                  children: space(4, [
                Spacer(),
                if (_actionButtons != null)
                  FutureBuilder(
                      future: _actionButtons,
                      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          actionButtons = snapshot.data!;
                        }
                        return Row(children: actionButtons);
                      })
              ]));
            }),
      )
    ]);
  }
}
