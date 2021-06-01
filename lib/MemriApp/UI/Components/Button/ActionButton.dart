import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../../BrowserView.dart';
import '../../ViewContextController.dart';

class ActionButton extends StatefulWidget {
  final CVUAction action;
  final CVUContext viewContext;

  ActionButton({required this.action, required this.viewContext});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  final SceneController sceneController = SceneController.sceneController;

  String _icon = "";

  get icon => _icon;

  set icon(newIcon) => setState(() => _icon = newIcon);

  @override
  initState() {
    super.initState();
    _icon =
        widget.action.getString("icon", widget.viewContext, sceneController.topMostContext) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.all(10.0)),
        child: Icon(MemriIcon.getByName(icon)),
        onPressed: () {
          widget.action.execute(sceneController, widget.viewContext);
          icon =
              widget.action.getString("icon", widget.viewContext, sceneController.topMostContext);
        });
  }
}

class ActionPopupButton extends StatefulWidget {
  final CVUActionOpenViewByName action;

  ActionPopupButton(this.action);

  @override
  _ActionPopupButtonState createState() => _ActionPopupButtonState();
}

class _ActionPopupButtonState extends State<ActionPopupButton> {
  @override
  Widget build(BuildContext context) {
    var action = widget.action;
    return TextButton(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(MemriIcon.getByName("plus")),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) => FutureBuilder<ViewContextController?>(
          future: action
              .getViewContext(CVUContext(viewName: action.viewName, rendererName: action.renderer)),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Empty();
              default:
                if (snapshot.hasData) {
                  return BrowserView(
                    viewContext: snapshot.data!,
                  );
                } else {
                  return Text("TODO: ActionPopupButton");
                }
            }
          },
        ),
      ),
    );
  }
}
