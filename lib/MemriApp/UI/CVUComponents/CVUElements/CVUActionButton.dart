import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';
import 'package:memri/MemriApp/UI/BrowserView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
// ignore: must_be_immutable
class CVUActionButton extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUActionButton({required this.nodeResolver});

  @override
  _CVUActionButtonState createState() => _CVUActionButtonState();
}

class _CVUActionButtonState extends State<CVUActionButton> {
  final SceneController sceneController = SceneController.sceneController;

  late Future<PropertyDatabaseValue?>? _starred;
  PropertyDatabaseValue? starred;

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    if (action is CVUActionStar) {
      _starred = widget.nodeResolver.context.currentItem?.propertyValue("starred");
    }
  }

  CVUAction? get action {
    return widget.nodeResolver.propertyResolver.action("onPress");
  }

  onPress() {
    var actions = widget.nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      action.execute(sceneController, widget.nodeResolver.context);
    }
  }

  String get title {
    var _action = action;
    if (_action is! CVUActionOpenViewByName) {
      return "";
    }
    var titleVal = _action.vars["title"];
    if (titleVal is! CVUValueConstant || titleVal.value is! CVUConstantString) {
      return "";
    }
    return (titleVal.value as CVUConstantString).value;
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
    properties["subject"] = CVUValueItem(currentItem.rowId!);

    return CVUViewArguments(
        args: properties, argumentItem: widget.nodeResolver.context.currentItem);
  }

  @override
  Widget build(BuildContext context) {
    var validAction = action;
    if (validAction is CVUActionOpenViewByName) {
      return TextButton(
          onPressed: () => showModalBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                isScrollControlled: true,
                builder: (BuildContext context) => FutureBuilder<ViewContextController?>(
                  future: validAction.getViewContext(CVUContext(
                      currentItem: widget.nodeResolver.context.currentItem,
                      viewName: validAction.viewName,
                      rendererName: validAction.renderer,
                      viewArguments: viewArguments)),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Empty();
                      default:
                        if (snapshot.hasData) {
                          return BrowserView(
                            viewContext: snapshot.data!,
                            sceneController: sceneController,
                          );
                        } else {
                          return Text("TODO: ActionPopupButton");
                        }
                    }
                  },
                ),
              ),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 15),
          ));
    } else if (validAction is CVUActionStar) {
      return IconButton(
          icon: FutureBuilder(
              initialData: starred,
              future: _starred,
              builder: (BuildContext context, AsyncSnapshot<PropertyDatabaseValue?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  starred = snapshot.data;
                }
                return Icon(
                  MemriIcon.getByName((starred?.asBool() ?? false) ? "star.fill" : "star"),
                  color: CVUColor.system("systemBlue"),
                );
              }),
          onPressed: () async {
            await validAction
                .execute(sceneController, widget.nodeResolver.context)
                .whenComplete(() => setState(init));
          });
    }
    return Text("TODO: CVU_ActionButton");
  }
}
