import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';

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
  bool isShowing = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(MemriIcon.getByName("plus")),
        ),
        onPressed: () => setState(() => isShowing = true));
  }
}

/*
    .sheet(isPresented: $isShowing) {
if let viewContext = action.getViewContext(context: CVUContext(viewName: action.viewName, rendererName: action.renderer)) {
BrowserView(context: viewContext)
} else {
Text("TODO: ActionPopupButton")
}
}
}*/
