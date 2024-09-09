import 'package:flutter/material.dart';

import '../../../../utilities/extensions/icon_data.dart';
import '../../../constants/cvu_color.dart';
import '../../../models/cvu_value.dart';
import '../../../models/cvu_value_constant.dart';
import '../../../models/cvu_view_arguments.dart';
import '../../../services/cvu_action.dart';
import '../cvu_ui_node_resolver.dart';

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
  bool? starred;

  @override
  initState() {
    super.initState();
    init();
  }

  init() {
    if (action is CVUActionStar) {
      starred = widget.nodeResolver.context.currentItem?.get<bool>("starred");
    }
  }

  CVUAction? get action {
    return widget.nodeResolver.propertyResolver.action("onPress");
  }

  String get title {
    var _action = action;
    if (_action is! CVUActionOpenView) {//TODO should be CVUActionOpenViewByName
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
    if (_action is! CVUActionOpenView) {//TODO should be CVUActionOpenViewByName
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
    properties["subject"] = CVUValueItem(currentItem.id);

    return CVUViewArguments(
        args: properties, argumentItem: widget.nodeResolver.context.currentItem);
  }

  @override
  Widget build(BuildContext context) {
    var validAction = action;
    if (validAction is CVUActionOpenView) {//TODO should be CVUActionOpenViewByName
      return TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            builder: (BuildContext context) => Text("Cvu action open view by name")/*FutureBuilder<ViewContextController?>(
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
            ),*/
          ),
          child: Text(
            title,
            style: TextStyle(color: Colors.black, fontSize: 15),
          ));
    } else if (validAction is CVUActionStar) {
      return IconButton(
          icon: Icon(
              MemriIcon.getByName((starred ?? false) ? "star.fill" : "star"),
              color: CVUColor.system("white"),
          ),
          onPressed: () async {
            await validAction
                .execute(widget.nodeResolver.context, context)
                .whenComplete(() => setState(init));
          });
    }
    return Text("TODO: CVU_ActionButton");
  }
}
