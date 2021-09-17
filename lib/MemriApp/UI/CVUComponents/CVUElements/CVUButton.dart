import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../CVUUINodeResolver.dart';
import 'CVUTextPropertiesModifier.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Future<TextProperties> textProperties;

  CVUButton({required this.nodeResolver, required this.textProperties});

  @override
  _CVUButtonState createState() => _CVUButtonState();
}

class _CVUButtonState extends State<CVUButton> {
  final SceneController sceneController = SceneController.sceneController;

  TextProperties? resolvedTextProperties;
  bool isLink = false;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  onPress() async {
    var actions = widget.nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      if (action is CVUActionOpenPopup) {
        var settings = await action.setPopupSettings(sceneController, widget.nodeResolver.context);
        if (settings != null) {
          openPopup(settings);
        }
      } else {
        await action.execute(sceneController, widget.nodeResolver.context);
      }
    }
  }

  openPopup(Map<String, dynamic> settings) {
    List<CVUAction>? actions = settings['actions'];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text(settings['title']),
          content: Text(settings['text']),
          actions: actions?.compactMap(
            (action) {
              var title = action.vars["title"]?.value?.value;
              if (title != null) {
                return TextButton(
                  onPressed: () async {
                    await action.execute(sceneController, widget.nodeResolver.context);
                    Navigator.pop(context, action.vars["title"]!.value.value);
                  },
                  child: Text(action.vars["title"]!.value.value),
                );
              } else {
                return null;
              }
            },
          ).toList()),
    );
  }

  init() async {
    resolvedTextProperties = await widget.textProperties;
    isLink = (await widget.nodeResolver.propertyResolver.boolean("isLink", false))!;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return isLink
              ? InkWell(
                  onTap: onPress,
                  child: widget.nodeResolver.childrenInForEachWithWrap(),
                )
              : TextButton(
                  onPressed: onPress,
                  child: widget.nodeResolver.childrenInForEachWithWrap(),
                  style: TextButton.styleFrom(
                      textStyle: resolvedTextProperties?.textStyle ?? TextStyle(),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                );
        });
  }
}
