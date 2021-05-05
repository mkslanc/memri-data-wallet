import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  final SceneController sceneController = SceneController.sceneController;

  CVUButton({required this.nodeResolver});

  onPress() {
    var actions = nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      action.execute(sceneController, nodeResolver.context);
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
    return ElevatedButton(onPressed: onPress, child: nodeResolver.childrenInForEachWithWrap());
  }
}
