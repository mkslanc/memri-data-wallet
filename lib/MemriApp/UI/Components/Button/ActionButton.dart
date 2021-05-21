import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../../BrowserView.dart';
import '../../ViewContextController.dart';

class ActionButton extends StatelessWidget {
  final SceneController sceneController = SceneController.sceneController;

  final CVUAction action;
  final CVUContext viewContext;

  ActionButton({required this.action, required this.viewContext});

  String get _icon {
    var defaultIcon = action.defaultVars["icon"];
    if (defaultIcon is! CVUValueConstant || defaultIcon.value is! CVUConstantString) {
      return "plus";
    }

    return (defaultIcon.value as CVUConstantString).value;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(MemriIcon.getByName(_icon)),
        ),
        onPressed: () => action.execute(sceneController, viewContext));
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
