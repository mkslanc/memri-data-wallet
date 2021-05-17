import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
// ignore: must_be_immutable
class CVUActionButton extends StatefulWidget {
  //TODO: stateful
  final CVUUINodeResolver nodeResolver;

  CVUActionButton({required this.nodeResolver});

  @override
  _CVUActionButtonState createState() => _CVUActionButtonState();
}

class _CVUActionButtonState extends State<CVUActionButton> {
  final SceneController sceneController = SceneController.sceneController;

  var isShowing = false;

  CVUAction? get action {
    var _action = widget.nodeResolver.propertyResolver.action("onPress");
    if (_action == null) {
      return null;
    }
    return _action;
  }

  onPress() {
    var actions = widget.nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return null;
    }
    for (var action in actions) {
      action.execute(sceneController, widget.nodeResolver.context);
    }
  }

  String get title {
    if (action is! CVUActionOpenViewByName) {
      return "";
    }
    var titleVal = (action as CVUActionOpenViewByName).vars["title"];
    if (titleVal == null) {
      return "";
    }
    var _title = titleVal;
    if (titleVal is! CVUValueConstant ||
        (titleVal is CVUValueConstant && titleVal.value is! CVUConstantString)) {
      return "";
    }
    return (_title as CVUConstantString).value;
  }

  CVUViewArguments? get viewArguments {
    var _action = action;
    if (_action is! CVUActionOpenViewByName) {
      return null;
    }
    var argsValue = _action.vars["viewArguments"];
    if (argsValue == null) {
      return null;
    }
    var args = argsValue;
    var currentItem = widget.nodeResolver.context.currentItem;
    if (args is! CVUValueSubdefinition || currentItem == null) {
      return null;
    }

    var properties = args.value.properties;
    properties["subject"] = CVUValueItem(currentItem.uid); //TODO: rowid

    return CVUViewArguments(
        args: properties, argumentItem: widget.nodeResolver.context.currentItem);
  }

  @override
  Widget build(BuildContext context) {
    var validAction = action;
    if (validAction is CVUActionOpenViewByName) {
      return TextButton(
          onPressed: () => isShowing = true,
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 15),
          ));
    } else if (validAction is CVUActionStar) {
      return IconButton(
          icon: FutureBuilder(
              future: widget.nodeResolver.context.currentItem?.propertyValue("starred"),
              builder: (BuildContext context, AsyncSnapshot<PropertyDatabaseValue?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var starred = snapshot.data?.asBool() ?? false;
                  return Icon(
                    MemriIcon.getByName(starred ? "star.fill" : "star"),
                    color: CVUColor.system("systemBlue"),
                  );
                }
                return Text("");
              }),
          onPressed: () async {
            await validAction
                .execute(sceneController, widget.nodeResolver.context)
                .whenComplete(() => setState(() => null));
          });
    }
    return Text("TODO: CVU_ActionButton");
  }
}
