import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../CVUUINodeResolver.dart';
import 'CVUTextPropertiesModifier.dart';

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

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
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

  init() async {
    resolvedTextProperties = await widget.textProperties;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return TextButton(
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
