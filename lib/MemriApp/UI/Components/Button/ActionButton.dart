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

  String? _icon;

  String get icon => _icon ?? "";

  @override
  initState() {
    super.initState();
    initIcon();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    initIcon();
  }

  initIcon() {
    _icon = widget.action.getString("icon", widget.viewContext);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Icon(MemriIcon.getByName(icon)),
        onPressed: () async {
          await widget.action.execute(sceneController, widget.viewContext);
          setState(() => initIcon());
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
