import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
// ignore: must_be_immutable
class CVUActionButton extends StatelessWidget {
  //TODO: stateful
  final CVUUINodeResolver nodeResolver;
  final SceneController sceneController = SceneController.sceneController;
  var isShowing = false;

  CVUActionButton({required this.nodeResolver});

  CVUAction? get action {
    var _action = nodeResolver.propertyResolver.action("onPress");
    if (_action == null) {
      return null;
    }
    return action;
  }

  onPress() {
    var actions = nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return null;
    }
    for (var action in actions) {
      action.execute(sceneController, nodeResolver.context);
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
    var currentItem = nodeResolver.context.currentItem;
    if (args is! CVUValueSubdefinition || currentItem == null) {
      return null;
    }

    var properties = args.value.properties;
    properties["subject"] = CVUValueItem(currentItem.uid); //TODO: rowid

    return CVUViewArguments(args: properties, argumentItem: nodeResolver.context.currentItem);
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
              future: nodeResolver.context.currentItem?.propertyValue("starred"),
              builder: (BuildContext context, AsyncSnapshot<PropertyDatabaseValue?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    var starred = snapshot.data?.asBool() ?? false;
                    return Icon(MemriIcon.getByName(starred ? "star.fill" : "star"));
                  }
                }
                return Text("");
              }),
          onPressed: () => validAction.execute(sceneController, nodeResolver.context));
    }
    return Text("TODO: CVU_ActionButton");
  }

/*
var body: some View {
        if let validAction = self.action as? CVUAction_OpenViewByName {
            Button(action: {
                self.isShowing = true
            }) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            .sheet(isPresented: $isShowing) {
                if let viewContext = validAction.getViewContext(context: CVUContext(currentItem:nodeResolver.context.currentItem, viewName: validAction.viewName, rendererName: validAction.renderer, viewArguments: viewArguments)) {
                    BrowserView(context: viewContext)
                } else {
                    Text("TODO: ActionPopupButton")
                }
            }
        } else if let starAction = self.action as? CVUAction_Star {
            Button(action: {
                withAnimation {
                    starAction.execute(sceneController: sceneController, context: nodeResolver.context)
                }
            }) {
                Image(systemName: (nodeResolver.context.currentItem?.propertyValue("starred")?.asBool() ?? false) == true ? "star.fill" : "star")
            }
        }  else {
            Text("TODO: CVU_ActionButton")
        }
    }
 */
}
